//
//  ThreeDollarGestureRecogniser.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "ThreeDollarGestureRecogniser.h"
#define BBOX_SIZE 100.0f
#define DETECTION_THRESHOLD 0.85f

@implementation ThreeDollarGestureRecogniser

- (id)initWithResampleAmount:(int)resampeAmount {
    if(self = [super init]) {
        self.resampleAmount = resampeAmount;
    }
    return self;
}

- (Matrix*)prepareMatrixForLibrary:(Matrix *)theTrace {
    
    NSLog(@"RAW MATRIX");
    
    self.gesture_path = [self createPathFromMatrix:theTrace];
    
    NSLog(@"gesture path Matrix size %d",self.gesture_path.rows);
    
    self.resampled_gesture = [self resamplePoints:self.gesture_path withAmount:self.resampleAmount];
    
    NSLog(@"resampled gesture Matrix size %d",self.resampled_gesture.rows);
    
    self.rotated_gesture = [self rotate_to_zero:self.resampled_gesture];
    
    NSLog(@"rotated gesture Matrix size %d",self.rotated_gesture.rows);
    
    Matrix *normalisedGesture = [self scale_to_cube:self.rotated_gesture];
    
    NSLog(@"normalised gesture Matrix size %d",normalisedGesture.rows);
    
 //   [self reset];
    
    return normalisedGesture;
    
}

- (NSString*)recogniseGesture:(Gesture *)candidate fromGestures:(NSDictionary *)library_gestures {
    NSString *recGest = nil;
    
    float pi_half = M_PI/2;
    NSLog(@"before prepareMatrixForLibrary library_gestures: %lu",(unsigned long)[library_gestures count]);
    
    Matrix *normalised = [self prepareMatrixForLibrary:candidate.gestureTrace];
    
    candidate.gestureTrace = normalised;
    
    NSLog(@"after prepareMatrixForLibrary library_gestures: %lu",(unsigned long)[library_gestures count]);
    
    NSMutableArray *scoreTable = [[NSMutableArray alloc]init];
    
    NSEnumerator *enumerator = [library_gestures objectEnumerator];
    NSArray *gestureList;
    float cutoff = 2.0f * (float) M_PI*(15.0/360.0f);
    
    
    while((gestureList = [enumerator nextObject])) {
        NSEnumerator *enumerator = [gestureList objectEnumerator];
        Gesture *gesture;
        int idnr = 0;
        while((gesture = [enumerator nextObject])) {
            float distance = [self distance_at_best_angle_rangeX:pi_half Y:pi_half Z:pi_half increment:0 candidateTrace:candidate.gestureTrace libraryTrace:gesture.gestureTrace andCutOffAngle:cutoff];
            
            float score = [self score:distance];
            Score *aScore = [[Score alloc]init];
            aScore.distance = distance;
            aScore.gid = gesture.gestureID;
            aScore.score = score;
            aScore.idnr = idnr++;
            [scoreTable addObject:aScore];
        }
    }
    NSRange theRange;
    theRange.location = 0;
    theRange.length = 3;
    NSArray *scoreTableSorted = [scoreTable sortedArrayUsingSelector:@selector(compare:)];
    
    Score *s;
    
    NSString *lowestScoreShape;
    int shapeScore = INFINITY;
    float compare;
    for(int i = [scoreTableSorted count]-1; i>=0; i--) {
        s = [scoreTableSorted objectAtIndex:i];
        NSLog(@"distance %f score %f for %@",s.distance,s.score,s.gid);
        compare = fabs(s.score);
        NSLog(@"%0.2f",compare);
        if(compare < shapeScore) {
            shapeScore = compare;
            lowestScoreShape = s.gid;
        }
    }
    return lowestScoreShape;
    
    
    
    
   // recGest = [self recognise_from_scoretable:scoreTableSorted];
   // return recGest;
    
    
}

- (float)distance_at_best_angle_rangeX:(float)angularRangeX Y:(float)angularRangeY Z:(float)angularRangeZ increment:(float)increment candidateTrace:(Matrix *)candidate_points libraryTrace:(Matrix *)library_points andCutOffAngle:(float)cutoff_angle {
    
    float mind = MAXFLOAT;
    float maxd = FLT_MIN;
    float minDistAngle = 0.0f;
    float maxDistAngle = 0.0f;
    
    int length1 = candidate_points.rows;
    int length2 = library_points.rows;
    
    int sampleLength = 0;
    if(length1 < length2)
        sampleLength = length1;
    
    else
        sampleLength = length2;
    
    length1 = sampleLength;
    length2 = sampleLength;
    
    //golden ratio search
    float theta_a = -angularRangeX;
    float theta_b = -theta_a;
    float theta_delta = cutoff_angle;
    
    //best angles for upper and lower bound
    float bestAngleLower[3] = {0.0f, 0.0f, 0.0f};
    float bestAngleUpper[3] = {0.0f, 0.0f, 0.0f};
    
    //minimum distances, init lower and upper values to max float
    float minDistL = MAXFLOAT;
    float minDistU = MAXFLOAT;
    
    float phi = 0.5f *(-1.0f + (float)sqrt(5));
    
    //initial lower angle search
    float li = phi * theta_a + (1-phi)*theta_b;
    
    Matrix *angle_search_result_lower = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:li bestAngle:bestAngleLower];
    
    minDistL = angle_search_result_lower.data[0][0];
    bestAngleLower[0] = angle_search_result_lower.data[1][0];
    bestAngleLower[1] = angle_search_result_lower.data[1][1];
    bestAngleLower[2] = angle_search_result_lower.data[1][2];
    
    //initial upper search angle
    float ui = (1-phi)*theta_a + phi*theta_b;
    
    //result of this ftn is [[mindist],[a1,a2,a3]]
    Matrix *angle_search_result_upper = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:ui bestAngle:bestAngleUpper];
    
    //assign return values of the previous ftn
    bestAngleUpper[0] = angle_search_result_upper.data[1][0];
    bestAngleUpper[1] = angle_search_result_upper.data[1][1];
    bestAngleUpper[2] = angle_search_result_upper.data[1][2];
    
    while(fabs(theta_b - theta_a) > theta_delta) {
        if(minDistL <= minDistU) {
            theta_b = ui;
            ui = li;
            minDistU = minDistL;
            li = phi*theta_a + (1-phi)*theta_b;
            
            //result of the following ftn: [[mindist],[a1,a2,a3]]
            Matrix *angleSearchResultLower = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:li bestAngle:bestAngleLower];
            
            //decode result
            minDistL = angle_search_result_lower.data[0][0];
            bestAngleLower[0] = angleSearchResultLower.data[1][0];
            bestAngleLower[1] = angleSearchResultLower.data[1][1];
            bestAngleLower[2] = angleSearchResultLower.data[1][2];
        }
        else {
            theta_a = li;
            li = ui;
            minDistL = minDistU;
            ui = (1-phi)*theta_a + phi*theta_b;
            Matrix *angleSearchResultUpper = [self search_around_angle_candidateTrace:candidate_points libraryTrace:library_points Angle:ui bestAngle:bestAngleUpper];
            
            //decode
            minDistU = angleSearchResultUpper.data[0][0];
            bestAngleUpper[0] = angleSearchResultUpper.data[1][0];
            bestAngleUpper[1] = angleSearchResultUpper.data[1][1];
            bestAngleUpper[2] = angleSearchResultUpper.data[1][2];
        }
    }
    
    if(minDistU >= minDistL)
        return minDistL;
    else
        return minDistU;
    
}

- (Matrix*)search_around_angle_candidateTrace:(Matrix *)candidate libraryTrace:(Matrix *)template Angle:(float)angle bestAngle:(float *)best_angles {
    
    float minDist = MAXFLOAT;
    float minAngles[3] = {0.0f,0.0f,0.0f};
    
    for(int i = 0; i < 8; i++) {
        float add[3] = {best_angles[0],best_angles[1],best_angles[2]};
        
        if(i % 2 == 1)
            add[2] += angle;
        if(i % 4 > 1)
            add[1] += angle;
        if(i % 8 > 3)
            add[2] += angle;
        
        float dist = [self distance_at_angles_candidateTrace:candidate libraryTrace:template andAngles:add];
        
        if(dist < minDist) {
            minDist = dist;
            minAngles[0] = add[0];
            minAngles[1] = add[1];
            minAngles[2] = add[2];
        }
    }
    Matrix *out = [[Matrix alloc]initMatrixWithRows:3 andCols:3];
    out.data[0][0] = minDist;
    out.data[1][0] = minAngles[0];
    out.data[1][1] = minAngles[1];
    out.data[1][2] = minAngles[2];
    
    return out;
    
    
}


- (NSString*)recognise_from_scoretable:(NSArray *)scoreTable {
    
    NSLog(@"RECOGNISING FROM SCORETABLE");
    
    //detect at least 2 candidates of same gesture id with score >.55
    int count_h1 = 0;
    int count_h2 = 0;
    
    NSRange theRange;
    theRange.location = 0;
    theRange.length = 3;
    
    NSArray *topThreeArray = [scoreTable subarrayWithRange:theRange];
    NSEnumerator *enumerator = [topThreeArray objectEnumerator];
    Score *s;
    while(s = [enumerator nextObject]) {
        
        //high prob match
        if(s.score > DETECTION_THRESHOLD*1.1) {
            NSRange theRange2;
            theRange2.location = 1;
            theRange2.length = 2;
            
            NSArray *twoAndThreeArray = [topThreeArray subarrayWithRange:theRange2];
            NSEnumerator *enumerator2 = [twoAndThreeArray objectEnumerator];
            Score *other;
            
            while(other = [enumerator2 nextObject]) {
                NSLog(@"recognise from scoretable other: \t Item: %@ \t score: %f",other.gid,other.score);
                
                if([s.gid isEqualToString:other.gid] && other.score >= DETECTION_THRESHOLD*0.95) {
                    NSLog(@"recognise from scoretable h1++");
                    count_h1++;
                }
                if([s.gid isEqualToString:other.gid]) {
                    NSLog(@"recognise from scoretable h2++");
                    count_h2++;
                }
            }
        }
        
        if(count_h1 > 0) {
            NSLog(@"recognise from scoretable decided by h1");
            return s.gid;
            
        }
        else if(count_h2 > 1) {
            NSLog(@"recognise from scoretable decided by h2");
            return s.gid;
        }
        else {
            count_h1 = 0;
            count_h2 = 0;
        }
        
    }
    return nil;
    
}


- (Matrix *)scale_to_cube:(Matrix *)gList {
    
    Matrix *newPoints = [[Matrix alloc]initMatrixWithRows:gList.rows andCols:3];
    Matrix *bbox = [self bounding_box3:gList];
    NSLog(@"bbox size %d",bbox.rows);
    [bbox printMatrix];
    
    float bwx = BBOX_SIZE / fabs(bbox.data[0][0] - bbox.data[0][1]);
    float bwy = BBOX_SIZE / fabs(bbox.data[1][0] - bbox.data[1][1]);
    float bwz = BBOX_SIZE / fabs(bbox.data[2][0] - bbox.data[2][1]);
    NSLog(@"bwx %f bwy %f bwz %f",bwx,bwy,bwz);
    
    for(int index = 0; index < gList.rows; index++) {
        float *p = gList.data[index];
        newPoints.data[index][0] = p[0] * bwx;
        newPoints.data[index][1] = p[1] * bwy;
        newPoints.data[index][2] = p[2] * bwz;
    }
    return newPoints;
    
}

- (Matrix*)resamplePoints:(Matrix *)gList withAmount:(int)numSamples {
    Matrix *newPoints = [[Matrix alloc]initMatrixWithRows:numSamples andCols:3];
    
    newPoints.data[0][0] = gList.data[0][0];
    newPoints.data[0][1] = gList.data[0][1];
    newPoints.data[0][2] = gList.data[0][2];
    newPoints.rows = 1;
    
    float pathLength = [self calculate_path_length:gList];
    float increment = pathLength / ((float) numSamples - 1);
    
    float qx, qy, qz; qx = qy = qz = 0.0f;
    int count = 1;
    Matrix *path = [[Matrix alloc]initMatrixWithRows:2 andCols:3];
    path.rows = 2;
    
    float D = 0.0f;
    for(int index = 1; index < gList.rows; index++) {
        path.data[0][0] = gList.data[index-1][0];
        path.data[0][1] = gList.data[index-1][1];
        path.data[0][2] = gList.data[index-1][2];
        
        path.data[1][0] = gList.data[index][0];
        path.data[1][1] = gList.data[index][1];
        path.data[1][2] = gList.data[index][2];
        path.rows = 2;
        
        float d = [self calculate_path_length:path];
        
        if(D + d >= increment) {
            float *v1 = path.data[path.rows-1];
            float *v2 = path.data[path.rows-2];
            
            float missingIncr = (increment - D)/d;
            
            qx = v2[0] + (missingIncr * (v1[0] - v2[0]));
            qy = v2[1] + (missingIncr * (v1[1] - v2[1]));
            qz = v2[2] + (missingIncr * (v1[2] - v2[2]));
            
            newPoints.data[newPoints.rows][0] = qx;
            newPoints.data[newPoints.rows][1] = qy;
            newPoints.data[newPoints.rows][2] = qz;

            newPoints.rows++;
            //insert (points, i, q)
            gList.data[index-1][0] = qx;
            gList.data[index-1][1] = qy;
            gList.data[index-1][2] = qz;
            
            D = 0;
            count++;
        }
        else {
            D = D + d;
        }
    }
    return newPoints;
}

- (float)calculate_path_length:(Matrix *)gList {
    float distance = 0;
    
    for(int index = 1; index < gList.rows; index++) {
        float *v = gList.data[index];
        float *u = gList.data[index-1];
        float delta = (float) sqrt((u[0]-v[0])*(u[0]-v[0]) + (u[1]-v[1])*(u[1]-v[1]) + (u[2]-v[2])*(u[2]-v[2]));

        distance = distance + delta;
    }
    return distance;
}

//returns vector orthogonal to cross-product of b and c
- (float*)orthogonal:(float *)b and:(float *)c {
    
    float ax,ay,az;
    ax = b[1]*c[2] - c[1]*b[2];
    ay = b[2]*c[0] - c[2]*b[0];
    az = b[0]*c[1] - c[0]*b[1];
    
    Matrix *out = [[Matrix alloc]initMatrixWithRows:1 andCols:3];
    out.data[0][0] = ax;
    out.data[0][1] = ay;
    out.data[0][2] = az;
    
    return out.data[0];
    
}

//returns a unit vector with direction given by v
- (float*)unit_vector:(float *)v {
    
    Matrix *zero = [Matrix zeroVec3];
    float norm = 1.0f / sqrt((v[0]-zero.data[0][0])*(v[0]-zero.data[0][0])+(v[1]-zero.data[0][1])*(v[1]-zero.data[0][1])+(v[2]-zero.data[0][2])*(v[2]-zero.data[0][2]));
    
    Matrix *out = [[Matrix alloc]initMatrixWithRows:1 andCols:3];
    out.data[0][0] = norm * v[0];
    out.data[0][1] = norm * v[1];
    out.data[0][2] = norm * v[2];
    
    return out.data[0];
}

- (Matrix*)rotate_to_zero:(Matrix *)gList {
    Matrix *rotatedPoints = [[Matrix alloc]initMatrixWithRows:gList.rows andCols:3];
    Matrix *centroidMatrix = [self centroidFromTrace:gList];
    
    float *centroid = centroidMatrix.data[0];
    float theta = [self angle3:centroid andV:gList.data[0]];
    
    float *axis = [self unit_vector:[self orthogonal:gList.data[0] and:centroid]];
    
    Matrix *rMatrix = [self rotationMatrixWithVector3:axis andTheta:theta];
    
    for(int i = 0 ; i < gList.rows; i++) {
        float *p = gList.data[i];
        
        Matrix *temp = [self rotate3:p withMatrix:rMatrix];
        rotatedPoints.data[i][0] = temp.data[0][0];
        rotatedPoints.data[i][1] = temp.data[0][1];
        rotatedPoints.data[i][2] = temp.data[0][2];
    }
    
    return rotatedPoints;
    
}

//multiply 3x3 rotation matrix with point
- (Matrix*)rotate3:(float *)p withMatrix:(Matrix *)matrix {
    
    Matrix *out = [[Matrix alloc]initMatrixWithRows:1 andCols:3];
    for(int i = 0 ; i < 3; i++) {
        float *r = matrix.data[i];
        out.data[0][i] = p[0]*r[0] + p[1]*r[1] + p[2]*r[2];
    }
    return out;
}

//returns 3 angle rotation matrix
- (Matrix*)rotationMatrixWithAngle3Alpha:(float)a Beta:(float)b Gamma:(float) g {
    
    Matrix *rotMatrix = [[Matrix alloc]initMatrixWithRows:3 andCols:3];
    rotMatrix.data[0][0] = (float) (cos(a)*cos(b));
    rotMatrix.data[0][1] = (float)(cos(a)*sin(b)*sin(g)-sin(a)*cos(g)) ;
    rotMatrix.data[0][2] =  (float)(cos(a)*sin(b)*cos(g)+sin(a)*sin(g));
    
    rotMatrix.data[1][0] = (float)(sin(a)*cos(b));
    rotMatrix.data[1][1] = (float)(sin(a)*sin(b)*sin(g)+cos(a)*cos(g));
    rotMatrix.data[1][2] =   (float)(sin(a)*sin(b)*cos(g) - cos(a)*sin(g));
    
    rotMatrix.data[2][0] = (float)(-sin(b));
    rotMatrix.data[2][1] = (float)(cos(b)*sin(g));
    rotMatrix.data[2][2] = (float)(cos(b)*cos(g));
    
    return rotMatrix;
}

//generate a rotation matrix along axis with the value theta
- (Matrix*)rotationMatrixWithVector3:(float *)axis andTheta:(float)theta {
    
    Matrix *matrix = [[Matrix alloc]initMatrixWithRows:3 andCols:3];
    
    float x = axis[0];
    float y = axis[1];
    float z = axis[2];
    float angle = (float)theta;
    
    matrix.data[0][0] = (float) (1 + (1-cos(angle))*(x*x-1));
    matrix.data[0][1] = (float) ((float) -z*sin(angle)+(1-cos(angle))*x*y);
    matrix.data[0][2] = (float) (y*sin(angle) + (1-cos(angle))*x*z);
    
    matrix.data[1][0] = (float)(z*sin(angle) + (1-cos(angle))*x*y);
    matrix.data[1][1] = (float)(1 + (1-cos(angle))*(y*y-1));
    matrix.data[1][2] = (float) (-x*sin(angle)+(1-cos(angle))*y*z);
    
    matrix.data[2][0] = (float) (-y*sin(angle) + (1-cos(angle))*x*z);
	matrix.data[2][1] = (float) (x*sin(angle)+(1-cos(angle))*y*z);
    matrix.data[2][2] = (float) (float) (1 + (1-cos(angle))*(z*z-1));
    
    return matrix;
    
}

- (float)angle3:(float *)u andV:(float *)v {
    float normProduct = [self norm_dot_product:u andV:v];
    if(normProduct <= 1.0) {
        float theta = (float) acos(normProduct);
        return theta;
    }
    else {
        return 0.0;
    }
}

- (float)norm_dot_product:(float *)u andV:(float *)v {
    float a = [self dot_product3:u andV:v];
    float b = [self norm:u] * [self norm:v];
    return a/b;
}

- (float)norm:(float *)u {
    return sqrtf((u[0]*u[0]) + (u[1]*u[1]) + (u[2]*u[2]));
}

- (float)dot_product3:(float *)u andV:(float *)v {
    return ((u[0]*v[0]) + (u[1]*v[1]) + (u[2]*v[2]));
}

- (Matrix*)centroidFromTrace:(Matrix *)gList {
    float mx = 0.0, my = 0.0, mz = 0.0;
    
    for(int i = 0; i < gList.rows; i++) {
        float *p = gList.data[i];
        mx += p[0];
        my += p[1];
        mz += p[2];
    }
    
    int l = gList.rows;
    
    Matrix *ret = [[Matrix alloc]initMatrixWithRows:1 andCols:3];
    ret.data[0][0] = mx/l;
    ret.data[0][1] = my/l;
    ret.data[0][2] = mz/l;
    
    return ret;
    
}

- (Matrix*)createPathFromMatrix:(Matrix *)gList {
    Matrix *path = [[Matrix alloc]initMatrixWithRows:gList.rows andCols:3];
    
    path.data[0][0] = gList.data[0][0];
    path.data[0][1] = gList.data[0][1];
    path.data[0][2] = gList.data[0][2];
    
    for(int i = 1 ; i < gList.rows; i++) {
        path.data[i][0] += gList.data[i][0];
        path.data[i][1] += gList.data[i][1];
        path.data[i][2] += gList.data[i][2];
    }
    
    return path;
}


- (float)score:(float)distance {
    float b = BBOX_SIZE;
    return 1.0f - (distance / sqrtf((b*b) + (b*b) + (b*b)));
}


//returns bounding box in 3d space of set of points
- (Matrix*)bounding_box3:(Matrix *)points {

    Matrix *outMatrix = [[Matrix alloc]initMatrixWithRows:3 andCols:3];
    float *p;
    if(points.rows > 0) {
        p = points.data[points.rows - 1];
    }
    else {
        return outMatrix;
    }
    
    float mmx[2] = {p[0],p[0]};
    float mmy[2] = {p[1],p[1]};
    float mmz[2] = {p[2],p[2]};
    
    for(int i = 1; i < points.rows; i++) {
        float *p = points.data[i];
        
        if(p[0] <= mmx[0])
            mmx[0] = p[0];
        else if (p[0] > mmx[1])
            mmx[1] = p[0];
        if(p[1] <= mmy[0])
            mmy[0] = p[1];
        else if(p[1] > mmy[1])
            mmy[1] = p[1];
        if(p[2] <= mmz[0])
            mmz[0] = p[2];
        else if(p[2] > mmz[1])
            mmz[1] = p[2];
    }
    
    outMatrix.data[0][0] = mmx[0];
    outMatrix.data[0][1] = mmx[1];
    outMatrix.data[1][0] = mmy[0];
    outMatrix.data[1][1] = mmy[1];
    outMatrix.data[2][0] = mmz[0];
    outMatrix.data[2][1] = mmz[1];
    
    return outMatrix;
}

- (float)distance_at_angles_candidateTrace:(Matrix *)candidate libraryTrace:(Matrix *)template andAngles:(float *)angles {
    
    float dist = MAXFLOAT;
    
    float alpha = angles[0];
    float beta = angles[1];
    float gamma = angles[2];
    
    Matrix *matrix = [self rotationMatrixWithAngle3Alpha:alpha Beta:beta Gamma:gamma];
    
    //rotate path according to angles and calculate the distance
    Matrix *newCandPoints = [[Matrix alloc]initMatrixWithRows:candidate.rows andCols:3];
    
    for(int i = 0; i < candidate.rows; i++) {
        
        Matrix *np = [self rotate3:candidate.data[i] withMatrix:matrix];
        
        newCandPoints.data[i][0] = np.data[0][0];
        newCandPoints.data[i][1] = np.data[0][1];
        newCandPoints.data[i][2] = np.data[0][2];
    }
    
    //save length as get manipulated
    int candidateRows = candidate.rows;
    int templateRows = template.rows;
    
    dist = [self path_distance_candidateTrace:candidate libraryTrace:template];
    
    candidate.rows = candidateRows;
    template.rows = templateRows;
    
    return dist;
}

- (float)distanceSqrt:(float*)u andV:(float*)v {
    return sqrtf((u[0]-v[0])*(u[0]-v[0])+(u[1]-v[1])*(u[1]-v[1])+(u[2]-v[2])*(u[2]-v[2]));
}

- (float)path_distance_candidateTrace:(Matrix *)path1 libraryTrace:(Matrix *)path2 {
    
    int length1 = path1.rows;
    int length2 = path2.rows;
    
    float distance = 0.0f;
    
    if(length1 == length2) {
        for (int i = 0; i < length1; i++) {
            float *v1 = path1.data[i];
            float *v2 = path2.data[i];
            distance += [self distanceSqrt:v1 andV:v2];
        }
        return distance;
    }
    
    else {
        if(length1 < length2) {
            int diff = length2 - length1;
            
            for(int i = length1-1; i < diff+length1-1;i++) {
                path2.rows = path2.rows-1;
            }
            return [self path_distance_candidateTrace:path1 libraryTrace:path2];
        }
        
        else {
            int diff = length1 - length2;
            for(int i = length2-1; i < diff+length2-1; i++) {
                path1.rows--;
            }
            //recurse
            return [self path_distance_candidateTrace:path1 libraryTrace:path2];
        }
    }
    return distance;
}

@end

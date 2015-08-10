//
//  Matrix.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "Matrix.h"

static int MATRIX_COUNT = 0;

@implementation Matrix

- (void)printVector:(float *)vec withSize:(uint)size {
  

    
    NSMutableString *out = [[NSMutableString alloc]initWithString:@"["];
    for(int i = 0; i < size; i++) {
        [out appendFormat:@"\t %f",vec[i]];
    }
    NSLog(@"%@",out);
}


- (void)printMatrix {
    NSMutableString *json = json = [NSMutableString stringWithString:@"["];
    for(int i = 0; i < self.rows; i++) {
       // [self printVector:self.data[i] withSize:self.cols];
        
        
        [json appendFormat:@"[%f, %f, %f], ",self.data[i][0],self.data[i][1],self.data[i][2]];
    }
    [json appendString:@"],\n"];
    NSLog(@"%@",json);
}

- (void)emptyMatrix {
    
    for(int j = 0 ; j < self.rows; j++) {
        bzero(self.data[j], sizeof(float[self.cols]));
    }
}

- (id)initMatrixWithRows:(uint)rows andCols:(uint)cols {
    
    if(self = [super init]) {
       
       
        MATRIX_COUNT++;
        if(MATRIX_COUNT % 10000 == 0) {
            NSLog(@"MATRIX created COUNT: %d",MATRIX_COUNT);
        }
        self.rows = rows;
        self.cols = cols;
        self.data = (float**)malloc(sizeof(float*)*self.rows);
        for(int i = 0; i < self.rows; i++) {
            self.data[i] = (float*) malloc(sizeof(float)*self.cols);

            
        }
        [self emptyMatrix];
    }
    return self;
}

+ (id)zeroVec3 {
    Matrix *zero = [[Matrix alloc]initMatrixWithRows:(uint) 1 andCols:(uint) 3];
    return zero;
}

- (void)copy:(float *)source Into:(float *)target andSize:(uint)size {
    for(int i = 0; i < size; i++) {
        target[i] = source[i];
    }
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    
   
    [encoder encodeInt:self.rows forKey:@"rows"];
    [encoder encodeInt:self.cols forKey:@"columns"];
    [encoder encodeArrayOfObjCType:@encode(float) count:self.rows * self.cols at:self.data];
    
        
 
    

}

- (id)initWithCoder:(NSCoder*)decoder {
   
    if(self = [super init]) {
        self.rows = [decoder decodeIntForKey:@"rows"];
        self.cols = [decoder decodeIntForKey:@"cols"];
        NSLog(@"number of rows: %i",self.rows);
        
        [decoder decodeArrayOfObjCType:@encode(float) count:self.rows*self.cols at:self.data];
        
    }
    
    return self;
}

- (void)makeDataEqualArray:(NSArray*)gestureList {
    
    NSLog(@"gesture list count: %li",gestureList.count);
       for(int i = 0; i < gestureList.count; i++) {
           NSNumber *arrayElements = [gestureList objectAtIndex:i];
           NSLog(@"array Elements: %@",arrayElements);
        
        self.data[i] = [arrayElements floatValue];
        
        
    }
    
    
}


@end

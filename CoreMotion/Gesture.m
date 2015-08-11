//
//  Gesture.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "Gesture.h"

@implementation Gesture

- (id)initWithName:(NSString *)aName andCapacity:(uint)maxSamples {
    
    if(self = [super init]) {
        
        self.gestureTrace = [[Matrix alloc] initMatrixWithRows:maxSamples andCols:3];
        self.gestureAdded = [NSDate date];
        self.gestureID = aName;
        self.databaseID = -1;
        NSLog(@"gesture %@ initialised",self.gestureID);
        NSLog(@"gestureTrace rows: %d, cols: %d",self.gestureTrace.rows,self.gestureTrace.cols);
    }
    return self;
}

- (id)initWithName:(NSString *)aName databaseID:(uint)aDatabaseID creationDate:(NSDate *)date andTrace:(Matrix*)trace {
    
     if(self = [super init]) {
         self.gestureTrace = trace;
         
         self.gestureAdded = [NSDate date];
         self.gestureID = aName;
         self.databaseID = -1;

     }
    return self;
}

- (void)printGestureWithTrace:(BOOL)withTrace {
    NSLog(@"Name: %@\t databaseID:%d",self.gestureID,self.databaseID);
    if(withTrace)
        [self.gestureTrace printMatrix];
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.gestureTrace forKey:@"gestureTrace"];
    [encoder encodeObject:self.gestureID forKey:@"gestureID"];
   
}

- (id)initWithCoder:(NSCoder*)decoder {
    
    if(self = [super init]) {
        self.gestureTrace = [decoder decodeObjectForKey:@"gestureTrace"];
        self.gestureID = [decoder decodeObjectForKey:@"gestureID"];
    }
    return self;
}


- (Matrix*)makeIntoGesture:(NSArray*)gestureList {
    
    NSString * dataString = [[gestureList valueForKey:@"description"] componentsJoinedByString:@""];
    
    
    NSArray * rowsArray = [dataString componentsSeparatedByString:@"],],"];
    
    NSLog(@"rowsArray: %@", rowsArray);
    
    int max = (int)[rowsArray count];
    Matrix* gestureTrace = [[Matrix alloc] initMatrixWithRows:400 andCols:3];
    
    NSUInteger i, count = [rowsArray count];
   // NSLog(@"count: %li",count);
    for (i = 0; i < count; i++) {
        NSString * aRow = [rowsArray objectAtIndex:i];
        NSArray * values = [aRow componentsSeparatedByString:@")"];
     //   NSLog(@"length of values array: %lu", (unsigned long)[values count]);
    //    NSLog(@"values Array: %@",values);
        int j;
        for(j = 0; j < 19; j++) {
            NSString *oneEntry = [values objectAtIndex:j];
            NSArray *individualElements = [oneEntry componentsSeparatedByString:@","];
            NSLog(@"oneEntry: %@",oneEntry);
            NSMutableString *validRep;
            int place = 0;
            for(int k = 0; k < [oneEntry length]; k++) {
                char check = [oneEntry characterAtIndex:k];
                if(isalpha(check)) {
                    NSString *add = [NSString stringWithFormat:@"%c",check];
                    [validRep insertString:add atIndex:place];
                    place++;
                }
            }
            NSLog(@"validRep: %@",validRep);
            NSLog(@"ind: %0.2f", [validRep floatValue]);
            NSLog(@"indObject: %@",[individualElements objectAtIndex:1]);
            gestureTrace.data[j][0] = [individualElements[0] floatValue];
            gestureTrace.data[j][1] = [[individualElements objectAtIndex:1] floatValue];
            gestureTrace.data[j][2] = [[individualElements objectAtIndex:2] floatValue];
            NSLog(@"X: %f, Y: %f, Z: %f",gestureTrace.data[i][0],gestureTrace.data[i][1],gestureTrace.data[i][2]);
            
        }
        
    
    }
    
    
    NSLog(@"gestureTrace: %@", gestureTrace);
    
    return gestureTrace;
    
    
    
}




@end

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


@end

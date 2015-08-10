//
//  Gesture.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"

@interface Gesture : NSObject

@property (nonatomic,retain) Matrix *gestureTrace;
@property (nonatomic,retain) NSDate *gestureAdded;
@property (nonatomic,retain) NSString *gestureID;
@property (nonatomic) int databaseID;

- (id)initWithName:(NSString*)aName andCapacity:(uint)maxSamples;
- (id)initWithName:(NSString*)aName databaseID:(uint)aDatabaseID creationDate:(NSDate*)date andTrace:(Matrix*)trace;
- (void)printGestureWithTrace:(BOOL)withTrace;

- (id)initWithCoder:(NSCoder*)decoder;

- (void)assignGestureTrace:(NSArray*)gestureList;

@end

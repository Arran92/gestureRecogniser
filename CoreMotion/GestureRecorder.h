//
//  GestureRecorder.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gesture.h"
#import "GestureRecorderDelegate.h"

@import CoreMotion;

@interface GestureRecorder : NSObject

@property BOOL isRecording;
@property (nonatomic,retain) Gesture *gesture;
@property (nonatomic) NSString *desiredName;
@property int samples;
@property int maxSamples;
@property float accelX;
@property float accelY;
@property float accelZ;
@property (assign) id<GestureRecorderDelegate> delegate;
@property (strong,nonatomic) CMMotionManager *motionManager;



- (void)outputAccelerationData:(float)X Y:(float)Y Z:(float)Z;
- (id)initWithNameForGesture:(NSString*)gestureName andDelegate:(id)aDelegate;

- (void)startRecording;
- (void)stopRecording;
- (void)configureAcclerometer;

@end

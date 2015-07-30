//
//  GestureRecorder.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "GestureRecorder.h"
#define ACCELEROMETER_FREQUENCY 100
#define GESTURE_MAX_SECONDS 4
#define FILTER_ENABLED TRUE
#define FILTERING_FACTOR 0.95

@implementation GestureRecorder

- (id)initWithNameForGesture:(NSString *)gestureName andDelegate:(id)aDelegate {
    
    if(self = [super init]) {
        self.delegate = aDelegate;
        NSLog(@"init GestureRecorder");
        self.accelX = 0;
        self.accelY = 0;
        self.accelZ = 0;
        self.maxSamples = ACCELEROMETER_FREQUENCY * GESTURE_MAX_SECONDS;
   //     self.gesture = [[Gesture alloc]init];
      
        self.desiredName = gestureName;
        [self configureAcclerometer];
        
    }
    return self;
}

- (void)configureAcclerometer {
    
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.01;
    
    NSLog(@"accelerometer initialised");
}

- (void)startRecording {
    self.accelX = 0;
    self.accelY = 0;
    self.accelZ = 0;
    self.samples = 0;
    self.maxSamples = ACCELEROMETER_FREQUENCY * GESTURE_MAX_SECONDS;
    self.gesture = [[Gesture alloc]initWithName:self.desiredName andCapacity:self.maxSamples];
    
    self.isRecording = YES;
    NSLog(@"accelerometer is on");
    
    
    // allocate a gesture once and only once
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        
       
        
        //added
      //  if(sampleCount < 2) {
        //    self.gesture = [[Gesture alloc]initWithName:self.desiredName andCapacity:self.maxSamples];
       //     sampleCount++;
       // }
        
 
            [self outputAccelerationData:accelerometerData.acceleration];
        
        
        if(error)
            NSLog(@"%@",error);
        
    }];
}

- (void)stopRecording {
    self.isRecording = NO;
    self.gesture.gestureTrace.rows = self.samples;
    [self.gesture printGestureWithTrace:NO];
}

- (void)outputAccelerationData:(CMAcceleration)acceleration {
    
    if(!self.isRecording) return;
   
    //self.gesture = [[Gesture alloc]initWithName:self.desiredName andCapacity:self.maxSamples];
    
   
    
    if(FILTER_ENABLED) {
        self.accelX = (acceleration.x *FILTERING_FACTOR) + (self.accelX * (1.0 - FILTERING_FACTOR));
        self.accelY = (acceleration.y *FILTERING_FACTOR) + (self.accelY * (1.0 - FILTERING_FACTOR));
        self.accelZ = (acceleration.z *FILTERING_FACTOR) + (self.accelZ * (1.0 - FILTERING_FACTOR));
    }
    
    else {
        self.accelX = acceleration.x;
        self.accelY = acceleration.y;
        self.accelZ = acceleration.z;
}

    if(self.gesture.gestureTrace == nil) {
        self.gesture.gestureTrace = [[Matrix alloc] initMatrixWithRows:400 andCols:3];
    }
    
    self.gesture.gestureTrace.data[self.samples][0] = self.accelX;
    self.gesture.gestureTrace.data[self.samples][1] = self.accelY;
    self.gesture.gestureTrace.data[self.samples][2] = self.accelZ;
       
    self.samples++;
    
    if(self.samples == self.maxSamples) {
        self.isRecording = NO;
        self.motionManager = nil;
        NSLog(@"END OF SAMPLING");
    }
    
}



@end

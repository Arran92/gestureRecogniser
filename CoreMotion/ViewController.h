//
//  ViewController.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureRecogniserDelegate.h"
#import "GestureRecorder.h"
#import "GestureDB.h"
@import CoreMotion;



@interface ViewController : UIViewController <GestureRecorderDelegate>

@property (strong,nonatomic) CMMotionManager *motionManager;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)touchDown:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic,retain) NSObject<GestureRecogniserDelegate> *gestureRecogniser;
@property (nonatomic,retain) GestureRecorder *gestureRecorder;
@property (nonatomic,retain) GestureDB *gestureDB;
@property (nonatomic,retain) NSString *lastRecognisedGesture;
@property BOOL forcedStop;
@property BOOL isRecordingTraining;

//protocol GestureRecordedDelegate
- (void)recorderForcedStop:(id)sender;


@end


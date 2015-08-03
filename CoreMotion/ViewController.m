//
//  ViewController.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "ViewController.h"
#import "ThreeDollarGestureRecogniser.h"
#define RESAMPLE_AMOUNT 50

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    // Do any additional setup after loading the view, typically from a nib.
    self.gestureDB = [GestureDB sharedInstance];
    
  
    self.forcedStop = NO;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)inThreadStartDoJob:(id)theJobToDo {
    
    self.gestureRecogniser = [[ThreeDollarGestureRecogniser alloc]initWithResampleAmount:RESAMPLE_AMOUNT];

    self.lastRecognisedGesture = [self.gestureRecogniser recogniseGesture:self.gestureRecorder.gesture fromGestures:self.gestureDB.gestureDict];
    
    NSLog(@"gestureRecogniser %@",self.gestureRecogniser);
    NSLog(@"recogniseGesture returned with GUESS %@",self.lastRecognisedGesture);
    
    self.label.text = self.lastRecognisedGesture;
    
    [NSThread sleepForTimeInterval:0.01];
    [self performSelectorOnMainThread:@selector(didStopJobWithStatus:) withObject:nil waitUntilDone:NO];
}

- (void)didStopJobWithStatus:(id)status {
    
    self.isRecordingTraining = NO;
    
}


- (IBAction)touchUpInside:(id)sender {
    if(self.forcedStop) {
        [self didStopJobWithStatus:nil];
        return;
    }
    
    NSLog(@"touchUpInside");
    [self.gestureRecorder stopRecording];
    self.isRecordingTraining = NO;
    [self performSelectorInBackground:@selector(inThreadStartDoJob:) withObject:nil];
    
    NSLog(@"touchUpInside END");
}

- (IBAction)touchDown:(id)sender {
    
    NSLog(@"touch down");
    if(self.isRecordingTraining) return;
    self.isRecordingTraining = YES;
    
    self.gestureRecorder = [[GestureRecorder alloc]initWithNameForGesture:@"TEST" andDelegate:self];
    
    [self.gestureRecorder startRecording];
    
    NSLog(@"touch down END");
    
}
@end

//
//  TrainingViewController.m
//  CoreMotion
//
//  Created by Arran Purewal on 25/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "TrainingViewController.h"
#import "ThreeDollarGestureRecogniser.h"
#import "ViewController.h"
#define RESAMPLE_AMOUNT 50

@interface TrainingViewController ()

@end

@implementation TrainingViewController

- (void)viewDidLoad {
    self.gestureNametextField.delegate = self;
    
    self.gestureRecogniser = [[ThreeDollarGestureRecogniser alloc]initWithResampleAmount:RESAMPLE_AMOUNT];
    
    self.gestureDB = [GestureDB sharedInstance];
    
    self.forcedStop = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





- (IBAction)touchUpInside:(id)sender {
    
    if(self.forcedStop) {
        [self didStopJobWithStatus:nil];
        return;
    }
    
    NSLog(@"touch up inside");
   [self.gestureRecorder stopRecording];
    self.isRecordingTraning = NO;
    self.infoLabel.text = @"processing gesture";
    
    self.trainButton.enabled = NO;
    [self.trainButton setTitle:@"please wait" forState:UIControlStateNormal];
    
    [self performSelectorInBackground:@selector(inThreadStartDoJob:) withObject:nil];
    
    NSLog(@"touch up inside END");
    
    [self.gestureDB printAllGestures];
    
}

- (void)didStopJobWithStatus:(id)status {
    self.isRecordingTraning = NO;
    self.trainButton.enabled = YES;
    self.trainButton.titleLabel.textColor = [UIColor blackColor];
    
    [self.trainButton setTitle:@"Press to Train" forState:UIControlStateNormal];
    
    if(self.forcedStop) {
        self.forcedStop = NO;
        self.infoLabel.text = @"Gesture dismissed";
    }
    else {
        self.infoLabel.text = @"OK: gesture saved";
    }
}

- (IBAction)touchDown:(id)sender {
    
    NSLog(@"touch down");
    if(self.isRecordingTraning) return;
    self.isRecordingTraning = YES;
    
    [self.trainButton setTitle:@"Recording Gesture" forState:UIControlStateNormal];
    self.infoLabel.text = @"start making gesture";
    self.gestureRecorder = [[GestureRecorder alloc]initWithNameForGesture:self.gestureNametextField.text andDelegate:self];
    [self.gestureRecorder startRecording];
    
    NSLog(@"touch down END");
    
}

- (void)inThreadStartDoJob:(id)theJobToDo {
    
    if(self.gestureDB != nil) {
        NSLog(@"gesture length before norm: %u",self.gestureRecorder.gesture.gestureTrace.rows);
        Matrix * normalised = [[Matrix alloc]initMatrixWithRows:400 andCols:3];
        
        normalised = [self.gestureRecogniser prepareMatrixForLibrary:self.gestureRecorder.gesture.gestureTrace];
        
        self.gestureRecorder.gesture.gestureTrace = normalised;
        
        [self.gestureDB addGesture:self.gestureRecorder.gesture];
        
        NSLog(@"TRY PRINT: %@",self.gestureRecorder.gesture);
        
        NSLog(@"recorded gesture length: %i",self.gestureRecorder.gesture.gestureTrace.rows);
        NSLog(@"gesture count in DB: %lu",(unsigned long)[self.gestureDB.gestures count]);
    }
    else {
        NSLog(@"ERROR gestureDB = nil");
    }
    
    [NSThread sleepForTimeInterval:0.01];
    [self performSelectorOnMainThread:@selector(didStopJobWithStatus:) withObject:nil waitUntilDone:NO];
    

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)recorderForcedStop:(id)sender {
    
    if(self.forcedStop)
        return;
    
    [self.gestureRecorder stopRecording];
    
    if(sender == self.gestureRecorder) {
        self.infoLabel.text = @"Timeout - gesture dismissed";
    }
    else {
        self.infoLabel.text = @"gesture dismissed";
    }
    
    self.trainButton.titleLabel.textColor = [UIColor redColor];
    [self.trainButton setTitle:@"press once" forState:UIControlStateNormal];
    
    
}
- (IBAction)mainScreenButton:(id)sender {
    
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [self presentViewController:vc animated:YES completion:nil];
    

}

@end

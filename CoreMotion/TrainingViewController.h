//
//  TrainingViewController.h
//  CoreMotion
//
//  Created by Arran Purewal on 25/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureRecorder.h"
#import "GestureDB.h"
#import "GestureRecogniserDelegate.h"
#import "GestureRecorderDelegate.h"


@interface TrainingViewController : UIViewController <UITextFieldDelegate, GestureRecogniserDelegate, GestureRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIButton *trainButton;
@property (weak, nonatomic) IBOutlet UITextField *gestureNametextField;
@property BOOL isRecordingTraning;
@property BOOL isProcessingGesture;
@property BOOL forcedStop;



@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic,retain) GestureRecorder *gestureRecorder;
@property (nonatomic,retain) GestureDB *gestureDB;
@property (nonatomic,retain) NSObject<GestureRecogniserDelegate> *gestureRecogniser;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;


- (IBAction)touchUpInside:(id)sender;
- (IBAction)touchDown:(id)sender;


- (void)recorderForcedStop:(id)sender;

@end

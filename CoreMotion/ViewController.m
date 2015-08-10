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

    //in this ftn need to change the parameter self.gestureDB.gestureDict to json dictionary
    
    [self loadJSONIntoDictionary];
    
    self.lastRecognisedGesture = [self.gestureRecogniser recogniseGesture:self.gestureRecorder.gesture fromGestures:self.gestureDB.gestureDict];
    

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
   
    
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"dict.plist"];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        
//        NSLog(@"saved data: %@",savedData);
//        self.gestureDB.gestureDict = [NSMutableDictionary dictionaryWithDictionary:savedData];
//        Gesture *retrievedFromFile = [[Gesture alloc]init];
//        
//        NSArray *retrieved = [self.gestureDB.gestureDict objectForKey:@"square"];
//        
//        retrievedFromFile = [retrieved objectAtIndex:0];
//        
//        
//        Matrix *fileMatrix = [[Matrix alloc]initMatrixWithRows:400 andCols:3];
//        fileMatrix = retrievedFromFile.gestureTrace;
//     
//        NSLog(@"fileMatrix: %@",retrievedFromFile.gestureTrace);
 //   }
    
    
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

- (void)loadJSONIntoDictionary {
      NSData *json = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Gestures" ofType:@"json"]];
    
    BOOL loadFromFile; NSError *error;
    loadFromFile = [self loadJSONintoTemplates:json error:error];
    if(!loadFromFile) {
        NSLog(@"cannot load gestures %@",error);
        return;
    }
}

- (BOOL)loadJSONintoTemplates:(NSData*)json error:(NSError*)error {
    
    NSMutableDictionary *holdingDict = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    
    if(!holdingDict) {
        NSLog(@"not able to load from the json file"); return NO;
    }
    
//    //need to convert the data from json file into CGPoint and keys
//    NSMutableDictionary *output = [NSMutableDictionary dictionary];
//    [holdingDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL *stop) {
//        NSMutableArray *points = [NSMutableArray arrayWithCapacity:value.count];
//        for(NSArray *pointArray in value) {
//            CGPoint pointToAdd = CGPointMake([pointArray[0] floatValue], [pointArray[1] floatValue]);
//            [points addObject:[NSValue valueWithCGPoint:pointToAdd]];
//            
//            
//        }
//        //the dictionary with key 'key' aligns with the corresponding points
//        output[key] = [points copy];
//    }];
    
    self.gestureDB.gestureDict = holdingDict;
    
    NSLog(@"dictionary: %@",self.gestureDB.gestureDict);
    
    return YES;
}



@end

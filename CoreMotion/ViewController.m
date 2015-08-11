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

    
    [self loadJSONIntoDictionary];
    
    //need to make the dictionary into Matrix objects
    
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
    

    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    [holdingDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL *stop) {
        
        //each array value has the coordinates
        Matrix *newMatrix = [[Matrix alloc]init];
        
        newMatrix = [self turnArrayIntoMatrix:value];
        NSDate *date = [NSDate date];
        
        Gesture *insertDictionary = [[Gesture alloc]initWithName:key databaseID:-1 creationDate:date andTrace:newMatrix];
        
        NSLog(@"newMatrix: %@",newMatrix);
//        NSMutableArray *points = [NSMutableArray arrayWithCapacity:value.count];
//        for(NSArray *pointArray in value) {
//            CGPoint pointToAdd = CGPointMake([pointArray[0] floatValue], [pointArray[1] floatValue]);
//            [points addObject:[NSValue valueWithCGPoint:pointToAdd]];
//            
//            
//        }
//        //the dictionary with key 'key' aligns with the corresponding points
        NSArray *newValue = [NSArray arrayWithObject:insertDictionary];
        output[key] = newValue;
    }];
    
    //this needs to be a dictionary of Matrices
    
   
    
    self.gestureDB.gestureDict = output;
    
    
    return YES;
}

//get given an array of coordinates to change into a Matrix
- (Matrix*)turnArrayIntoMatrix:(NSArray*)passedInArray {
    
    Matrix *passBack = [[Matrix alloc]initMatrixWithRows:400 andCols:3];
    
    NSLog(@"lengthOfPassed: %li",(unsigned long)[passedInArray count]);
   
    
//    NSArray *oneElement = passedInArray[0];
//    NSLog(@"firstElement: %@",oneElement[0]);
//    NSLog(@"floatFirstEl: %f",[oneElement[0]floatValue]);
    
    for(int i = 0; i < [passedInArray count]; i++) {
        NSArray *oneSetofCoords = passedInArray[i];
        passBack.data[i][0] = [oneSetofCoords[0]floatValue];
        passBack.data[i][1] = [oneSetofCoords[1]floatValue];
        passBack.data[i][2] = [oneSetofCoords[2]floatValue];
       
        
    }
    
    NSLog(@"passBack object: %@", passBack);
    
    return passBack;
}



@end

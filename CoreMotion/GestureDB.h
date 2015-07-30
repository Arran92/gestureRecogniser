//
//  GestureDB.h
//  CoreMotion
//
//  Created by Arran Purewal on 24/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gesture.h"
#import "Matrix.h"
#import <sqlite3.h>


@interface GestureDB : NSObject

@property (readwrite) NSString *filename;
@property (retain) NSMutableArray *gestures;
@property (retain) NSMutableDictionary *gestureDict;
@property (nonatomic) NSString *path;

- (void)saveToFile;
- (BOOL)addGesture:(Gesture*)aGesture;
- (BOOL)addGesturetoDB:(Gesture*)gesture;
- (BOOL)addGestureToArray:(Gesture*)aGesture;
- (void)printAllGestures;
- (void)checkAndCreateDatabase;
- (void)readGesturesFromDatabase;
+ (id)sharedInstance;
- (Matrix*)getMatrixFromData:(NSData*)data;
- (NSData*)getDataFromMatrix:(Matrix*)matrix;
- (void)deleteGesture:(int)databaseID;
+ (void)finalizeStatements;

@end

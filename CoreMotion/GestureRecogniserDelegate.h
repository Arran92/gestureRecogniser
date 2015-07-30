//
//  GestureRecogniserDelegate.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "Gesture.h"

@protocol GestureRecogniserDelegate <NSObject>

- (Matrix*)prepareMatrixForLibrary:(Matrix*)theTrace;
- (NSString*)recogniseGesture:(Gesture*)candidate fromGestures:(NSDictionary*)library_gestures;


@end

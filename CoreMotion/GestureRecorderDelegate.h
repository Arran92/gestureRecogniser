//
//  GestureRecorderDelegate.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GestureRecorderDelegate <NSObject>

- (void)recorderForcedStop:(id)sender;

@end

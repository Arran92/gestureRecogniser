//
//  Sensor.h
//  CoreMotion
//
//  Created by Arran Purewal on 03/08/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface sensorKXTJ9 : NSObject

#define KXTJ9_RANGE 4.0

+(float) calcXValue:(NSData *)data;
+(float) calcYValue:(NSData *)data;
+(float) calcZValue:(NSData *)data;
+(float) getRange;

@end



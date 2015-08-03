//
//  SensorTag.h
//  CoreMotion
//
//  Created by Arran Purewal on 03/08/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sensor.h"
#import "GestureRecorder.h"

@import CoreBluetooth;

@interface SensorTag : NSObject <CBPeripheralDelegate, CBCentralManagerDelegate>

@property (strong,nonatomic) CBCentralManager *centralManager;
@property (strong,nonatomic) CBPeripheral *peripheralDevice;

@property (strong,nonatomic) GestureRecorder *gestureRecorderObject;
- (id)initTheSensorTagWithGestureRecorder:(GestureRecorder*)recorderObject;

- (void)connectDevice;

@property int buttonCount;



@end

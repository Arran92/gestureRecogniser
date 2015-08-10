//
//  SensorTag.m
//  CoreMotion
//
//  Created by Arran Purewal on 03/08/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "SensorTag.h"


NSString *accService = @"F000AA10-0451-4000-B000-000000000000";
NSString *accConfig = @"F000AA12-0451-4000-B000-000000000000";
NSString *accData = @"F000AA11-0451-4000-B000-000000000000";
NSString *accPeriod = @"F000AA13-0451-4000-B000-000000000000";

NSString *keysService = @"FFE0";
NSString *keysPressState = @"FFE1";


@implementation SensorTag

- (id)initTheSensorTagWithGestureRecorder:(GestureRecorder*)recorderObject {
    if(self = [super init]) {
        self.gestureRecorderObject = [[GestureRecorder alloc]init];
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        self.gestureRecorderObject = recorderObject;
    }
    return self;
}



#pragma mark CBCentralManager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *deviceName = @"SensorTag";
    if([deviceName isEqualToString:[advertisementData objectForKey:CBAdvertisementDataLocalNameKey]]) {
        self.peripheralDevice = peripheral;
        self.peripheralDevice.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSArray *accAndKeys = [[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:accService], [CBUUID UUIDWithString:keysService],nil];
    
    peripheral.delegate = self;
    NSLog(@"connected");
    
    [self.peripheralDevice discoverServices:accAndKeys];
    
}

#pragma mark CBPeripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for(CBService *services in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:services];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    //write to config and then read
    for(CBCharacteristic* chars in service.characteristics) {
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accConfig]]) {
            int state = 1;
            NSData *encode = [NSData dataWithBytes:&state length:sizeof(u_int8_t)];
            [self.peripheralDevice writeValue:encode forCharacteristic:chars type:CBCharacteristicWriteWithResponse];
        }
        
        //setting the period between readings to be 300ms
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accPeriod]]) {
            int period = 10;
            NSData *periodToSet = [NSData dataWithBytes:&period length:sizeof(u_int8_t)];
            [self.peripheralDevice writeValue:periodToSet forCharacteristic:chars type:CBCharacteristicWriteWithResponse];
        }
        
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accData]]) {
            [self.peripheralDevice setNotifyValue:YES forCharacteristic:chars];
            
        }
        
        if([chars.UUID isEqual:[CBUUID UUIDWithString:keysPressState]]) {
            [self.peripheralDevice setNotifyValue:YES forCharacteristic:chars];
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error)
        NSLog(@"Error in updating the notification state: %@",error);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
 
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:accData]] && self.gestureRecorderObject.isRecording) {
            NSLog(@"output");
            [self.gestureRecorderObject outputAccelerationData:[sensorKXTJ9 calcXValue:characteristic.value] Y:[sensorKXTJ9 calcYValue:characteristic.value] Z:[sensorKXTJ9 calcZValue:characteristic.value]];
            NSLog(@"Button count: %i",self.buttonCount);
        }

    

    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error)
        NSLog(@"Error writing the value: %@",error);
}


@end

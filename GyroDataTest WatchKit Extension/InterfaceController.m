//
//  InterfaceController.m
//  GyroDataTest WatchKit Extension
//
//  Created by Cee on 9/20/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "InterfaceController.h"
#import <CoreMotion/CoreMotion.h>

@interface InterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;

@property (strong, nonatomic) IBOutlet WKInterfacePicker *xPicker;
@property (strong, nonatomic) IBOutlet WKInterfacePicker *yPicker;
@property (strong, nonatomic) IBOutlet WKInterfacePicker *zPicker;

@property (strong, nonatomic) CMMotionManager *manager;

@property (strong, nonatomic) NSMutableArray<WKPickerItem *> *pickerItems;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.xPicker setItems:self.pickerItems];
    [self.yPicker setItems:self.pickerItems];
    [self.zPicker setItems:self.pickerItems];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if (!self.manager) {
        self.manager = [[CMMotionManager alloc] init];
    }
    
    self.manager.accelerometerUpdateInterval = .1f;
    
    if (self.manager.accelerometerAvailable) {
        [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            [self setOffset:accelerometerData.acceleration.x picker:self.xPicker];
            [self setOffset:accelerometerData.acceleration.y picker:self.yPicker];
            [self setOffset:accelerometerData.acceleration.z picker:self.zPicker];
            if (error == nil) {
                [self.statusLabel setText:@"Tracking"];
            } else {
                [self.statusLabel setText:error.localizedDescription];
            }
        }];
    } else {
        [self.statusLabel setText:@"No Data"];
    }
    
    NSString *status = @"";
    if([self.manager isAccelerometerAvailable])
        status = [status stringByAppendingString:@"A"];
    if([self.manager isGyroAvailable])
        status = [status stringByAppendingString:@"G"];
    if([self.manager isMagnetometerAvailable])
        status = [status stringByAppendingString:@"M"];
    if([self.manager isDeviceMotionAvailable])
        status = [status stringByAppendingString:@"D"];
    
    NSLog(@"%@", status);
    

}

- (void)didDeactivate {
    [super didDeactivate];
    [self.manager stopAccelerometerUpdates];
}

- (void)setOffset:(double)offs picker:(WKInterfacePicker *)picker {
    int idx = 50 + 50 * offs;
    if (idx < 0) idx = 0;
    if (idx > 100) idx = 100;
    [picker setSelectedItemIndex:idx];
}

- (NSMutableArray<WKPickerItem *> *)pickerItems {
    if (!_pickerItems) {
        _pickerItems = [NSMutableArray array];
        for (int c = 100; c >= 0; c--) {
            NSString *name = [NSString stringWithFormat:@"bar%d", c];
            WKImage *img = [WKImage imageWithImageName:name];
            WKPickerItem *item = [WKPickerItem new];
            item.contentImage = img;
            [_pickerItems addObject:item];
        }
    }
    return _pickerItems;
}

@end




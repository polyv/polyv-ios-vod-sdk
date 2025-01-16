//
//  PLVVodHeatMapModel.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/6.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodHeatMapModel.h"

@implementation PLVVodHeatMapModel

+ (instancetype)defaultTestData{
    PLVVodHeatMapModel *model = [[PLVVodHeatMapModel alloc] init];
    model.dataPoints = @[@9592, @9692, @10063, @41138, @30485, @23905,
        @10966.5, @10316.5, @8533.5, @7249, @7181, @6813, @5929,
        @18046.5,  @8817, @3684.5, @4863.5, @7818, @11122, @11977.5,
        @12045.5, @6882, @8616, @3389.5, @2791.5, @2378, @2415,
        @3561.5, @4563.5, @5351, @5166, @3649.5, @3817.5, @6808,
          @3503, @2831.5, @2617.5, @2401, @2149, @2478.5, @2498.5,
          @2311.5, @1843.5, @1800, @2101, @2002.5, @2882.5, @3380,
          @3880, @3966, @3257, @8804, @5440, @6468, @6432, @3885, @3611,
          @7348, @11954, @12317, @5834, @1549.5, @1658.5, @1649, @2053, @3831.5,
          @6050.5, @7764, @8290, @8549, @5757, @1898, @1393, @1263.5, @1356.5,
          @2841, @5774, @4294, @1798, @1260.5];
    model.defautDuration = 5;
    model.totalVideoDuration = 150;
    
    return model;
}

- (instancetype)init{
    if (self = [super init]){
        _defautDuration = 5;
        _totalVideoDuration = 10.0;
    }
    return self;
}

@end

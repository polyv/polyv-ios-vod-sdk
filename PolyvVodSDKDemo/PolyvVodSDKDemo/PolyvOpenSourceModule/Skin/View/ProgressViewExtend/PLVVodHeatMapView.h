//
//  PLVVodHeatMapView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodHeatMapModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodHeatMapView : UIView

@property (nonatomic, strong) PLVVodHeatMapModel *heatMapModel;

/// 更新视图
- (void)updateWithData:(PLVVodHeatMapModel *)data;

@end

NS_ASSUME_NONNULL_END

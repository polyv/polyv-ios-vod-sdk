//
//  PLVVodHeatMapContentView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/14.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodHeatMapModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodHeatMapContentView : UIView

@property (nonatomic, strong) PLVVodHeatMapModel *heatMapModel;

/// 更新视图
- (void)updateWithData:(PLVVodHeatMapModel *)data;

@end

NS_ASSUME_NONNULL_END

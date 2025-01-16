//
//  PLVVodProgressMarkerView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodMarkerViewData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodProgressMarkerView : UIView

@property (nonatomic, strong) NSArray<PLVVodMarkerViewData *> *markerViewDatas;
@property (nonatomic, strong) NSMutableArray *bubbleViews;
/// 事件回调处理
@property (nonatomic, strong) void (^handleClickItem)(PLVVodMarkerViewData *markerData);

/// 刷新视图
- (void)updateWithMarkerViewData:(NSArray<PLVVodMarkerViewData *> *)data;
- (void)createBubbleViews;
- (void)layoutBubbleViews;



@end

NS_ASSUME_NONNULL_END

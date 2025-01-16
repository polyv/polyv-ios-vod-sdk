//
//  PLVVodProgressMarkerView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import "PLVVodProgressMarkerView.h"
#import "PLVVodBubbleMarkerView.h"


@implementation PLVVodProgressMarkerView

#pragma mark -- life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bubbleViews = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layoutBubbleViews];
}

#pragma mark -- public

- (void)updateWithMarkerViewData:(NSArray<PLVVodMarkerViewData* > *)data {
    self.markerViewDatas = data;
    [self createBubbleViews];
    [self layoutBubbleViews];
}

- (void)createBubbleViews {
    // 清除现有的气泡视图
    for (UIView *view in self.bubbleViews) {
        [view removeFromSuperview];
    }
    [self.bubbleViews removeAllObjects];
    
    // 根据数据创建新的气泡视图
    NSInteger tag = 0;
    __weak typeof(self) weakSelf = self;
    for (PLVVodMarkerViewData *item in self.markerViewDatas) {
        PLVVodBubbleMarkerView *bubbleView = [[PLVVodBubbleMarkerView alloc] initWithData:item];
        bubbleView.tag = tag;
        tag ++;

        bubbleView.tapHandler = ^(NSInteger tag) {
            [weakSelf handleClickEvent:tag];
        };
        [self addSubview:bubbleView];
        [self.bubbleViews addObject:bubbleView];
    }
}

- (void)layoutBubbleViews {
    CGSize bubbleSize = CGSizeMake(40, 30);  // 气泡的大小
    CGFloat viewWidth = self.bounds.size.width;
    
    // 遍历数组，根据 time 值设置位置
    for (NSInteger i = 0; i < self.bubbleViews.count; i++) {
        PLVVodBubbleMarkerView *bubbleView = self.bubbleViews[i];
        PLVVodMarkerViewData *data = self.markerViewDatas[i];
        
        // 计算 x 坐标：将 time 值映射到视图宽度范围内
        CGFloat point = data.time/ data.totalVideoTime;
        CGFloat xPosition = point * (viewWidth - bubbleSize.width);
        
        // y 坐标固定在中间
        CGFloat yPosition = 0;
        bubbleView.frame = CGRectMake(xPosition, yPosition, bubbleSize.width, bubbleSize.height);
    }
}

#pragma event handle
- (void)handleClickEvent:(NSInteger )index{
    if (self.handleClickItem){
        PLVVodMarkerViewData *viewData = self.markerViewDatas[index];
        self.handleClickItem(viewData);
    }
}


@end

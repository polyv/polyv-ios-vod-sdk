//
//  PLVVodBubbleMarkerView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodMarkerViewData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodBubbleMarkerView : UIView

@property (nonatomic, copy) void (^tapHandler)(NSInteger tag);

- (instancetype)initWithData:(PLVVodMarkerViewData *)data;

@end

NS_ASSUME_NONNULL_END

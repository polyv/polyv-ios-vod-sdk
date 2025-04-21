//
//  PLVVodNetworkPlayErrorTipsView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/17.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodNetworkPlayErrorTipsView : UIView

/// 线路切换点击事件处理
@property (nonatomic, strong) void(^handleSwitchEvent)(void);

////  视图展示
///
- (void)showInView:(UIView *)superView startY:(NSInteger)startY tipsMessage:(NSString *)tipsMessage;

/// 隐藏
- (void)hide;


@end

NS_ASSUME_NONNULL_END

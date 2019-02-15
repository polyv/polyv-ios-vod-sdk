//
//  PLVVodLockScreenView.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/12/10.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodLockScreenView : UIView

@property (weak, nonatomic) IBOutlet UIButton *unlockScreenBtn;

// 显示解锁按钮
- (void)showLockScreenButton;

@end

NS_ASSUME_NONNULL_END

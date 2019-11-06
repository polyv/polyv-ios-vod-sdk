//
//  PLVPPTLoadFailAlertView.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/6.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTLoadFailAlertView : UIView

@property (nonatomic, copy) void (^didTapButtonHandler)(void);

@end

NS_ASSUME_NONNULL_END

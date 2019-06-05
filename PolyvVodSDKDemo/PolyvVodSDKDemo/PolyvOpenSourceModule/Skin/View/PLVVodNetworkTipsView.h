//
//  PLVVodNetworkTipsView.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2019/3/14.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodNetworkTipsView : UIView

@property (nonatomic, copy) void (^playBtnClickBlock) (void);

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UILabel * tipsLb;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END

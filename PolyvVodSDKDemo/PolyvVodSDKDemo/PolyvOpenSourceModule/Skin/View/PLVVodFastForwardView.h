//
//  PLVVodFastForwardView.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/3/9.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodFastForwardView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) double rate;

- (void)show;
- (void)hide;
- (void)setLoading:(BOOL)load;

@end

NS_ASSUME_NONNULL_END

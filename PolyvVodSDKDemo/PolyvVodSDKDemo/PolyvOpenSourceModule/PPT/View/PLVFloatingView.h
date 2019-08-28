//
//  PLVFloatingView.h
//  PLVVodSDK
//
//  Created by MissYasiky on 2019/7/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVFloatingView;

@protocol PLVFloatingViewProtocol <NSObject>

- (void)tapAtFloatingView:(PLVFloatingView *)floatingView;

@end

@interface PLVFloatingView : UIView

@property (nonatomic, weak) id<PLVFloatingViewProtocol> delegate;
@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, assign) CGPoint fullScreenPoint;

+ (CGSize)viewSize;

@end

NS_ASSUME_NONNULL_END

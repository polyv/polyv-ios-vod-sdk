//
//  PLVToast.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/4/12.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PLVToastView;
@interface PLVToast : NSObject

/** 仅文字，展示在屏幕底部 */
+(void)showMessage:(NSString *)message;

@end

@interface PLVToastView : UIView

-(instancetype)initWithMessage:(NSString *)message;

-(void)show;

@end

NS_ASSUME_NONNULL_END

//
//  PLVToast.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/4/12.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVToast.h"

@class PLVToastView;
@interface PLVToast ()

@end

@implementation PLVToast

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PLVToast *toast = nil;
    dispatch_once(&onceToken, ^{
        toast = [[self alloc] init];
    });
    return toast;
}

#pragma mark - Public
/** 仅文字，展示在屏幕底部 */
+ (void)showMessage:(NSString *)message
{
    [[self sharedInstance] showMessage:message];
}


#pragma mark - Private
- (void)showMessage:(NSString *)message
{
    PLVToastView *toastView = [[PLVToastView alloc]initWithMessage:message];
    [toastView show];
}

@end

@interface PLVToastView ()

@property (nonatomic, strong) UILabel *lblMessage;

@end


@implementation PLVToastView
-(instancetype)initWithMessage:(NSString *)message
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 25;
        self.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1];
        self.alpha = 0;
        
        self.lblMessage = [[UILabel alloc]init];
        self.lblMessage.text = message;
        self.lblMessage.font = [UIFont systemFontOfSize:15.0];
        self.lblMessage.textAlignment = NSTextAlignmentCenter;
        self.lblMessage.numberOfLines = 0;
        [self addSubview:self.lblMessage];
    }
    return self;
}

-(void)show
{
    UIView *attachedView = [UIApplication sharedApplication].delegate.window;
    [attachedView addSubview:self];
    
    CGFloat msgWidth = [self.lblMessage.text boundingRectWithSize:CGSizeMake(1000, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.lblMessage.font} context:nil].size.width;
    msgWidth += 40;
    msgWidth = msgWidth < (attachedView.frame.size.width - 60) ? msgWidth : (attachedView.frame.size.width - 60);
    
    self.frame = CGRectMake((attachedView.frame.size.width - msgWidth) *0.5, attachedView.frame.size.height - 150, msgWidth, 50);
    self.lblMessage.frame = self.bounds;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
    }];
}

-(void)hide
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

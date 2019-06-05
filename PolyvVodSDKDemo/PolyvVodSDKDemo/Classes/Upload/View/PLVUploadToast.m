//
//  PLVUploadToast.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/5/15.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadToast.h"

static BOOL isShowing = NO;

@interface PLVUploadToast ()

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIWindow *container;

@end

@implementation PLVUploadToast

#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_tipsLabel];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat yOffset = 0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = (UIWindow *)[UIApplication sharedApplication].delegate.window;
            yOffset = window.safeAreaInsets.top;
        }
        _container = [[UIWindow alloc] initWithFrame:CGRectMake(0, yOffset, width, 20)];
        _container.windowLevel = UIWindowLevelStatusBar + 1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(0, 0, width, 20);
    self.tipsLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Public

+ (void)showText:(NSString *)text {
    if (isShowing) {
        return;
    }
    isShowing = YES;
    
    PLVUploadToast *toast = [[PLVUploadToast alloc] init];
    toast.tipsLabel.text = text;
    
    [toast.container makeKeyAndVisible];
    [toast.container addSubview:toast];
    
    [self performSelector:@selector(dissmissToast:) withObject:toast afterDelay:3];
}

#pragma mark - Private

+ (void)dissmissToast:(PLVUploadToast *)toast {
    UIWindow *window = (UIWindow *)[UIApplication sharedApplication].delegate.window;
    [window makeKeyAndVisible];
    
    [toast removeFromSuperview];
    toast.container = nil;
    toast = nil;
    
    isShowing = NO;
}

@end

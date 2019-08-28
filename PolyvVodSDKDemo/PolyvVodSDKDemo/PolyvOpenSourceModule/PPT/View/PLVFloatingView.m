//
//  PLVFloatingView.m
//  PLVVodSDK
//
//  Created by MissYasiky on 2019/7/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVFloatingView.h"

@interface PLVFloatingView ()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation PLVFloatingView

#pragma mark - Public

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        
        [self addSubview:self.closeBtn];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        self.lastPoint = self.bounds.origin;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

+ (CGSize)viewSize {
    return CGSizeMake(125, 70);
}

#pragma mark - UIGestureRecognizer

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    // 切换主副屏
    if (self.delegate) {
        [self.delegate tapAtFloatingView:self];
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.superview];
    CGSize superViewSize = self.superview.bounds.size;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGRect rect = self.frame;
        
        CGFloat newOriginX = rect.origin.x + point.x - self.lastPoint.x;
        newOriginX = MIN(MAX(0, newOriginX), superViewSize.width - rect.size.width);
        
        CGFloat newOriginY = rect.origin.y + point.y - self.lastPoint.y;
        newOriginY = MIN(MAX(0, newOriginY), superViewSize.height - rect.size.height);
        
        self.frame = CGRectMake(newOriginX, newOriginY, rect.size.width, rect.size.height);
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    }
    
    self.lastPoint = point;
}

@end

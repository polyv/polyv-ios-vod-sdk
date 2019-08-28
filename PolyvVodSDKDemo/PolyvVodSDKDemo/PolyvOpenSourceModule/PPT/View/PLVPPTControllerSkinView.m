//
//  PLVPPTControllerSkinView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/20.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTControllerSkinView.h"
#import "PLVPPTSkinProgressView.h"

@interface PLVPPTControllerSkinView ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) PLVPPTSkinProgressView *progressView;

@end

@implementation PLVPPTControllerSkinView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.tipsLabel.frame = frame;
        [self addSubview:self.tipsLabel];
        
        [self addSubview:self.progressView];
        self.progressView.center = self.center;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (frame.size.width <= 125) {
        [self.progressView changeRadius:12];
    } else {
        [self.progressView changeRadius:24];
    }
    self.progressView.center = self.center;
}

#pragma mark - Getter & Setter

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.text = @"暂无课件";
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (PLVPPTSkinProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[PLVPPTSkinProgressView alloc] initWithRadius:24];
    }
    return _progressView;
}

#pragma mark - Public

- (void)showNoPPTTips {
    [self showTipLabel:YES];
}

- (void)hiddenNoPPTTips {
    [self showTipLabel:NO];
}

- (void)startLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipsLabel.hidden = YES;
        [self.progressView startLoading];
    });
}

- (void)startDownloading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipsLabel.hidden = YES;
        [self.progressView startDownloading];
    });
}

- (void)downloadProgressChanged:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipsLabel.hidden = YES;
        [self.progressView updateProgress:progress];
    });
}

#pragma mark - Private

- (void)showTipLabel:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipsLabel.hidden = !show;
        [self.progressView stopLoading];
    });
}

@end

//
//  PLVPPTViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/25.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTViewController.h"
#import "PLVPPTControllerSkinView.h"
#import <PLVVodSDK/PLVVodPPT.h>
#import <YYWebImage/YYWebImage.h>

@interface PLVPPTViewController ()

@property (nonatomic, strong) UIImageView *pptImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) PLVPPTControllerSkinView *skinView;

@end

@implementation PLVPPTViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.pptImageView];
    [self.view addSubview:self.skinView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.pptImageView.frame = self.view.bounds;
    self.skinView.frame = self.view.bounds;
}

#pragma mark - Getters & Setters

- (UIImageView *)pptImageView {
    if (!_pptImageView) {
        _pptImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _pptImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _pptImageView;
}

- (PLVPPTControllerSkinView *)skinView {
    if (!_skinView) {
        _skinView = [[PLVPPTControllerSkinView alloc] initWithFrame:self.view.bounds];
    }
    return _skinView;
}

- (void)setPpt:(PLVVodPPT *)ppt {
    _ppt = ppt;
    
    if (_ppt == nil || _ppt.pages == nil || [_ppt.pages count] == 0) {
        return;
    }
    
    [self.skinView hiddenNoPPTTips];
    
    self.currentIndex = -1;
    [self _playPPTAtIndex:0];
}

#pragma mark - Public

- (void)playAtCurrentSecond:(NSInteger)second {
    for (int i = 0; i < self.ppt.pages.count; i++) {
        PLVVodPPTPage *page = self.ppt.pages[i];
        if (page.timing == second) {
            [self _playPPTAtIndex:i];
            break;
        } else if (page.timing < second) {
            if ([self.ppt.pages count] == i + 1) { // 已过了最后一张ppt的播放节点
                [self _playPPTAtIndex:i];
            } else {
                continue;
            }
        } else if (page.timing > second) {
            if (i == 0) { // 第一张 ppt 的播放时间不为 0 时
                [self _playPPTAtIndex:0];
            } else {
                PLVVodPPTPage *prePage = self.currentIndex >= 1 ? self.ppt.pages[self.currentIndex - 1] : nil;
                if (i == self.currentIndex && page.timing - second < second - prePage.timing) {
                    // 这时不进行ppt切换，避免ppt抖动
                } else {
                    [self _playPPTAtIndex:i-1];
                }
            }
            break;
        }
    }
}

- (void)playPPTAtIndex:(NSInteger)index {
    
    [self _playPPTAtIndex:index];
}

#pragma mark - Private

- (void)_playPPTAtIndex:(NSInteger)index {
    if (index == self.currentIndex) {
        return;
    }
    if (index < 0 || index >= (NSInteger)[self.ppt.pages count]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PLVVodPPTPage *page = self.ppt.pages[index];
        if ([page isLocalImage]) {
            [self.pptImageView setImage:[page localImage]];
        } else {
            NSURL *url = [NSURL URLWithString:page.imageUrl];
            [self.pptImageView yy_setImageWithURL:url options:YYWebImageOptionUseNSURLCache];
        }
        self.currentIndex = index;
    });
}

@end

@implementation PLVPPTViewController (PLVPPTSkin)

- (void)startLoading {
    [self.skinView startLoading];
}

- (void)loadPPTFail {
    [self.skinView showNoPPTTips];
}

- (void)startDownloading {
    [self.skinView startDownloading];
}

- (void)setDownloadProgress:(CGFloat)progress {
    [self.skinView downloadProgressChanged:progress];
}

@end

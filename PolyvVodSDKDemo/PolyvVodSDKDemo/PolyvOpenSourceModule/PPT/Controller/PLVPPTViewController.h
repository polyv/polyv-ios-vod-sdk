//
//  PLVPPTViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/25.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLVVodPPT;

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTViewController : UIViewController

@property (nonatomic, strong) PLVVodPPT * _Nullable ppt;

- (void)loadPPTFail;

- (void)playAtCurrentSecond:(NSInteger)second;

- (void)playPPTAtIndex:(NSInteger)index;

@end

@interface PLVPPTViewController (Loading)

- (void)startLoading;

- (void)startDownloading;

- (void)setDownloadProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END

//
//  PLVVodAudioCoverPanelView.h
//  PolyvVodSDKDemo
//
//  Created by 李长杰 on 2018/5/28.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVVodAudioCoverPanelView : UIView

- (void)setCoverUrl:(NSString *)url;

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode;

- (void)startRotate;
- (void)stopRotate;

@end

//
//  PLVVodDownloadHelper.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/13.
//  Copyright © 2018年 POLYV. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PLVVodDownloadHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <PLVVodSDK/PLVVodDownloadManager.h>

@interface PLVVodDownloadHelper ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

static PLVVodDownloadHelper *instance = nil;


@implementation PLVVodDownloadHelper

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PLVVodDownloadHelper alloc] init];
    });
    
    return instance;
}

- (void)setAudioSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    if (@available (iOS 10.0, *)){
        [session setCategory:AVAudioSessionCategoryPlayback
                        mode:AVAudioSessionModeMeasurement
                     options:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    }else {
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    }
}

/*
- (BOOL)isOtherAudioPlaying {
    UInt32 isPlaying = 0;
    UInt32 varSize = sizeof(isPlaying);
    AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying, &varSize, &isPlaying);
    return (isPlaying != 0);
}
*/

- (AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer){
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[self mp3Path]] error:nil];
        _audioPlayer.numberOfLoops = -1;
        _audioPlayer.volume = 0;
        [_audioPlayer prepareToPlay];
    }
    
    return _audioPlayer;
}

- (NSString *)mp3Path{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"plv_bg_voice" ofType:@"mp3"];
    
    return path;
}

- (void)startPlay{
    //
    [self setAudioSession];
    [self.audioPlayer play];
}

- (void)stopPlay{
    //
    if (_audioPlayer){
        [self.audioPlayer pause];
    }
}

- (void)applicationWillEnterForeground{
    [self stopPlay];
}

- (void)applicationDidEnterBackground{
    if ([[PLVVodDownloadManager sharedManager] isDownloading])
    {
        [self startPlay];
        
        __weak typeof(self) weakSelf = self;
        if (![PLVVodDownloadManager sharedManager].completeBlock){
            [PLVVodDownloadManager sharedManager].completeBlock = ^{
                // 停止播放
                [weakSelf stopPlay];
            };
        }
    }
}

@end

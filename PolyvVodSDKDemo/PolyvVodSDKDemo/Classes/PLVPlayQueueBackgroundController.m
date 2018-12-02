//
//  PLVPlayQueueBackgroundController.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/8/29.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVPlayQueueBackgroundController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVVodSkinPlayerController.h"
#import "PLVVodAccountVideo.h"

@interface PLVPlayQueueBackgroundController ()

@property (strong, nonatomic) UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;
@property (nonatomic, assign) NSUInteger playIndex;
@property (nonatomic, strong) NSMutableArray *playList;

@end

@implementation PLVPlayQueueBackgroundController

- (void)dealloc {
    //NSLog(@"%s", __FUNCTION__);
}

- (UIView *)playerPlaceholder{
    if (!_playerPlaceholder){
        _playerPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    }
    
    return _playerPlaceholder;
}

- (NSMutableArray *)playList{
    if (!_playList){
        _playList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _playList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.playerPlaceholder];
    
    [self.videoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 3)
        {
            [self.playList addObject:obj];
        }
    }];
    
    [self setupPlayer];
}

- (void)setupPlayer {
    // 初始化播放器
    PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
    [player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
    self.player = player;
    self.player.rememberLastPosition = YES;
    self.player.enableBackgroundPlayback = YES;
    
    _playIndex = 0;
    
    PLVVodAccountVideo *video = self.playList[_playIndex];
    // 有网情况下，也可以调用此接口，只要存在本地视频，都会优先播放本地视频
    __weak typeof(self) weakSelf = self;
    [PLVVodVideo requestVideoWithVid:video.vid completion:^(PLVVodVideo *video, NSError *error) {
        if (!video.available) return;
        weakSelf.player.video = video;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.title = video.title;
        });
    }];
    
    self.player.reachEndHandler = ^(PLVVodPlayerViewController *player) {
        //
        [weakSelf playNextOne];
    };
}

- (void)playNextOne{
    self.playIndex ++;
    
    if (self.playIndex < self.playList.count){
        PLVVodAccountVideo *video = [self.playList objectAtIndex:self.playIndex];

        __weak typeof(self) weakSelf = self;
        NSString *vid = video.vid;
        
        //
        [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (!video.available) return;
            weakSelf.player.video = video;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.title = video.title;
            });
            
            NSLog(@"--- palyer:%@  video:%@ --", weakSelf.player, video);
        }];
        
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.player.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.player.preferredStatusBarStyle;
}

@end

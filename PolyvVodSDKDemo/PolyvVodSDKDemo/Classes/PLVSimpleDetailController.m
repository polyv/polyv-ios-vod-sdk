//
//  PLVSimpleDetailController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVSimpleDetailController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVVodSkinPlayerController.h"

#import "PLVCastBusinessManager.h"

@interface PLVSimpleDetailController ()

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@property (nonatomic, strong) PLVCastBusinessManager * castBM; // 投屏功能管理器

@end

@implementation PLVSimpleDetailController

- (void)dealloc {
    [self.castBM quitAllFuntionc];
	//NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupPlayer];
    
    if ([PLVCastBusinessManager authorizationInfoIsLegal]) {
        self.castBM = [[PLVCastBusinessManager alloc] initCastBusinessWithListPlaceholderView:self.view player:self.player];
        [self.castBM setup];
    }
}

- (void)setupPlayer {
	// 初始化播放器
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
	[player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
	self.player = player;
    self.player.rememberLastPosition = YES;
    self.player.enableBackgroundPlayback = YES;
    
	NSString *vid = self.vid;
    if (self.localVideo){
        // 本地播放
        self.player.video = self.localVideo;
    }
    else{
        // 有网情况下，也可以调用此接口，只要存在本地视频，都会优先播放本地视频
        __weak typeof(self) weakSelf = self;
        [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (!video.available) return;
            weakSelf.player.video = video;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.title = video.title;
            });
        }];
    }
}

- (BOOL)prefersStatusBarHidden {
	return self.player.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.player.preferredStatusBarStyle;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{
    if (self.player.isLockScreen){
        return NO;
    }
    return YES;
}

@end

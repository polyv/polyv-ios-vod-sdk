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

@interface PLVSimpleDetailController ()

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@end

@implementation PLVSimpleDetailController

- (void)dealloc {
	//NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupPlayer];
}

- (void)setupPlayer {
	// 初始化播放器
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
	[player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
	self.player = player;
	NSString *vid = self.vid;
    if (self.localVideo){
        // 本地播放
        self.player.video = self.localVideo;
    }
    else{
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

@end

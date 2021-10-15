//
//  PLVCourseDetailController.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseDetailController.h"
#import "PLVCourseVideoListController.h"
#import "PLVCourseIntroductionController.h"
#import "PLVCourseNetworking.h"
#import "PLVCourseSection.h"
#import "DLTabedSlideView.h"
#import "PLVVodSkinPlayerController.h"

#ifdef PLVCastFeature
#import "PLVCastBusinessManager.h"
#endif

@interface PLVCourseDetailController ()<DLTabedSlideViewDelegate>

@property (nonatomic, strong) NSArray *subViewControllers;

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@property (weak, nonatomic) IBOutlet DLTabedSlideView *tabedSlideView;

#ifdef PLVCastFeature
@property (nonatomic, strong) PLVCastBusinessManager * castBM; // 投屏功能管理器
#endif

@end

@implementation PLVCourseDetailController

- (void)dealloc {
#ifdef PLVCastFeature
    [self.castBM quitAllFuntionc];
#endif
	NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
}

#pragma mark - property

- (NSArray *)subViewControllers {
	if (!_subViewControllers) {
		PLVCourseVideoListController *courseVideoList = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseVideoListController"];
		PLVCourseIntroductionController *courseIntro = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseIntroductionController"];
		_subViewControllers = @[courseVideoList, courseIntro];
	}
	return _subViewControllers;
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	PLVCourseIntroductionController *intro = self.subViewControllers[1];
	intro.htmlContent = self.course.courseDescription;
	//NSLog(@"desc: %@", intro.htmlContent);
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestCourseVideosWithCourseId:self.course.courseId completion:^(NSArray *videoSections) {
		if (!videoSections.count) return;
		PLVCourseVideoListController *courseVideoList = weakSelf.subViewControllers[0];
		courseVideoList.videoSections = videoSections;
		dispatch_async(dispatch_get_main_queue(), ^{
			[courseVideoList.tableView reloadData];
			// 自动播放第一项
			[courseVideoList selectRowWithIndex:0];
		});
	}];
	[self setupUI];
	
	// setup slide view
	self.tabedSlideView.delegate = self;
	self.tabedSlideView.baseViewController = self;
	UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
	self.tabedSlideView.tabbarHeight = 44;
	self.tabedSlideView.tabItemNormalColor = [UIColor blackColor];
	self.tabedSlideView.tabItemSelectedColor = themeColor;
	self.tabedSlideView.tabbarTrackColor = themeColor;
	DLTabedbarItem *item0 = [DLTabedbarItem itemWithTitle:@"课程目录" image:nil selectedImage:nil];
	DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"课程介绍" image:nil selectedImage:nil];
	self.tabedSlideView.tabbarItems = @[item0, item1];
	[self.tabedSlideView buildTabbar];
	self.tabedSlideView.selectedIndex = 0;
	
	PLVCourseVideoListController *courseVideoList = self.subViewControllers.firstObject;
	courseVideoList.videoDidSelect = ^(PLVVodVideo *video) {
		//NSLog(@"video: %@", video.title);
        
#ifdef PLVCastFeature
        if (weakSelf.castBM.castManager.connected) {
            [weakSelf showMessage:@"请先退出投屏再切换"];
        }else{
            weakSelf.player.video = video;
        }
#else
        weakSelf.player.video = video;
#endif
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 设置默认跑马灯，移除旧版本跑马灯
            PLVMarqueeModel *marqueeModel = [[PLVMarqueeModel alloc]init];
            [weakSelf.player.marqueeView setPLVMarqueeModel:marqueeModel];
            weakSelf.player.marquee = nil;
        });
        
	};
    
    // 若需投屏功能，则需以下代码来启用投屏
#ifdef PLVCastFeature
    if ([PLVCastBusinessManager authorizationInfoIsLegal]) {
        self.castBM = [[PLVCastBusinessManager alloc]initCastBusinessWithListPlaceholderView:self.view player:self.player];
        [self.castBM setup];
    }
#endif
}

- (void)setupUI {
	self.title = self.course.title;
	// 初始化播放器
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
	[player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
    player.rememberLastPosition = YES;
    player.enableBackgroundPlayback = YES;
	player.reachEndHandler = ^(PLVVodPlayerViewController *player) {
		NSLog(@"%@ finish handler.", player.video.vid);
	};
    __weak typeof (self) weakSelf = self;
    player.playbackStateHandler = ^(PLVVodPlayerViewController *player) {
        //新版跑马灯的启动暂停控制
        if (player.playbackState == PLVVodPlaybackStatePlaying) {
            [weakSelf.player.marqueeView start];
        }else if (player.playbackState == PLVVodPlaybackStatePaused) {
            [weakSelf.player.marqueeView pause];
        }else if (player.playbackState == PLVVodPlaybackStateStopped) {
            [weakSelf.player.marqueeView stop];
        }
    };
	self.player = player;
}

- (BOOL)prefersStatusBarHidden {
	return self.player.prefersStatusBarHidden;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.player.preferredStatusBarStyle;
}

- (BOOL)shouldAutorotate{
    if (self.player.isLockScreen){
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:^{}];
    }]];
    [self presentViewController:alertController animated:YES completion:^{

    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	id vc = segue.destinationViewController;
	if ([vc isKindOfClass:[PLVVodSkinPlayerController class]]) {
		self.player = vc;
	}
}

#pragma mark - DLTabedSlideViewDelegate

- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender{
	return self.subViewControllers.count;
}
- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index{
	return self.subViewControllers[index];
}
@end

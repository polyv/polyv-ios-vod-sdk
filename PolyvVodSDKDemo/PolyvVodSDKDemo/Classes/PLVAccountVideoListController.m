//
//  PLVAccountVideoListController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVAccountVideoListController.h"
#import "PLVCourseNetworking.h"
#import "PLVVodAccountVideo.h"
#import "PLVVideoCell.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "UIColor+PLVVod.h"
#import "PLVSimpleDetailController.h"
#import "PLVPPTSimpleDetailController.h"
#import "PLVPlayQueueBackgroundController.h"
#import <PLVVodSDK/PLVVodSDK.h>

static NSString * const PLVSimplePlaySegueKey = @"PLVSimplePlaySegue";

@interface PLVAccountVideoListController ()

@property (nonatomic, strong) NSArray<PLVVodAccountVideo *> *accountVideos;
@property (nonatomic, copy) NSString *vidShouldPlay;
@property (nonatomic, strong) UIButton *switchAccount;

@end

@implementation PLVAccountVideoListController

- (UIButton *)switchAccount{
    if (!_switchAccount){
        _switchAccount = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100, 100)];
        _switchAccount.backgroundColor = [UIColor redColor];
        [_switchAccount setTitle:@"帐号切换" forState:UIControlStateNormal];
        
        [_switchAccount addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _switchAccount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self requestData];
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.tableFooterView = [UIView new];
    
#ifdef PLVSupportMultiAccount
    // 用于多账号临时测试
    [self.view addSubview:self.switchAccount];
#endif
    
}

- (void)requestData {
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestAccountVideoWithPageCount:99 page:1 completion:^(NSArray<PLVVodAccountVideo *> *accountVideos) {
		weakSelf.accountVideos = accountVideos;
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.tableView reloadData];
		});
	}];
}

- (UIView *)emptyView {
	UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeSystem];
	emptyButton.showsTouchWhenHighlighted = YES;
	emptyButton.tintColor = [UIColor themeColor];
	[emptyButton setTitle:@"暂无数据，点击重试" forState:UIControlStateNormal];
	[emptyButton addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];
	return emptyButton;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([PLVSimplePlaySegueKey isEqualToString:segue.identifier] && [segue.destinationViewController isKindOfClass:[PLVSimpleDetailController class]]) {
		PLVSimpleDetailController *vc = (PLVSimpleDetailController *)segue.destinationViewController;
		vc.vid = self.vidShouldPlay;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger number = self.accountVideos.count;
	tableView.backgroundView = number ? nil : [self emptyView];
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVideoCell *cell = (PLVVideoCell *)[tableView dequeueReusableCellWithIdentifier:[PLVVideoCell identifier] forIndexPath:indexPath];
	cell.video = self.accountVideos[indexPath.row];
	__weak typeof(self) weakSelf = self;
    
	cell.playButtonAction = ^(PLVVideoCell *cell, UIButton *sender) {
		PLVVodAccountVideo *accountVideo = cell.video;
		NSString *vid = accountVideo.vid;
		if (!vid.length) return;
        
        /* 普通视频播放页面入口
        weakSelf.vidShouldPlay = vid;
        [weakSelf performSegueWithIdentifier:PLVSimplePlaySegueKey sender:sender];
         */
        // 三分屏模式视频播放页面入口
        PLVPPTSimpleDetailController *vctrl = [[PLVPPTSimpleDetailController alloc] init];
        vctrl.vid = accountVideo.vid;
        vctrl.isOffline = NO;
        [weakSelf.navigationController pushViewController:vctrl animated:YES];
        
//        PLVPlayQueueBackgroundController *queueVC = [[PLVPlayQueueBackgroundController alloc] init];
//        queueVC.videoArray = weakSelf.accountVideos;
//        [weakSelf.navigationController pushViewController:queueVC animated:YES];
        
	};
    
	cell.downloadButtonAction = ^(PLVVideoCell *cell, UIButton *sender) {
		PLVVodAccountVideo *accountVideo = cell.video;
		NSString *vid = accountVideo.vid;
		if (!vid.length) return;
        
        [PLVVodVideo requestVideoPriorityCacheWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (video.available){
                [weakSelf downloadVideo:video];
            }
        }];
	};
	cell.backgroundColor = self.tableView.backgroundColor;
	
    return cell;
}


- (void)downloadVideo:(PLVVodVideo *)video {
	PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
	PLVVodDownloadInfo *info = [downloadManager downloadVideo:video];
    
#ifdef PLVSupportDownloadAudio
    // 音频下载测试入口，需要音频下载功能客户，放开注释
    [downloadManager downloadAudio:video];
    
#endif
    
	if (info) NSLog(@"%@ - %zd 已加入下载队列", info.video.vid, info.quality);
}

#pragma mark - Action

- (IBAction)settingsAction:(UIBarButtonItem *)sender {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"前往设置" message:@"可配置点播加密串\n更改设置后需重启应用" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[alertController dismissViewControllerAnimated:YES completion:^{}];
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		UIApplication *app = [UIApplication sharedApplication];
		if ([app canOpenURL:settingsURL]) {
			[app openURL:settingsURL];
		}
	}]];
	[self presentViewController:alertController animated:YES completion:^{
		
	}];
}

// 帐号切换
- (void)switchBtnClick:(UIButton *)btn{
    //
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"帐号切换"
                                                                             message:@"注意：每次帐号切换时先执行登出操作"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"帐号111111"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
#ifdef PLVSupportMultiAccount
                                                          [[PLVVodDownloadManager sharedManager] switchDownloadAccount:@"111111"];
#endif
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"帐号222222"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
#ifdef PLVSupportMultiAccount
                                                          [[PLVVodDownloadManager sharedManager] switchDownloadAccount:@"222222"];
#endif

    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"帐号333333"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
#ifdef PLVSupportMultiAccount
                                                          [[PLVVodDownloadManager sharedManager] switchDownloadAccount:@"333333"];
#endif
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"登出多账号"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
#ifdef PLVSupportMultiAccount
                                                          [[PLVVodDownloadManager sharedManager] logoutMultiAccount];
#endif
                                                          
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


@end

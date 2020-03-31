//
//  PLVDemoViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/3/30.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVDemoViewController.h"
#import "PLVDemoPlayerViewController.h"
#import <PLVVodSDK/PLVVodSDK.h>

// 获取导航栏高度
#define NavHight (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

@interface PLVDemoViewController ()<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *navigationBar;

// 主播放器所在视图
@property (nonatomic, strong) UIView *playerPlaceholder;

// 播放器
@property (nonatomic, strong) PLVDemoPlayerViewController *player;

@end

@implementation PLVDemoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"播放器Demo页";
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.playerPlaceholder];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.navigationBar];
    
    [self setupPlayer];
    [self.player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationBar removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Getter & Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavHight, PLV_ScreenWidth, PLV_ScreenHeight - NavHight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor brownColor];
        _tableView.rowHeight = 44.0;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        CGFloat width = PLV_ScreenWidth;
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width * 9 / 16)];
        _headerView.backgroundColor = [UIColor yellowColor];
    }
    return _headerView;
}

- (UIView *)playerPlaceholder {
    if (!_playerPlaceholder) {
        _playerPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, NavHight, self.headerView.frame.size.width, self.headerView.frame.size.height)];
        _playerPlaceholder.backgroundColor = [UIColor redColor];
    }
    return _playerPlaceholder;
}

- (UIView *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PLV_ScreenWidth, NavHight)];
        _navigationBar.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, NavHight - 20, PLV_ScreenWidth, 20);
        label.text = @"导航栏标题";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:16];
        [_navigationBar addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, NavHight - 44, 44, 44);
        [button setTitle:@"返回" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [_navigationBar addSubview:button];
    }
    return _navigationBar;
}

#pragma mark - Initialize

- (instancetype)initWithVid:(NSString *)vid {
    self = [self init];
    if (self) {
        _vid = vid;
    }
    return self;
}

- (void)setupPlayer {
    self.player = [[PLVDemoPlayerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    
    self.player.didFullScreenSwitch = ^(BOOL fullScreen) {
        weakSelf.navigationBar.hidden = fullScreen;
    };
    
    // 当前页面只考虑在线视频播放方式，离线播放参考 PLVSimpleDetailController 页面
    NSString *vid = self.vid;
    
    [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) { // 在线视频播放，默认会优先播放本地视频
        if (error) {
            if (weakSelf.player.playerErrorHandler) {
                weakSelf.player.playerErrorHandler(weakSelf.player, error);
            };
        } else {
            weakSelf.player.video = video;
        }
    }];
}

#pragma mark - Action

- (void)buttonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第 %zd 行", indexPath.row];
    return cell;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 按照 SDK 的布局方式，只有改变 playerPlaceholder 的 frame 才能让播放器跟随 scrollView 滚动
    CGRect playerHolderRect = self.playerPlaceholder.frame;
    playerHolderRect.origin.y =  scrollView.frame.origin.y - scrollView.contentOffset.y;
    self.playerPlaceholder.frame = playerHolderRect;
}

@end

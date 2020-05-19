//
//  PLVPPTSimpleDetailController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/25.
//  Copyright © 2019 POLYV. All rights reserved.
//

#define PLVPPTBASEVIEWCONTROLLER_PROTECTED_ACCESS

#import "PLVPPTSimpleDetailController.h"
#import "PLVPPTBaseViewControllerInternal.h"
#import "PLVPPTTableViewCell.h"
#import "PLVEmptyPPTViewCell.h"

@interface PLVPPTSimpleDetailController ()<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL pptError;

@end

@implementation PLVPPTSimpleDetailController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    /*
    // 需要添加播放器 logo 解开这段注释
    [self addLogo];
     */
}

- (void)viewWillLayoutSubviews {
    // 若覆写 “-viewWillLayoutSubviews” 必须执行 [super viewWillLayoutSubviews]; 否则影响父类布局
    [super viewWillLayoutSubviews];
    
    CGFloat originY = self.mainView.frame.origin.y + self.mainView.frame.size.height;
    self.tableView.frame = CGRectMake(0, originY, PLV_ScreenWidth, PLV_ScreenHeight - originY);
    [self.view sendSubviewToBack:self.tableView];
}

#pragma mark - Override

- (void)interfaceOrientationDidChange {
    // 横竖屏切换后的相关业务操作
}

- (void)getPPTFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.hidden = NO;
        self.pptError = YES;
        [self.tableView reloadData];
    });
}

- (void)getPPTSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.hidden = !self.ppt;
        self.pptError = NO;
        [self.tableView reloadData];
    });
}

#pragma mark - Getters & Setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.hidden = YES;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = [PLVPPTTableViewCell rowHeight];
    }
    return _tableView;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PLV_ScreenWidth, 48 + 16)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, PLV_ScreenWidth - 16 * 2, 48)];
        label.text = @"课件目录";
        label.textColor = [UIColor colorWithRed:0x4a/255.0 green:0x4a/255.0 blue:0x4a/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:14];
        [_tableHeaderView addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 48, PLV_ScreenWidth - 16 * 2, 0.5)];
        line.backgroundColor = [UIColor colorWithRed:0xe5/255.0 green:0xe5/255.0 blue:0xe5/255.0 alpha:1.0];
        [_tableHeaderView addSubview:line];
    }
    return _tableHeaderView;
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pptError) {
        return 1;
    } else {
        return self.ppt ? [self.ppt.pages count] : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pptError) {
        static NSString *errorCellIdentifier = @"errorCellIdentifier";
        PLVEmptyPPTViewCell *cell = (PLVEmptyPPTViewCell *)[tableView dequeueReusableCellWithIdentifier:errorCellIdentifier];
        if (cell == nil) {
            cell = [[PLVEmptyPPTViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:errorCellIdentifier];
            __weak typeof(self) weakSelf = self;
            cell.didTapButtonHandler = ^{
                [weakSelf reGetPPTData];
            };
        }
        return cell;
    } else {
        static NSString *cellIdentifier = @"cellIdentifier";
        PLVPPTTableViewCell *cell = (PLVPPTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[PLVPPTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell configPPTPage:self.ppt.pages[indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pptError) {
        CGFloat height = self.tableView.frame.size.height - self.tableHeaderView.frame.size.height - 16 ;
        return MAX(0, height);
    } else {
        return [PLVPPTTableViewCell rowHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.pptError == NO) {
        [self selectPPTAtIndex:indexPath.row];
    }
}

#pragma mark - Private
/*
// 需要添加播放器 logo 解开这段注释，在这里自定义需要的logo
- (void)addLogo {
    PLVVodPlayerLogo *playerLogo = [[PLVVodPlayerLogo alloc] init];
    
    PLVVodPlayerLogoParam *vodLogoParam = [[PLVVodPlayerLogoParam alloc] init];
    vodLogoParam.logoWidthScale = 0.2;
    vodLogoParam.logoHeightScale = 0.2;
    vodLogoParam.logoUrl = @"https://wwwimg.polyv.net/assets/dist/images/web3.0/doc-home/logo-vod.png";
    [playerLogo insertLogoWithParam:vodLogoParam];
    
    PLVVodPlayerLogoParam *polyvLogoParam = [[PLVVodPlayerLogoParam alloc] init];
    polyvLogoParam.logoWidthScale = 0.1;
    polyvLogoParam.logoHeightScale = 0.1;
    polyvLogoParam.logoAlpha = 0.5;
    polyvLogoParam.position = PLVVodPlayerLogoPositionLeftDown;
    polyvLogoParam.logoUrl = @"https://wwwimg.polyv.net/assets/certificate/polyv-logo.jpeg";
    [playerLogo insertLogoWithParam:polyvLogoParam];
    
    [self addLogoWithParam:@[vodLogoParam, polyvLogoParam]];
}
*/
@end

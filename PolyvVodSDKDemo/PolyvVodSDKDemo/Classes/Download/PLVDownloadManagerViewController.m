//
//  PLVDownloadManagerViewController.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVDownloadManagerViewController.h"
#import "PLVDownloadCompleteViewController.h"
#import "PLVDownloadProcessingViewController.h"
#import "DLTabedSlideView.h"

@interface PLVDownloadManagerViewController ()<DLTabedSlideViewDelegate>

@property (nonatomic, strong) DLTabedSlideView *tabedSlideView;

@property (nonatomic, strong) NSArray<UIViewController *> *subViewControllers;

@end

@implementation PLVDownloadManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma init --
- (void)initUI{
    
    [self.view addSubview:self.tabedSlideView];
    self.tabedSlideView.frame = CGRectMake(0, PLV_StatusAndNaviBarHeight, PLV_ScreenWidth, PLV_ScreenHeight - PLV_StatusAndNaviBarHeight);
    
    [self setupTabedSlideView];
}

- (void)setupTabedSlideView{
    // setup slide view
    self.tabedSlideView.delegate = self;
    self.tabedSlideView.baseViewController = self;
    UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
    self.tabedSlideView.tabbarHeight = 44;
    self.tabedSlideView.tabItemNormalColor = [UIColor blackColor];
    self.tabedSlideView.tabItemSelectedColor = themeColor;
    self.tabedSlideView.tabbarTrackColor = themeColor;
    DLTabedbarItem *item0 = [DLTabedbarItem itemWithTitle:@"已缓存" image:nil selectedImage:nil];
    DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"缓存中" image:nil selectedImage:nil];
    self.tabedSlideView.tabbarItems = @[item0, item1];
    self.tabedSlideView.canScroll = NO;
    
    [self.tabedSlideView buildTabbar];
    self.tabedSlideView.selectedIndex = 0;
}

#pragma getter --
- (DLTabedSlideView *)tabedSlideView{
    if (!_tabedSlideView){
        _tabedSlideView = [[DLTabedSlideView alloc] init];
    }
    
    return _tabedSlideView;
}

- (NSArray<UIViewController *> *)subViewControllers{
    if (!_subViewControllers){
        
        PLVDownloadCompleteViewController *completeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVDownloadCompleteViewController"];
        PLVDownloadProcessingViewController *processVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVDownloadProcessingViewController"];
        
        _subViewControllers = @[completeVC, processVC];
    }
    
    return _subViewControllers;
}

#pragma mark -- DLTabedSlideViewDelegate

- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender{
    return self.subViewControllers.count;
}
- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index{
    return self.subViewControllers[index];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

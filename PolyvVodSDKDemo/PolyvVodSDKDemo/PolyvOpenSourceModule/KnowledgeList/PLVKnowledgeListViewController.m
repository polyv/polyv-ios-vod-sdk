//
//  PLVKnowledgeListViewController.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVKnowledgeListViewController.h"
#import "UIColor+PLVVod.h"
#import <PLVMasonry/PLVMasonry.h>
#import "PLVSlideTabbarView.h"
#import "PLVKnowledgeCategoryTableViewCell.h"
#import "PLVKnowledgePointTableViewCell.h"
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVKnowledgeListViewController ()<PLVSlideTabbarViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PLVSlideTabbarView *slideTabbarView;
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;

/// 当前一级分类
@property (nonatomic, strong) PLVKnowledgeWorkType *currentWorkType;
/// 当前二级分类
@property (nonatomic, strong) PLVKnowledgeWorkKey *currentWorkKey;
/// 当前一级分类索引
@property (nonatomic, assign) NSInteger currentWoryTypeIndex;
/// 当前二级分类索引
@property (nonatomic, assign) NSInteger currentWoryKeyIndex;
/// 当前point索引: currentWoryTypeIndex_currentWoryKeyIndex_pointIndex
@property (nonatomic, copy) NSString *currentPointIndex;

/// 是否正在展示
@property (nonatomic, assign) BOOL showing;

/// 用于自动隐藏的计时器
@property (nonatomic, strong) NSTimer *hideTimer;

/// 无操作的时间统计
@property (nonatomic, assign) NSInteger noOperationTime;

@end

@implementation PLVKnowledgeListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.slideTabbarView];
    [self.slideTabbarView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.plv_equalTo(48);
    }];
    
    [self.view addSubview:self.leftTableView];
    [self.leftTableView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.width.plv_equalTo(240);
        make.top.equalTo(self.slideTabbarView.plv_bottom);
    }];
    
    [self.view addSubview:self.rightTableView];
    [self.rightTableView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.equalTo(self.leftTableView.plv_right);
        make.right.bottom.equalTo(self.view);
        make.top.equalTo(self.leftTableView);
    }];
    
    self.view.alpha = 0;
}

-(void)dealloc {
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

#pragma mark - Setter

- (void)setKnowledgeModel:(PLVKnowledgeModel *)knowledgeModel {

    NSMutableArray *categoryList = [NSMutableArray arrayWithCapacity:1];
    for (PLVKnowledgeWorkType *workTypeModel in knowledgeModel.knowledgeWorkTypes) {
        [categoryList addObject:workTypeModel.name];
    }
    
    _knowledgeModel = knowledgeModel;
    
    self.slideTabbarView.tabbarItemArray = categoryList;
    
    [self dealKnowledgeDataWithIndex];
}


#pragma mark - Action

/// 展示知识清单
- (void)showKnowledgeListView {
    if (self.showing) {
        return;
    }
    
    [UIView animateWithDuration:PLVVodAnimationDuration animations:^{
        self.view.alpha = 1;
        self.showing = YES;
    } completion:^(BOOL finished) {
        
    }];
    
    [self startTimerForAutoHiden];
}

/// 隐藏知识清单
- (void)hideKnowledgeListView {
    [UIView animateWithDuration:0.15 animations:^{
        self.view.alpha = 0;
        self.showing = NO;
        if (self.hideTimer) {
            [self.hideTimer invalidate];
            self.hideTimer = nil;
        }
    }];
}

/// 根据索引，筛选数据用于显示
- (void)dealKnowledgeDataWithIndex {
    if (self.currentWoryTypeIndex >= self.knowledgeModel.knowledgeWorkTypes.count) {
        return;
    }
    self.currentWorkType = self.knowledgeModel.knowledgeWorkTypes[self.currentWoryTypeIndex];
    
    if (!self.currentWorkType ||
        self.currentWoryKeyIndex >= self.currentWorkType.knowledgeWorkKeys.count) {
        return;
    }
    self.currentWorkKey = self.currentWorkType.knowledgeWorkKeys[self.currentWoryKeyIndex];
    
    if (!self.currentWorkKey) {
        return;
    }
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

- (NSString *)createPointIndexStringWithPointIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%ld_%ld_%ld", (long)self.currentWoryTypeIndex, (long)self.currentWoryKeyIndex, (long)index];
}

/// 开始计时器
- (void)startTimerForAutoHiden {
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
    self.noOperationTime = 0;
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
}

/// 计时操作
- (void)timeEvent {
    self.noOperationTime ++;
    // 无操作10s 关闭清单
    if (self.noOperationTime >= 10) {
        [self hideKnowledgeListView];
        if (self.hideTimer) {
            [self.hideTimer invalidate];
            self.hideTimer = nil;
        }
    }
}

#pragma mark - PLVSlideTabbarViewDelegate

/// 选中一级分类回调
/// @param slideTabbarView tabbar
/// @param index 一级分类序号
- (void)plvSlideTabbarView:(PLVSlideTabbarView *)slideTabbarView selectItemAtIndex:(NSInteger)index {
    self.noOperationTime = 0;
    self.currentWoryTypeIndex = index;
    self.currentWoryKeyIndex = 0;
    [self dealKnowledgeDataWithIndex];
}

/// 点击关闭按钮
- (void)plvSlideTabbarViewCloseButtonAction:(PLVSlideTabbarView *)slideTabbarView {
    [self hideKnowledgeListView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        return self.currentWorkType.knowledgeWorkKeys.count;
    }
    return self.currentWorkKey.knowledgePoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        PLVKnowledgeCategoryTableViewCell *cell = [PLVKnowledgeCategoryTableViewCell cellWithTableView:tableView];
        cell.workKeyModel = self.currentWorkType.knowledgeWorkKeys[indexPath.row];
        cell.isSelectCell = indexPath.row == self.currentWoryKeyIndex;
        return cell;
    }
    PLVKnowledgePointTableViewCell *cell = [PLVKnowledgePointTableViewCell cellWithTableView:tableView];
    cell.isShowDesc = self.knowledgeModel.fullScreenStyle;
    cell.pointModel = self.currentWorkKey.knowledgePoints[indexPath.row];
    NSString *pointString = [self createPointIndexStringWithPointIndex:indexPath.row];
    cell.isSelectCell = [pointString isEqualToString:self.currentPointIndex];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.noOperationTime = 0;
    if (tableView == self.leftTableView) {
        self.currentWoryKeyIndex = indexPath.row;
        [self dealKnowledgeDataWithIndex];
    }else {
        self.currentPointIndex = [self createPointIndexStringWithPointIndex:indexPath.row];
        [self.rightTableView reloadData];
        PLVKnowledgePoint *pointModel = self.currentWorkKey.knowledgePoints[indexPath.row];
        if (self.selectKnowledgePointBlock) {
            self.selectKnowledgePointBlock(pointModel);
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}


#pragma mark - Loadlazy

-(PLVSlideTabbarView *)slideTabbarView {
    if (_slideTabbarView == nil) {
        _slideTabbarView = [[PLVSlideTabbarView alloc]init];
        _slideTabbarView.delegate = self;
    }
    return _slideTabbarView;
}

- (UITableView *)leftTableView {
    if (_leftTableView == nil) {
        _leftTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _leftTableView.backgroundColor = [UIColor colorWithHex:0x222326];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _leftTableView.separatorColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
        if (@available(iOS 11.0, *)) {
            _leftTableView.estimatedRowHeight = 0;
            _leftTableView.estimatedSectionHeaderHeight = 0;
            _leftTableView.estimatedSectionFooterHeight = 0;
            _leftTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _leftTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            _leftTableView.scrollIndicatorInsets = _leftTableView.contentInset;
        }
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (_rightTableView == nil) {
        _rightTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _rightTableView.backgroundColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightTableView.showsVerticalScrollIndicator = NO;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _rightTableView.estimatedRowHeight = 0;
            _rightTableView.estimatedSectionHeaderHeight = 0;
            _rightTableView.estimatedSectionFooterHeight = 0;
            _rightTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _rightTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            _rightTableView.scrollIndicatorInsets = _rightTableView.contentInset;
        }
    }
    return _rightTableView;
}

@end

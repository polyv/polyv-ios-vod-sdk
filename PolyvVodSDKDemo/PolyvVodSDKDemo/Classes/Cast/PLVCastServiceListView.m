//
//  PLVCastServiceListView.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/17.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import "PLVCastServiceListView.h"

#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height
#define SPACE         0
#define Cell_height   54
#define CellFrontSpace 24
#define IndiViewScale 0.9

#define titleLbH 48
#define wifiBgH 35

#define tableViewWidthInLands 340 // 横屏时 Tableview 宽度
#define tableViewHeightInVer  340 // 竖屏时 Tableview 高度

@interface PLVCastFatherCell : UITableViewCell // 私有类 投屏Cell父类

@property (nonatomic, assign) BOOL hideLine;

@end

@interface PLVCastTipsCell : PLVCastFatherCell // 私有类 投屏提示Cell

@end

@interface PLVCastDeviceCell : PLVCastFatherCell // 私有类 投屏设备Cell

@property (nonatomic, assign) BOOL isAirPlay;

@end

@interface PLVSearchCastNetCell : PLVCastFatherCell // 私有类 搜索中Cell

@property (nonatomic, strong) UIActivityIndicatorView * indiV;
@property (nonatomic, strong) UILabel * textLb;

- (void)startIndicatorAnimation;

@end


@interface PLVCastServiceListView ()<UITableViewDelegate, UITableViewDataSource> // 投屏设备选择视图

@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * devicesArr;
@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong) UIView * headView;
@property (nonatomic, strong) UILabel * titleLb;

@property (nonatomic, strong) UIView * wifiBg;
@property (nonatomic, strong) UIImageView * wifiImgV;
@property (nonatomic, strong) UILabel * wifiNameLb;
@property (nonatomic, strong) UIButton * refreshBtn;

@property (nonatomic, strong) UIButton * cancleBtn;

// 反复展示的模型
@property (nonatomic, strong) PLVCastCellInfoModel * tipsModel;
@property (nonatomic, strong) PLVCastCellInfoModel * airPlayModel;
@property (nonatomic, strong) PLVCastCellInfoModel * searchingModel;

@property (nonatomic, assign) BOOL isShow; // 当前隐藏状态

@end


@implementation PLVCastServiceListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _dataArr = [[NSMutableArray alloc]init];
        
        _tipsModel = [[PLVCastCellInfoModel alloc]init];
        _tipsModel.type = PLVCastCellType_Tips;
        _tipsModel.tips = @"请将手机与电视/盒子连接同一个WiFi";
        
        _airPlayModel = [[PLVCastCellInfoModel alloc]init];
        _airPlayModel.type = PLVCastCellType_AirPlay;
        _airPlayModel.deviceName = @"AirPlay";
        
        _searchingModel = [[PLVCastCellInfoModel alloc]init];
        _searchingModel.type = PLVCastCellType_Searching;
        
        [self craetUI];
        [self dismissToHidden];
        
    }
    return self;
}

- (void)craetUI
{
    [self addSubview:self.maskView];
    [self addSubview:self.tableView];
    [self addSubview:self.cancleBtn];
}

- (void)layoutSubviews{
    self.landsOrVer = UIScreen.mainScreen.bounds.size.width > UIScreen.mainScreen.bounds.size.height; // yes - 横屏；no - 竖屏
    
    float boundsW = CGRectGetWidth(self.bounds);
    float boundsH = CGRectGetHeight(self.bounds);

    float t_x;
    float t_y;
    float t_w = self.landsOrVer ? tableViewWidthInLands : boundsW;
    float t_h = self.landsOrVer ? boundsH : tableViewHeightInVer;
    if (_isShow) { // 出现
        t_x = self.landsOrVer ? (boundsW - tableViewWidthInLands) : 0;
        t_y = self.landsOrVer ? 0 : boundsH - Cell_height - tableViewHeightInVer;
    }else{        // 隐藏
         t_x = self.landsOrVer ? boundsW : 0;
         t_y = self.landsOrVer ? 0 : boundsH - Cell_height;
    }
    _tableView.frame = CGRectMake(t_x, t_y, t_w, t_h);
    
    self.cancleBtn.frame = CGRectMake(0, boundsH - Cell_height, boundsW, Cell_height);
    if (self.landsOrVer) {
        self.cancleBtn.hidden = YES;
    }else{
        self.cancleBtn.hidden = NO;
    }
    
    self.maskView.frame = [UIScreen mainScreen].bounds;
    self.headView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), titleLbH + wifiBgH);
}

- (UIButton *)cancleBtn{
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancleBtn.backgroundColor = [UIColor whiteColor];
        [_cancleBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancleBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        _cancleBtn.layer.shadowOffset = CGSizeMake(5, 5);
        _cancleBtn.layer.shadowRadius = 5;
        _cancleBtn.layer.shadowOpacity = 0.5;
    }
    return _cancleBtn;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = .5;
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

- (UIView*)headView {
    if (!_headView) {
        
        float leftSpace = 24;
        float btnW = 24;
        float headViewW = CGRectGetWidth(self.bounds);
        
        // 背景
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headViewW - 20, titleLbH + wifiBgH)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        // 标题
        UILabel * titleLb = [[UILabel alloc]initWithFrame:CGRectMake(leftSpace, 0, 150, titleLbH)];
        titleLb.text = @"选择投屏设备";
        titleLb.font = [UIFont boldSystemFontOfSize:18];
        titleLb.textColor = [UIColor colorWithRed:73/255.0 green:75/255.0 blue:90/255.0 alpha:1];
        titleLb.textAlignment = NSTextAlignmentLeft;
        [_headView addSubview:titleLb];
        self.titleLb = titleLb;
        
        // 刷新
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"btn-refresh-b"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(CGRectGetWidth(_headView.frame) - btnW - 18, (titleLbH - btnW) / 2, btnW, btnW);
        // btn.backgroundColor = [UIColor yellowColor];
        [btn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:btn];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.refreshBtn = btn;

        // WiFi详情背景
        UIView * wifiBg = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLb.frame), headViewW, wifiBgH)];
        wifiBg.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_headView addSubview:wifiBg];
        self.wifiBg = wifiBg;
        
        // WiFi图标
        float wifiImgVH = 20;
        UIImageView * wifiImgV = [[UIImageView alloc]initWithFrame:CGRectMake(leftSpace, (CGRectGetHeight(wifiBg.frame) - wifiImgVH) / 2, wifiImgVH, wifiImgVH)];
        wifiImgV.image = [UIImage imageNamed:@"ic-nowifi-dgray"];
        // wifiImgV.backgroundColor = [UIColor orangeColor];
        [wifiBg addSubview:wifiImgV];
        self.wifiImgV = wifiImgV;
        
        // WiFi详情
        float wifiLbH = 15;
        UILabel * wifiLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(wifiImgV.frame) + 5, (CGRectGetHeight(wifiBg.frame) - wifiLbH) / 2, headViewW, wifiLbH)];
        wifiLb.text = @"当前是非WiFi环境，无法使用投屏功能";
        wifiLb.font = [UIFont systemFontOfSize:12];
        wifiLb.textColor = [UIColor blackColor];
        wifiLb.textAlignment = NSTextAlignmentLeft;
        [wifiBg addSubview:wifiLb];
        self.wifiNameLb = wifiLb;
    }
    return _headView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - Cell_height, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - Cell_height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = Cell_height;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableHeaderView = self.headView;
        _tableView.separatorInset = UIEdgeInsetsMake(0, CellFrontSpace, 0, 0);

        [_tableView registerClass:[PLVCastTipsCell class] forCellReuseIdentifier:@"tipsCellID"];
        [_tableView registerClass:[PLVCastDeviceCell class] forCellReuseIdentifier:@"deviceCellID"];
        [_tableView registerClass:[PLVSearchCastNetCell class] forCellReuseIdentifier:@"castingCellID"];
        
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

#pragma mark - ----------------- < TableView Delegate > -----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.dataArr removeAllObjects];
    
    if (self.showTips) { // 展示提示
        [self.dataArr addObject:self.tipsModel];
    }
    
    if (self.showSearching) { // 展示搜索中
        [self.dataArr addObject:self.searchingModel];
    }
    
    if (self.devicesArr.count > 0) { // 展示设备信息
        [self.dataArr addObjectsFromArray:self.devicesArr];
    }
    
    if (self.showAirPlayOption) { // 展示AirPlay
        [self.dataArr addObject:self.airPlayModel];
    }
    
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * tipsCellID = @"tipsCellID";
    static NSString * deviceCellID = @"deviceCellID";
    static NSString * castingCellID = @"castingCellID";
    
    PLVCastFatherCell * cell;
    PLVCastCellInfoModel * m = self.dataArr[indexPath.row];
    
    UIColor * textColor = self.landsOrVer ? [UIColor whiteColor] : [UIColor blackColor];
    
    if (m.type == PLVCastCellType_Tips) { // 提示
        
        cell = [tableView dequeueReusableCellWithIdentifier:tipsCellID];
        if (cell == nil) cell = [[PLVCastTipsCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipsCellID];
        
        cell.textLabel.text = m.tips;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = textColor;
        
    }else if(m.type == PLVCastCellType_Device || m.type == PLVCastCellType_AirPlay){ // 设备 或 AirPlay
        
        cell = [tableView dequeueReusableCellWithIdentifier:deviceCellID];
        if (cell == nil) cell = [[PLVCastDeviceCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:deviceCellID];
        
        cell.textLabel.text = m.deviceName;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (m.isConnecting == YES) {
            textColor = [UIColor colorWithRed:49/255.0 green:173/255.0 blue:254/255.0 alpha:1.0];
        }
        cell.textLabel.textColor = textColor;

        UIImage * img = nil;
        if (m.type == PLVCastCellType_AirPlay) {
            if (self.landsOrVer) img = [UIImage imageNamed:@"ic-airplay-w"];
            else img = [UIImage imageNamed:@"ic-airplay-dgray"];
        }else{
            img = nil;
        }
        cell.imageView.image = img;

    }else if (m.type == PLVCastCellType_Searching){ // 搜索
        
        cell = [tableView dequeueReusableCellWithIdentifier:castingCellID];
        if (cell == nil) cell = [[PLVSearchCastNetCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:castingCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        PLVSearchCastNetCell * netCell = (PLVSearchCastNetCell *)cell;
        [netCell startIndicatorAnimation];
    }
    
    if (self.landsOrVer) {
        cell.backgroundColor = [UIColor clearColor];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.hideLine = NO;
    if (indexPath.row == self.dataArr.count - 1) {
        cell.hideLine = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PLVCastCellInfoModel * m = self.dataArr[indexPath.row];
    
    if (m.type == PLVCastCellType_Tips) return;     // 提示
    if (m.type == PLVCastCellType_Searching) return;// 搜索中
    
    if (m.type == PLVCastCellType_AirPlay) {        // AirPlay
        if (self.selectEvent) self.selectEvent(self, indexPath.row, m.type);
    }
    
    if (m.type == PLVCastCellType_Device){          // 设备
        [self clearSelectedDevice];
    }
    
    NSInteger oriIdx = indexPath.row;
    NSInteger resIdx = self.showTips ? (oriIdx - 1) : oriIdx;
    resIdx = self.showSearching ? (resIdx - 1) : resIdx;
    if (self.selectEvent) self.selectEvent(self, resIdx, m.type);
}

- (void)show
{
    [UIView animateWithDuration:.33 animations:^{
        CGRect rect = _tableView.frame;
        
        if (self.landsOrVer) { // 横屏
            rect.origin.x = (CGRectGetWidth(self.bounds) - tableViewWidthInLands);
        }else{                 // 竖屏
            rect.origin.y = CGRectGetHeight(self.bounds) - Cell_height - tableViewHeightInVer;
        }
        
        _tableView.frame = rect;
        
        self.alpha = 1;
        self.userInteractionEnabled = YES;
    }];
    
    self.isShow = YES;
}

- (void)dismiss
{
    [UIView animateWithDuration:.33 animations:^{
        [self dismissToHidden];
    } completion:^(BOOL finished) {

    }];
}

- (void)dismissToHidden{
    CGRect rect = _tableView.frame;
    if (self.landsOrVer) { // 横屏
        rect.origin.x = (CGRectGetWidth(self.bounds)) ;
    }else{                 // 竖屏
        rect.origin.y = CGRectGetHeight(self.bounds) - Cell_height;
    }
    
    _tableView.frame = rect;
    
    self.alpha = 0;
    self.userInteractionEnabled = NO;
    
    self.isShow = NO;
}

#pragma mark - ----------------- < Private Method > -----------------
- (void)setIsShow:(BOOL)isShow{
    if (self.listViewShowOrHideEvent) self.listViewShowOrHideEvent(isShow);
    _isShow = isShow;
}

#pragma mark - ----------------- < Open Method > -----------------
- (void)setLandsOrVer:(BOOL)landsOrVer{
    
    if (landsOrVer == YES) { // 横屏样式
        
        // 其他
        self.cancleBtn.hidden = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        // 颜色
        self.backgroundColor = [UIColor clearColor];
        self.headView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8];
        self.titleLb.textColor = [UIColor whiteColor];
        
        // icon
        [self.refreshBtn setImage:[UIImage imageNamed:@"btn-refresh-w"] forState:UIControlStateNormal];
        NSString * wifiImgString = _wifiName == nil ? @"ic-nowifi-lgray" : @"ic-wifi-lgray";
        self.wifiImgV.image = [UIImage imageNamed:wifiImgString];
        self.wifiNameLb.textColor = [UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0];
        self.wifiBg.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
        
    }else{                  // 竖屏样式
        
        // 其他
        self.cancleBtn.hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

        // 颜色
        self.backgroundColor = [UIColor clearColor];
        self.headView.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.titleLb.textColor = [UIColor blackColor];
        
        // icon
        [self.refreshBtn setImage:[UIImage imageNamed:@"btn-refresh-b"] forState:UIControlStateNormal];
        NSString * wifiImgString = _wifiName == nil ? @"ic-nowifi-dgray" : @"ic-wifi-dgray";
        self.wifiImgV.image = [UIImage imageNamed:wifiImgString];
        self.wifiNameLb.textColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0];
        self.wifiBg.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
    }
    _landsOrVer = landsOrVer;
    
    if (_isShow) {
        [self.tableView reloadData];
        self.alpha = 0.7;
        [UIView animateWithDuration:0.33 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)setShowTips:(BOOL)showTips{
    _showTips = showTips;
}

- (void)setShowAirPlayOption:(BOOL)showAirPlayOption{
    // 18-12-11 AirPlay放在下期做，本期默认一直是NO
    // _showAirPlayOption = showAirPlayOption;
    _showAirPlayOption = NO;
}

- (void)setShowSearching:(BOOL)showSearching{
    _showSearching = showSearching;
}

- (void)setWifiName:(NSString *)wifiName{
    if (wifiName == nil || [wifiName isKindOfClass: [NSString class]] == NO || wifiName.length == 0) {
        self.wifiNameLb.text = @"当前是非WiFi环境，无法使用投屏功能";
        if (self.landsOrVer) { // 横屏
            self.wifiImgV.image = [UIImage imageNamed:@"ic-nowifi-lgray"];
        }else{                 // 竖屏
            self.wifiImgV.image = [UIImage imageNamed:@"ic-nowifi-dgray"];
        }
        _wifiName = nil;
        return;
    }
    
    if (_wifiName != wifiName) {
        self.wifiNameLb.text = wifiName;
        if (self.landsOrVer) { // 横屏
            self.wifiImgV.image = [UIImage imageNamed:@"ic-wifi-lgray"];
        }else{                 // 竖屏
            self.wifiImgV.image = [UIImage imageNamed:@"ic-wifi-dgray"];
        }
        _wifiName = [wifiName copy];
    }
}

- (void)reloadList{
    [self.tableView reloadData];
}

- (void)reloadServicesListWithModelArray:(NSArray<PLVCastCellInfoModel *> *)modelArray{
    self.devicesArr = modelArray;
    [self.tableView reloadData];
}

- (void)refreshBtnClickToSelected:(BOOL)toSelected{
    if (self.refreshBtn.selected == toSelected) {
        return;
    }
    [self refreshBtnClick:self.refreshBtn];
}

- (void)startRefreshBtnRotate {
    self.refreshBtn.alpha = 0;
    self.refreshBtn.userInteractionEnabled = NO;
    self.refreshBtn.selected = YES;
    
    /*
    if ([self.refreshBtn.layer.animationKeys count] == 0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.repeatCount = MAXFLOAT;
        animation.beginTime = CACurrentMediaTime();
        animation.duration = 0.8;
        animation.fromValue = @(0.0);
        animation.toValue = @(2 * M_PI);
        animation.removedOnCompletion = NO;
        [self.refreshBtn.layer addAnimation:animation forKey:@"rotate"];
    }
    */
}

- (void)stopRefreshBtnRotate {
    self.refreshBtn.alpha = 1;
    self.refreshBtn.userInteractionEnabled = YES;
    self.refreshBtn.selected = NO;

    /*
    if ([self.refreshBtn.layer.animationKeys count] != 0) {
        [self.refreshBtn.layer removeAllAnimations];
    }
    */
}

- (void)clearSelectedDevice{
    if (self.devicesArr.count == 0) return;
    for (PLVCastCellInfoModel * m in self.devicesArr) {
        if (m.type == PLVCastCellType_Device) {
            if (m.isConnecting) {
                // 重置
                m.isConnecting = NO;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - ----------------- < Event > -----------------
- (void)cancleBtnClick:(UIButton *)btn{
    [self dismiss];
}

- (void)refreshBtnClick:(UIButton *)btn{
    if (self.refreshButtonClickEvent) {
        self.refreshButtonClickEvent(self, btn);
    };
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end


@implementation PLVCastCellInfoModel


@end


@implementation PLVCastFatherCell

- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = self.hideLine;
            break;
        }
    }
}

@end


@implementation PLVCastTipsCell


@end


@implementation PLVCastDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float imgh = 16;
    float imgw = 18;
    self.imageView.frame = CGRectMake(24, (CGRectGetHeight(self.bounds) - imgh) / 2, imgw, imgh);
}

@end


@implementation PLVSearchCastNetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    // 指示器
    UIActivityIndicatorView * indiV = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indiV.color = [UIColor grayColor];
    indiV.hidesWhenStopped = NO;
    CGAffineTransform transform = CGAffineTransformMakeScale(IndiViewScale, IndiViewScale);
    indiV.transform = transform;
    [self.contentView addSubview:indiV];
    [indiV startAnimating];
    self.indiV = indiV;
    
    // 提示
    UILabel * textLb = [[UILabel alloc]init];
    textLb.text = @"正在搜索设备";
    textLb.font = [UIFont systemFontOfSize:18];
    textLb.textColor = [UIColor lightGrayColor];
    textLb.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:textLb];
    self.textLb = textLb;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float indiVW = 28 * IndiViewScale;
    float textLbH = 30;
    self.indiV.center = CGPointMake(CellFrontSpace + indiVW / 2, CGRectGetHeight(self.bounds) / 2);
    self.textLb.frame = CGRectMake(CGRectGetMaxX(self.indiV.frame) + 5, (CGRectGetHeight(self.bounds) - textLbH) / 2, 150, 30);
}

- (void)startIndicatorAnimation{
    [self.indiV startAnimating];
}

@end

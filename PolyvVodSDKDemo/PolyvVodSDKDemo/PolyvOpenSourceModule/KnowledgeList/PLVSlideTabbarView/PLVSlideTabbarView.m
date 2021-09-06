//
//  PLVSlideTabbarView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVSlideTabbarView.h"
#import <PLVMasonry/PLVMasonry.h>
#import "UIColor+PLVVod.h"

@interface PLVSlideTabbarView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentView;
@property (nonatomic, strong) UIView *indexView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) NSMutableArray<UIButton *> *itemButtonArray;
@property (nonatomic, copy) NSMutableArray *itemTitleWidthArray;

@end


@implementation PLVSlideTabbarView

#pragma mark - Init & UI

- (instancetype)init
{
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithHex:0x222326];
    [self addSubview:self.closeButton];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollContentView];
    [self.scrollContentView addSubview:self.indexView];
    
    [self.closeButton plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.plv_equalTo(55);
    }];
    
    [self.scrollView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-55);
    }];
    
    [self.scrollContentView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
    
    [self.indexView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.height.plv_equalTo(2);
        make.width.plv_equalTo(46);
        make.bottom.equalTo(self.scrollContentView);
        make.centerX.equalTo(self.scrollContentView);
    }];
}

/// 重新设置Tabbar
- (void)rebuildTabbar {
    for (UIButton *itemButton in self.itemButtonArray) {
        [itemButton removeFromSuperview];
    }
    [self.itemButtonArray removeAllObjects];
    [self.itemTitleWidthArray removeAllObjects];
    
    CGFloat itemPadding = 20;
    CGFloat itemMarginLeft = 12;
    for (NSInteger i = 0; i < self.tabbarItemArray.count; i++) {
        NSString *title = self.tabbarItemArray[i];
        UIButton *itemButton = [self createButtonWithTitle:title];
        itemButton.tag = 100 + i;
        itemButton.selected = self.currentIndex == i;
        
        CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width;
        CGFloat itemWidth = titleWidth + 2 * itemPadding;
        
        [self.scrollContentView addSubview:itemButton];
        [itemButton plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.width.plv_equalTo(itemWidth);
            make.top.bottom.equalTo(self.scrollContentView);
            make.left.equalTo(self.scrollContentView).offset(itemMarginLeft);
            if (i == self.tabbarItemArray.count - 1) {
                make.right.equalTo(self.scrollContentView);
            }
        }];
        
        [itemButton addTarget:self action:@selector(clickItemAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.itemButtonArray addObject:itemButton];
        [self.itemTitleWidthArray addObject:[NSNumber numberWithFloat:titleWidth]];
        itemMarginLeft += itemWidth;
    }
    [self updateIndexView];
}

/// 更新indexView位置
- (void)updateIndexView {
    self.indexView.hidden = self.currentIndex >= self.itemButtonArray.count;
    if (self.currentIndex < self.itemButtonArray.count) {
        UIButton *item = self.itemButtonArray[self.currentIndex];
        CGFloat width = [self.itemTitleWidthArray[self.currentIndex] floatValue];
        
        [self.indexView plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.height.plv_equalTo(2);
            make.width.plv_equalTo(width);
            make.bottom.equalTo(self.scrollContentView);
            make.centerX.equalTo(item);
        }];
    }
}

/// 生成itemButton
/// @param title title
- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:0];
    UIColor *normalColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [button setTitleColor:normalColor forState:0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

#pragma mark - Setter

-(void)setTabbarItemArray:(NSArray<NSString *> *)tabbarItemArray {
    _tabbarItemArray = tabbarItemArray;
    [self rebuildTabbar];
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self updateIndexView];
}

#pragma mark - Action

/// 点击关闭按钮
- (void)clickCloseButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(plvSlideTabbarViewCloseButtonAction:)]) {
        [self.delegate plvSlideTabbarViewCloseButtonAction:self];
    }
}

/// 点击item
/// @param button item
- (void)clickItemAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    for (NSInteger i = 0; i < self.itemButtonArray.count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        itemButton.selected = i == index;
    }
    self.currentIndex = index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(plvSlideTabbarView:selectItemAtIndex:)]) {
        [self.delegate plvSlideTabbarView:self selectItemAtIndex:index];
    }
}

#pragma mark - Loadlazy

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (_scrollContentView == nil) {
        _scrollContentView = [[UIView alloc]init];
    }
    return _scrollContentView;
}

- (UIView *)indexView {
    if (_indexView == nil) {
        _indexView = [[UIView alloc]init];
        _indexView.backgroundColor = [UIColor colorWithHex:0x3990FF];
    }
    return _indexView;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"plv_white_close"] forState:0];
        [_closeButton addTarget:self action:@selector(clickCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (NSMutableArray<UIButton *> *)itemButtonArray {
    if (_itemButtonArray == nil) {
        _itemButtonArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _itemButtonArray;
}

- (NSMutableArray *)itemTitleWidthArray {
    if (_itemTitleWidthArray == nil) {
        _itemTitleWidthArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _itemTitleWidthArray;
}

@end

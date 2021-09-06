//
//  PLVSlideTabbarView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVSlideTabbarView;

@protocol PLVSlideTabbarViewDelegate <NSObject>
/// 选中一级分类的回调
- (void)plvSlideTabbarView:(PLVSlideTabbarView *)slideTabbarView selectItemAtIndex:(NSInteger)index;
/// 点击关闭按钮回调
- (void)plvSlideTabbarViewCloseButtonAction:(PLVSlideTabbarView *)slideTabbarView;
@end

/// 带有关闭按钮的分类tabbar视图
@interface PLVSlideTabbarView : UIView

/// 一级分类数组
@property (nonatomic, strong) NSArray<NSString *> *tabbarItemArray;

/// 当前选中序号
@property (nonatomic, assign) NSInteger currentIndex;

@property(nonatomic, weak) id<PLVSlideTabbarViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END

//
//  PLVVodOptimizeOptionsPanelView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/9.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVVodOptimizeOptionsPanelView;

@protocol PLVVodOptimizeOptionsPanelViewDelegate <NSObject>

@optional
/**
 * 解码方式选择回调
 * @param hardDecode YES: 硬解, NO: 软解
 */
- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectDecodeOption:(BOOL)hardDecode;

/**
 * 线路选择回调
 * @param lineIndex 线路索引, 0: 线路一, 1: 线路二  2:线路三
 */
- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectLineOption:(NSInteger)lineIndex;

/**
 * DNS解析方式选择回调
 * @param isHttpDns YES: httpDns, NO: localDns
 */
- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectDnsOption:(BOOL)isHttpDns;

@end

@interface PLVVodOptimizeOptionsPanelView : UIView

@property (nonatomic, weak) id<PLVVodOptimizeOptionsPanelViewDelegate> delegate;

/**
 * 显示面板
 */
- (void)show;

/**
 * 隐藏面板
 */
- (void)hide;

/**
 * 设置初始状态
 * @param hardDecode 是否硬解
 * @param lineIndex 线路索引
 * @param totalLine 总线路数
 * @param isHttpDns 是否使用httpDns
 */
- (void)setupWithHardDecode:(BOOL)hardDecode 
                  lineIndex:(NSInteger)lineIndex
                  totalLine:(NSInteger)totalLine
                  isHttpDns:(BOOL)isHttpDns;

@end

NS_ASSUME_NONNULL_END

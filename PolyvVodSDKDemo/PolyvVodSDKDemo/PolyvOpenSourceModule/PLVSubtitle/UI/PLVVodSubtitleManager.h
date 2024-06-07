//
//  PLVVodSubtitleManager.h
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodSubtitleItem.h"
#import "PLVVodSubtitleViewModel.h"

@interface PLVVodSubtitleManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<PLVVodSubtitleItem *> *subtitleItems;

@property (nonatomic, strong, readonly) NSMutableArray<PLVVodSubtitleItem *> *subtitleItems2;

// 仅底部字幕 单字幕模式
+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel error:(NSError **)error;

// 底部字幕+顶部字幕 单字幕模式
+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel error:(NSError **)error;

- (void)showSubtitleWithTime:(NSTimeInterval)time;

// 底部字幕+顶部字幕 单字幕模式支持样式自定义
+ (instancetype)managerWithSubtitle:(NSString *)subtitle style:(PLVVodSubtitleItemStyle *)style label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel error:(NSError **)error;

/// 底部+顶部字幕 支持单字幕/双字幕模式
///
/// @note 仅配置subtitle或者subtitle2时，字幕显示于label和topLabel
///       同时配置subtitle或者subtitle2时，字幕subtitle显示于label2和topLabel，字幕subtitle2显示于label和topLabel2
/// @param subtitle 字幕内容
/// @param style 字幕样式
/// @param label 底部字幕（下）
/// @param topLabel 顶部字幕（上）
/// @param subtitle2 第二份字幕内容
/// @param style2 字幕样式2
/// @param label2 底部字幕（上）
/// @param topLabel2 顶部字幕（下）
+ (instancetype)managerWithSubtitle:(NSString *)subtitle style:(PLVVodSubtitleItemStyle *)style error:(NSError **)error subtitle2:(NSString *)subtitle2 style2:(PLVVodSubtitleItemStyle *)style2  error2:(NSError **)error2 label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel label2:(UILabel *)subtitleLabel2 topLabel2:(UILabel *)subtitleTopLabel2;

@end

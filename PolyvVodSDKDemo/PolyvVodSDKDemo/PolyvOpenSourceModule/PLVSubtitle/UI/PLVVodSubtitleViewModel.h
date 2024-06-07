//
//  PLVVodSubtitleViewModel.h
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodSubtitleItem.h"

@interface PLVVodSubtitleItemStyle : NSObject

@property (nonatomic, strong) UIColor *textColor; // 字体颜色
@property (nonatomic, assign) BOOL bold; // 字体是否加粗
@property (nonatomic, assign) BOOL italic; // 字体是否
@property (nonatomic, strong) UIColor *backgroundColor; // 背景颜色

+ (instancetype)styleWithTextColor:(UIColor *)textColor bold:(BOOL)bold italic:(BOOL)italic backgroundColor:(UIColor *)backgroundColor;

@end

@interface PLVVodSubtitleViewModel : NSObject

@property (nonatomic, strong) PLVVodSubtitleItem *subtitleItem;
@property (nonatomic, strong) PLVVodSubtitleItem *subtitleAtTopItem;
@property (nonatomic, strong) PLVVodSubtitleItem *subtitleItem2;
@property (nonatomic, strong) PLVVodSubtitleItem *subtitleAtTopItem2;

@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleTopLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel2;
@property (nonatomic, weak) IBOutlet UILabel *subtitleTopLabel2;

@property (nonatomic, assign) BOOL enable;

@property (nonatomic, strong) PLVVodSubtitleItemStyle *subtitleItemStyle;
@property (nonatomic, strong) PLVVodSubtitleItemStyle *subtitleAtTopItemStyle;
@property (nonatomic, strong) PLVVodSubtitleItemStyle *subtitleItemStyle2;
@property (nonatomic, strong) PLVVodSubtitleItemStyle *subtitleAtTopItemStyle2;

- (void)setSubtitleLabel:(UILabel *)subtitleLabel style:(PLVVodSubtitleItemStyle *)style;
- (void)setSubtitleTopLabel:(UILabel *)subtitleTopLabel style:(PLVVodSubtitleItemStyle *)style;
- (void)setSubtitleLabel2:(UILabel *)subtitleLabel2 style:(PLVVodSubtitleItemStyle *)style;
- (void)setSubtitleTopLabel2:(UILabel *)subtitleTopLabel2 style:(PLVVodSubtitleItemStyle *)style;

@end

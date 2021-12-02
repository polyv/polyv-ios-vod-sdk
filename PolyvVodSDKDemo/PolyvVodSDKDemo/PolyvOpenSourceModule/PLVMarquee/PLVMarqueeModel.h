//
//  PLVMarqueeModel.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/3/3.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PLVMarqueeModelStyle) {
    /// 滚动（自屏幕右方至左方一直滚动）
    PLVMarqueeModelStyleRoll = 1,
    /// 闪烁（屏幕内随机位置闪烁）
    PLVMarqueeModelStyleFlash,
    /// 滚动+闪烁（自屏幕右方至左方一直滚动，渐隐渐现）
    PLVMarqueeModelStyleRollFade,
    /// 局部滚动（上下15%的视频区域之间滚动）
    PLVMarqueeModelStylePartRoll,
    /// 局部闪烁（上下15%的视频区域随机闪烁文字）
    PLVMarqueeModelStylePartFlash,
    /// 滚动（自屏幕右方至左方一直滚动）双跑马灯
    PLVMarqueeModelStyleDoubleRoll,
    /// 闪烁（屏幕内随机位置闪烁））双跑马灯
    PLVMarqueeModelStyleDoubleFlash,
};

/// 负责定义跑马灯样式和动画
@interface PLVMarqueeModel : NSObject

/// 跑马灯样式
@property (nonatomic, assign) PLVMarqueeModelStyle style;

#pragma mark - 内容属性

/// 跑马灯内容，默认”Polyv跑马灯“
@property (nonatomic, strong) NSString *content;
/// 字体大小，默认30
@property (nonatomic, assign) NSUInteger fontSize;
/// 字体颜色，默认#000000
@property (nonatomic, strong) NSString *fontColor;
/// 自定义播放错误提示信息（跑马灯校验失败）
@property (nonatomic, strong) NSString *errorMessage;


#pragma mark - 描边属性

/// 是否描边，默认NO
@property (nonatomic, assign) BOOL outline;
/// 描边颜色，默认#000000
@property (nonatomic, strong) NSString *outlineColor;
/// 阴影透明度，（范围：0~1），默认1
@property (nonatomic, assign) float shadowAlpha;
/// 阴影半径，默认4
@property (nonatomic, assign) NSUInteger shadowBlurRadius;
/// 阴影水平偏移量，默认2
@property (nonatomic, assign) NSUInteger shadowOffsetX;
/// 描边垂直偏移量.默认2
@property (nonatomic, assign) NSUInteger shadowOffsetY;


#pragma mark - 动画相关属性

/// 文本透明度（范围：0~1），默认1
@property (nonatomic, assign) float alpha;
/// 双跑马灯中，第二个跑马灯的文本透明度（范围：0~1），默认0.02
@property (nonatomic, assign) float secondMarqueeAlpha;
/// 文本渐隐渐现时间 (单位：秒)，默认1，有效样式：Flash、PartFlash、DoubleFlash、RollFade
@property (nonatomic, assign) NSUInteger tweenTime;
/// 文本隐藏间隔时间 (单位：秒)，默认5，有效样式：Flash、PartFlash、DoubleFlash
@property (nonatomic, assign) NSUInteger interval;
/// 文本显示时间 (单位：秒)，默认3，有效样式：Flash、PartFlash、DoubleFlash
@property (nonatomic, assign) NSUInteger lifeTime;
/// 文字移动指定像素所需时间/显示时间（单位：秒），默认20，有效样式：Roll、RollFade、PartRoll、DoubleRoll
@property (nonatomic, assign) NSUInteger speed;


/// 暂停跑马灯的时候，是否隐藏。默认为YES
@property (nonatomic, assign) BOOL isHiddenWhenPause;
/// 跑马灯运行的时候，是否一直完整显示跑马灯。为YES时interval不生效。默认为NO
@property (nonatomic, assign) BOOL isAlwaysShowWhenRun;



/// 初始化最简单的跑马灯样式model
/// @param content 跑马灯内容
/// @param fontSize 字体大小
/// @param fontColor 字体颜色（0x000000）
/// @param alpha 文本透明度（范围：0~1）
+(instancetype)createMarqueeModelWithContent:(NSString *)content
                                    fontSize:(NSUInteger)fontSize
                                   fontColor:(NSString *)fontColor
                                       alpha:(float)alpha;

/// 初始化跑马灯样式model（适用于自定义url方式获取的跑马灯数据转换为model）
/// @param marqueeDict 跑马灯数据
+(instancetype)createMarqueeModelWithMarqueeDict:(NSDictionary *)marqueeDict;


#pragma mark - 生成跑马灯描述

/// 根据模型内容生成描述跑马灯的富文本
-(NSAttributedString *)createMarqueeAttributedContent;

/// 根据富文本内容计算size
-(CGSize)marqueeAttributedContentSize;


@end

NS_ASSUME_NONNULL_END

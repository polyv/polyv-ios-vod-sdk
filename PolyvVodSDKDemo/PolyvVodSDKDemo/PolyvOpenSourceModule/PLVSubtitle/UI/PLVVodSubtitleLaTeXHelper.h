//
//  PLVVodSubtitleLaTeXHelper.h
//  PLVVodSubtitleDemo
//
//  Created by Dhan on 2025/7/3.
//  Copyright © 2025年 PLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodSubtitleLaTeXHelper : NSObject

/**
 * 检查是否支持LaTeX渲染
 * @return 如果项目中引入了iosMath则返回YES，否则返回NO
 */
+ (BOOL)isLaTeXSupported;

/**
 * 将包含LaTeX公式的文本转换为富文本
 * @param text 原始文本，可能包含$...$格式的LaTeX公式
 * @param font 普通文本的字体
 * @param textColor 普通文本的颜色
 * @param mathFontSize LaTeX公式的字体大小
 * @param mathColor LaTeX公式的颜色
 * @return 包含LaTeX渲染的富文本
 */
+ (NSAttributedString *)attributedStringWithText:(NSString *)text
                                           font:(UIFont *)font
                                      textColor:(UIColor *)textColor
                                   mathFontSize:(CGFloat)mathFontSize
                                      mathColor:(UIColor *)mathColor;

@end

NS_ASSUME_NONNULL_END 

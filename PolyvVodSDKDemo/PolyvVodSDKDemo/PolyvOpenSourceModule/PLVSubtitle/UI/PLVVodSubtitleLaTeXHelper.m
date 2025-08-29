//
//  PLVVodSubtitleLaTeXHelper.m
//  PLVVodSubtitleDemo
//
//  Created by Dhan on 2025/7/3.
//  Copyright © 2025年 PLY. All rights reserved.
//

#import "PLVVodSubtitleLaTeXHelper.h"

// 检查是否引入了iosMath
#if __has_include(<MTMathUILabel.h>)
#import <MTMathUILabel.h>
#define HAS_IOSMATH 1
#else
#define HAS_IOSMATH 0
#endif

@interface PLVVodSubtitleLaTeXHelper ()

@end

@implementation PLVVodSubtitleLaTeXHelper

#pragma mark - Public Methods

+ (BOOL)isLaTeXSupported {
    return HAS_IOSMATH;
}

+ (NSAttributedString *)attributedStringWithText:(NSString *)text
                                           font:(UIFont *)font
                                      textColor:(UIColor *)textColor
                                   mathFontSize:(CGFloat)mathFontSize
                                      mathColor:(UIColor *)mathColor {
    if (!text || text.length == 0) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    // 如果不支持LaTeX，直接返回普通文本
    if (![self isLaTeXSupported]) {
        return [[NSAttributedString alloc] initWithString:text attributes:@{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        }];
    }
    
    // 解析文本，分离普通文本和LaTeX公式
    NSArray *segments = [self parseTextSegments:text];
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    for (NSDictionary *segment in segments) {
        NSString *type = segment[@"type"];
        NSString *content = segment[@"content"];
        
        if ([type isEqualToString:@"latex"]) {
            NSAttributedString *mathAttributedString = [self createMathAttributedString:content
                                                                              fontSize:mathFontSize
                                                                                 color:mathColor];
            [result appendAttributedString:mathAttributedString];
        } else {
            // 处理普通文本
            NSAttributedString *textAttributedString = [[NSAttributedString alloc] initWithString:content attributes:@{
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: textColor
            }];
            [result appendAttributedString:textAttributedString];
        }
    }
    
    return [result copy];
}

#pragma mark - Private Methods

/**
 * 解析文本，分离普通文本和LaTeX公式
 * @param text 原始文本
 * @return 分段数组，每个元素包含type和content
 */
+ (NSArray *)parseTextSegments:(NSString *)text {
    NSMutableArray *segments = [NSMutableArray array];
    
    // 只匹配$...$格式的LaTeX公式
    NSArray *dollarMatches = [self findDollarMatches:text];
    // 只匹配\(...\)格式的LaTeX公式
    NSArray *backslashParenthesisMatches = [self findBackslashParenthesisMatches:text];
    
    // 合并所有匹配结果，按位置排序
    NSMutableArray *allMatches = [NSMutableArray array];
    [allMatches addObjectsFromArray:dollarMatches];
    [allMatches addObjectsFromArray:backslashParenthesisMatches];
    
    // 按位置排序
    [allMatches sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSNumber *pos1 = obj1[@"start"];
        NSNumber *pos2 = obj2[@"start"];
        return [pos1 compare:pos2];
    }];
    
    if (allMatches.count == 0) {
        // 没有LaTeX公式，整个文本都是普通文本
        [segments addObject:@{
            @"type": @"text",
            @"content": text
        }];
        return segments;
    }
    
    NSUInteger lastEnd = 0;
    
    for (NSDictionary *match in allMatches) {
        NSNumber *startPos = match[@"start"];
        NSNumber *endPos = match[@"end"];
        NSString *content = match[@"content"];
        NSString *format = match[@"format"];
        
        // 添加LaTeX公式前的普通文本
        if (startPos.unsignedIntegerValue > lastEnd) {
            NSString *textBefore = [text substringWithRange:NSMakeRange(lastEnd, startPos.unsignedIntegerValue - lastEnd)];
            if (textBefore.length > 0) {
                [segments addObject:@{
                    @"type": @"text",
                    @"content": textBefore
                }];
            }
        }
        
        // 添加LaTeX公式
        [segments addObject:@{
            @"type": @"latex",
            @"content": content,
            @"format": format
        }];
        
        lastEnd = endPos.unsignedIntegerValue;
    }
    
    // 添加最后一个LaTeX公式后的普通文本
    if (lastEnd < text.length) {
        NSString *textAfter = [text substringFromIndex:lastEnd];
        if (textAfter.length > 0) {
            [segments addObject:@{
                @"type": @"text",
                @"content": textAfter
            }];
        }
    }
    
    return segments;
}

/**
 * 查找$...$格式的LaTeX公式
 */
+ (NSArray *)findDollarMatches:(NSString *)text {
    NSMutableArray *matches = [NSMutableArray array];
    
    NSString *pattern = @"\\$([^$]+)\\$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    
    NSArray *regexMatches = [regex matchesInString:text
                                           options:0
                                             range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in regexMatches) {
        NSRange contentRange = [match rangeAtIndex:1];
        NSString *content = [text substringWithRange:contentRange];
        
        [matches addObject:@{
            @"start": @(match.range.location),
            @"end": @(match.range.location + match.range.length),
            @"content": content,
            @"format": @"dollar"
        }];
    }
    
    return matches;
}

/**
 * 查找\(...\)格式的LaTeX公式（反斜杠+括号）
 */
+ (NSArray *)findBackslashParenthesisMatches:(NSString *)text {
    NSMutableArray *matches = [NSMutableArray array];
    
    // 匹配\(...\)格式的LaTeX公式
    // 使用非贪婪匹配，避免匹配多个连续的公式
    NSString *pattern = @"\\\\\\(([^)]*?)\\\\\\)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    
    NSArray *regexMatches = [regex matchesInString:text
                                           options:0
                                             range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in regexMatches) {
        NSRange contentRange = [match rangeAtIndex:1];
        NSString *content = [text substringWithRange:contentRange];
        
        [matches addObject:@{
            @"start": @(match.range.location),
            @"end": @(match.range.location + match.range.length),
            @"content": content,
            @"format": @"backslash_parenthesis"
        }];
    }
    
    return matches;
}

/**
 * 创建LaTeX公式的富文本
 * @param latexContent LaTeX公式内容
 * @param fontSize 字体大小
 * @param color 颜色
 * @return 富文本
 */
+ (NSAttributedString *)createMathAttributedString:(NSString *)latexContent
                                         fontSize:(CGFloat)fontSize
                                            color:(UIColor *)color {
#if HAS_IOSMATH
    @try {
        // 预处理LaTeX内容，修复常见问题
        NSString *processedLatex = [self preprocessLatexContent:latexContent];
        
        // 创建MTMathUILabel来渲染LaTeX
        MTMathUILabel *mathLabel = [[MTMathUILabel alloc] init];
        mathLabel.fontSize = fontSize;
        mathLabel.textColor = color;
        mathLabel.latex = processedLatex;
        
        // 计算LaTeX标签的大小
        [mathLabel sizeToFit];
        
        // 确保有有效的大小
        if (mathLabel.bounds.size.width <= 0 || mathLabel.bounds.size.height <= 0) {
            // 如果渲染失败，返回原始文本
            return [[NSAttributedString alloc] initWithString:latexContent];
        }
        
        // 将MTMathUILabel转换为图片
        UIGraphicsBeginImageContextWithOptions(mathLabel.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            // 保存当前上下文状态
            CGContextSaveGState(context);
            
            // 翻转坐标系（iOS的坐标系与Core Graphics不同）
            CGContextTranslateCTM(context, 0, mathLabel.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            [mathLabel.layer renderInContext:context];
            
            // 恢复上下文状态
            CGContextRestoreGState(context);
            
            UIImage *mathImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (mathImage) {
                // 创建图片附件
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = mathImage;
                attachment.bounds = CGRectMake(0, -2, mathImage.size.width, mathImage.size.height); // 微调垂直对齐
                
                return [NSAttributedString attributedStringWithAttachment:attachment];
            }
        }
        UIGraphicsEndImageContext();
    } @catch (NSException *exception) {
        NSLog(@"LaTeX渲染异常: %@", exception.reason);
    }
    
    // 如果渲染失败，返回原始文本
    return [[NSAttributedString alloc] initWithString:latexContent];
#else
    // 如果不支持LaTeX，返回原始文本
    return [[NSAttributedString alloc] initWithString:latexContent];
#endif
}

/**
 * 预处理LaTeX内容，修复常见问题
 * @param latexContent 原始LaTeX内容
 * @return 处理后的LaTeX内容
 */
+ (NSString *)preprocessLatexContent:(NSString *)latexContent {
    if (!latexContent || latexContent.length == 0) {
        return latexContent;
    }
    
    NSString *processed = latexContent;
    
    // 1. 智能修复双反斜杠转义问题
    // 只修复真正的双反斜杠，保留LaTeX命令中的单反斜杠
    // 例如：\\gt -> \gt (保留LaTeX命令) 但是 \\\\ -> \\ (修复转义)
    processed = [self smartFixBackslashes:processed];
    
    // 2. 矩阵处理 - 直接交给iOSMath处理，只修复转义问题
    // 将矩阵中的双反斜杠转换为单反斜杠，让iOSMath自己处理矩阵语法
    
    // 处理 pmatrix 格式
    if ([processed containsString:@"\\begin{pmatrix}"]) {
        processed = [self processMatrix:processed beginTag:@"\\begin{pmatrix}" endTag:@"\\end{pmatrix}"];
    }
    
    // 处理 bmatrix 格式
    if ([processed containsString:@"\\begin{bmatrix}"]) {
        processed = [self processMatrix:processed beginTag:@"\\begin{bmatrix}" endTag:@"\\end{bmatrix}"];
    }
    
    // 3. 修复其他常见问题
    // 替换不支持的积分符号
    processed = [processed stringByReplacingOccurrencesOfString:@"\\int" withString:@"∫"];
    
    // 替换不支持的无穷符号
    processed = [processed stringByReplacingOccurrencesOfString:@"\\infty" withString:@"∞"];
    
    // 替换不支持的箭头
    processed = [processed stringByReplacingOccurrencesOfString:@"\\to" withString:@"→"];
    
    // 4. 修复极限符号
    processed = [processed stringByReplacingOccurrencesOfString:@"\\lim" withString:@"lim"];
    
    // 5. 修复比较符号 - iosMath可能不支持\gt等命令
    processed = [processed stringByReplacingOccurrencesOfString:@"\\gt" withString:@">"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\lt" withString:@"<"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\ge" withString:@"≥"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\le" withString:@"≤"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\neq" withString:@"≠"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\approx" withString:@"≈"];
    processed = [processed stringByReplacingOccurrencesOfString:@"\\equiv" withString:@"≡"];
    
    return processed;
}

/**
 * 处理矩阵内容，修复转义问题
 * @param text 包含矩阵的文本
 * @param beginTag 矩阵开始标签
 * @param endTag 矩阵结束标签
 * @return 处理后的文本
 */
+ (NSString *)processMatrix:(NSString *)text beginTag:(NSString *)beginTag endTag:(NSString *)endTag {
    NSString *processed = text;
    
    // 只处理矩阵内的转义问题，不改变矩阵结构
    NSRange beginRange = [processed rangeOfString:beginTag];
    NSRange endRange = [processed rangeOfString:endTag];
    
    if (beginRange.location != NSNotFound && endRange.location != NSNotFound) {
        NSRange contentRange = NSMakeRange(beginRange.location + beginRange.length, 
                                          endRange.location - beginRange.location - beginRange.length);
        NSString *matrixContent = [processed substringWithRange:contentRange];
        
        // 只修复矩阵内容中的转义问题
        NSString *processedMatrixContent = [matrixContent stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        
        // 保持原始矩阵结构，只替换内容
        NSString *processedMatrix = [NSString stringWithFormat:@"%@%@%@", beginTag, processedMatrixContent, endTag];
        
        // 替换整个矩阵
        NSString *originalMatrix = [processed substringWithRange:NSMakeRange(beginRange.location, 
                                                                            endRange.location + endRange.length - beginRange.location)];
        processed = [processed stringByReplacingOccurrencesOfString:originalMatrix withString:processedMatrix];
    }
    
    return processed;
}

/**
 * 智能修复反斜杠转义问题
 * 只修复真正的双反斜杠，保留LaTeX命令中的单反斜杠
 * @param text 原始文本
 * @return 处理后的文本
 */
+ (NSString *)smartFixBackslashes:(NSString *)text {
    if (!text || text.length == 0) {
        return text;
    }
    
    NSString *processed = text;
    
    // 定义常见的LaTeX命令，这些命令中的反斜杠应该保留
    NSArray *latexCommands = @[
        @"\\gt", @"\\lt", @"\\ge", @"\\le", @"\\neq", @"\\approx", @"\\equiv",
        @"\\alpha", @"\\beta", @"\\gamma", @"\\delta", @"\\epsilon", @"\\zeta",
        @"\\eta", @"\\theta", @"\\iota", @"\\kappa", @"\\lambda", @"\\mu",
        @"\\nu", @"\\xi", @"\\pi", @"\\rho", @"\\sigma", @"\\tau", @"\\upsilon",
        @"\\phi", @"\\chi", @"\\psi", @"\\omega",
        @"\\frac", @"\\sqrt", @"\\sum", @"\\int", @"\\lim", @"\\infty",
        @"\\to", @"\\leftarrow", @"\\rightarrow", @"\\Leftarrow", @"\\Rightarrow",
        @"\\begin", @"\\end", @"\\matrix", @"\\pmatrix", @"\\bmatrix",
        @"\\vmatrix", @"\\Vmatrix", @"\\array", @"\\cases", @"\\align",
        @"\\gather", @"\\multline", @"\\split", @"\\aligned", @"\\gathered",
        @"\\alignedat", @"\\gathered", @"\\split", @"\\substack", @"\\subarray",
        @"\\text", @"\\mathrm", @"\\mathbf", @"\\mathit", @"\\mathcal",
        @"\\mathbb", @"\\mathfrak", @"\\mathscr", @"\\mathsf", @"\\mathtt",
        @"\\hat", @"\\bar", @"\\vec", @"\\dot", @"\\ddot", @"\\dddot",
        @"\\widetilde", @"\\widehat", @"\\overleftarrow", @"\\overrightarrow",
        @"\\overleftrightarrow", @"\\overline", @"\\underline", @"\\overbrace",
        @"\\underbrace", @"\\overset", @"\\underset"
    ];
    
    // 先保护LaTeX命令，避免被误处理
    NSMutableDictionary *commandMap = [NSMutableDictionary dictionary];
    NSInteger commandIndex = 0;
    
    for (NSString *command in latexCommands) {
        NSString *placeholder = [NSString stringWithFormat:@"__LATEX_COMMAND_%ld__", (long)commandIndex];
        commandMap[placeholder] = command;
        processed = [processed stringByReplacingOccurrencesOfString:command withString:placeholder];
        commandIndex++;
    }
    
    // 现在安全地修复双反斜杠转义
    processed = [processed stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    // 恢复LaTeX命令
    for (NSString *placeholder in commandMap) {
        NSString *command = commandMap[placeholder];
        processed = [processed stringByReplacingOccurrencesOfString:placeholder withString:command];
    }
    
    return processed;
}

@end 

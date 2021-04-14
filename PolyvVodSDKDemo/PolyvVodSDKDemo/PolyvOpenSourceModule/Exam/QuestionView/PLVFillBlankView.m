//
//  PLVFillBlankView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/1/28.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVFillBlankView.h"
#import <CoreText/CoreText.h>

#define kFillString @"_"    //!< 填空符

@interface PLVFillBlankView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *fillRangeArray;   //!< 填空符范围数组（可根据输入长度变化）
@property (nonatomic, strong) NSMutableArray *originalFillRangeArray;    //!< 原来的填空符范围数组（不变）

@property (nonatomic, strong) NSMutableArray *textfieldArray;   //!< 生成的输入框数组

@end

@implementation PLVFillBlankView
#pragma mark - Init

-(instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.questionColor = [UIColor blackColor];
    self.fillColor = [UIColor blackColor];
    self.questionFontSize = 18.0f;
    self.fillFontSize = 15.0f;
    self.fillRangeArray = [NSMutableArray arrayWithCapacity:1];
    self.originalFillRangeArray = [NSMutableArray arrayWithCapacity:1];
    self.textfieldArray = [NSMutableArray arrayWithCapacity:1];
}

-(void)layoutSubviews
{
    //自身的frame改变，就要重绘
    if (self.questionString) {
        //处理填空符超出一行的情况
        _questionString = [self regularFillOverQuestionText:_questionString];
        //查找处理过后字符串的填空符范围
        self.fillRangeArray = [self searchFillRangeWithString:_questionString];
        //计算高度，并回调
        [self calculateFillBlankViewHeightCallback];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Action
/// 计算填空题view高度，并回调
-(void)calculateFillBlankViewHeightCallback
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 24;
    paragraphStyle.minimumLineHeight = 24;
    CGFloat fillHeight = [self.questionString boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.questionFontSize], NSParagraphStyleAttributeName : paragraphStyle} context:nil].size.height;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, fillHeight);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fillBlankView:didChangeHeight:)]) {
        [self.delegate fillBlankView:self didChangeHeight:fillHeight];
    }
}

#pragma mark - Setter

-(void)setQuestionString:(NSString *)questionString
{
    //给填空符前后添加空格，当填空符前后有英文的时候系统会把填空符和英文看作一个单词，从而导致换行问题
    questionString = [self regularLineBreakQuestionText:questionString];
    //处理填空符超出一行的情况
    questionString = [self regularFillOverQuestionText:questionString];
    //处理填空符低于3个的情况
//    questionString = [self regularFillLowerQuestionText:questionString];
    //查找处理过后字符串的填空符范围
    self.fillRangeArray = [self searchFillRangeWithString:questionString];
    self.originalFillRangeArray = [self.fillRangeArray mutableCopy];
    
    if (self.textfieldArray.count) {
        for (UITextField *oldTextfield in self.textfieldArray) {
            [oldTextfield removeFromSuperview];
        }
        [self.textfieldArray removeAllObjects];
    }
    
    self.textfieldArray = [self createTextfieldWithCount:self.fillRangeArray.count];
    _questionString = questionString;
    [self calculateFillBlankViewHeightCallback];
    [self setNeedsDisplay];
}

-(void)setQuestionColor:(UIColor *)questionColor
{
    _questionColor = questionColor;
    [self setNeedsDisplay];
}

-(void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    if (self.textfieldArray.count) {
        for (UITextField *input in self.textfieldArray) {
            input.textColor = fillColor;
        }
    }
}

-(void)setQuestionFontSize:(CGFloat)questionFontSize
{
    _questionFontSize = questionFontSize;
    [self setNeedsDisplay];
}

-(void)setFillFontSize:(CGFloat)fillFontSize
{
    _fillFontSize = fillFontSize;
    if (self.textfieldArray.count) {
        for (UITextField *input in self.textfieldArray) {
            input.font = [UIFont systemFontOfSize:fillFontSize];
        }
    }
}

#pragma mark - Draw

-(void)drawRect:(CGRect)rect
{
    if (self.questionString
        && self.questionString.length > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.backgroundColor setFill];
        CGContextFillRect(context, rect);
        //翻转坐标系步骤
        //设置当前文本矩阵
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        //文本沿y轴移动
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        //文本翻转成为CoreText坐标系
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //获取NSMutableAttributedString
        NSMutableAttributedString *attributedString = [self buildAttributedStringWithTag];
        //根据AttString生成CTFramesetterRef
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
        
        //创建绘制区域
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        CGPathAddRect(path, NULL, bounds);
        
        //绘制文本
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter,CFRangeMake(0, 0), path, NULL);
        CTFrameDraw(ctFrame, context);
        
        //获取CTLine数组
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        CGPoint lineOrigins[CFArrayGetCount(lines)];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
        //遍历每一个CTline
        for (int i = 0; i < CFArrayGetCount(lines); i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            
            //遍历每一个CTRunRef
            for (int j = 0; j < CFArrayGetCount(runs); j++) {
                CGPoint lineOrigin = lineOrigins[i];
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
                const CGPoint *point = CTRunGetPositionsPtr(run);
                
                //找到标记，添加自定义控件
                NSString *attributeName = [attributes objectForKey:@"PLVCoreTextDataName"];
                if ([attributeName containsString:@"input_"]) {
                    // 计算输入框frame
                    NSInteger rangeIndex = [[attributeName componentsSeparatedByString:@"_"][1] integerValue];
                    
                    if (rangeIndex < self.textfieldArray.count) {
                        NSRange range = NSRangeFromString(self.fillRangeArray[rangeIndex]);
                        NSInteger count = range.length > 2 ? range.length - 2 : range.length;
                        CGFloat textfieldWidth = [self calculateWidthWithFillCount:count];
                        CGRect textFieldFrame = CGRectMake(point[0].x + 5, self.frame.size.height - lineOrigin.y - self.questionFontSize, textfieldWidth, self.questionFontSize);
                        
                        UITextField *textfield = self.textfieldArray[rangeIndex];
                        textfield.hidden = NO;
                        textfield.frame = textFieldFrame;
                    }
                }
            }
        }
            
        CFRelease(ctFrame);
        CFRelease(path);
        CFRelease(ctFramesetter);
    }
    else {
        [super drawRect:rect];
    }
}


#pragma mark - UITextField delagate

-(void)textFieldDidChange:(UITextField *)textField
{
    NSInteger index = textField.tag - 100;
    NSString *str = textField.text;
    if (textField.text.length > 200) {
        str = [textField.text substringWithRange:NSMakeRange(0, 200)];
        textField.text = str;
    }
    
    CGFloat width = [str boundingRectWithSize:CGSizeMake(1000, self.fillFontSize) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fillFontSize]} context:nil].size.width;
    
    //填满输入框文字，需要多少个填空符
    NSInteger needCount = [self calculateFillCountForfullWidth:width];
    //生成的填空符需要比输入框多两个单位长度
    NSInteger numTotal = needCount + 2;
    //填满一行需要多少个填空符
    NSInteger fullCount = [self calculateFillCountForfullWidth:self.bounds.size.width];
    //填空符不能超出一行
    numTotal = numTotal > fullCount ? fullCount : numTotal;
    //填空符不能低于3个
    numTotal = numTotal < 3 ? 3 : numTotal;
    
    NSRange fillRange = NSRangeFromString(self.fillRangeArray[index]);
    NSRange oldFillRange = NSRangeFromString(self.originalFillRangeArray[index]);
    
    if (numTotal >= oldFillRange.length) {
        NSString *fillStr = [self createFillStringWithCount:numTotal];
        _questionString = [self.questionString stringByReplacingCharactersInRange:fillRange withString:fillStr];
        self.fillRangeArray = [self searchFillRangeWithString:self.questionString];
        
        //计算高度，并回调
        [self calculateFillBlankViewHeightCallback];
        
        [self setNeedsDisplay];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fillBlankView:textFieldShouldBeginEditingBlock:)]) {
        [self.delegate fillBlankView:self textFieldShouldBeginEditingBlock:textField];
    }
    return YES;
}

#pragma mark - Tool Method

/// 整理原来的字符串，给填空符前后添加空格，当填空符前后有英文的时候系统会把填空符和英文看作一个单词，从而导致换行问题
/// @param questionText 原字符串
-(NSString *)regularLineBreakQuestionText:(NSString *)questionText
{
    //原字符串填空符的范围
    NSMutableArray *rangeArray = [self searchFillRangeWithString:questionText];
    
    for (NSInteger i = rangeArray.count - 1; i >= 0; i--) {
        NSRange range = NSRangeFromString(rangeArray[i]);
        NSString *rangeString = [questionText substringWithRange:range];
        NSString *dealString = [[NSString alloc]initWithFormat:@" %@ ",rangeString];
        questionText = [questionText stringByReplacingCharactersInRange:range withString:dealString];
    }
    return questionText;
}

/// 整理原来的字符串，需求是填空符长度不能超出一行
/// @param questionText 原字符串
-(NSString *)regularFillOverQuestionText:(NSString *)questionText
{
    //填满一行需要的填空符个数
    NSInteger fullIndex = [self calculateFillCountForfullWidth:self.bounds.size.width];
    
    //原字符串填空符的范围
    NSMutableArray *rangeArray = [self searchFillRangeWithString:questionText];
    //填空符超出一行的范围
    NSMutableArray *overRange = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *rangeStr in rangeArray) {
        NSRange range = NSRangeFromString(rangeStr);
        if (range.length > fullIndex) {
            [overRange addObject:rangeStr];
        }
    }
    if (overRange.count > 0) {
        //超出一行的填空符，用一行代替
        //填满一行的填空符
        NSString *fullFillStr = [self createFillStringWithCount:fullIndex];
        for (NSInteger i = overRange.count - 1; i >= 0; i--) {
            NSRange range = NSRangeFromString(overRange[i]);
            questionText = [questionText stringByReplacingCharactersInRange:range withString:fullFillStr];
        }
    }
    return questionText;
}

/// 整理原来的字符串，需求是填空符长度不能低于3个
/// @param questionText 原字符串
-(NSString *)regularFillLowerQuestionText:(NSString *)questionText
{
    //原字符串填空符的范围
    NSMutableArray *rangeArray = [self searchFillRangeWithString:questionText];
    //填空符低于3个的范围
    NSMutableArray *lowerRange = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *rangeStr in rangeArray) {
        NSRange range = NSRangeFromString(rangeStr);
        if (range.length < 3) {
            [lowerRange addObject:rangeStr];
        }
    }
    if (lowerRange.count > 0) {
        //低于3个的填空符，用3个填空符代替
        NSString *threeFillStr = [self createFillStringWithCount:3];
        for (NSInteger i = lowerRange.count - 1; i >= 0; i--) {
            NSRange range = NSRangeFromString(lowerRange[i]);
            questionText = [questionText stringByReplacingCharactersInRange:range withString:threeFillStr];
        }
    }
    return questionText;
}

/// 生成富文本，给富文本插入标记
-(NSMutableAttributedString *)buildAttributedStringWithTag{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.questionString];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.maximumLineHeight = 24;
    paragraphStyle.minimumLineHeight = 24;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.questionString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.questionFontSize] range:NSMakeRange(0, self.questionString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.questionColor range:NSMakeRange(0, self.questionString.length)];
    
    for (NSInteger i = 0; i < self.fillRangeArray.count; i++) {
        NSString *rangeStr = self.fillRangeArray[i];
        NSString *indexValue = [NSString stringWithFormat:@"input_%ld", (long)i];
        NSRange fillRange = NSRangeFromString(rangeStr);
        [attributedString addAttribute:(id)@"PLVCoreTextDataName" value:(id)indexValue range:fillRange];
    }
    return attributedString;
}

/// 计算填满某宽度需要多少个填空符
/// @param fullWidth 宽度
-(NSInteger)calculateFillCountForfullWidth:(CGFloat)fullWidth
{
    if (fullWidth <= 0) {
        return 0;
    }
    
    NSInteger index = 0;
    CGFloat width = 0;
    
    while (width < fullWidth) {
        index ++;
        width = [self calculateWidthWithFillCount:index];
    }
    return index > 0 ? index - 1 : 0;
}

/// 计算count数量填空符的长度
/// @param count 填空符数量
-(CGFloat)calculateWidthWithFillCount:(NSInteger)count
{
    NSString *fillStr = [self createFillStringWithCount:count];
    CGFloat fillWidth = [fillStr boundingRectWithSize:CGSizeMake(1000, self.questionFontSize) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.questionFontSize]} context:nil].size.width;
    return fillWidth;
}

/// 在字符串中搜索填空符的范围（需求只要前5处填空符为可输入，其余为普通字符串）
/// @param string 要搜索的字符串
-(NSMutableArray *)searchFillRangeWithString:(NSString *)string
{
    NSMutableArray *rangeArray = [NSMutableArray arrayWithCapacity:3];
    NSInteger location = -1;
    NSInteger length = 0;
    for (NSInteger i = 0; i < string.length; i++) {
        NSString *temp = [string substringWithRange:NSMakeRange(i,1)];
        
        if ([temp isEqualToString:kFillString]) {
            if (location == -1) {
                location = i;
                length = 1;
            }else {
                length++;
            }
            if (i == string.length - 1
                && length >= 3
                && rangeArray.count < 5) {
                NSRange range = NSMakeRange(location, length);
                [rangeArray addObject:NSStringFromRange(range)];
                location = -1;
                length = 0;
            }
        }else {
            if (location != -1) {
                if (length >= 3
                    && rangeArray.count < 5) {
                    NSRange range = NSMakeRange(location, length);
                    [rangeArray addObject:NSStringFromRange(range)];
                    location = -1;
                    length = 0;
                }
                else {
                    location = -1;
                    length = 0;
                }
            }
        }
    }
    return rangeArray;
}

/// 生成count数量的填空符
/// @param count 数量
-(NSString *)createFillStringWithCount:(NSInteger)count
{
    NSString *fillStr = kFillString;
    for (NSInteger i = 0; i < count; i++) {
        fillStr = [fillStr stringByAppendingString:kFillString];
    }
    return fillStr;
}

/// 生成count数量的输入框
/// @param count 数量
-(NSMutableArray *)createTextfieldWithCount:(NSInteger)count
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < count; i++) {
        UITextField *textField = [[UITextField alloc] init];
        [textField setBorderStyle:UITextBorderStyleNone];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.font = [UIFont systemFontOfSize:self.fillFontSize];
        textField.textColor = self.fillColor;
        textField.tag = 100 + i;
        textField.hidden = YES;
        textField.delegate = self;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:textField];
        [array addObject:textField];
    }
    return array;
}

@end

//
//  PLVVodBubbleMarkerView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import "PLVVodBubbleMarkerView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodBubbleMarkerView ()

@property (nonatomic, strong) PLVVodMarkerViewData *data;

@end

@implementation PLVVodBubbleMarkerView

- (instancetype)initWithData:(PLVVodMarkerViewData *)data {
    if (self = [super init]) {
        _data = data;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *bubblePath = [UIBezierPath bezierPath];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat radius = 5.0;
    CGFloat arrow = 5.0;
    
    // 绘制气泡路径
    [bubblePath moveToPoint:CGPointMake(radius, 0)];
    [bubblePath addLineToPoint:CGPointMake(width - radius, 0)];
    [bubblePath addArcWithCenter:CGPointMake(width - radius, radius)
                         radius:radius
                     startAngle:-M_PI_2
                       endAngle:0
                      clockwise:YES];
    [bubblePath addLineToPoint:CGPointMake(width, height - radius - arrow)];
    [bubblePath addArcWithCenter:CGPointMake(width - radius, height - radius - arrow)
                         radius:radius
                     startAngle:0
                       endAngle:M_PI_2
                      clockwise:YES];
    
    // 绘制箭头
    [bubblePath addLineToPoint:CGPointMake(width/2 + arrow, height - arrow)];
    [bubblePath addLineToPoint:CGPointMake(width/2, height)];
    [bubblePath addLineToPoint:CGPointMake(width/2 - arrow, height - arrow)];
    
    // 完成路径
    [bubblePath addLineToPoint:CGPointMake(radius, height - arrow)];
    [bubblePath addArcWithCenter:CGPointMake(radius, height - radius - arrow)
                         radius:radius
                     startAngle:M_PI_2
                       endAngle:M_PI
                      clockwise:YES];
    [bubblePath addLineToPoint:CGPointMake(0, radius)];
    [bubblePath addArcWithCenter:CGPointMake(radius, radius)
                         radius:radius
                     startAngle:M_PI
                       endAngle:-M_PI_2
                      clockwise:YES];
    
    [[UIColor colorWithHexString:self.data.color alpha:self.data.colorAlpha] setFill];
    [bubblePath fill];

    if (self.data.title) {
        // 计算文本尺寸
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        CGSize textSize = [self.data.title sizeWithAttributes:attributes];
        
        // 计算居中位置
        CGFloat textX = (width - textSize.width) / 2;
        CGFloat textY = (height - arrow - textSize.height) / 2;
        
        // 绘制文本
        [self.data.title drawInRect:CGRectMake(textX, textY, textSize.width, textSize.height)
              withAttributes:attributes];
    }
}

- (void)tapClick:(UITapGestureRecognizer *)gesture {
    if (self.tapHandler) {
        self.tapHandler(self.tag);
    }
}


@end

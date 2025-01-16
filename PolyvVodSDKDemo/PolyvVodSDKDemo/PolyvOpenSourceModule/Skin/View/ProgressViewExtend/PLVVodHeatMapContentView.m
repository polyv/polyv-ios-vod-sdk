//
//  PLVVodHeatMapContentView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/14.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodHeatMapContentView.h"

@implementation PLVVodHeatMapContentView

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.3;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 示例热力图数据
    NSArray<NSNumber *> *heatData = self.heatMapModel.dataPoints;
    
    // 数据归一化
    CGFloat maxValue = [[heatData valueForKeyPath:@"@max.self"] floatValue];
    NSMutableArray<NSNumber *> *normalizedData = [NSMutableArray array];
    int i=0;
    int maxPointCount = self.heatMapModel.totalVideoDuration/ self.heatMapModel.defautDuration;
    for (NSNumber *value in heatData) {
        if (i > maxPointCount)
            break;
        [normalizedData addObject:@(value.floatValue / maxValue)];
        i ++;
    }
    
    // 绘制曲线
    [self drawHeatCurveInRect:rect withData:normalizedData];
}

- (void)drawHeatCurveInRect:(CGRect)rect withData:(NSArray<NSNumber *> *)data {
    if (data.count < 2) return;

    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat widthPerSegment = rect.size.width *(self.heatMapModel.defautDuration/self.heatMapModel.totalVideoDuration);
    
    [path moveToPoint:CGPointMake(0, rect.size.height)];
    [path addLineToPoint:CGPointMake(0, rect.size.height * (1 - data[0].floatValue))];
    
    // 使用更平滑的贝塞尔曲线
    for (NSInteger i = 0; i < data.count - 1; i++) {
        CGFloat x1 = i * widthPerSegment;
        CGFloat y1 = rect.size.height * (1 - data[i].floatValue);
        CGFloat x2 = (i + 1) * widthPerSegment;
        CGFloat y2 = rect.size.height * (1 - data[i + 1].floatValue);
        
        // 调整控制点的位置，使用更大的水平距离和垂直插值
        CGFloat controlX1 = x1 + widthPerSegment * 0.5;
        CGFloat controlX2 = x2 - widthPerSegment * 0.5;
        
        // 添加垂直方向的插值，使曲线更平滑
        CGFloat controlY1 = y1 + (y2 - y1) * 0.2;  // 添加垂直方向的过渡
        CGFloat controlY2 = y2 - (y2 - y1) * 0.2;  // 添加垂直方向的过渡
        
        [path addCurveToPoint:CGPointMake(x2, y2)
                controlPoint1:CGPointMake(controlX1, controlY1)
                controlPoint2:CGPointMake(controlX2, controlY2)];
    }
    
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [path closePath];
    
    [self fillPath:path inRect:rect];
}

- (void)fillPath:(UIBezierPath *)path inRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // 裁剪路径
    [path addClip];
    
    // 设置单一填充颜色
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] setFill];

    [path fill];
    
    CGContextRestoreGState(context);
}

#pragma mark -- PUBLIC
- (void)updateWithData:(PLVVodHeatMapModel *)data{
    self.heatMapModel = data;
    
    // 重绘
    [self setNeedsDisplay];
}


@end

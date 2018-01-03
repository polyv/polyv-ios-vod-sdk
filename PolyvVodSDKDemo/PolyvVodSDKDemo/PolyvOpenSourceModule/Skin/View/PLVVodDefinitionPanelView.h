//
//  PLVVodDefinitionPanelView.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodDefinitionPanelView : UIView

/// 清晰度数量
@property (nonatomic, assign) int qualityCount;
/// 选择的清晰度
@property (nonatomic, assign) int quality;
@property (nonatomic, copy) void (^qualityDidChangeBlock)(NSInteger quality);

@property (nonatomic, copy) void (^qualityButtonDidClick)(UIButton *sender);

@end

//
//  PLVOptionView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/2/1.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 选择题选项view
@interface PLVOptionView : UIView

@property (nonatomic, strong) NSString *optionString;

@property (nonatomic, assign) BOOL multipleChoiceType; // 是否多选样式

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, copy) void (^selectActionHandler)(BOOL isSelect);

@end

NS_ASSUME_NONNULL_END

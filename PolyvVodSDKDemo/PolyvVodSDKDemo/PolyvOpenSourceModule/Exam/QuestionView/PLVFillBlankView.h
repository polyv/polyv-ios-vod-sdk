//
//  PLVFillBlankView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/1/28.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVFillBlankView;
@protocol PLVFillBlankViewDelegate <NSObject>

/// 填空题view的高度变化
/// @param height 变化后的高度
-(void)fillBlankView:(PLVFillBlankView *)fillBlankView didChangeHeight:(CGFloat)height;

-(void)fillBlankView:(PLVFillBlankView *)fillBlankView textFieldShouldBeginEditingBlock:(UITextField *)tfEditing;

@end

/// 填空题view
@interface PLVFillBlankView : UIView

@property (nonatomic, weak) id<PLVFillBlankViewDelegate> delegate;

/// 填空题内容，会触发绘制
@property (nonatomic, strong) NSString *questionString;

@property (nonatomic, strong) UIColor *questionColor;   //!< 问题字体颜色（默认黑色）
@property (nonatomic, strong) UIColor *fillColor;   //!< 填空字体颜色（默认黑色）

@property (nonatomic, assign) CGFloat questionFontSize; //!< 问题字体大小（默认18）
@property (nonatomic, assign) CGFloat fillFontSize; //!< 填空字体大小（默认15）

@property (nonatomic, strong, readonly) NSMutableArray *textfieldArray;   //!< 生成的输入框数组


@end

NS_ASSUME_NONNULL_END

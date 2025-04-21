//
//  PLVVodOptimizeOptionView.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/9.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodOptimizeOptionView : UIButton

@property (nonatomic, copy) NSString *mainTitleText;
@property (nonatomic, copy) NSString *subTitleText;

/**
 * Set if the option is selected
 */
- (void)setSelected:(BOOL)selected;

/**
 * Check if the option is selected
 */
- (BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END

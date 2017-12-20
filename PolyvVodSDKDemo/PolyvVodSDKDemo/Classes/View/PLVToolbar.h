//
//  PLVToolbar.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/20.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVToolbar : UIToolbar

@property (nonatomic, strong) NSArray<UIButton *> *buttons;

+ (void)addToolbarOnView:(UIView *)superview;

+ (UIButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image;

@end

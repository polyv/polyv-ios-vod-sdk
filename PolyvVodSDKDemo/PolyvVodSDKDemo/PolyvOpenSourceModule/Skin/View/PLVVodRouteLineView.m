//
//  PLVVodRouteLineView.m
//  _PolyvVodSDK
//
//  Created by mac on 2019/2/13.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVVodRouteLineView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodRouteLineView ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *routeStackView;

#pragma clang diagnostic pop

@end

@implementation PLVVodRouteLineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews{
    if (self.frame.size.width <= PLV_Max_ScreenWidth){
        self.routeStackView.spacing = 30;
    }
    else{
        self.routeStackView.spacing = 50;
    }
}

- (void)setRouteLineCount:(NSUInteger)routeLineCount{
    _routeLineCount = routeLineCount;
    if (routeLineCount <= 1) {
        return;
    }
    if (routeLineCount > 3) {
        routeLineCount = 3;
    }
    
    UIButton *lineOne = [self.class buttonWithTitle:@"线路一" target:self];
    lineOne.selected = YES;
    UIButton *lineTwo = [self.class buttonWithTitle:@"线路二" target:self];
    UIButton *lineThree = [self.class buttonWithTitle:@"线路三" target:self];
    
    // 清除控件
    for (UIView *subview in self.routeStackView.arrangedSubviews) {
        [self.routeStackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    
    switch (routeLineCount) {
        case 1:{
            [self.routeStackView addArrangedSubview:lineOne];
        }break;
        case 2:{
            [self.routeStackView addArrangedSubview:lineOne];
            [self.routeStackView addArrangedSubview:lineTwo];
        }break;
        case 3:{
            [self.routeStackView addArrangedSubview:lineOne];
            [self.routeStackView addArrangedSubview:lineTwo];
            [self.routeStackView addArrangedSubview:lineThree];
        }break;
        default:{}break;
    }
}

#pragma mark - action
- (IBAction)lineButtonAction:(UIButton *)sender {
    for (UIButton *button in self.routeStackView.arrangedSubviews) {
        button.selected = NO;
    }
    sender.selected = YES;
    
    NSInteger index = [self.routeStackView.arrangedSubviews indexOfObject:sender];

    if (self.routeLineDidChangeBlock){
        self.routeLineDidChangeBlock(index);
    }
    if (self.routeLineBtnDidClick){
        self.routeLineBtnDidClick(sender);
    }
}

#pragma mark - tool

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHex:0x00B3F7] forState:UIControlStateSelected];
    button.tintColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:@selector(lineButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


@end

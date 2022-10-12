//
//  PLVVodVideoToolBoxPanelView.m
//  PolyvVodSDKDemo
//
//  Created by juno on 2022/9/14.
//  Copyright © 2022 POLYV. All rights reserved.
//

#import "PLVVodVideoToolBoxPanelView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodVideoToolBoxPanelView ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *videoToolBoxStackView;

#pragma clang diagnostic pop

@end

@implementation PLVVodVideoToolBoxPanelView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self buildUI];
}

- (void)buildUI {
    UIButton *ffmpegButton = [self.class buttonWithTitle:@"软解" target:self];
    UIButton *videoToolBoxButton = [self.class buttonWithTitle:@"硬解" target:self];
    videoToolBoxButton.selected = YES;
    // 清除控件
    for (UIView *subview in self.videoToolBoxStackView.arrangedSubviews) {
        [self.videoToolBoxStackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    [self.videoToolBoxStackView addArrangedSubview:ffmpegButton];
    [self.videoToolBoxStackView addArrangedSubview:videoToolBoxButton];
}

- (void)layoutSubviews{
    if (self.frame.size.width <= PLV_Max_ScreenWidth){
        self.videoToolBoxStackView.spacing = 70;
    }
    else{
        self.videoToolBoxStackView.spacing = 100;
    }
}

-(void)setIsVideoToolBox:(BOOL)isVideoToolBox {
    _isVideoToolBox = isVideoToolBox;
    
    for (UIButton *button in self.videoToolBoxStackView.arrangedSubviews) {
        button.selected = NO;
    }
    NSInteger index = isVideoToolBox ? 1 : 0;
    UIButton *button = self.videoToolBoxStackView.arrangedSubviews[index];
    button.selected = YES;
}

#pragma mark - action

- (void)videoToolBoxButtonAction:(UIButton *)sender {
    for (UIButton *button in self.videoToolBoxStackView.arrangedSubviews) {
        button.selected = NO;
    }
    sender.selected = YES;
    NSInteger index = [self.videoToolBoxStackView.arrangedSubviews indexOfObject:sender];
    if (self.videoToolBoxDidChangeBlock) self.videoToolBoxDidChangeBlock(index == 0 ? NO : YES);
    if (self.videoToolBoxButtonDidClick) self.videoToolBoxButtonDidClick(sender);
}

#pragma mark - tool

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHex:0x00B3F7] forState:UIControlStateSelected];
    button.tintColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:@selector(videoToolBoxButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end

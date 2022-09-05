//
//  PLVPictureInPicturePlaceholderView.m
//  PolyvVodSDKDemo
//
//  Created by junotang on 2022/4/19.
//  Copyright © 2022 POLYV. All rights reserved.
//

#import "PLVPictureInPicturePlaceholderView.h"
#import "UIColor+PLVVod.h"

@interface PLVPictureInPicturePlaceholderView ()

@property (nonatomic, strong) UIImageView *placeholderImage;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation PLVPictureInPicturePlaceholderView

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithHex:0x35384f];
        [self addSubview:self.placeholderImage];
        [self addSubview:self.placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat top = (self.bounds.size.height - (16 + 4 + 64)) * 0.5;
    self.placeholderImage.frame = CGRectMake((self.bounds.size.width - 64) * 0.5, top, 64, 64);
    self.placeholderLabel.frame = CGRectMake(0, CGRectGetMaxY(self.placeholderImage.frame) + 4, self.bounds.size.width, 16);
}

#pragma mark - Getter
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.text = @"正在启用画中画";
        _placeholderLabel.textColor = [UIColor colorWithHex:0xffffff alpha:0.6];
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _placeholderLabel;
}

- (UIImageView *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [[UIImageView alloc]init];
        [_placeholderImage setImage:[UIImage imageNamed:@"plv_pictureInPicture_holder"]];
        [_placeholderImage setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _placeholderImage;
}

@end

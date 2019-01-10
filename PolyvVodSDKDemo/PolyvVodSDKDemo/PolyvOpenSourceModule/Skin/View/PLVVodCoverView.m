//
//  PLVVodCoverView.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/25.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import "PLVVodCoverView.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVVodCoverView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgVHeightConstraint;

@end

@implementation PLVVodCoverView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    float height = 0;
    if (self.bounds.size.width > self.bounds.size.height) {
        height = self.bounds.size.height;
    }else{
        height = self.bounds.size.width;
    }
    
    self.imgVHeightConstraint.constant = height;
}

- (void)setCoverImageWithUrl:(NSString *)coverUrl{
    [self.coverImgV yy_setImageWithURL:[NSURL URLWithString:coverUrl] options:0];
}

@end

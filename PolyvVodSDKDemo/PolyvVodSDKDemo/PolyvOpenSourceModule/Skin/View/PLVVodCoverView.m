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

@end

@implementation PLVVodCoverView

- (void)setCoverImageWithUrl:(NSString *)coverUrl{
    [self.coverImgV yy_setImageWithURL:[NSURL URLWithString:coverUrl] options:0];
}

@end

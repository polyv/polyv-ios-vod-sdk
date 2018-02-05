//
//  PLVVodFullscreenView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodFullscreenView.h"

@interface PLVVodFullscreenView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeight;


@end

@implementation PLVVodFullscreenView

- (void)awakeFromNib {
	[super awakeFromNib];
	if (@available(iOS 9.0, *)) {} else {
		self.statusBarHeight.constant = 12;
	}
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end

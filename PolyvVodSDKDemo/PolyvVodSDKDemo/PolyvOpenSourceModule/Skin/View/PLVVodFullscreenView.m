//
//  PLVVodFullscreenView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodFullscreenView.h"
#import <FDStackView.h>

@interface PLVVodFullscreenView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeight;

@property (weak, nonatomic) IBOutlet UIImageView *videoModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoModeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioModeLabel;

@end

@implementation PLVVodFullscreenView

- (void)awakeFromNib {
	[super awakeFromNib];
    
	if ([UIDevice currentDevice].systemVersion.integerValue < 11) {
		self.statusBarHeight.constant = 12;
	}
    
    if (PLV_iPhoneX || PLV_iPhoneMR){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.firstItem isKindOfClass:[UIStackView class]]){
                if (obj.firstAttribute == NSLayoutAttributeLeading && obj.secondAttribute == NSLayoutAttributeLeading){
                    //
                    obj.constant = PLV_Landscape_Left_And_Right_Safe_Side_Margin;
                }
            }
        }];
#pragma clang diagnostic pop
    }
}

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
        self.videoModeSelectedImageView.hidden = YES;
        self.videoModeLabel.highlighted = NO;
        self.audioModeSelectedImageView.hidden = NO;
        self.audioModeLabel.highlighted = YES;
        
        self.definitionButton.hidden = YES;
        self.snapshotButton.hidden = YES;
    } else {
        self.videoModeSelectedImageView.hidden = NO;
        self.videoModeLabel.highlighted = YES;
        self.audioModeSelectedImageView.hidden = YES;
        self.audioModeLabel.highlighted = NO;
        
        self.definitionButton.hidden = NO;
        self.snapshotButton.hidden = NO;
    }
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end

//
//  PLVLCMediaProgressView.h
//  PLVLiveScenesDemo
//
//  Created by Dhan on 2022/11/9.
//  Copyright © 2022 PLV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodSpriteChartView : UIView

- (void)updateWithDurationTime:(NSTimeInterval)durationTime progressImageString:(NSString *)progressImageString ratio:(CGFloat)ratio;

- (void)updateProgressTime:(NSTimeInterval)progressTime;

@end

NS_ASSUME_NONNULL_END

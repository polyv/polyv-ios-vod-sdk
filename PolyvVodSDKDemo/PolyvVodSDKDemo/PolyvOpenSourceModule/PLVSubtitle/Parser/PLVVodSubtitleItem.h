//
//  PLVVodSubtitleItem.h
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSInteger hours;
	NSInteger minutes;
	NSInteger seconds;
	NSInteger milliseconds;
} PLVVodSubtitleTime;

NS_INLINE NSMutableAttributedString *HTMLString(NSString *string);
NSTimeInterval PLVVodSubtitleTimeGetSeconds(PLVVodSubtitleTime time);

@interface PLVVodSubtitleItem : NSObject

@property (nonatomic, assign) PLVVodSubtitleTime startTime;
@property (nonatomic, assign) PLVVodSubtitleTime endTime;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, assign) NSString *identifier;

@property (nonatomic, assign) BOOL atTop;

- (instancetype)initWithText:(NSString *)text start:(PLVVodSubtitleTime)startTime end:(PLVVodSubtitleTime)endTime;

@end

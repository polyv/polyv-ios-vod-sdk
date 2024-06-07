//
//  PLVVodSubtitleParser.h
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVVodSubtitleItem.h"

@interface PLVVodSubtitleParser : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<PLVVodSubtitleItem *> *subtitleItems;

+ (instancetype)parserWithSubtitle:(NSString *)content error:(NSError **)error;
- (NSDictionary *)subtitleItemAtTime:(NSTimeInterval)time;

@end

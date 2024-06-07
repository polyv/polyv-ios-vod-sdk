//
//  PLVVodSubtitleParser.m
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSubtitleParser.h"

static NSString *const PLVVodSubtitleErrorDomain = @"net.polyv.subtitle.error";

//typedef NS_ENUM(NSInteger, PLVVodSubtitlePosition) {
//	PLVVodSubtitlePositionIndex,
//	PLVVodSubtitlePositionTimes,
//	PLVVodSubtitlePositionText
//};

NS_INLINE BOOL scanLinebreak(NSScanner *scanner, NSString *linebreakString, NSInteger linenr);
NS_INLINE BOOL scanString(NSScanner *scanner, NSString *str);
NS_INLINE NSString * convertSubViewerLineBreaks(NSString *currentText);

@interface PLVVodSubtitleParser ()

@property (nonatomic, strong) NSMutableArray<PLVVodSubtitleItem *> *subtitleItems;
@property (nonatomic, strong) NSMutableArray<PLVVodSubtitleItem *> *subtitleAtTopItems;

@property (nonatomic, strong) NSDictionary<NSNumber *, PLVVodSubtitleItem *> *subtitleItemsDictionary;

@end

@implementation PLVVodSubtitleParser

#pragma mark - property

- (NSMutableArray<PLVVodSubtitleItem *> *)subtitleItems {
	if (!_subtitleItems) {
		_subtitleItems = [NSMutableArray array];
	}
	return _subtitleItems;
}

- (NSMutableArray<PLVVodSubtitleItem *> *)subtitleAtTopItems {
    if (!_subtitleAtTopItems) {
        _subtitleAtTopItems = [NSMutableArray array];
    }
    return _subtitleAtTopItems;
}

// abandon
- (NSDictionary<NSNumber *,PLVVodSubtitleItem *> *)subtitleItemsDictionary {
	if (!_subtitleItemsDictionary) {
		NSMutableDictionary *subtitleItemsDictionary = [NSMutableDictionary dictionary];
		for (PLVVodSubtitleItem *item in self.subtitleItems) {
			subtitleItemsDictionary[@(PLVVodSubtitleTimeGetSeconds(item.startTime))] = item;
		}
		_subtitleItemsDictionary = subtitleItemsDictionary;
	}
	return _subtitleItemsDictionary;
}

#pragma mark - public method

+ (instancetype)parserWithSubtitle:(NSString *)content error:(NSError *__autoreleasing *)error {
	PLVVodSubtitleParser *parser = [[PLVVodSubtitleParser alloc] init];
	[parser scanSubtitleItemsWithContent:content error:error];
	return parser;
}

- (NSDictionary *)subtitleItemAtTime:(NSTimeInterval)time {
    PLVVodSubtitleItem * item = [self searchSubtitleWithTime:time atTop:NO];
    PLVVodSubtitleItem * itemAtTop = [self searchSubtitleWithTime:time atTop:YES];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    if (item == nil && itemAtTop == nil) {
        return nil;
    }
    
    if (item) {
        [dic setObject:item forKey:@"subtitleItem_bot"];
    }
    
    if (itemAtTop) {
        [dic setObject:itemAtTop forKey:@"subtitleItem_top"];
    }
    
    return dic;
}

- (PLVVodSubtitleItem *)searchSubtitleWithTime:(NSTimeInterval)time
                                      atTop:(BOOL)atTop{
    NSMutableArray<PLVVodSubtitleItem *> * arr = atTop ? self.subtitleAtTopItems : self.subtitleItems;
    
    if (!arr.count) {
        return nil;
    }
    // Finds the first PLVVodSubtitleItem whose startTime <= desiredTime < endTime.
    // Requires that we ensure the subtitleItems are ordered, because we are using binary search.
    NSUInteger *index = NULL;
    NSUInteger subtitleItemsCount = arr.count;
    
    // 二分法查找
    NSUInteger low = 0;
    NSUInteger high = subtitleItemsCount - 1;
    
    while (low <= high) {
        //NSLog(@"high : %lud", high);
        NSUInteger mid = (low + high) >> 1;
        PLVVodSubtitleItem *thisSub = arr[mid];
        NSTimeInterval thisStartTime = PLVVodSubtitleTimeGetSeconds(thisSub.startTime);
        
        if (thisStartTime <= time) {
            NSTimeInterval thisEndTime = PLVVodSubtitleTimeGetSeconds(thisSub.endTime);
            
            if (time < thisEndTime) {
                // 命中
                if (index != NULL) *index = mid;
                return thisSub;
            } else {
                // Continue search in upper *half*.
                low = mid + 1;
            }
        } else {
            if (mid == 0) break;  // Nothing found.
            // Continue search in lower *half*.
            high = mid - 1;
        }
    }
    
    if (index != NULL) *index = NSNotFound;
    
    return nil;
}

#pragma mark - private method

- (BOOL)scanSubtitleItemsWithContent:(NSString *)str error:(NSError **)error{
	// Should handle mal-formed SRT files. May fill error even if parsing was successful!
	// Basis for implementation donated by Peter Ljunglöf (SubTTS)
#   define SCAN_LINEBREAK() scanLinebreak(scanner, linebreakString, lineNr)
#   define SCAN_STRING(str) scanString(scanner, (str))
	if (!str.length) return NO;
	NSScanner *scanner = [NSScanner scannerWithString:str];
	[scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	
	// 检测换行符
	NSString *linebreakString = nil;
	{
		NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
		BOOL ok = ([scanner scanUpToCharactersFromSet:newlineCharacterSet intoString:NULL] &&
				   [scanner scanCharactersFromSet:newlineCharacterSet intoString:&linebreakString]);
		
		if (ok == NO) {
			linebreakString = @"\n";
		}
		// 维护变量
		[scanner setScanLocation:0];
	}
	
	NSString *subTextLineSeparator = @"\n";
	NSInteger subtitleNr = 0;
	NSInteger lineNr = 1;
	
	NSRegularExpression *tagRe;
	
	// 忽略空行
	while (SCAN_LINEBREAK());
	
	while (![scanner isAtEnd]) {
		NSString *subText;
		NSMutableArray *subTextLines;
		NSString *subTextLine;
		PLVVodSubtitleTime start = { -1, -1, -1, -1 };
		PLVVodSubtitleTime end = { -1, -1, -1, -1 };
		NSInteger _subtitleNr;
		
		subtitleNr++;
		
		BOOL ok = ([scanner scanInteger:&_subtitleNr] && SCAN_LINEBREAK() &&
				   // 起始时间
				   [scanner scanInteger:&start.hours] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&start.minutes] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&start.seconds] &&
				   (
					((SCAN_STRING(@",") || SCAN_STRING(@".")) &&
					 [scanner scanInteger:&start.milliseconds]
					 ) || YES // We either find milliseconds or we ignore them.
					) &&
				   
				   // 字幕时间
				   //#if SUBVIEWER_SUPPORT
				   (SCAN_STRING(@"-->") || SCAN_STRING(@",")) &&
				   
				   // 结束时间
				   [scanner scanInteger:&end.hours] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&end.minutes] && SCAN_STRING(@":") &&
				   [scanner scanInteger:&end.seconds] &&
				   (
					((SCAN_STRING(@",") || SCAN_STRING(@".")) &&
					 [scanner scanInteger:&end.milliseconds]
					 ) || YES // We either find milliseconds or we ignore them.
					) &&
				   
				   // 字幕内容
				   (
					[scanner scanUpToString:linebreakString intoString:&subTextLine] || // We either find subtitle text…
					(subTextLine = @"") // … or we assume empty text.
					) &&
				   
				   // 结束一条字幕
				   (
                    SCAN_LINEBREAK() || [scanner isAtEnd])
                   );
		
		if (!ok) {
			if (error) {
				const NSUInteger contextLength = 20;
				NSUInteger strLength = str.length;
				NSUInteger errorLocation = [scanner scanLocation];
				
				NSRange beforeRange, afterRange;
				
				beforeRange.length = MIN(contextLength, errorLocation);
				beforeRange.location = errorLocation - beforeRange.length;
				NSString *beforeError = [str substringWithRange:beforeRange];
				
				afterRange.length = MIN(contextLength, (strLength - errorLocation));
				afterRange.location = errorLocation;
				NSString *afterError = [str substringWithRange:afterRange];
				
				NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"The SRT subtitles could not be parsed: error in subtitle #%d (line %d):\n%@<HERE>%@", @"Cannot parse SRT file"),
											  subtitleNr, lineNr, beforeError, afterError];
				NSDictionary *errorDetail = [NSDictionary dictionaryWithObjectsAndKeys:
											 errorDescription, NSLocalizedDescriptionKey,
											 nil];
				*error = [NSError errorWithDomain:PLVVodSubtitleErrorDomain
											code:-1
										userInfo:errorDetail];
				if (*error) {
					NSLog(@"scaner error: %@", *error);
				}
			}
			
			return NO;
		}
		
		if (subtitleNr != _subtitleNr) {
			NSLog(@"Subtitle # mismatch (line %@): got %@, expected %@. ", @(lineNr), @(_subtitleNr), @(subtitleNr));
			subtitleNr = _subtitleNr;
		}
		
		subTextLine = convertSubViewerLineBreaks(subTextLine);
		subTextLines = [NSMutableArray arrayWithObject:subTextLine];
		
		// Accumulate multi-line text if any.
		while ([scanner scanUpToString:linebreakString intoString:&subTextLine] &&
			   (SCAN_LINEBREAK() || [scanner isAtEnd]))
			[subTextLines addObject:subTextLine];
		
		if (subTextLines.count == 1) {
			subText = [subTextLines objectAtIndex:0];
			subText = [subText stringByReplacingOccurrencesOfString:@"|"
														 withString:@"\n"
															options:NSLiteralSearch
															  range:NSMakeRange(0, subText.length)];
		} else {
			subText = [subTextLines componentsJoinedByString:subTextLineSeparator];
		}
		
		// Curly braces enclosed tag processing
        BOOL atTop = NO;
		{
			NSString *const tagStart = @"{";
			
			NSRange searchRange = NSMakeRange(0, subText.length);
			
			NSRange tagStartRange = [subText rangeOfString:tagStart options:NSLiteralSearch range:searchRange];
			
			if (tagStartRange.location != NSNotFound) {
                if ([subText containsString:@"{\\an8}"]) {
                    atTop = YES;
                }
                
				searchRange = NSMakeRange(tagStartRange.location, subText.length - tagStartRange.location);
				NSMutableString *subTextMutable = [subText mutableCopy];
				
				// Remove all
				if (tagRe == nil) {
					NSString *const tagPattern = @"\\{(\\\\|Y:)[^\\{]+\\}";
					
					tagRe = [[NSRegularExpression alloc] initWithPattern:tagPattern options:0 error:error];
				}
				
				[tagRe replaceMatchesInString:subTextMutable
									  options:0
										range:searchRange
								 withTemplate:@""];
				
				subText = [subTextMutable copy];
			}
		}
		
		PLVVodSubtitleItem *item = [[PLVVodSubtitleItem alloc] initWithText:subText
															  start:start
																end:end];
		
        item.atTop = atTop;
        
        if (atTop) {
            [self.subtitleAtTopItems addObject:item];
        }else{
            [self.subtitleItems addObject:item];
        }
        
		while (SCAN_LINEBREAK());  // Skip trailing empty lines.
	}
	return YES;
	
#   undef SCAN_LINEBREAK
#   undef SCAN_STRING
}

- (NSString *)description {
	return [NSString stringWithFormat:@"SRT file: %@", self.subtitleItems];
}

@end

NS_INLINE BOOL scanLinebreak(NSScanner *scanner, NSString *linebreakString, NSInteger linenr) {
	BOOL success = ([scanner scanString:linebreakString intoString:NULL] && (++linenr >= 0));
	return success;
}

NS_INLINE BOOL scanString(NSScanner *scanner, NSString *str) {
	BOOL success = [scanner scanString:str intoString:NULL];
	return success;
}

NS_INLINE NSString * convertSubViewerLineBreaks(NSString *currentText) {
	NSUInteger currentTextLength = currentText.length;
	
	if (currentTextLength == 0) return currentText;
	
	NSRange currentTextRange = NSMakeRange(0, currentTextLength);
	NSString *subViewerLineBreak = @"[br]";
	NSRange subViewerLineBreakRange = [currentText rangeOfString:subViewerLineBreak
														 options:NSLiteralSearch
														   range:currentTextRange];
	
	if (subViewerLineBreakRange.location != NSNotFound) {
		NSRange subViewerLineBreakSearchRange = NSMakeRange(subViewerLineBreakRange.location,
															(currentTextRange.length - subViewerLineBreakRange.location));
		
		currentText = [currentText stringByReplacingOccurrencesOfString:subViewerLineBreak
															 withString:@"\n"
																options:NSLiteralSearch
																  range:subViewerLineBreakSearchRange];
	}
	
	return currentText;
}

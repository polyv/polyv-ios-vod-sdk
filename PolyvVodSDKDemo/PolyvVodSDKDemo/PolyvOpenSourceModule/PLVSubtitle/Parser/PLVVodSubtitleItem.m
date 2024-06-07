//
//  PLVVodSubtitleItem.m
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSubtitleItem.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@implementation PLVVodSubtitleItem

- (instancetype)init {
	if (self = [super init]) {
		_identifier = [NSProcessInfo processInfo].globallyUniqueString;
	}
	return self;
}

- (instancetype)initWithText:(NSString *)text start:(PLVVodSubtitleTime)startTime end:(PLVVodSubtitleTime)endTime {
	self = [self init];
	_text = text;
	_startTime = startTime;
	_endTime = endTime;
	return self;
}

#pragma mark - property

- (NSAttributedString *)attributedText {
	if (!_attributedText) {
		_attributedText = HTMLString(self.text);
	}
	return _attributedText;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%02f --> %02f : %@",
			PLVVodSubtitleTimeGetSeconds(self.startTime),
			PLVVodSubtitleTimeGetSeconds(self.endTime),
			self.text];
}

@end

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunused-function"

NS_INLINE NSMutableAttributedString *HTMLString(NSString *string) {
	static const CGFloat kDefaultFontSize = 20.0;
	static NSString * kDefaultFontFamily = @"PingFangSC";
	
	string = [string copy];
	
	if ([string length] > 0) {
		if ([[string substringToIndex:1] isEqualToString:@"\n"]) {
			string = [string substringFromIndex:1];
		}
	}
	
	NSMutableAttributedString *HTMLString;
	NSRange HTMLStringRange = NSMakeRange(0, 0);
	if ([string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch].location != NSNotFound) {
		NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
		HTMLString =  [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF16StringEncoding]
															  options:options
												   documentAttributes:nil
																error:NULL];
		HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
		
		//Edit font size
		[HTMLString beginEditing];
		[HTMLString enumerateAttribute:NSFontAttributeName
							   inRange:HTMLStringRange
							   options:0
							usingBlock:^(id value, NSRange range, BOOL *stop) {
								if (value) {
									UIFont *oldFont = (UIFont *)value;
									NSString *fontName = kDefaultFontFamily;
									if ([oldFont.fontName rangeOfString:@"Italic"].location != NSNotFound) {
										fontName = [fontName stringByAppendingString:@"-Italic"];
									} else if ([oldFont.fontName rangeOfString:@"Bold"].location != NSNotFound) {
										fontName = [fontName stringByAppendingString:@"-Bold"];
									}
									UIFont *newFont = [UIFont fontWithName:fontName size:kDefaultFontSize];
									//Workaround for iOS 7.0.3 && 7.0.4 font bug
									if (newFont == nil && ([UIFontDescriptor class] != nil)) {
										newFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)fontName, kDefaultFontSize, NULL);
									}
									[HTMLString removeAttribute:NSFontAttributeName range:range];
									[HTMLString addAttribute:NSFontAttributeName value:newFont range:range];
								}
							}];
		[HTMLString endEditing];
	}
	
	if (!HTMLString) {
		UIFont *defaultFont = [UIFont fontWithName:kDefaultFontFamily size:kDefaultFontSize];
		//Workaround for iOS 7.0.3 && 7.0.4 font bug
		if (defaultFont == nil && ([UIFontDescriptor class] != nil)) {
			defaultFont = (__bridge_transfer UIFont*)CTFontCreateWithName((__bridge CFStringRef)kDefaultFontFamily, kDefaultFontSize, NULL);
		}
		
		HTMLString = [[NSMutableAttributedString alloc] initWithString:string
															attributes:@{
																		 NSFontAttributeName: defaultFont
																		 }];
		HTMLStringRange = NSMakeRange(0, [HTMLString.string length]);
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	//Add color and paragraph style
	[HTMLString addAttributes:@{
								NSParagraphStyleAttributeName: paragraphStyle,
								NSForegroundColorAttributeName: [UIColor whiteColor]
								}
						range:HTMLStringRange];
	
	
	
	return HTMLString;
}

NSTimeInterval PLVVodSubtitleTimeGetSeconds(PLVVodSubtitleTime time) {
	NSTimeInterval seconds = 1.0*time.milliseconds/1000 + time.seconds + 60.0*time.minutes + 3600.0*time.hours;
	return seconds;;
}

//#pragma clang diagnostic pop


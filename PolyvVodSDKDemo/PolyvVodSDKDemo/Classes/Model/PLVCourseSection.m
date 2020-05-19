//
//  PLVCourseSection.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseSection.h"

@implementation PLVCourseSection

+ (NSArray<PLVCourseSection *> *)sectionsWithArray:(NSArray *)array {
	if (!array.count) {
		return nil;
	}
	NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
		NSInteger order1 = [obj1[@"ordered"] integerValue];
		NSInteger order2 = [obj2[@"ordered"] integerValue];
		return order1 - order2 >= 0 ? NSOrderedDescending : NSOrderedAscending;
	}];
	NSMutableArray *sections = [NSMutableArray array];
	PLVCourseSection *section = nil;
	NSMutableArray *videos = [NSMutableArray array];
	for (NSDictionary *dic in sortedArray) {
		NSString *type = dic[@"curriculumType"];
		if ([@"section" isEqualToString:type]) {
			// 维护变量
			if (videos.count) {
				section.videos = videos;
                if (section){
                    [sections addObject:section];
                }
				videos = [NSMutableArray array];
			}
			
			// 新值
			PLVCourseSection *_section = [[PLVCourseSection alloc] init];
			_section.title = dic[@"title"];
			section = _section;
		} else if ([@"lecture" isEqualToString:type]) {
			PLVCourseVideo *video = [[PLVCourseVideo alloc] initWithDic:dic];
			[videos addObject:video];
		}
	}
	if (!section) {
		section = [[PLVCourseSection alloc] init];
	}
	section.videos = videos;
	[sections addObject:section];
	return sections;
}

@end

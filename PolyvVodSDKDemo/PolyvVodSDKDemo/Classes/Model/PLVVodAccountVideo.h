//
//  PLVVodAccountVideo.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/14.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVVodAccountVideo : NSObject

/// filesize 各码率文件大小
@property (nonatomic, strong) NSArray<NSNumber *> *filesizes;

/// first_image 视频截图
@property (nonatomic, copy) NSString *snapshot;

/// cataid 分类ID
@property (nonatomic, copy) NSString *cataid;

/// cataname 分类名称
@property (nonatomic, copy) NSString *cataname;

/// vid
@property (nonatomic, copy) NSString *vid;

/// title 标题
@property (nonatomic, copy) NSString *title;

/// duration 时长
@property (nonatomic, assign) NSTimeInterval duration;

/// status 状态，大于60才能正常播放
@property (nonatomic, assign) NSInteger status;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end

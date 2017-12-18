//
//  PLVCourseVideo.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodSDK/PLVVodSDK.h>

@interface PLVCourseVideo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) double duration;
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, strong) PLVVodVideo *vodVideo;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (void)requestVodVideoWithCompletion:(void (^)(PLVVodVideo *vodVideo))completion;

@end

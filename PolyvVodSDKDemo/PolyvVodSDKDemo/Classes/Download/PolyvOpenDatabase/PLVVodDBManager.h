//
//  PLVVodDBManager.h
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVVodExtendVideoInfo;

@interface PLVVodDBManager : NSObject

+ (void)testDBManager;

// 创建扩展表
+ (BOOL)createExtendInfoTable;

// 插入或更新一条记录
+ (BOOL)insertOrUpdateWithExtendInfo:(PLVVodExtendVideoInfo *)extendInfo;

// 根据条件查询记录
+ (PLVVodExtendVideoInfo *)getExtendInfoWithVid:(NSString *)vid;

// 查询所有记录
+ (NSArray<PLVVodExtendVideoInfo *> *)getAllExtendInfos;

// 根据条件删除记录
+ (BOOL)deleteExtendInfoWithVid:(NSString *)vid;

// 删除所有记录
+ (BOOL)deleteAllExtendInfos;

@end

NS_ASSUME_NONNULL_END

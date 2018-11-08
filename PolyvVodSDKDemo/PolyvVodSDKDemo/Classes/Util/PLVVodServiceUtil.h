//
//  PLVVodServiceUtil.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVUserVideoListResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodServiceUtil : NSObject

/**
 
 根据子账号，分类信息获取视频列表
 
 @param emailAccount    非必须，子帐号邮箱,默认为查询所有子帐号(不包括主账号)
 @param cataId          非必须，分类id,默认为查询所有分类
 @param needSubCata     非必须， 1表示结果包含子分类，0表示结果不包含子分类，默认为0
 @param orderType       非必须，结果排序类型, 1表示ptime升序，2表示ptime降序，3表示times升序，4表示times降序
 @param pageIndex       非必须 ，第几页，默认查询第1页


 */
+ (void)requestVideoListWithAccount:(NSString *)emailAccount
                             cataId:(NSString *)cataId
                            subCata:(NSString *)needSubCata
                          orderType:(NSString *)orderType
                          pageIndex:(NSString *)pageIndex
                      completeBlock:(void(^)(PLVUserVideoListResult *resultModel))success
                          failBlock:(void(^)(NSError *error))fail;


@end

NS_ASSUME_NONNULL_END

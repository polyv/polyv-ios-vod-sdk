//
//  PLVVodDBManager.m
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodDBManager.h"
#import <PLVVodSDK/PLVVodDownloadManager+Database.h>
#import "PLVVodExtendVideoInfo+WCTTableCoding.h"

@implementation PLVVodDBManager

// 创建扩展表
+ (BOOL)createExtendInfoTable{
    return [PLVVodDownloadManager createExtendTableWithClass:[PLVVodExtendVideoInfo class]];
}

// 插入或更新一条记录
+ (BOOL)insertOrUpdateWithExtendInfo:(PLVVodExtendVideoInfo *)extendInfo{
    return [PLVVodDownloadManager insertOrUpdateWithExtendInfo:extendInfo];
}

// 根据条件查询记录
+ (PLVVodExtendVideoInfo *)getExtendInfoWithVid:(NSString *)vid{
    NSArray<PLVVodExtendVideoInfo *> *array = [PLVVodDownloadManager getExtendInfoWithClass:[PLVVodExtendVideoInfo class]
                                                                                  condition:PLVVodExtendVideoInfo.vid==vid];
    
    return [array firstObject];
}

// 查询所有记录
+ (NSArray<PLVVodExtendVideoInfo *> *)getAllExtendInfos{
    NSArray<PLVVodExtendVideoInfo *> *array = [PLVVodDownloadManager getAllExtendInfoWithClass:[PLVVodExtendVideoInfo class]];
    return array;
}

// 根据条件删除记录
+ (BOOL)deleteExtendInfoWithVid:(NSString *)vid{
    return [PLVVodDownloadManager deleteExtendInfoWithClass:[PLVVodExtendVideoInfo class]
                                           condition:PLVVodExtendVideoInfo.vid==vid];
}

// 删除所有记录
+ (BOOL)deleteAllExtendInfos{
    return [PLVVodDownloadManager deleteAllExtendInfoWithClass:[PLVVodExtendVideoInfo class]];
}


+ (void)testDBManager{

    // create table
    [PLVVodDownloadManager createExtendTableWithClass:[PLVVodExtendVideoInfo class]];

    // insert or update
    for (int i = 0; i < 1000; i++){
        PLVVodExtendVideoInfo *extendInfo = [PLVVodExtendVideoInfo new];
        extendInfo.vid = [@"vid_" stringByAppendingFormat:@"%d", i ];
        extendInfo.CusCatagoryID = [@"CusCatagoryID_" stringByAppendingFormat:@"%d", i ];
        extendInfo.CusCatagoryName = [@"CusCatagoryName_" stringByAppendingFormat:@"%d", i ];
        extendInfo.CusCourseID = [@"CusCourseID_" stringByAppendingFormat:@"%d", i ];
        extendInfo.CusCourseName = [@"CusCourseName_" stringByAppendingFormat:@"%d", i ];

        [PLVVodDownloadManager insertOrUpdateWithExtendInfo:extendInfo];
    }

    // query
    for (int i = 0; i < 1000; i++){

        if (i%3){
            // 查询
            NSString *vid = [@"vid_" stringByAppendingFormat:@"%d", i ];
            NSArray<PLVVodExtendVideoInfo *> *array = [PLVVodDownloadManager getExtendInfoWithClass:[PLVVodExtendVideoInfo class]
                                                                                         condition:PLVVodExtendVideoInfo.vid==vid];
//
            NSLog(@"queryData: %@", array);
        }
    }
    
    // query all
    NSArray<PLVVodExtendVideoInfo *> *array = [PLVVodDownloadManager getAllExtendInfoWithClass:[PLVVodExtendVideoInfo class]];
    [array enumerateObjectsUsingBlock:^(PLVVodExtendVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSLog(@"-- %@ --", obj);
    }];
        
    
    // delete
    for (int i = 0; i < 1000; i++){
        
        
        if (i%3){
            // 查询
            NSString *vid = [@"vid_" stringByAppendingFormat:@"%d", i ];
            [PLVVodDownloadManager deleteExtendInfoWithClass:[PLVVodExtendVideoInfo class]
                                                   condition:PLVVodExtendVideoInfo.vid==vid];
            //
        }
    }
    
    // delete all
//    [PLVVodDownloadManager deleteAllExtendInfoWithClass:[PLVVodExtendVideoInfo class]];
}

@end

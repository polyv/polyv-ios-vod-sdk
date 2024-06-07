//
//  PLVVodExtendVideoInfo.mm
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodExtendVideoInfo.h"
#import <PLVFDB/PLVFDatabase.h>

@interface PLVVodExtendVideoInfo () <PLVFDatabaseProtocol>

@end

@implementation PLVVodExtendVideoInfo

#pragma mark - PLVFDatabaseProtocol

+ (nonnull NSString *)primaryKey {
    return @"vid";
}

+ (nonnull NSArray<NSString *> *)propertyKeys {
    return @[
        @"CusCatagoryID",
        @"CusCatagoryName",
        @"CusCourseID",
        @"CusCourseName",
        @"vid"
    ];
}

@end

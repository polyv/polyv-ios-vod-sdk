//
//  PLVVodExtendVideoInfo.mm
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodExtendVideoInfo+WCTTableCoding.h"
#import "PLVVodExtendVideoInfo.h"
#import <WCDB/WCDB.h>

@implementation PLVVodExtendVideoInfo

WCDB_IMPLEMENTATION(PLVVodExtendVideoInfo)
WCDB_SYNTHESIZE(PLVVodExtendVideoInfo, CusCatagoryID)
WCDB_SYNTHESIZE(PLVVodExtendVideoInfo, CusCatagoryName)
WCDB_SYNTHESIZE(PLVVodExtendVideoInfo, CusCourseID)
WCDB_SYNTHESIZE(PLVVodExtendVideoInfo, CusCourseName)
WCDB_SYNTHESIZE(PLVVodExtendVideoInfo, vid)

WCDB_PRIMARY(PLVVodExtendVideoInfo, vid);


@end

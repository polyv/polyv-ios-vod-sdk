//
//  PLVVodExtendVideoInfo.mm
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodExtendVideoInfo+WCTTableCoding.h"
#import "PLVVodExtendVideoInfo.h"

#if __has_include(<WCDB/WCDBObjc.h>)
    #import <WCDB/WCDBObjc.h>
#elif __has_include(<WCDBObjc/WCDBObjc.h>)
    #import <WCDBObjc/WCDBObjc.h>
#elif __has_include(<WCDB/WCDB.h>)
    #import <WCDB/WCDB.h>
#endif

@implementation PLVVodExtendVideoInfo

WCDB_IMPLEMENTATION(PLVVodExtendVideoInfo)
WCDB_SYNTHESIZE(CusCatagoryID)
WCDB_SYNTHESIZE(CusCatagoryName)
WCDB_SYNTHESIZE(CusCourseID)
WCDB_SYNTHESIZE(CusCourseName)
WCDB_SYNTHESIZE(vid)

WCDB_PRIMARY(vid);


@end

//
//  PLVVodExtendVideoInfo+WCTTableCoding.h
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodExtendVideoInfo.h"

#if __has_include(<WCDB/WCDBObjc.h>)
    #import <WCDB/WCDBObjc.h>
#elif __has_include(<WCDBObjc/WCDBObjc.h>)
    #import <WCDBObjc/WCDBObjc.h>
#elif __has_include(<WCDB/WCDB.h>)
    #import <WCDB/WCDB.h>
#endif

@interface PLVVodExtendVideoInfo (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(vid)

// 以下可自定义字段
WCDB_PROPERTY(CusCatagoryID)
WCDB_PROPERTY(CusCatagoryName)
WCDB_PROPERTY(CusCourseID)
WCDB_PROPERTY(CusCourseName)

@end

//
//  PLVVodExtendVideoInfo+WCTTableCoding.h
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodExtendVideoInfo.h"
#import <WCDB/WCDB.h>

@interface PLVVodExtendVideoInfo (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(vid)

// 以下可自定义字段
WCDB_PROPERTY(CusCatagoryID)
WCDB_PROPERTY(CusCatagoryName)
WCDB_PROPERTY(CusCourseID)
WCDB_PROPERTY(CusCourseName)

@end

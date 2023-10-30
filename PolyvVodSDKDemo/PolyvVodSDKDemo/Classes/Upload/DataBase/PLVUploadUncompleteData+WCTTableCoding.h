//
//  PLVUploadUncompleteData+WCTTableCoding.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/24.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadUncompleteData.h"

#if __has_include(<WCDB/WCDBObjc.h>)
    #import <WCDB/WCDBObjc.h>
#elif __has_include(<WCDBObjc/WCDBObjc.h>)
    #import <WCDBObjc/WCDBObjc.h>
#elif __has_include(<WCDB/WCDB.h>)
    #import <WCDB/WCDB.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadUncompleteData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(vid)
WCDB_PROPERTY(status)
WCDB_PROPERTY(title)
WCDB_PROPERTY(originFileName)
WCDB_PROPERTY(fileSize)
WCDB_PROPERTY(progress)
WCDB_PROPERTY(createDate)

@end

NS_ASSUME_NONNULL_END

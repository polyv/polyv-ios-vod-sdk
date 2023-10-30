//
//  PLVUploadCompleteData+WCTTableCoding.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadCompleteData.h"

#if __has_include(<WCDB/WCDBObjc.h>)
    #import <WCDB/WCDBObjc.h>
#elif __has_include(<WCDBObjc/WCDBObjc.h>)
    #import <WCDBObjc/WCDBObjc.h>
#elif __has_include(<WCDB/WCDB.h>)
    #import <WCDB/WCDB.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadCompleteData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(vid)
WCDB_PROPERTY(title)
WCDB_PROPERTY(fileSize)
WCDB_PROPERTY(completeDate)

@end

NS_ASSUME_NONNULL_END

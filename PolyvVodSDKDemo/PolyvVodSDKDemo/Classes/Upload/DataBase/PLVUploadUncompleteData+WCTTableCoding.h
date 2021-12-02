//
//  PLVUploadUncompleteData+WCTTableCoding.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/24.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadUncompleteData.h"
#import <WCDB/WCDB.h>

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

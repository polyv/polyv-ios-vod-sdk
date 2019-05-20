//
//  PLVUploadCompleteData+WCTTableCoding.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadCompleteData.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadCompleteData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(vid)
WCDB_PROPERTY(title)
WCDB_PROPERTY(fileSize)
WCDB_PROPERTY(completeDate)

@end

NS_ASSUME_NONNULL_END

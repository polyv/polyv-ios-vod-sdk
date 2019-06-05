//
//  PLVUploadUncompleteData.m，
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/24.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadUncompleteData.h"
#import "PLVUploadCompleteData+WCTTableCoding.h"
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>
#import "PLVUploadModel.h"

@implementation PLVUploadUncompleteData

WCDB_IMPLEMENTATION(PLVUploadUncompleteData)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, vid)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, status)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, title)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, fileSize)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, progress)
WCDB_SYNTHESIZE(PLVUploadUncompleteData, createDate)

WCDB_PRIMARY(PLVUploadUncompleteData, vid)

WCDB_INDEX(PLVUploadUncompleteData, "_index", createDate)

- (instancetype)initWithVideo:(PLVUploadVideo *)video {
    self = [super init];
    if (self) {
        _vid = video.vid;
        _title = video.fileName;
        _fileSize = video.fileSize;
        _createDate = [NSDate date];
        _status = video.status;
        _progress = 0.0;
    }
    return self;
}

- (PLVUploadModel *)changeToModel {
    PLVUploadModel *model = [[PLVUploadModel alloc] init];
    model.vid = self.vid;
    model.title = self.title;
    model.fileSize = self.fileSize;
    model.progress = self.progress;
    model.createDate = self.createDate;
    model.status = self.status;
    return model;
}

#pragma mark - Override

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> \n%@",[self class],&self, [self propertyDictionary]];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p> \n%@",[self class],&self, [self propertyDictionary]];
}

- (NSDictionary *)propertyDictionary {
    return @{
             @"vid":self.vid,
             @"status":@(self.status),
             @"title":self.title,
             @"fileSize":@(self.fileSize),
             @"progress":@(self.progress),
             @"createDate":self.createDate
             };
}

@end

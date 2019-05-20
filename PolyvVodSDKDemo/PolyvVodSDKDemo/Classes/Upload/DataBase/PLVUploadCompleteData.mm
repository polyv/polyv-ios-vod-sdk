//
//  PLVUploadCompleteData.mm
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadCompleteData.h"
#import "PLVUploadUncompleteData.h"
#import "PLVUploadModel.h"
#import "PLVUploadCompleteData+WCTTableCoding.h"


@implementation PLVUploadCompleteData

WCDB_IMPLEMENTATION(PLVUploadCompleteData)
WCDB_SYNTHESIZE(PLVUploadCompleteData, vid)
WCDB_SYNTHESIZE(PLVUploadCompleteData, title)
WCDB_SYNTHESIZE(PLVUploadCompleteData, fileSize)
WCDB_SYNTHESIZE(PLVUploadCompleteData, completeDate)

WCDB_PRIMARY(PLVUploadCompleteData, vid)

WCDB_INDEX(PLVUploadCompleteData, "_index", completeDate)

- (instancetype)initWithUncompleteData:(PLVUploadUncompleteData *)uncompleteData {
    self = [super init];
    if (self) {
        _vid = uncompleteData.vid;
        _title = uncompleteData.title;
        _fileSize = uncompleteData.fileSize;
        _completeDate = [NSDate date];
    }
    return self;
}

- (PLVUploadModel *)changeToModel {
    PLVUploadModel *model = [[PLVUploadModel alloc] init];
    model.vid = self.vid;
    model.title = self.title;
    model.fileSize = self.fileSize;
    model.completeDate = self.completeDate;
    model.status = PLVUploadStatusComplete;
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
             @"title":self.title,
             @"fileSize":@(self.fileSize),
             @"completeDate":self.completeDate
             };
}

@end

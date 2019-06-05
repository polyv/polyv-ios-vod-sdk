//
//  PLVUploadModel.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/17.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadModel.h"

@interface PLVUploadModel ()

@property (nonatomic, strong) PLVUploadVideo *video;

@end

@implementation PLVUploadModel

#pragma mark - Public

- (instancetype)initWithVideo:(PLVUploadVideo *)video {
    self = [super init];
    if (self) {
        _video = video;
        
        _vid = video.vid;
        _fileURL = video.fileURL;
        _title = video.fileName;
        _fileSize = video.fileSize;
        _progress = 0.0;
        _status = video.status;
        _createDate = [NSDate date];
        _completeDate = nil;
    }
    return self;
}

- (void)updateStatusWithVideo:(PLVUploadVideo *)video {
    self.status = video.status;
}

- (void)linkVideo:(PLVUploadVideo *)video {
    if (video) {
        self.video = video;
    }
}

- (void)updateProgress:(float)progress {
    self.progress = progress;
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
             @"fileURL":self.fileURL,
             @"title":self.title,
             @"fileSize":@(self.fileSize),
             @"progress":@(self.progress),
             @"status":@(self.status),
             @"createDate":self.createDate,
             @"completeDate":self.completeDate,
             @"video":self.video
             };
}

@end

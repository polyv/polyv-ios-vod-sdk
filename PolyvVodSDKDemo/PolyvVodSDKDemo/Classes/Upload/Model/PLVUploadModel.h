//
//  PLVUploadModel.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/17.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadModel : NSObject

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger fileSize;

@property (nonatomic, assign) float progress;

@property (nonatomic, assign) PLVUploadStatus status;

@property (nonatomic, strong) NSDate *createDate;

@property (nonatomic, strong) NSDate *completeDate;

@property (nonatomic, strong, readonly) PLVUploadVideo *video;

- (instancetype)initWithVideo:(PLVUploadVideo *)video;

- (void)updateStatusWithVideo:(PLVUploadVideo *)video;

- (void)linkVideo:(PLVUploadVideo *)video;

- (void)updateProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END

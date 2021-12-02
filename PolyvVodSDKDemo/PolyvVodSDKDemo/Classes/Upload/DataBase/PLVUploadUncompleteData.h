//
//  PLVUploadUncompleteData.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/24.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

@class PLVUploadModel;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadUncompleteData : NSObject

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, assign) PLVUploadStatus status;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *originFileName;

@property (nonatomic, assign) NSInteger fileSize;

@property (nonatomic, assign) float progress;

@property (nonatomic, strong) NSDate *createDate;

- (instancetype)initWithVideo:(PLVUploadVideo *)video;

- (PLVUploadModel *)changeToModel;

@end

NS_ASSUME_NONNULL_END

//
//  PLVUploadDataBase.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>
#import <PLVFDB/PLVFDatabase.h>

@class PLVUploadCompleteData, PLVUploadUncompleteData;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadDataBase : NSObject

@property (nonatomic, strong) PLVFDatabase *database;

+ (instancetype)sharedDataBase;

@end

@interface PLVUploadDataBase (CompleteData)

- (void)insertCompleteData:(PLVUploadCompleteData *)completeData;

- (void)deleteCompleteDataWithVid:(NSString *)vid;

- (NSArray<PLVUploadCompleteData *> *  _Nullable)getAllCompleteData;

@end

@interface PLVUploadDataBase (UncompleteData)

- (void)insertUncompleteData:(PLVUploadUncompleteData *)uncompleteData;

- (void)deleteUncompleteDataWithVid:(NSString *)vid;

- (void)updateAllUncompleteDataFromWaitingToAborted;

- (void)updateAllUncompleteDataFromUploadingToResumable;

- (void)updateUncompleteDataStatus:(PLVUploadStatus)status withVid:(NSString *)vid;

- (void)updateUncompleteDataProgress:(float)progress withVid:(NSString *)vid;

- (PLVUploadUncompleteData * _Nullable)getUncompleteDataWithVid:(NSString *)vid;

- (PLVUploadUncompleteData * _Nullable)getUncompleteDataWithTitle:(NSString *)title;

- (NSArray<PLVUploadUncompleteData *> * _Nullable)getAllUncompleteData;

@end

NS_ASSUME_NONNULL_END

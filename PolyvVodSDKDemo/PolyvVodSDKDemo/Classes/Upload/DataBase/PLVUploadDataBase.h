//
//  PLVUploadDataBase.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

#if __has_include(<WCDB/WCDBObjc.h>)
    #import <WCDB/WCDBObjc.h>
#elif __has_include(<WCDBObjc/WCDBObjc.h>)
    #import <WCDBObjc/WCDBObjc.h>
#elif __has_include(<WCDB/WCDB.h>)
    #import <WCDB/WCDB.h>
#endif

@class PLVUploadCompleteData, PLVUploadUncompleteData;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadDataBase : NSObject

@property (nonatomic, strong) WCTDatabase *database;

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

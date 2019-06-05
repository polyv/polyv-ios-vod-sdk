//
//  PLVUploadTableViewModel.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/19.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVUploadTableViewController.h"

@class PLVUploadVideo, PLVUploadModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PLVUploadListViewModelType) {
    PLVUploadListViewModelTypeUncomplete = 0,
    PLVUploadListViewModelTypeComplete
};

@interface PLVUploadTableViewModel : NSObject

@property (nonatomic, weak) id<PLVUploadTableViewControllerDelegate> viewController;

- (instancetype)initWithViewController:(id<PLVUploadTableViewControllerDelegate>)controller;

- (NSInteger)sectionNumber;

- (NSInteger)rowNumberAtSection:(NSInteger)section;

- (PLVUploadListViewModelType)typeAtSection:(NSInteger)section;

- (NSString *)tableHeaderTextAtSection:(NSInteger)section;

- (PLVUploadModel * _Nullable)modelAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isVideoUploading:(NSURL *)fileURL;

- (void)uploadStartWithVideo:(PLVUploadVideo *)video;

- (void)uploadEndWithVideo:(PLVUploadVideo *)video;

- (void)uploadFailureWithVid:(NSString *)vid;

- (void)uploadAbortWithVid:(NSString *)vid;

- (void)uploadSuccessWithVid:(NSString *)vid;

- (void)uploadProgressChanged:(float)progress withVid:(NSString *)vid;

- (void)deleteDataAtIndex:(NSIndexPath *)indexPath;

- (NSString *)cacheDirectory;

@end

NS_ASSUME_NONNULL_END


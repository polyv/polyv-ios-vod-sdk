//
//  PLVUploadDataBase.mm
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadDataBase.h"
#import "PLVUploadCompleteData.h"
#import "PLVUploadUncompleteData.h"
#import "PLVUploadCompleteData.h"
#import "PLVUploadUncompleteData.h"
#import <PLVVodSDK/PLVVodSDK.h>

static NSString *kCompleteUploadTableName = @"PLVUploadCompleteData";
static NSString *kUncompleteUploadTableName = @"PLVUploadUncompleteData";

@implementation PLVUploadDataBase

+ (instancetype)sharedDataBase {
    static dispatch_once_t onceToken;
    static PLVUploadDataBase *dataBase = nil;
    dispatch_once(&onceToken, ^{
        dataBase = [[PLVUploadDataBase alloc] init];
    });
    return dataBase;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [NSString stringWithFormat:@"%@/plvUploadData", [self databaseDirectory]];
        _database = [PLVFDatabase databaseWithPath:path];
        NSString *logMessage = [NSString stringWithFormat:@"数据库路径：\n%@", path];
        [self logForMessage:logMessage];
        
        BOOL completeRresult = [_database createTable:kCompleteUploadTableName withClass:PLVUploadCompleteData.class];
        logMessage = [NSString stringWithFormat:@"初始化表格 %@ %@", kCompleteUploadTableName, completeRresult ? @"成功" : @"失败"];
        [self logForMessage:logMessage];
        
        BOOL uncompleteResult = [_database createTable:kUncompleteUploadTableName withClass:PLVUploadUncompleteData.class];
        logMessage = [NSString stringWithFormat:@"初始化表格 %@ %@", kUncompleteUploadTableName, uncompleteResult ? @"成功" : @"失败"];
        [self logForMessage:logMessage];
    }
    return self;
}

- (NSString *)databaseDirectory {
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", cachesDirectory, [PLVVodSettings sharedSettings].userid];
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exist || isDirectory == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (void)logForMessage:(NSString *)message {
    NSLog(@"【上传数据库】%@", message);
}

@end

#pragma mark -

@implementation PLVUploadDataBase(CompleteData)

- (void)insertCompleteData:(PLVUploadCompleteData *)completeData {
    BOOL result = [self.database insert:completeData table:kCompleteUploadTableName];
    NSString *logMessage = [NSString stringWithFormat:@"插入数据 %@ %@", completeData, result ? @"成功" : @"失败"];
    [self logForCompleteDataMessage:logMessage];
}

- (void)deleteCompleteDataWithVid:(NSString *)vid {
    BOOL result = [self.database deleteTable:kCompleteUploadTableName where:[NSString stringWithFormat:@"where vid = '%@'",vid]];
    NSString *logMessage = [NSString stringWithFormat:@"删除 vid = %@ 的数据%@", vid, result ? @"成功" : @"失败"];
    [self logForCompleteDataMessage:logMessage];
}

- (NSArray<PLVUploadCompleteData *> *)getAllCompleteData {
    NSArray<PLVUploadCompleteData *> *completeDatas = [self.database objectsFromClass:[PLVUploadCompleteData class] table:kCompleteUploadTableName where:nil];
    NSString *logMessage = [NSString stringWithFormat:@"获取所有数据 %@", completeDatas];
    [self logForCompleteDataMessage:logMessage];
    return completeDatas;
}

#pragma mark Private

- (void)logForCompleteDataMessage:(NSString *)message {
    NSLog(@"【上传数据库】%@: %@", kCompleteUploadTableName, message);
}

@end

#pragma mark -

@implementation PLVUploadDataBase(UncompleteData)

- (void)insertUncompleteData:(PLVUploadUncompleteData *)uncompleteData {
    BOOL result = [self.database insert:uncompleteData table:kUncompleteUploadTableName];
    NSString *logMessage = [NSString stringWithFormat:@"插入数据 %@ %@", uncompleteData, result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (void)deleteUncompleteDataWithVid:(NSString *)vid {
    BOOL result = [self.database deleteTable:kUncompleteUploadTableName where:[NSString stringWithFormat:@"where vid = '%@'",vid]];
    NSString *logMessage = [NSString stringWithFormat:@"删除 vid = %@ 的数据%@", vid, result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (void)updateAllUncompleteDataFromUploadingToResumable {
    BOOL result = [self.database updateFromTable:kUncompleteUploadTableName values:[NSString stringWithFormat:@"status = %ld",PLVUploadStatusResumable] where:[NSString stringWithFormat:@"where status = %ld",PLVUploadStatusUploading]];
    NSString *logMessage = [NSString stringWithFormat:@"修改数据状态\"上传中\" -> \"可续传\" %@", result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (void)updateAllUncompleteDataFromWaitingToAborted {
    BOOL result = [self.database updateFromTable:kUncompleteUploadTableName values:[NSString stringWithFormat:@"status = %ld",PLVUploadStatusAborted] where:[NSString stringWithFormat:@"where status = %ld",PLVUploadStatusWaiting]];
    NSString *logMessage = [NSString stringWithFormat:@"修改数据状态\"等待中\" -> \"被中止\" %@", result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (void)updateUncompleteDataStatus:(PLVUploadStatus)status withVid:(NSString *)vid {
    PLVUploadUncompleteData *originData = [self getUncompleteDataWithVid:vid];
    if (originData.status == PLVUploadStatusAborted && status == PLVUploadStatusFailure) {
        return;
    }
    BOOL result = [self.database updateFromTable:kUncompleteUploadTableName values:[NSString stringWithFormat:@"status = %ld",status] where:[NSString stringWithFormat:@"where vid = '%@'",vid]];
    NSString *logMessage = [NSString stringWithFormat:@"修改 vid = %@ 的数据的 status 为 %zd %@", vid, status, result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (void)updateUncompleteDataProgress:(float)progress withVid:(NSString *)vid {
    PLVUploadUncompleteData *uncompleteData = [[PLVUploadUncompleteData alloc] init];
    uncompleteData.progress = progress;
    BOOL result = [self.database updateFromTable:kUncompleteUploadTableName values:[NSString stringWithFormat:@"progress = %f",progress] where:[NSString stringWithFormat:@"where vid = '%@'",vid]];
    NSString *logMessage = [NSString stringWithFormat:@"修改 vid = %@ 的数据的 progress 为 %.2f %@", vid, progress, result ? @"成功" : @"失败"];
    [self logForUncompleteDataMessage:logMessage];
}

- (PLVUploadUncompleteData *)getUncompleteDataWithVid:(NSString *)vid {
    NSArray<PLVUploadUncompleteData *> *uncompleteDatas = [self.database objectsFromClass:PLVUploadUncompleteData.class table:kUncompleteUploadTableName where:[NSString stringWithFormat:@"where vid = '%@'",vid]];
    NSString *logMessage = [NSString stringWithFormat:@"获取 vid = %@ 的数据 %@", vid, [uncompleteDatas count] > 0 ? uncompleteDatas[0] : @"为空"];
    [self logForUncompleteDataMessage:logMessage];
    if ([uncompleteDatas count] > 0) {
        return uncompleteDatas[0];
    } else {
        return nil;
    }
}

- (PLVUploadUncompleteData *)getUncompleteDataWithTitle:(NSString *)title {
    NSArray<PLVUploadUncompleteData *> *uncompleteDatas = [self.database objectsFromClass:PLVUploadUncompleteData.class table:kUncompleteUploadTableName where:[NSString stringWithFormat:@"where title = '%@'",title]];
    NSString *logMessage = [NSString stringWithFormat:@"获取 title = %@ 的数据 %@", title, [uncompleteDatas count] > 0 ? uncompleteDatas[0] : @"为空"];
    [self logForUncompleteDataMessage:logMessage];
    if ([uncompleteDatas count] > 0) {
        return uncompleteDatas[0];
    } else {
        return nil;
    }
}

- (NSArray<PLVUploadUncompleteData *> *)getAllUncompleteData {
    NSArray<PLVUploadUncompleteData *> *uncompleteDatas =  [self.database objectsFromClass:PLVUploadUncompleteData.class table:kUncompleteUploadTableName order:@"order by createDate asc"];
    NSString *logMessage = [NSString stringWithFormat:@"获取所有数据 %@", uncompleteDatas];
    [self logForUncompleteDataMessage:logMessage];
    return uncompleteDatas;
}

#pragma mark Private

- (void)logForUncompleteDataMessage:(NSString *)message {
    NSLog(@"【上传数据库】%@: %@", kUncompleteUploadTableName, message);
}

@end

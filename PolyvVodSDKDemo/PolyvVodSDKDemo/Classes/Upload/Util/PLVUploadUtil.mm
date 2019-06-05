//
//  PLVUploadUtil.mm
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/28.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadUtil.h"
#import "PLVUploadToast.h"
#import "PLVUploadDataBase.h"
#import "PLVUploadCompleteData.h"
#import "PLVUploadUncompleteData.h"
#import "PLVUploadTableViewController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

extern NSString *PLVUploadAbortNotification;

@interface PLVUploadUtil ()<
PLVUploadClientDelegate
>

@end

@implementation PLVUploadUtil

+ (instancetype)sharedUtil {
    static dispatch_once_t onceToken;
    static PLVUploadUtil *util = nil;
    dispatch_once(&onceToken, ^{
        util = [[PLVUploadUtil alloc] init];
    });
    return util;
}

- (void)dealloc {
    [[PLVUploadClient sharedClient] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PLVUploadClientDelegate

- (void)uploadClientLoginError:(NSError *)error {
    
    NSString *logMessage = @"uploadClientLoginError: ";
    
    if (error.code == PLVClientErrorCodeLoginFailure) {
        logMessage = [logMessage stringByAppendingString:@"登录失败"];
    } else if (error.code == PLVClientErrorCodeAccountError) {
        logMessage = [logMessage stringByAppendingString:@"不得使用公共账号"];
    } else if (error.code == PLVClientErrorCodeGetTokenFailure) {
        logMessage = [logMessage stringByAppendingString:@"获取 token 失败"];
    }
    
    logMessage = [logMessage stringByAppendingFormat:@" {\n%@}", error];
    [self logForMessage:logMessage];
}

- (void)prepareUploadError:(NSError *)error fileURL:(NSURL *)fileURL {
    if (error.code == PLVClientErrorCodeHaventLogin) {
        // 重新登录
        PLVVodSettings *settings = [PLVVodSettings sharedSettings];
        [[PLVUploadClient sharedClient] loginWithUserId:settings.userid secretKey:settings.secretkey];
    }
}

- (void)startUploadTaskFailure:(NSString *)vid {
    PLVUploadUncompleteData *uncompleteData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithVid:vid];
    if (uncompleteData) {
        [[PLVUploadDataBase sharedDataBase] updateUncompleteDataStatus:PLVUploadStatusFailure withVid:vid];
    }
}

- (void)waitingUploadTask:(PLVUploadVideo *)video {
    [self uploadStartWithVideo:video];
}

- (void)startUploadTask:(PLVUploadVideo *)video {
    [self uploadStartWithVideo:video];
}

- (void)didUploadTask:(PLVUploadVideo *)video error:(NSError *)error {
    if (error) {
        if (error.code == PLVClientErrorCodeOSSErrorCanResumeUpload) { // 可重试
            [[PLVUploadDataBase sharedDataBase] updateUncompleteDataStatus:PLVUploadStatusResumable withVid:video.vid];
        } else { // 不可重试
            PLVUploadUncompleteData *uncompleteData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithVid:video.vid];
            if (uncompleteData && uncompleteData.status != PLVUploadStatusAborted) {
                [[PLVUploadDataBase sharedDataBase] updateUncompleteDataStatus:PLVUploadStatusFailure withVid:video.vid];
            }
        }
    } else {
        PLVUploadUncompleteData *uncompleteData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithVid:video.vid];
        if (uncompleteData == nil) {
            return;
        }
        
        PLVUploadCompleteData *completeData = [[PLVUploadCompleteData alloc] initWithUncompleteData:uncompleteData];
        [[PLVUploadDataBase sharedDataBase] insertCompleteData:completeData];
        [[PLVUploadDataBase sharedDataBase] deleteUncompleteDataWithVid:video.vid];
    }
}

- (void)uploadTask:(NSString *)vid progressChange:(float)progress {
    [[PLVUploadDataBase sharedDataBase] updateUncompleteDataProgress:progress withVid:vid];
}

#pragma mark - Notification

- (void)uploadAbort:(NSNotification *)notification {
    NSString *vid = (NSString *)notification.object;
    [[PLVUploadDataBase sharedDataBase] updateUncompleteDataStatus:PLVUploadStatusAborted withVid:vid];
}

#pragma mark - Public

- (void)loginUploadClient {
    PLVVodSettings *settings = [PLVVodSettings sharedSettings];
    [[PLVUploadClient sharedClient] loginWithUserId:settings.userid secretKey:settings.secretkey];
    [PLVUploadClient sharedClient].enableLog = YES;
    [[PLVUploadClient sharedClient] addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAbort:) name:PLVUploadAbortNotification object:nil];
}

- (void)uploadVideos:(NSArray *)filePathArray {
    for (NSString *filePath in filePathArray) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if ([self isVideoUploading:fileURL]) {
            continue;
        }
        
        PLVUploadParameter *parameter = [[PLVUploadParameter alloc] init];
        parameter.fileURL = fileURL;
        NSError *error = [[PLVUploadClient sharedClient] uploadVideoWithMutipleParameter:parameter];
        if (error) {
            NSString *logMessage = [NSString stringWithFormat:@"uploadVideos 失败: fileURL - %@, %@", fileURL, error];
            [self logForMessage:logMessage];
            
            if (error.code == PLVClientErrorCodeInitUploadTaskFailure) {
                [self toastToNotifyUploadFailure:fileURL];
                continue;
            } else if (error.code == PLVClientErrorCodeNoEnoughSpace) {
                [self toastToNotifyNoEnoughSpace];
                break;
            } else if (error.code == PLVClientErrorCodeHaventLogin) {
                [self toastToNotifyHaventLogin];
                break;
            }
        } else {
            NSString *logMessage = [NSString stringWithFormat:@"uploadVideos 成功: fileURL - %@", fileURL];
            [self logForMessage:logMessage];
        }
    }
}

#pragma mark - Toast Relate

- (void)toastToNotifyUploadFailure:(NSURL *)fileURL {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fileName = [fileURL lastPathComponent];
        NSString *tips = [NSString stringWithFormat:@"视频%@初始化失败", fileName];
        [PLVUploadToast showText:tips];
    });
}

- (void)toastToNotifyNoEnoughSpace {
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        if ([navVC.topViewController isKindOfClass:[PLVUploadTableViewController class]]) {
            return;
        }
        [PLVUploadToast showText:@"剩余空间已不足"];
    });
}

- (void)toastToNotifyHaventLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        [PLVUploadToast showText:@"上传失败，请检查您的网络"];
    });
}

#pragma mark - Private

- (void)uploadStartWithVideo:(PLVUploadVideo *)video {
    PLVUploadUncompleteData *needRemoveData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithTitle:video.fileName];
    if (needRemoveData && ![needRemoveData.vid isEqualToString:video.vid]) {
        [[PLVUploadDataBase sharedDataBase] deleteUncompleteDataWithVid:needRemoveData.vid];
    }
    
    PLVUploadUncompleteData *uncompleteData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithVid:video.vid];
    if (uncompleteData) {
        [[PLVUploadDataBase sharedDataBase] updateUncompleteDataStatus:video.status withVid:video.vid];
    } else {
        uncompleteData = [[PLVUploadUncompleteData alloc] initWithVideo:video];
        if (needRemoveData) {
            uncompleteData.createDate = needRemoveData.createDate;
        }
        [[PLVUploadDataBase sharedDataBase] insertUncompleteData:uncompleteData];
    }
}

- (BOOL)isVideoUploading:(NSURL *)fileURL {
    NSString *fileName = [fileURL lastPathComponent];
    PLVUploadUncompleteData *uncompleteData = [[PLVUploadDataBase sharedDataBase] getUncompleteDataWithTitle:fileName];
    return uncompleteData != nil;
}

- (void)logForMessage:(NSString *)message {
    NSLog(@"【%@】%@", self, message);
}

@end

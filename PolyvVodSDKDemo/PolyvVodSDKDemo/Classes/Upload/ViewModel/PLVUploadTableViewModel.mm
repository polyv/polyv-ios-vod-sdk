//
//  PLVUploadTableViewModel.mm
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/19.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadTableViewModel.h"
#import "PLVUploadModel.h"
#import "PLVUploadDataBase.h"
#import "PLVUploadCompleteData.h"
#import "PLVUploadUncompleteData.h"
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

@interface PLVUploadTableModel : NSObject

@property (nonatomic, assign) PLVUploadListViewModelType type;

@property (nonatomic, strong) NSMutableArray <PLVUploadModel *> *modelArray;

@end

@implementation PLVUploadTableModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _modelArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)tableModelWithType:(PLVUploadListViewModelType)type {
    PLVUploadTableModel *tableModel = [[PLVUploadTableModel alloc] init];
    tableModel.type = type;
    return tableModel;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> \n%@",[self class],&self, [self propertyDictionary]];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p> \n%@",[self class],&self, [self propertyDictionary]];
}

- (NSDictionary *)propertyDictionary {
    return @{
             @"type":@(self.type),
             @"modelArray":self.modelArray
             };
}

@end

@interface PLVUploadTableViewModel ()

@property (nonatomic, strong) NSArray <PLVUploadTableModel *> *listDataArray;

@end

@implementation PLVUploadTableViewModel

#pragma mark - Public

- (instancetype)initWithViewController:(id<PLVUploadTableViewControllerDelegate>)controller {
    self = [super init];
    if (self) {
        _viewController = controller;
        PLVUploadTableModel *listDataModel0 = [PLVUploadTableModel tableModelWithType:PLVUploadListViewModelTypeUncomplete];
        PLVUploadTableModel *listDataModel1 = [PLVUploadTableModel tableModelWithType:PLVUploadListViewModelTypeComplete];
        _listDataArray = @[listDataModel0, listDataModel1];
        [self fetchData];
    }
    return self;
}

- (NSInteger)sectionNumber {
    NSInteger sectionNumber = 0;
    for (PLVUploadTableModel *tableModel in self.listDataArray) {
        if ([tableModel.modelArray count] > 0) {
            sectionNumber++;
        }
    }
    return sectionNumber;
}

- (NSInteger)rowNumberAtSection:(NSInteger)section {
    NSMutableArray *modelArray = [self modelArrayAtSection:section];
    return [modelArray count];
}

- (PLVUploadListViewModelType)typeAtSection:(NSInteger)section {
    PLVUploadTableModel *tableModel = [self tableModelAtSection:section];
    return tableModel ? tableModel.type : PLVUploadListViewModelTypeUncomplete;
}

- (NSString *)tableHeaderTextAtSection:(NSInteger)section {
    PLVUploadListViewModelType type = [self typeAtSection:section];
    NSInteger count = [self rowNumberAtSection:section];
    NSString *typeString = (type == PLVUploadListViewModelTypeUncomplete) ? @"上传中" : @"已完成";
    NSString *returnText = [NSString stringWithFormat:@"%@(%zd)", typeString, count];
    return returnText;
}

- (PLVUploadModel *)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *modelArray = [self modelArrayAtSection:indexPath.section];
    if ([modelArray count] > indexPath.row) {
        PLVUploadModel *model = modelArray[indexPath.row];
        return model;
    } else {
        return nil;
    }
}

- (BOOL)isVideoUploading:(NSURL *)fileURL {
    PLVUploadModel *model = [self findVideoWithFileURL:fileURL withType:PLVUploadListViewModelTypeUncomplete];
    return model != nil;
}

- (void)uploadStartWithVideo:(PLVUploadVideo *)video {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[video.fileURL path]]) {
        return;
    }
    
    PLVUploadModel *model = [self findVideoWithVid:video.vid withType:PLVUploadListViewModelTypeUncomplete];
    
    PLVUploadModel *needRemovedModel = [self findVideoWithFileURL:video.fileURL withType:PLVUploadListViewModelTypeUncomplete];
    BOOL needReplace = NO;
    if (needRemovedModel && ![needRemovedModel.vid isEqualToString:model.vid]) {
        needReplace = YES;
    }
    
    if (model) {
        [model updateStatusWithVideo:video];
        [model linkVideo:video];
    } else {
        NSMutableArray *modelArray = [self videosWithType:PLVUploadListViewModelTypeUncomplete];
        PLVUploadModel *model = [[PLVUploadModel alloc] initWithVideo:video];
        if (needReplace) {
            model.createDate = needRemovedModel.createDate;
            NSUInteger index = [modelArray indexOfObject:needRemovedModel];
            [modelArray replaceObjectAtIndex:index withObject:model];
        } else {
            [modelArray addObject:model];
        }
    }
    [self.viewController reloadTableView];
}

- (void)uploadEndWithVideo:(PLVUploadVideo *)video {
    PLVUploadModel *model = [self findVideoWithVid:video.vid withType:PLVUploadListViewModelTypeUncomplete];
    if (model && model.status != PLVUploadStatusAborted) {
        model.status = video.status;
        [self.viewController reloadTableView];
    }
}

- (void)uploadFailureWithVid:(NSString *)vid {
    PLVUploadModel *model = [self findVideoWithVid:vid withType:PLVUploadListViewModelTypeUncomplete];
    if (model) {
        model.status = PLVUploadStatusFailure;
        [self.viewController reloadTableView];
    }
}

- (void)uploadAbortWithVid:(NSString *)vid {
    PLVUploadModel *model = [self findVideoWithVid:vid withType:PLVUploadListViewModelTypeUncomplete];
    if (model) {
        model.status = PLVUploadStatusAborted;
        [self.viewController reloadTableView];
    }
}

- (void)uploadSuccessWithVid:(NSString *)vid {
    PLVUploadModel *model = [self findVideoWithVid:vid withType:PLVUploadListViewModelTypeUncomplete];
    if (model == nil) {
        return;
    }
    
    model.status = PLVUploadStatusComplete;
    model.completeDate = [NSDate date];
    NSMutableArray *uncompleteModelArray = [self videosWithType:PLVUploadListViewModelTypeUncomplete];
    NSMutableArray *completeModelArray = [self videosWithType:PLVUploadListViewModelTypeComplete];
    [completeModelArray insertObject:model atIndex:0];
    [uncompleteModelArray removeObject:model];
    [self.viewController reloadTableView];
}

- (void)uploadProgressChanged:(float)progress withVid:(NSString *)vid {
    PLVUploadModel *model = [self findVideoWithVid:vid withType:PLVUploadListViewModelTypeUncomplete];
    [model updateProgress:progress];
}

- (void)deleteDataAtIndex:(NSIndexPath *)indexPath {
    NSMutableArray *modelArray = [self modelArrayAtSection:indexPath.section];
    
    PLVUploadModel *model = [self modelAtIndexPath:indexPath];
    if (model == nil) {
        return;
    }
    
    [modelArray removeObjectAtIndex:indexPath.row];
    [self.viewController reloadTableView];
    
    if (model.status == PLVUploadStatusComplete) {
        [[PLVUploadDataBase sharedDataBase] deleteCompleteDataWithVid:model.vid];
    } else {
        [[PLVUploadDataBase sharedDataBase] deleteUncompleteDataWithVid:model.vid];
    }
}

#pragma mark - Private

- (PLVUploadTableModel *)tableModelAtSection:(NSInteger)section {
    if (section >= 2) {
        return nil;
    }
    NSInteger sectionIndex = -1;
    for (PLVUploadTableModel *tableModel in self.listDataArray) {
        if([tableModel.modelArray count] == 0) {
            continue;
        }
        sectionIndex++;
        if (sectionIndex == section) {
            return tableModel;
        }
    }
    return nil;
}

- (NSMutableArray *)modelArrayAtSection:(NSInteger)section {
    PLVUploadTableModel *tableModel = [self tableModelAtSection:section];
    return tableModel ? tableModel.modelArray : nil;
}

- (NSMutableArray *)videosWithType:(PLVUploadListViewModelType)type {
    for (PLVUploadTableModel *listDataModel in self.listDataArray) {
        if (listDataModel.type == type) {
            return listDataModel.modelArray;
        }
    }
    return nil;
}

- (PLVUploadModel *)findVideoWithVid:(NSString *)vid withType:(PLVUploadListViewModelType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@", @"vid", vid];
    NSMutableArray *modelArray = [self videosWithType:type];
    NSArray *filteredModels = [modelArray filteredArrayUsingPredicate:predicate];
    return ([filteredModels count] > 0) ? filteredModels[0] : nil;
}

- (PLVUploadModel *)findVideoWithFileURL:(NSURL *)fileURL withType:(PLVUploadListViewModelType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"fileURL", fileURL];
    NSMutableArray *modelArray = [self videosWithType:type];
    NSArray *filteredModels = [modelArray filteredArrayUsingPredicate:predicate];
    return ([filteredModels count] > 0) ? filteredModels[0] : nil;
}

- (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dirString = [NSString stringWithFormat:@"%@/plvUploadFileCaches", paths[0]];
    return dirString;
}

#pragma mark - Private

- (void)fetchData {
    BOOL uploading = [[PLVUploadClient sharedClient].allUploadVideos count] > 0;
    if (uploading == NO) {
        [[PLVUploadDataBase sharedDataBase] updateAllUncompleteDataFromUploadingToResumable];
        [[PLVUploadDataBase sharedDataBase] updateAllUncompleteDataFromWaitingToAborted];
    }
    
    NSArray <PLVUploadUncompleteData *> *uncompleteDatas = [[PLVUploadDataBase sharedDataBase] getAllUncompleteData];
    if ([uncompleteDatas count] > 0) {
        NSMutableArray *modelArray = [self videosWithType:PLVUploadListViewModelTypeUncomplete];
        for (PLVUploadUncompleteData *uncompleteData in uncompleteDatas) {
            PLVUploadModel *model = [uncompleteData changeToModel];
            NSString *originFileName = uncompleteData.originFileName ?: uncompleteData.title;
            NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], originFileName];
            model.fileURL = [NSURL fileURLWithPath:cacheFilePath];
            if (model.fileURL && [[NSFileManager defaultManager] fileExistsAtPath:[model.fileURL path]]) {
                PLVUploadVideo *video = [[PLVUploadClient sharedClient] videoWithVid:model.vid];
                [model linkVideo:video];
                [modelArray addObject:model];
            } else {
                [[PLVUploadDataBase sharedDataBase] deleteUncompleteDataWithVid:uncompleteData.vid];
            }
        }
    }
    
    NSArray <PLVUploadCompleteData *> *completeDatas = [[PLVUploadDataBase sharedDataBase] getAllCompleteData];
    if ([completeDatas count] > 0) {
        NSMutableArray *modelArray = [self videosWithType:PLVUploadListViewModelTypeComplete];
        for (PLVUploadCompleteData *completeData in completeDatas) {
            PLVUploadModel *model = [completeData changeToModel];
            [modelArray addObject:model];
        }
    }
    
    [self.viewController reloadTableView];
}

@end

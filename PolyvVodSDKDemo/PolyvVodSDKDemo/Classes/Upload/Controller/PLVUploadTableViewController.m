//
//  PLVUploadTableViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/15.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadTableViewController.h"
#import "TZImagePickerController.h"
#import "PLVUploadModel.h"
#import "PLVUploadTableViewModel.h"
#import "PLVUploadingCell.h"
#import "PLVUploadedCell.h"
#import "UIColor+PLVVod.h"
#import "PLVUploadUtil.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import <PLVVodUploadSDK/PLVVodUploadSDK.h>

NSString *PLVUploadAbortNotification = @"PLVUploadAbortNotification";

@interface PLVUploadTableViewController ()<
TZImagePickerControllerDelegate,
UITableViewDataSource,
UITableViewDelegate,
PLVUploadClientDelegate
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) PLVUploadTableViewModel *viewModel;

@end

@implementation PLVUploadTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PLVUploadClient sharedClient] addDelegate:self];
    
    self.viewModel = [[PLVUploadTableViewModel alloc] initWithViewController:self];
    
    [self.view addSubview:self.emptyView];
    self.emptyView.hidden = [self.viewModel sectionNumber] > 0;
    
    [self.view addSubview:self.tableView];
    self.tableView.hidden = !self.emptyView.hidden;
}

- (void)viewWillLayoutSubviews {
    _tableView.frame = CGRectMake(0, PLV_StatusAndNaviBarHeight, PLV_ScreenWidth, PLV_ScreenHeight - PLV_StatusAndNaviBarHeight);
}

- (void)dealloc {
    [[PLVUploadClient sharedClient] removeDelegate:self];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

#pragma mark - Getters & Setters

- (UITableView *)tableView {
    if (_tableView == nil) {
        CGRect bound = [UIScreen mainScreen].bounds;
        _tableView = [[UITableView alloc] initWithFrame:bound style:UITableViewStyleGrouped];
        _tableView.separatorColor = [UIColor colorWithHex:0xe5e5e5];
        _tableView.allowsSelection = NO;
        _tableView.estimatedRowHeight = 70;
        _tableView.rowHeight = 70;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_icon_norecord"]];
        emptyImageView.frame = CGRectMake((_emptyView.frame.size.width - 120)/2.0, 200, 120, 120);
        [_emptyView addSubview:emptyImageView];
        
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyImageView.frame.origin.y + emptyImageView.frame.size.height, _emptyView.frame.size.width, 14)];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.text = @"暂无上传记录";
        emptyLabel.font = [UIFont systemFontOfSize:14];
        [_emptyView addSubview:emptyLabel];
    }
    return _emptyView;
}

#pragma mark - Action

- (IBAction)openLibrary:(id)sender {
    [self presentViewController:[self getNewVideoPicker] animated:YES completion:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel sectionNumber];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel rowNumberAtSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVUploadModel *model = [self.viewModel modelAtIndexPath:indexPath];
    if ([self.viewModel typeAtSection:indexPath.section] == PLVUploadListViewModelTypeUncomplete) {
        PLVUploadingCell *cell = (PLVUploadingCell *)[tableView dequeueReusableCellWithIdentifier:model.vid];
        if (cell == nil) {
            cell = [[PLVUploadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.vid];
        }
        __weak typeof(self) weakSelf = self;
        cell.abortHandler = ^{
            [[PLVUploadClient sharedClient] abortUploadWithVid:model.vid];
            [weakSelf.viewModel uploadAbortWithVid:model.vid];
            [[NSNotificationCenter defaultCenter] postNotificationName:PLVUploadAbortNotification object:model.vid];
        };
        cell.retryHandler = ^{
            [[PLVUploadClient sharedClient] uploadVideoAtFileURL:model.fileURL];
        };
        cell.resumeHandler = ^{
            [[PLVUploadClient sharedClient] retryUploadWithVid:model.vid fileURL:model.fileURL fileName:model.title];
        };
        [cell setCellModel:model];
        return cell;
    } else {
        static NSString *uploadedCellIdentifier = @"uploadedCellIdentifier";
        PLVUploadedCell *cell = (PLVUploadedCell *)[tableView dequeueReusableCellWithIdentifier:uploadedCellIdentifier];
        if (cell == nil) {
            cell = [[PLVUploadedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uploadedCellIdentifier];
        }
        [cell setCellModel:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVUploadModel *model = [self.viewModel modelAtIndexPath:indexPath];
    PLVUploadListViewModelType type = [self.viewModel typeAtSection:indexPath.section];
    if (type == PLVUploadListViewModelTypeUncomplete) {
        [[PLVUploadClient sharedClient] abortUploadWithVid:model.vid];
    }
    [self.viewModel deleteDataAtIndex:indexPath];
    [self removeFileAtCacheURL:model.fileURL];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat tableWidth = self.tableView.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, tableWidth - 15 * 2, 14)];
    label.font = [UIFont systemFontOfSize:14];
    label.text = [self.viewModel tableHeaderTextAtSection:section];
    [view addSubview:label];
    
    UIView *coverSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, tableWidth, 0.5)];
    coverSeparatorLine.backgroundColor = [UIColor whiteColor];
    [view addSubview:coverSeparatorLine];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat tableWidth = self.tableView.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableWidth, CGFLOAT_MIN)];
    return view;
}

#pragma mark - PLVUploadTableViewControllerDelegate

- (void)reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.emptyView.hidden = [self.viewModel sectionNumber] > 0;
        self.tableView.hidden = !self.emptyView.hidden;
        [self.tableView reloadData];
    });
}

#pragma mark - PLVUploadClientDelegate

- (void)prepareUploadError:(NSError *)error fileURL:(NSURL *)fileURL {
    if (error.code == PLVClientErrorCodeNoEnoughSpace) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *content = @"当前剩余空间不足上传该视频，请及时联系客服";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:content preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            
            UINavigationController *navVC = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            if (![navVC.visibleViewController isKindOfClass:[PLVUploadTableViewController class]]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)startUploadTaskFailure:(NSString *)vid {
    NSString *logMessage = [NSString stringWithFormat:@"startUploadTaskFailure:\nvid=%@", vid];
    [self logForMessage:logMessage];
    [self.viewModel uploadFailureWithVid:vid];
}

- (void)waitingUploadTask:(PLVUploadVideo *)video {
    NSString *logMessage = [NSString stringWithFormat:@"waitingUploadTask:\n%@", video];
    [self logForMessage:logMessage];
    [self.viewModel uploadStartWithVideo:video];
}

- (void)startUploadTask:(PLVUploadVideo *)video {
    NSString *logMessage = [NSString stringWithFormat:@"startUploadTask:\n%@", video];
    [self logForMessage:logMessage];
    [self.viewModel uploadStartWithVideo:video];
}

- (void)didUploadTask:(PLVUploadVideo *)video error:(NSError *)error {
    NSString *logMessage = @"didUploadTask ";
    if (error) {
        logMessage = [logMessage stringByAppendingFormat:@"上传任务失败 {\n%@}", error];
        [self.viewModel uploadEndWithVideo:video];
    } else {
        logMessage = [logMessage stringByAppendingString:@"上传任务成功"];
        [self.viewModel uploadSuccessWithVid:video.vid];
        [self removeFileAtCacheURL:video.fileURL];
    }
    logMessage = [logMessage stringByAppendingFormat:@"\n%@", video];
    [self logForMessage:logMessage];
}

- (void)uploadTask:(NSString *)vid progressChange:(float)progress {
    [self.viewModel uploadProgressChanged:progress withVid:vid];
}

#pragma mark - TZImagePickerController & Delegate

- (TZImagePickerController *)getNewVideoPicker {
    TZImagePickerController *videoPicker = [[TZImagePickerController alloc] initWithMaxImagesCount:10 delegate:self];
    videoPicker.iconThemeColor = [UIColor themeColor]; // 主题色，从绿色改为蓝色，否则相册列表选中视频数目背景色为绿色
    videoPicker.allowPickingMultipleVideo = YES; // 允许多选视频
    videoPicker.allowPickingImage = NO; // 不允许选择照片
    videoPicker.allowTakePicture = NO; // 不允许拍照
    videoPicker.allowTakeVideo = NO; // 不允许拍摄视频
    videoPicker.showSelectedIndex = YES; //显示选择序号
    videoPicker.showPhotoCannotSelectLayer = YES; // 选择视频到达最大数目时，显示白色透明浮层
    videoPicker.allowPreview = NO; // 不允许预览
    videoPicker.autoDismiss = NO; // 不自动 dismiss 相册，需要代码 dismiss
    videoPicker.naviBgColor = [UIColor whiteColor]; // 白色导航栏
    videoPicker.naviTitleColor = [UIColor blackColor]; // 黑色导航栏标题
    videoPicker.barItemTextColor = [UIColor themeColor]; // 导航栏按钮文字使用主题色
    videoPicker.photoNumberIconImage = nil; // 底部完成按钮旁边旁边不显示选择视频数
    videoPicker.photoSelImage = nil; // 去掉选中图片序号下方绿色背景图
    videoPicker.barItemTextFont = [UIFont systemFontOfSize:16]; // 导航栏按钮文字大小
    videoPicker.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) { // 自定义返回按钮
        [leftButton setImage:[UIImage imageNamed:@"plv_btn_back"] forState:UIControlStateNormal];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    };
    videoPicker.photoPickerPageUIConfigBlock = ^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) { // 自定义底部完成按钮 UI
        UIImage *normalImage = [self imageWithColor:[UIColor colorWithHex:0x007aff]];
        UIImage *disabledImage = [self imageWithColor:[UIColor colorWithHex:0x007aff alpha:0.4]];
        [doneButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [doneButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor colorWithHex:0xc0deff] forState:UIControlStateDisabled];
        doneButton.layer.cornerRadius = 4.0;
        doneButton.layer.masksToBounds = YES;
    };
    videoPicker.assetCellDidSetModelBlock = ^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) { // 自定义选中图片 cell UI
        bottomView.backgroundColor = [UIColor clearColor];
        indexLabel.backgroundColor = [UIColor themeColor];
    };
    videoPicker.photoPickerPageDidLayoutSubviewsBlock = ^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) { // 自定义底部完成按钮布局
        doneButton.frame = CGRectMake(collectionView.frame.size.width - 64 - 11, 9, 64, 32);
        doneButton.layer.cornerRadius = 4.0;
        // 隐藏原图按钮、图片大小文本
        originalPhotoButton.frame = CGRectZero;
        originalPhotoLabel.frame = CGRectZero;
        numberLabel.frame = CGRectZero;
    };
    videoPicker.assetCellDidLayoutSubviewsBlock = ^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) { // 图片/视频 cell 布局调整
        videoImgView.hidden = YES; // 隐藏下方 video icon
        // label 做成圆形，替代底部绿色图片 photoSelImage
        indexLabel.layer.cornerRadius = indexLabel.frame.size.width/2.;
        indexLabel.layer.masksToBounds = YES;
    };
    return videoPicker;
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:[assets count]];
    for (PHAsset *asset in assets) {
        if (@available(iOS 9.0, *)) {
            PHAssetResource *assetRescource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
            NSString *filePath = [self exportFilePathWithAsset:asset];
            [muArray addObject:filePath];
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetRescource toFile:[NSURL fileURLWithPath:filePath] options:nil completionHandler:^(NSError * _Nullable error) {
                dispatch_semaphore_signal(semaphore);
                if (error) {
                    NSString *logMessage = [NSString stringWithFormat:@"TZImagePickerController: iOS 9.0以下 导出视频出错 %@", error];
                    [self logForMessage:logMessage];
                    [muArray removeObject:filePath];
                }
            }];
        } else {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
            option.version = PHVideoRequestOptionsVersionOriginal;
            [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:option exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info) {
                NSString *filePath = [self exportFilePathWithAsset:asset];
                exportSession.outputURL = [NSURL fileURLWithPath:filePath];
                [muArray addObject:filePath];
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    dispatch_semaphore_signal(semaphore);
                    if (exportSession.status != AVAssetExportSessionStatusCompleted) {
                        NSString *logMessage = [NSString stringWithFormat:@"TZImagePickerController: iOS 9.0以上 导出视频出错 %@", exportSession.error];
                        [self logForMessage:logMessage];
                        [self logForMessage:logMessage];
                        [muArray removeObject:filePath];
                    }
                }];
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PLVUploadUtil sharedUtil] uploadVideos:muArray];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - Private

- (NSString *)exportFilePathWithAsset:(PHAsset *)asset {
    NSString *fileName = [asset valueForKey:@"filename"];
    NSString *dirString = [self.viewModel cacheDirectory];
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dirString isDirectory:&isDirectory];
    if (!exist || isDirectory == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", dirString, fileName];
    [self removeFileAtCacheURL:[NSURL fileURLWithPath:cacheFilePath]];
    return cacheFilePath;
}

- (void)removeFileAtCacheURL:(NSURL *)fileURL {
    NSString *cacheFilePath = [fileURL path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    if (@available(iOS 17.0, *)) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:rect.size];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ref) {
            CGContextRef context = ref.CGContext;
            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, rect);
        }];
        return image;
    } else {
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

- (void)logForMessage:(NSString *)message {
    NSLog(@"【%@】%@", self, message);
}

@end

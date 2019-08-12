//
//  PLVDownloadCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/12.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVDownloadCell : UITableViewCell

/// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/// 视频大小
@property (weak, nonatomic) IBOutlet UILabel *videoSizeLabel;

/// 下载状态
@property (weak, nonatomic) IBOutlet UIImageView *downloadStateImgView;

/// 缩略图
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (copy, nonatomic) NSString *thumbnailUrl;

+ (NSString *)identifier;

@end

NS_ASSUME_NONNULL_END

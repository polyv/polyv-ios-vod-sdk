//
//  PLVDownloadComleteCell.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVDownloadComleteCell : UITableViewCell

/// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/// 视频大小
@property (weak, nonatomic) IBOutlet UILabel *videoSizeLabel;

/// 下载状态
@property (weak, nonatomic) IBOutlet UIImageView *downloadStateImgView;

/// 缩略图
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

/// 视频时长
@property (weak, nonatomic) IBOutlet UILabel *videoDurationTime;

///
@property (copy, nonatomic) NSString *thumbnailUrl;

+ (NSString *)identifier;


@end

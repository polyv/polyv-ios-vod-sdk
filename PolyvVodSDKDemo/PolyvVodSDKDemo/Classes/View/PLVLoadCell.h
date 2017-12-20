//
//  PLVLoadCell.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PLVLoadCellState) {
	PLVLoadCellStateProcessing,
	PLVLoadCellStateCompleted
};

@interface PLVLoadCell : UITableViewCell

/// 下载按钮
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (nonatomic, copy) void (^downloadButtonAction)(PLVLoadCell *cell, UIButton *sender);

/// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/// 视频大小
@property (weak, nonatomic) IBOutlet UILabel *videoSizeLabel;

/// 下载状态
@property (weak, nonatomic) IBOutlet UILabel *downloadStateLabel;

/// 下载速率
@property (weak, nonatomic) IBOutlet UILabel *downloadSpeedLabel;

/// 下载进度
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

/// 缩略图
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

/// 控件状态
@property (nonatomic, assign) PLVLoadCellState state;

+ (NSString *)identifier;

@end

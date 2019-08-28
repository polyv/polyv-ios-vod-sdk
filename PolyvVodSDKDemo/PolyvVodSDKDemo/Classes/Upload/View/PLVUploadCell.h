//
//  PLVUploadCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/12.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVUploadModel;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadCell : UITableViewCell

@property (nonatomic, strong) PLVUploadModel *model;

@property (nonatomic, strong) UIImageView *videoIconImageView;

@property (nonatomic, strong) UILabel *videoTitleLabel;

- (void)setCellModel:(PLVUploadModel *)model;

@end

NS_ASSUME_NONNULL_END

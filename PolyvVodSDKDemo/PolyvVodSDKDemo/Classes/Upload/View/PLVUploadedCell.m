//
//  PLVUploadedCell.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/16.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadedCell.h"
#import "PLVUploadModel.h"
#import "UIColor+PLVVod.h"

@interface PLVUploadedCell ()

@property (nonatomic, strong) PLVUploadModel *model;

@property (nonatomic, strong) UIImageView *videoIconImageView;

@property (nonatomic, strong) UILabel *videoTitleLabel;

@property (nonatomic, strong) UILabel *uploadDataLabel;

@property (nonatomic, strong) UILabel *fileSizeLabel;

@property (nonatomic, strong) NSDateFormatter *dataFormatter;

@end

@implementation PLVUploadedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _videoIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_icon_video_placeholder"]];
        [self.contentView addSubview:_videoIconImageView];
        
        _videoTitleLabel = [[UILabel alloc] init];
        _videoTitleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_videoTitleLabel];
        
        _uploadDataLabel = [[UILabel alloc] init];
        _uploadDataLabel.font = [UIFont systemFontOfSize:12];
        _uploadDataLabel.textColor = [UIColor colorWithHex:0x909090];
        [self.contentView addSubview:_uploadDataLabel];
        
        _fileSizeLabel = [[UILabel alloc] init];
        _fileSizeLabel.textAlignment = NSTextAlignmentRight;
        _fileSizeLabel.font = [UIFont systemFontOfSize:12];
        _fileSizeLabel.textColor = [UIColor colorWithHex:0x909090];
        [self.contentView addSubview:_fileSizeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rowWidth = self.contentView.frame.size.width;
    CGFloat rowHeight = self.contentView.frame.size.height;
    
    _videoIconImageView.frame = CGRectMake(15, (rowHeight - 40)/2.0, 40, 40);
    
    CGFloat titleLabelOriginX = _videoIconImageView.frame.origin.x + _videoIconImageView.frame.size.width + 15;
    CGFloat titleLabelWidth = rowWidth - 70 - 15;
    _videoTitleLabel.frame = CGRectMake(titleLabelOriginX, 18, titleLabelWidth, 15);
    
    CGFloat secondLabelOriginY = rowHeight - 12 - 15;
    _uploadDataLabel.frame = CGRectMake(titleLabelOriginX, secondLabelOriginY, titleLabelWidth - 80, 12);
    _fileSizeLabel.frame = CGRectMake(titleLabelOriginX + titleLabelWidth - 80., secondLabelOriginY, 80, 12);
}

- (void)setCellModel:(PLVUploadModel *)model {
    self.model = model;
    
    self.videoTitleLabel.text = model.title;
    if (model.completeDate) {
        self.uploadDataLabel.text = [self.dataFormatter stringFromDate:model.completeDate];
    } else {
        self.uploadDataLabel.text = @"";
    }
    self.fileSizeLabel.text = [self readableSize:model.fileSize];
}

- (NSString *)readableSize:(NSInteger)byteSize {
    return [NSByteCountFormatter stringFromByteCount:byteSize countStyle:NSByteCountFormatterCountStyleFile];
}

#pragma mark - Getters & Setters

- (NSDateFormatter *)dataFormatter {
    if (_dataFormatter == nil) {
        _dataFormatter = [[NSDateFormatter alloc] init];
        [_dataFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    }
    return _dataFormatter;
}

@end

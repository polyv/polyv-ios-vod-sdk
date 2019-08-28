//
//  PLVUploadingCell.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/16.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadingCell.h"
#import "PLVUploadModel.h"
#import "UIColor+PLVVod.h"

@interface PLVUploadingCell ()

@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *button;

@end

@implementation PLVUploadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:12];
        _progressLabel.textColor = [UIColor colorWithHex:0x909090];
        [self.contentView addSubview:_progressLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [UIColor colorWithHex:0x909090];
        [self.contentView addSubview:_statusLabel];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.layer.masksToBounds = YES;
        _button.layer.cornerRadius = 4.0;
        _button.layer.borderWidth = 0.5;
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0;
        _progressView.progressTintColor = [UIColor colorWithHex:0x909090];
        _progressView.trackTintColor = [UIColor colorWithHex:0xebebeb];
        [self.contentView addSubview:_progressView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rowWidth = self.contentView.frame.size.width;
    CGFloat rowHeight = self.contentView.frame.size.height;
    
    CGFloat buttonWidth = 72;
    CGFloat buttonHeight = 30;
    CGFloat buttonOriginX = rowWidth - buttonWidth - 10;
    CGFloat buttonOriginY = (rowHeight - buttonHeight) / 2.;
    _button.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonWidth, buttonHeight);
    
    CGFloat titleLabelOriginX = self.videoIconImageView.frame.origin.x + self.videoIconImageView.frame.size.width + 15;
    CGFloat titleLabelWidth = rowWidth - titleLabelOriginX - 10 - buttonWidth - 10;
    self.videoTitleLabel.frame = CGRectMake(titleLabelOriginX, 18, titleLabelWidth, 15);
    
    CGFloat secondLabelOriginY = rowHeight - 12 - 15;
    _progressLabel.frame = CGRectMake(titleLabelOriginX, secondLabelOriginY, titleLabelWidth/2., 12);
    _statusLabel.frame = CGRectMake(titleLabelOriginX + titleLabelWidth/2., secondLabelOriginY, titleLabelWidth/2., 12);
    
    _progressView.frame = CGRectMake(titleLabelOriginX, rowHeight/2. + 1.5, titleLabelWidth, 3);
}

- (void)buttonAction:(id)sender {
    NSUInteger layerBorderColorHex = [self buttonBorderColorHexWithData:self.model];
    self.button.layer.borderColor = [UIColor colorWithHex:layerBorderColorHex].CGColor;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.model.status == PLVUploadStatusWaiting || self.model.status == PLVUploadStatusUploading) {
            self.abortHandler();
        } else if (self.model.status == PLVUploadStatusResumable) {
            self.resumeHandler();
        } else if (self.model.status == PLVUploadStatusFailure || self.model.status == PLVUploadStatusAborted) {
            self.retryHandler();
        }
    });
}

- (void)setCellModel:(PLVUploadModel *)model {
    self.model = model;
    
    self.videoTitleLabel.text = model.title;
    
    self.statusLabel.text = [self statusTextWithData:model];
    self.statusLabel.textColor = [self statusTextColorWithData:model];
    
    NSString *buttonTitle = [self buttonTitleWithData:model];
    [self.button setTitle:buttonTitle forState:UIControlStateNormal];
    [self.button setTitle:buttonTitle forState:UIControlStateHighlighted];
    
    NSUInteger layerBorderColorHex = [self buttonBorderColorHexWithData:model];
    self.button.layer.borderColor = [UIColor colorWithHex:layerBorderColorHex].CGColor;
    
    NSUInteger titleColorHex = [self buttonTitleColorHexWithData:model];
    [self.button setTitleColor:[UIColor colorWithHex:titleColorHex alpha:1] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithHex:titleColorHex alpha:0.5] forState:UIControlStateHighlighted];
    
    NSString *uploadedSizeString = [self readableSize:model.fileSize * model.progress];
    NSString *totalSizeString = [self readableSize:model.fileSize];
    
    if (model.status == PLVUploadStatusWaiting || model.status == PLVUploadStatusAborted || model.status == PLVUploadStatusFailure) {
        self.progressView.progress = 0;
        self.progressLabel.text = totalSizeString;
    } else if (model.status == PLVUploadStatusResumable) {
        self.progressView.progress = model.progress;
        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@", uploadedSizeString, totalSizeString];
    } else if (model.status == PLVUploadStatusUploading) {
        if ([self.progressLabel.text isEqualToString:@""] || self.progressLabel.text == nil) {
            self.progressView.progress = 0;
            self.progressLabel.text = [NSString stringWithFormat:@"0/%@", totalSizeString];
        }
        if (model.progress > 0 && self.progressView.progress == 0) {
            self.progressView.progress = model.progress;
            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@", uploadedSizeString, totalSizeString];
        }
    }
    
    NSInteger fileSize = model.fileSize;
    __weak typeof(self) weakSelf = self;
    model.video.uploadProgress = ^(float progress) {
        if (model.status == PLVUploadStatusUploading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.progress = progress;
                weakSelf.progressLabel.text = [NSString stringWithFormat:@"%@/%@", [weakSelf readableSize:fileSize * progress], [weakSelf readableSize:fileSize]];
            });
        }
    };
}

#pragma mark - Private

- (UIColor *)statusTextColorWithData:(PLVUploadModel *)model {
    NSUInteger colorHex;
    if (model.status == PLVUploadStatusResumable || model.status == PLVUploadStatusFailure) {
        colorHex = 0xff5b5b;
    } else {
        colorHex = 0x909090;
    }
    return [UIColor colorWithHex:colorHex];
}

- (NSString *)statusTextWithData:(PLVUploadModel *)model {
    NSString *result = @"";
    if (model.status == PLVUploadStatusWaiting) {
        result = @"等待上传";
    } else if (model.status == PLVUploadStatusUploading) {
        result = @"上传中";
    } else if (model.status == PLVUploadStatusResumable) {
        result = @"上传失败";
    } else if (model.status == PLVUploadStatusFailure) {
        result = @"上传失败";
    } else if (model.status == PLVUploadStatusAborted) {
        result = @"已取消";
    }
    return result;
}

- (NSString *)buttonTitleWithData:(PLVUploadModel *)model  {
    NSString *result = @"";
    if (model.status == PLVUploadStatusWaiting) {
        result = @"取消";
    } else if (model.status == PLVUploadStatusUploading) {
        result = @"取消";
    } else if (model.status == PLVUploadStatusResumable) {
        result = @"恢复";
    } else if (model.status == PLVUploadStatusFailure) {
        result = @"重试";
    } else if (model.status == PLVUploadStatusAborted) {
        result = @"重新上传";
    }
    return result;
}

- (NSUInteger)buttonTitleColorHexWithData:(PLVUploadModel *)model  {
    if (model.status == PLVUploadStatusWaiting || model.status == PLVUploadStatusUploading) {
        return 0x909090;
    } else {
        return [UIColor hexValueForThemeColor];
    }
}

- (NSUInteger)buttonBorderColorHexWithData:(PLVUploadModel *)model  {
    if (model.status == PLVUploadStatusWaiting || model.status == PLVUploadStatusUploading) {
        return 0xd5d5d5;
    } else {
        return [UIColor hexValueForThemeColor];
    }
}

- (NSString *)readableSize:(int64_t)byteSize {
    return [NSByteCountFormatter stringFromByteCount:byteSize countStyle:NSByteCountFormatterCountStyleFile];
}

@end

//
//  PLVPPTTableViewCell.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/5.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTTableViewCell.h"
#import <PLVVodSDK/PLVVodPPT.h>
#import <YYWebImage/YYWebImage.h>
#import <PLVMasonry/PLVMasonry.h>

@interface PLVPPTTableViewCell ()

@property (nonatomic, strong) UIImageView *pptImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *indexLabel;

@end

@implementation PLVPPTTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.pptImageView];
        [self.pptImageView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.plv_equalTo(16);
            make.top.plv_equalTo(0);
            make.size.plv_equalTo(CGSizeMake(160, 90));
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.equalTo(self.pptImageView.plv_right).with.offset(16);
            make.top.plv_equalTo(0);
            make.right.plv_equalTo(-16);
            make.bottom.lessThanOrEqualTo(self.pptImageView.plv_bottom).with.offset(-14);
        }];
        
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.plv_bottom);
            make.height.plv_equalTo(14).priorityMedium();
            make.left.and.right.plv_equalTo(self.titleLabel);
            make.bottom.lessThanOrEqualTo(self.pptImageView.plv_bottom);
        }];
        
        [self.pptImageView addSubview:self.indexLabel];
        [self.indexLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(24, 18));
            make.right.and.bottom.plv_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (UIImageView *)pptImageView {
    if (!_pptImageView) {
        _pptImageView = [[UIImageView alloc] init];
        _pptImageView.backgroundColor = [UIColor blackColor];
        _pptImageView.clipsToBounds = YES;
        _pptImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _pptImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    }
    return _timeLabel;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:13];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.backgroundColor = [UIColor colorWithRed:0x05/255.0 green:0x04/255.0 blue:0x04/255.0 alpha:1.0];
    }
    return _indexLabel;
}

#pragma mark - Public

+ (CGFloat)rowHeight {
    return 106;
}

- (void)configPPTPage:(PLVVodPPTPage *)pptPage {
    self.titleLabel.text = pptPage.title;
    
    self.indexLabel.text = (pptPage.index+1 < 100) ? [NSString stringWithFormat:@"%zd", pptPage.index+1] : @"N";
    self.timeLabel.text = [self convertSecondToTime:pptPage.timing];
    
    if ([pptPage isLocalImage]) {
        [self.pptImageView setImage:[pptPage localImage]];
    } else {
        NSURL *url = [NSURL URLWithString:pptPage.thumbImageUrl];
        [self.pptImageView yy_setImageWithURL:url options:YYWebImageOptionShowNetworkActivity];
    }
}

#pragma mark - Private

- (NSString *)convertSecondToTime:(NSInteger)second {
    if (second < 60) {
        return [NSString stringWithFormat:@"00:00:%02zd", second];
    } else if (second < 60 * 60) {
        return [NSString stringWithFormat:@"00:%02zd:%02zd", second / 60, second % 60];
    } else if (second < 60 * 60 * 60) {
        NSInteger hour = second / 3600;
        NSInteger min = second / 60 - hour * 60;
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, min, second - hour * 3600 - min * 60];
    } else {
        return @"59:59:59";
    }
}

@end

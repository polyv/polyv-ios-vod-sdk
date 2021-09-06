//
//  PLVKnowledgePointTableViewCell.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVKnowledgePointTableViewCell.h"
#import "UIColor+PLVVod.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVKnowledgePointTableViewCell ()

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation PLVKnowledgePointTableViewCell

#pragma mark - Init & UI

+ (PLVKnowledgePointTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"PLVKnowledgePointTableViewCell";
    PLVKnowledgePointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[PLVKnowledgePointTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.statusImageView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.timeLabel];
    
    [self.statusImageView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.size.plv_equalTo(CGSizeMake(24, 24));
        make.left.equalTo(self.contentView).offset(23);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.timeLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.width.height.plv_greaterThanOrEqualTo(10);
        make.right.equalTo(self.contentView).offset(-32);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.descLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.width.height.plv_greaterThanOrEqualTo(1);
        make.left.equalTo(self.statusImageView.plv_right).offset(15);
        make.centerY.equalTo(self.contentView);
    }];
}


#pragma mark - Setter

- (void)setPointModel:(PLVKnowledgePoint *)pointModel {
    _pointModel = pointModel;
    if (self.isShowDesc) {
        self.descLabel.hidden = NO;
        self.descLabel.text = pointModel.name;
    }else {
        self.descLabel.hidden = YES;
        self.descLabel.text = @"";
    }
    self.timeLabel.text = [self timeStringWithSeconds:pointModel.time];
}

- (void)setIsSelectCell:(BOOL)isSelectCell {
    _isSelectCell = isSelectCell;
    if (isSelectCell) {
        [self.statusImageView setImage:[UIImage imageNamed:@"plv_playing_btn"]];
        self.descLabel.textColor = [UIColor colorWithHex:0x3990FF];
    }else {
        [self.statusImageView setImage:[UIImage imageNamed:@"plv_play_btn"]];
        self.descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

- (void)setIsShowDesc:(BOOL)isShowDesc {
    _isShowDesc = isShowDesc;
    if (isShowDesc) {
        self.descLabel.hidden = NO;
        [self.timeLabel plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.width.height.plv_greaterThanOrEqualTo(10);
            make.right.equalTo(self.contentView).offset(-32);
            make.centerY.equalTo(self.contentView);
        }];
    }else {
        self.descLabel.hidden = YES;
        [self.timeLabel plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.width.height.plv_greaterThanOrEqualTo(10);
            make.left.equalTo(self.statusImageView.plv_right).offset(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    
}

/// 时间转字符串
- (NSString *)timeStringWithSeconds:(NSTimeInterval)seconds {
    NSInteger time = seconds;
    NSInteger _hours = time / 60 / 60;
    NSInteger _minutes = (time / 60) % 60;
    NSInteger _seconds = time % 60;
    NSString *timeString = _hours > 0 ? [NSString stringWithFormat:@"%02zd:", _hours] : @"00:";
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%02zd:%02zd", _minutes, _seconds]];
    return timeString;
}


#pragma mark - Loadlazy

- (UIImageView *)statusImageView {
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc]init];
        [_statusImageView setImage:[UIImage imageNamed:@"plv_play_btn"]];
    }
    return _statusImageView;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc]init];
        _descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.numberOfLines = 0;
    }
    return _timeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

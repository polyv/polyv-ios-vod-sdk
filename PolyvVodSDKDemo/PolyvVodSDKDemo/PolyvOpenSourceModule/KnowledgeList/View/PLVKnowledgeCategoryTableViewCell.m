//
//  PLVKnowledgeCategoryTableViewCell.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVKnowledgeCategoryTableViewCell.h"
#import "UIColor+PLVVod.h"
#import <PLVMasonry/PLVMasonry.h>
#import "PLVMarqueeLabel.h"

@interface PLVKnowledgeCategoryTableViewCell ()

@property (nonatomic, strong) PLVMarqueeLabel *categoryLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation PLVKnowledgeCategoryTableViewCell

#pragma mark - Init & UI

+ (PLVKnowledgeCategoryTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"PLVKnowledgeCategoryTableViewCell";
    PLVKnowledgeCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[PLVKnowledgeCategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithHex:0x222326];
        cell.contentView.backgroundColor = [UIColor colorWithHex:0x222326];
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
    [self.contentView addSubview:self.categoryLabel];
//    [self.categoryLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(32);
//        make.centerY.equalTo(self.contentView);
//        make.right.equalTo(self.contentView).offset(-10);
//        make.height.plv_greaterThanOrEqualTo(10);
//    }];
    
    [self.categoryLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(32);
        make.centerY.equalTo(self.contentView);
        make.height.plv_greaterThanOrEqualTo(10);
        make.width.plv_lessThanOrEqualTo(120);
    }];
    
    [self.contentView addSubview:self.numberLabel];
    [self.numberLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.equalTo(self.categoryLabel.plv_right);
        make.centerY.equalTo(self.contentView);
        make.width.height.plv_greaterThanOrEqualTo(10);
    }];
}

#pragma mark - Setter
- (void)setWorkKeyModel:(PLVKnowledgeWorkKey *)workKeyModel {
    _workKeyModel = workKeyModel;
    self.categoryLabel.text = workKeyModel.name;
    self.numberLabel.text = [NSString stringWithFormat:@"（%lu）", (unsigned long)workKeyModel.knowledgePoints.count];
}

- (void)setIsSelectCell:(BOOL)isSelectCell {
    if (isSelectCell) {
        self.backgroundColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:51/255.0 green:52/255.0 blue:55/255.0 alpha:1];
        // 滚动
        self.categoryLabel.scrollDuration = 10;
        [self.categoryLabel restartLabel];
    }else {
        self.backgroundColor = [UIColor colorWithHex:0x222326];
        self.contentView.backgroundColor = [UIColor colorWithHex:0x222326];
        //暂停滚动
        self.categoryLabel.scrollDuration = -1;
        [self.categoryLabel shutdownLabel];
    }
}


#pragma mark - Pravite Method

- (void)beginAnimation {
    [self.categoryLabel restartLabel];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationFinish) object:nil];
    [self performSelector:@selector(animationFinish) withObject:nil afterDelay:10*3];
}

- (void)animationFinish {
    [self.categoryLabel shutdownLabel];
    self.hidden = YES;
}


#pragma mark - Loadlazy

- (UILabel *)numberLabel {
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc]init];
        _numberLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
        _numberLabel.font = [UIFont systemFontOfSize:14];
    }
    return _numberLabel;
}

- (PLVMarqueeLabel *)categoryLabel {
    if (_categoryLabel == nil) {
        _categoryLabel = [[PLVMarqueeLabel alloc] initWithFrame:self.contentView.bounds duration:10.0 andFadeLength:0];
        _categoryLabel.scrollDuration = -1;
//        _categoryLabel.holdScrolling = YES;
        _categoryLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
        _categoryLabel.font = [UIFont systemFontOfSize:14];
    }
    return _categoryLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

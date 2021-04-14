//
//  PLVOptionView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/2/1.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVOptionView.h"
#import "UIColor+PLVVod.h"

@interface PLVOptionView ()

@property (nonatomic, strong) UIButton *btnCheckbox;

@property (nonatomic, strong) UILabel *lblOption;

@end


@implementation PLVOptionView

#pragma mark - Init & UI
-(instancetype)init
{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.btnCheckbox];
    [self addSubview:self.lblOption];
    
    NSMutableArray<NSLayoutConstraint *> *constrainsArray = [NSMutableArray array];
    
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.btnCheckbox attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.btnCheckbox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.btnCheckbox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:32]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.btnCheckbox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:18]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.lblOption attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.btnCheckbox attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.lblOption attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.lblOption attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.lblOption attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:20]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.lblOption attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    
    [self addConstraints:constrainsArray];
    
}


#pragma mark - Setter
-(void)setOptionString:(NSString *)optionString
{
    self.lblOption.text = optionString;
    _optionString = optionString;
}

-(void)setIsSelect:(BOOL)isSelect
{
    self.btnCheckbox.selected = isSelect;
    _isSelect = isSelect;
}

- (void)setMultipleChoiceType:(BOOL)multipleChoiceType{
    if (multipleChoiceType) {
        [self.btnCheckbox setImage:[UIImage imageNamed:@"Checkbox-Default"] forState:UIControlStateNormal];
        [self.btnCheckbox setImage:[UIImage imageNamed:@"Checkbox-Selected-Default"] forState:UIControlStateSelected];
    }else{
        [self.btnCheckbox setImage:[UIImage imageNamed:@"Checkbox-Default"] forState:UIControlStateNormal];
        [self.btnCheckbox setImage:[UIImage imageNamed:@"RadioBox-Selected-Default"] forState:UIControlStateSelected];
    }
    _multipleChoiceType = multipleChoiceType;
}


#pragma mark - Action

-(void)clickCheckBoxAction:(UIButton *)sender
{
//    sender.selected = !sender.selected;
//    _isSelect = sender.selected;
    if (self.selectActionHandler) {
        self.selectActionHandler(sender.selected);
    }
}


#pragma mark - Loadlazy

-(UIButton *)btnCheckbox
{
    if (_btnCheckbox == nil) {
        _btnCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
        [_btnCheckbox setImage:[UIImage imageNamed:@"Checkbox-Default"] forState:UIControlStateNormal];
        [_btnCheckbox setImage:[UIImage imageNamed:@"Checkbox-Selected-Default"] forState:UIControlStateSelected];
        [_btnCheckbox addTarget:self action:@selector(clickCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCheckbox;
}

-(UILabel *)lblOption
{
    if (_lblOption == nil) {
        _lblOption = [[UILabel alloc]init];
        _lblOption.translatesAutoresizingMaskIntoConstraints = NO;
        _lblOption.textColor = [UIColor colorWithHex:0x333333];
        _lblOption.font = [UIFont systemFontOfSize:14];
        _lblOption.numberOfLines = 0;
    }
    return _lblOption;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

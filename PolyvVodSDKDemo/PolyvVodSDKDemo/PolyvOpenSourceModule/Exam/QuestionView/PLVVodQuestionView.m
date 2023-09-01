//
//  PLVVodQuestionView.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodQuestionView.h"
#import <YYWebImage/YYWebImage.h>
#import "PLVOptionView.h"

@interface PLVVodQuestionView ()

//容器约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTopConstraint;
@property CGFloat outerContanerWeidht;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paddingTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paddingLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paddingRightConstraint;

//UI控件
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet UIView *optionsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitBtnWidthConstraint;

//插图约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *illustrationContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *illustrationContainerRightConstraint;


@property (nonatomic, strong) NSMutableArray<PLVOptionView *> *optionViewArray;

@end

@implementation PLVVodQuestionView

#pragma mark - init & dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self commonInit];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
    self.optionViewArray = [NSMutableArray arrayWithCapacity:4];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    if (self.question) {
        [self updateOuterContainerSize];
    }
}

- (void)awakeFromNib {
	[super awakeFromNib];
    self.illustrationImageView.clipsToBounds = YES;
    self.illustrationImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.containerView.layer.masksToBounds = YES;
}


/// 生成选项，设置问卷
-(void)createOptionsView
{
    // 设置问题
    NSString *questionType = _question.isMultipleChoice ? @"【多选题】" : @"【单选题】";
    
    self.questionLabel.text = [NSString stringWithFormat:@"%@%@", questionType, _question.question];
    
    // 设置插图
    if (_question.illustration.length > 0) {
        [self.illustrationImageView yy_setImageWithURL:[NSURL URLWithString:_question.illustration] placeholder:nil];
    }
    
    //设置选项
    [self.optionViewArray removeAllObjects];
    [[self.optionsContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __weak typeof(self) weakSelf = self;
    for (NSInteger i = 0; i < _question.options.count; i++) {
        NSString *question = _question.options[i];
        PLVOptionView *optionView = [[PLVOptionView alloc]init];
        optionView.optionString = [NSString stringWithFormat:@"%@%@", [self optionOrderWithIndex:i], question];
        optionView.multipleChoiceType = _question.isMultipleChoice;
        optionView.isSelect = NO;
        [optionView setSelectActionHandler:^(BOOL isSelect) {
            [weakSelf selectAnswerWithIndex:i andSelect:isSelect];
        }];
        [self.optionsContainerView addSubview:optionView];
        [self.optionViewArray addObject:optionView];
        
        
        NSMutableArray<NSLayoutConstraint *> *constrainsArray = [NSMutableArray array];
        
        [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:optionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.optionsContainerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:optionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.optionsContainerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        if (i > 0) {
            PLVOptionView *lastView = self.optionViewArray[i - 1];
            [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:optionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:16]];
            if (i == _question.options.count - 1) {
                [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:optionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.optionsContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            }
        }
        else {
            [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:optionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.optionsContainerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        }
        
        [self.optionsContainerView addConstraints:constrainsArray];
    }
}

- (void)layoutSubviews{
    if (self.question) {
        [self updateOuterContainerSize];
    }
}


#pragma mark - Setter
- (void)setQuestion:(PLVVodQuestion *)question {
	_question = question;
    
	dispatch_async(dispatch_get_main_queue(), ^{
        [self createOptionsView];
        [self updateOuterContainerSize];
	});
}

#pragma mark - Action

-(void)selectAnswerWithIndex:(NSInteger)index andSelect:(BOOL)select
{
    if (_question.isMultipleChoice) {
        if (index < self.optionViewArray.count) {
            PLVOptionView *optionView = self.optionViewArray[index];
            optionView.isSelect = !optionView.isSelect;
        }
    }else {
        for (NSInteger i = 0; i < self.optionViewArray.count; i++) {
            PLVOptionView *optionView = self.optionViewArray[i];
            optionView.isSelect = index == i;
        }
    }
}

- (IBAction)skipButtonAction:(UIButton *)sender {
    if (self.skipActionHandler) {
        self.skipActionHandler();
    }
}

- (IBAction)submitButtonAction:(UIButton *)sender {
    if (self.submitActionHandler) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger i = 0; i < self.optionViewArray.count; i++) {
            PLVOptionView *optionView = self.optionViewArray[i];
            if (optionView.isSelect) {
                [array addObject:@(i)];
            }
        }
        self.submitActionHandler(array);
    }
}


#pragma mark - public method
- (void)scrollToTop {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView scrollsToTop];
    });
}

#pragma mark - private method

/// 更新视图
- (void)updateOuterContainerSize {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    float width = self.superview.bounds.size.width;
    float height = self.superview.bounds.size.height;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) { // 竖屏
        if (width >= height) {
            self.outerContainerTopConstraint.constant = 0;
            self.outerContainerBottomConstraint.constant = 0;
        }else{
            CGFloat contanerHeight = width / (16.0 / 9.0);
            CGFloat topBottomPadding = (height - contanerHeight) / 2.0;
            
            self.outerContainerTopConstraint.constant = topBottomPadding;
            self.outerContainerBottomConstraint.constant = topBottomPadding;
        }
        
        self.outerContainerLeadingConstraint.constant = 0;
        self.outerContainerTailingConstraint.constant = 0;
        self.outerContanerWeidht = [UIScreen mainScreen].bounds.size.width;
        self.paddingTopConstraint.constant = 20;
        self.paddingLeftConstraint.constant = 16;
        self.paddingRightConstraint.constant = 16;
        
        // 设置插图
        if (_question.illustration.length > 0) {
            self.illustrationContainerRightConstraint.constant = 8;
            self.illustrationContainerWidthConstraint.constant = 150;
        }else {
            self.illustrationContainerRightConstraint.constant = 0;
            self.illustrationContainerWidthConstraint.constant = 0;
        }
        
        self.containerView.layer.cornerRadius = 0;
    } else { // 横屏
        CGFloat verticalPadding = 67;
        CGFloat horzontalPadding;
        
        CGFloat scale = verticalPadding / 375.0;
        verticalPadding = scale * height;
        
        CGFloat outerContanerHeight = height - verticalPadding * 2;
        self.outerContanerWeidht = outerContanerHeight / 9.0 * 16;
        
        horzontalPadding = (width - self.outerContanerWeidht) / 2.0 ;
        
        self.outerContainerLeadingConstraint.constant = horzontalPadding;
        self.outerContainerTailingConstraint.constant = horzontalPadding;
        self.outerContainerTopConstraint.constant = verticalPadding;
        self.outerContainerBottomConstraint.constant = verticalPadding;
        
        self.paddingTopConstraint.constant = 24;
        self.paddingLeftConstraint.constant = 24;
        self.paddingRightConstraint.constant = 24;
        
        // 设置插图
        if (_question.illustration.length > 0) {
            self.illustrationContainerRightConstraint.constant = 8;
            self.illustrationContainerWidthConstraint.constant = 160;
        }else {
            self.illustrationContainerRightConstraint.constant = 0;
            self.illustrationContainerWidthConstraint.constant = 0;
        }
        
        self.containerView.layer.cornerRadius = 8;
    }
    
    [self.containerView layoutIfNeeded];
    [self.scrollView setContentSize:CGSizeMake(self.containerView.frame.size.width, self.scrollView.contentSize.height)];
    
    // 设置跳过按钮
    if (_question.skippable) {
        self.skipButton.hidden = NO;
        self.submitBtnWidthConstraint.constant = 0;
    }else {
        self.skipButton.hidden = YES;
        self.submitBtnWidthConstraint.constant = self.outerContanerWeidht * 0.5;
    }
}


/// 获取答案序号
/// @param index 第几个答案
- (NSString *)optionOrderWithIndex:(NSInteger )index{
    NSDictionary *dict = @{@"0":@"A.",
                           @"1":@"B.",
                           @"2":@"C.",
                           @"3":@"D.",
                           @"4":@"E."
                           };
    
    NSString *keyStr = [NSString stringWithFormat:@"%d", (int)index];
    return dict[keyStr];
}

#pragma mark - Override

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *touchView = [super hitTest:point withEvent:event];
    if (touchView == self) {
        return nil;
    } else {
        return touchView;
    }
}


@end

//
//  PLVFillBlankQuestionView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/1/28.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVFillBlankQuestionView.h"
#import "PLVFillBlankView.h"
#import "UIColor+PLVVod.h"

@interface PLVFillBlankQuestionView ()<PLVFillBlankViewDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) PLVFillBlankView *fillBlankView;
@property (nonatomic, strong) UIButton *btnSubmit;
@property (nonatomic, strong) UIButton *btnSkip;
@property (nonatomic, strong) UIView *lineH;
@property (nonatomic, strong) UIView *lineV;
@property (nonatomic, assign) BOOL isKeyBoradShow;
@property (nonatomic, assign) UITextField *editingTextField;//!< 正在编辑的输入框
@property (nonatomic, assign) CGFloat fillBlankViewHeight;


@end

@implementation PLVFillBlankQuestionView
#pragma mark - init & dealloc

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
    self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.7];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.scrollView];
    [self.containerView addSubview:self.btnSkip];
    [self.containerView addSubview:self.lineV];
    [self.containerView addSubview:self.btnSubmit];
    [self.containerView addSubview:self.lineH];
    
    [self.scrollView addSubview:self.fillBlankView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutSubviews{
    if (_question) {
        [self updateUI];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - NSNotification

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    if (self.question) {
        [self updateUI];
    }
}

-(void)keyboardDidShow:(NSNotification *)notification
{
    if (self.question) {
        //键盘出现的时候，上移视图，并且在有遮挡的情况下移动scrollview
        self.isKeyBoradShow = YES;
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat topPadding = interfaceOrientation == UIInterfaceOrientationPortrait ? 0 : 16;
        self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, topPadding, self.containerView.frame.size.width, self.containerView.frame.size.height);
        
        if (self.editingTextField) {
            UIView *window = [UIApplication sharedApplication].delegate.window;
            //相对于windows的frame
            CGRect tempTextFieldFrame = [self.editingTextField.superview convertRect:self.editingTextField.frame toView:window];
            CGFloat textfieldMaxY = CGRectGetMaxY(tempTextFieldFrame);
            
            NSDictionary *userInfo = [notification userInfo];
            CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
            CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
            
            CGFloat offsetY = textfieldMaxY + keyboardHeight - windowHeight;

            if (offsetY > 0) {
                //输入框跟键盘有重叠的时候，上移scrollView
                CGFloat originalOffsetY = self.scrollView.contentOffset.y;
                [self.scrollView setContentOffset:CGPointMake(0, originalOffsetY + offsetY + 50) animated:YES];
            }
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    if (self.question) {
        //键盘退出的时候移回中间显示
        self.isKeyBoradShow = NO;
        float height = self.superview.bounds.size.height;
        CGFloat topPadding = 67 / 375.0 * height;
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat offsetY = interfaceOrientation == UIInterfaceOrientationPortrait ? 0 : topPadding;
        self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, offsetY, self.containerView.frame.size.width, self.containerView.frame.size.height);
    }
}

#pragma mark - UI
-(void)updateUI
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    float width = self.superview.bounds.size.width;
    float height = self.superview.bounds.size.height;
    CGFloat contanerWeidht = width;
    CGFloat contanerHeight = height;
    
    CGFloat fillBlankViewHorzontalPadding = 0;
    CGFloat fillBlankViewVerticalPadding = 0;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        //竖屏
        if (width >= height) {
            self.containerView.frame = CGRectMake(0, 0, contanerWeidht, contanerHeight);
        }else{
            contanerHeight = contanerWeidht / (16.0 / 9.0);
            CGFloat topBottomPadding = (height - contanerHeight) / 2.0;
            self.containerView.frame = CGRectMake(0, topBottomPadding, contanerWeidht, contanerHeight);
        }
        
        self.containerView.layer.cornerRadius = 0;
        
        fillBlankViewHorzontalPadding = 16;
        fillBlankViewVerticalPadding = 20;
    }
    else {
        //横屏
        CGFloat verticalPadding = 67;
        CGFloat horzontalPadding;
        
        CGFloat scale = verticalPadding / 375.0;
        verticalPadding = scale * height;
        
        contanerHeight = height - verticalPadding * 2;
        contanerWeidht = contanerHeight / 9.0 * 16;
        
        horzontalPadding = (width - contanerWeidht) / 2.0 ;
        
        if (self.isKeyBoradShow) {
            verticalPadding = 16;
        }
        
        self.containerView.frame = CGRectMake(horzontalPadding, verticalPadding, contanerWeidht, contanerHeight);
        self.containerView.layer.cornerRadius = 8;
        
        fillBlankViewHorzontalPadding = 24;
        fillBlankViewVerticalPadding = 24;
    }
    
    self.scrollView.frame = CGRectMake(0, 0, contanerWeidht, contanerHeight - 45);
    self.fillBlankView.frame = CGRectMake(fillBlankViewHorzontalPadding, fillBlankViewVerticalPadding, contanerWeidht - fillBlankViewHorzontalPadding * 2, self.fillBlankViewHeight);
    [self.fillBlankView setNeedsDisplay];
    
    self.lineH.frame = CGRectMake(16, contanerHeight - 45, contanerWeidht - 32, 1);
    self.btnSkip.frame = CGRectMake(0, contanerHeight - 45, contanerWeidht * 0.5, 45);
    self.lineV.frame = CGRectMake(contanerWeidht * 0.5 - 1, contanerHeight - 45 + 11, 1, 45 - 22);
    if (_question.skippable) {
        self.btnSkip.hidden = NO;
        self.btnSubmit.frame = CGRectMake(contanerWeidht * 0.5, contanerHeight - 45, contanerWeidht * 0.5, 45);
    }else {
        self.btnSkip.hidden = YES;
        self.btnSubmit.frame = CGRectMake(0, contanerHeight - 45, contanerWeidht, 45);
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height)];
}


#pragma mark - Setter
-(void)setQuestion:(PLVVodQuestion *)question
{
    _question = question;
    [self updateUI];
    self.fillBlankView.questionString = [NSString stringWithFormat:@"【填空题】%@", question.question];
}

#pragma mark - Action

-(void)clickSkipButtonAction
{
    [self endEditing:YES];
    if (self.skipActionHandler) {
        self.skipActionHandler();
    }
}

-(void)clickSubmitButtonAction
{
    [self endEditing:YES];
    if (self.submitFillBlankTopicActionHandler) {
        NSMutableArray *answerArray = [NSMutableArray arrayWithCapacity:1];
        for (UITextField *input in self.fillBlankView.textfieldArray) {
            NSString *answer = @"";
            if (input.text.length) {
                answer = input.text;
            }
            [answerArray addObject:answer];
        }
        self.submitFillBlankTopicActionHandler(answerArray);
    }
}

- (void)scrollToTop {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView scrollsToTop];
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}


#pragma mark - PLVFillBlankViewDelegate

/// 填空题view高度变化回调
/// @param fillBlankView fillBlankView
/// @param height 变化后的高度
-(void)fillBlankView:(PLVFillBlankView *)fillBlankView didChangeHeight:(CGFloat)height
{
    self.fillBlankViewHeight = height;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, height + 50)];
}

/// 将要编辑事件回调
/// @param fillBlankView fillBlankView
/// @param tfEditing 将要编辑的输入框
-(void)fillBlankView:(PLVFillBlankView *)fillBlankView textFieldShouldBeginEditingBlock:(UITextField *)tfEditing
{
    self.editingTextField = tfEditing;
}


#pragma mark - Loadlazy

-(UIView *)containerView
{
    if (_containerView == nil) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

-(UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = YES;
    }
    return _scrollView;
}

-(PLVFillBlankView *)fillBlankView
{
    if (_fillBlankView == nil) {
        _fillBlankView = [[PLVFillBlankView alloc]init];
        _fillBlankView.delegate = self;
        _fillBlankView.questionColor = [UIColor colorWithHex:0x333333];
        _fillBlankView.questionFontSize = 16;
        _fillBlankView.fillColor = [UIColor colorWithHex:0x4A90E2];
        _fillBlankView.fillFontSize = 14;
    }
    return _fillBlankView;
}

-(UIButton *)btnSkip
{
    if (_btnSkip == nil) {
        _btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSkip.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btnSkip setTitleColor:[UIColor colorWithHex:0x333333] forState:0];
        [_btnSkip setTitle:@"跳过" forState:0];
        [_btnSkip addTarget:self action:@selector(clickSkipButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSkip;
}

-(UIButton *)btnSubmit
{
    if (_btnSubmit == nil) {
        _btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSubmit.backgroundColor = [UIColor whiteColor];
        _btnSubmit.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btnSubmit setTitleColor:[UIColor colorWithHex:0x4A90E2] forState:0];
        [_btnSubmit setTitle:@"提交" forState:0];
        [_btnSubmit addTarget:self action:@selector(clickSubmitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSubmit;
}

-(UIView *)lineV
{
    if (_lineV == nil) {
        _lineV = [[UIView alloc]init];
        _lineV.backgroundColor = [UIColor colorWithHex:0xC8C7CC];
    }
    return _lineV;
}

-(UIView *)lineH
{
    if (_lineH == nil) {
        _lineH = [[UIView alloc]init];
        _lineH.backgroundColor = [UIColor colorWithHex:0xC8C7CC];
    }
    return _lineH;
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

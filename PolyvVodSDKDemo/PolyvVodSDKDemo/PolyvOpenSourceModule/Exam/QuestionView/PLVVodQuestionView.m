//
//  PLVVodQuestionView.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodQuestionView.h"
#import "PLVVodOptionCell.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVVodQuestionView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTopConstraint;
@property CGFloat outerContanerWeidht;

//@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *questionLabel;

@property (weak, nonatomic) IBOutlet UILabel *questionTypeLb;

@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *illustrationContainerWidthConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionLayout;
@property CGFloat cellwidth;
@property CGFloat *cellHeights;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    if (self.question) {
        [self updateOuterContainerSize];
    }
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self.optionCollectionView registerNib:[UINib nibWithNibName:[PLVVodOptionCell identifier] bundle:nil] forCellWithReuseIdentifier:[PLVVodOptionCell identifier]];
	self.optionCollectionView.allowsMultipleSelection = YES;
	self.optionCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.questionLabel.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.questionLabel.editable = NO;
}

- (void)layoutSubviews{
    [self updateOuterContainerSize];
}

- (void)clear {
    self.question = nil;
    self.cellwidth = 0;
    self.cellHeights = NULL;
    self.outerContanerWeidht = 0;
}

#pragma mark - property
- (void)setQuestion:(PLVVodQuestion *)question {
	_question = question;
    self.optionCollectionView.allowsMultipleSelection = _question.isMultipleChoice;
	dispatch_async(dispatch_get_main_queue(), ^{
        [self updateOuterContainerSize];
	});
}

#pragma mark - action
- (IBAction)skipButtonAction:(UIBarButtonItem *)sender {
	if (self.skipActionHandler) self.skipActionHandler();
}
- (IBAction)submitButtonAction:(UIBarButtonItem *)sender {
	if (self.submitActionHandler) self.submitActionHandler(self.optionCollectionView.indexPathsForSelectedItems);
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.question.options.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	PLVVodOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PLVVodOptionCell identifier] forIndexPath:indexPath];
//    cell.text = self.question.options[indexPath.item];
    NSString *optionText = [NSString stringWithFormat:@"%@ %@", [self optionOrderWithIndex:indexPath.row], self.question.options[indexPath.item]];
    cell.text = optionText;
    cell.multipleChoiceType = self.question.isMultipleChoice;
	return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = self.cellwidth;
    CGFloat h = self.cellHeights[indexPath.row];
    return CGSizeMake(w, h);
}

#pragma mark - public method
- (void)scrollToTop {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.optionCollectionView setContentOffset:CGPointZero animated:YES];
    });
}

#pragma mark - private method
- (void)updateUI {    
    CGFloat padding = 16;
    
    // 是否有插图
    BOOL hasIllustration = _question.illustration.length > 0;
    
    // 设置插图
    if (hasIllustration) {
        self.illustrationContainerWidthConstraint.constant = self.outerContanerWeidht / 2 - padding;
        [self.illustrationImageView yy_setImageWithURL:[NSURL URLWithString:_question.illustration] placeholder:nil];
    } else {
        self.illustrationContainerWidthConstraint.constant = 0;
    }
    
    // 计算cell的宽度
    CGFloat cellW = self.outerContanerWeidht / 2 - padding - 10;
    if ([self isLandscape] && !hasIllustration){
        // 无图且处于横屏状态，显示一行，重新计算cell 宽度，
       cellW = self.outerContanerWeidht - 2*padding -10;
    }
    
    if (cellW <= 0) { cellW = 1; }
    self.cellwidth = cellW;
    
    // 计算cell的高度
    int count = (int)_question.options.count;
    self.cellHeights = malloc(sizeof(CGFloat) * count);
    for (int i=0; i<count; i++) { // 根据每个cell的文字计算每个cell适合的高度
        NSString *optionText = [NSString stringWithFormat:@"%@ %@", [self optionOrderWithIndex:i], self.question.options[i]];
        CGFloat h = [PLVVodOptionCell calculateCellWithHeight:optionText andWidth:self.cellwidth];
        self.cellHeights[i] = h;
    }
    if (!hasIllustration) { // 没有插图时，一行显示两个cell，两个cell的高度要保持一致
        if (![self isLandscape]){
            for (int i=0; i<count/2; i++) {
                int leftCellIndex = i * 2;
                int rightCellIndex = i * 2 + 1;
                if (self.cellHeights[leftCellIndex] > self.cellHeights[rightCellIndex]) {
                    self.cellHeights[rightCellIndex] = self.cellHeights[leftCellIndex];
                } else {
                    self.cellHeights[leftCellIndex] = self.cellHeights[rightCellIndex];
                }
            }
        }
    }
    
    [self.optionCollectionView reloadData];
    
    // 设置问题
    self.questionLabel.text = _question.question;

    // 设置题型
    self.questionTypeLb.text = _question.isMultipleChoice ? @"【多选题】" : @"【单选题】";
    
    // 设置跳过按钮
    self.skipButton.enabled = _question.skippable;
    
    if ([self isLandscape]){
        self.questionLabel.textAlignment = NSTextAlignmentCenter;
    }else{
        self.questionLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    [self layoutIfNeeded];
}

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

    } else { // 横屏
        CGFloat verticalPadding = 60;
        CGFloat horzontalPadding;
        
        CGFloat scale = verticalPadding / 375.0;
        verticalPadding = scale * height;
        
        CGFloat outerContanerHeight = height - verticalPadding * 2;
        self.outerContanerWeidht = outerContanerHeight / 9.0 * 16;
        
        horzontalPadding = (width - self.outerContanerWeidht) / 2.0 ;
        
        // NSLog(@"outerContanerHeight = %f", outerContanerHeight);
        
        self.outerContainerLeadingConstraint.constant = horzontalPadding;
        self.outerContainerTailingConstraint.constant = horzontalPadding;
        self.outerContainerTopConstraint.constant = verticalPadding;
        self.outerContainerBottomConstraint.constant = verticalPadding;
    }
    
    [self updateUI];
}

- (BOOL)isLandscape{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIDeviceOrientationIsLandscape((UIDeviceOrientation)interfaceOrientation);
}

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


@end

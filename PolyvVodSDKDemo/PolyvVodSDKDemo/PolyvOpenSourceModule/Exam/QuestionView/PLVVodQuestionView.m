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

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

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
        [self updateUI];
    }
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self.optionCollectionView registerNib:[UINib nibWithNibName:[PLVVodOptionCell identifier] bundle:nil] forCellWithReuseIdentifier:[PLVVodOptionCell identifier]];
	self.optionCollectionView.allowsMultipleSelection = YES;
	self.optionCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
	dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
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
    return CGSizeMake(self.cellwidth, self.cellHeights[indexPath.row]);
}

#pragma mark - public method
- (void)scrollToTop {
	[self.optionCollectionView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - private method
- (void)updateUI {
    [self updateOuterContainerSize];
    
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
    self.cellwidth = self.outerContanerWeidht / 2 - padding - 10;
    if ([self isLandscape] && !hasIllustration){
        // 无图且处于横屏状态，显示一行，重新计算cell 宽度，
        self.cellwidth = self.outerContanerWeidht - 2*padding -10;
    }

    // 计算cell的高度
    int count = (int)_question.options.count;
    self.cellHeights = malloc(sizeof(CGFloat) * count);
    for (int i=0; i<count; i++) { // 根据每个cell的文字计算每个cell适合的高度
        self.cellHeights[i] = [PLVVodOptionCell calculateCellWithHeight:_question.options[i] andWidth:self.cellwidth];
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
    self.questionLabel.numberOfLines = 0;
    
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
    if (interfaceOrientation == UIInterfaceOrientationPortrait) { // 竖屏
        self.outerContainerLeadingConstraint.constant = 0;
        self.outerContainerTailingConstraint.constant = 0;
        self.outerContainerTopConstraint.constant = 0;
        self.outerContainerBottomConstraint.constant = 0;
        
        self.outerContanerWeidht = [UIScreen mainScreen].bounds.size.width;
    } else { // 横屏
        CGFloat verticalPadding = 60;
        CGFloat horzontalPadding;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat outerContanerHeight = screenHeight - 60 * 2;
        NSLog(@"outerContanerHeight = %f", outerContanerHeight);
        self.outerContanerWeidht = outerContanerHeight / 9 * 16;
        
        horzontalPadding = (screenWidth - self.outerContanerWeidht) / 2 ;
        
        self.outerContainerLeadingConstraint.constant = horzontalPadding;
        self.outerContainerTailingConstraint.constant = horzontalPadding;
        self.outerContainerTopConstraint.constant = verticalPadding;
        self.outerContainerBottomConstraint.constant = verticalPadding;
    }
    
//    [self layoutIfNeeded];
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

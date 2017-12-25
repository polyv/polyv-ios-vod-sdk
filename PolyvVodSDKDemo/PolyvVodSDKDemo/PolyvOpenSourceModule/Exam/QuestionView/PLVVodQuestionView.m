//
//  PLVVodQuestionView.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodQuestionView.h"
#import "PLVVodOptionCell.h"
#import "PLVVodQuestionReusableView.h"

@interface PLVVodQuestionView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionLayout;

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
	[self.optionCollectionView reloadData];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self.optionCollectionView registerNib:[UINib nibWithNibName:[PLVVodOptionCell identifier] bundle:nil] forCellWithReuseIdentifier:[PLVVodOptionCell identifier]];
	[self.optionCollectionView registerNib:[UINib nibWithNibName:[PLVVodQuestionReusableView identifier] bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[PLVVodQuestionReusableView identifier]];
	self.optionCollectionView.allowsMultipleSelection = YES;
	self.optionCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
}

#pragma mark - property

- (void)setQuestion:(PLVVodQuestion *)question {
	_question = question;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.optionCollectionView reloadData];
		self.skipButton.enabled = question.skippable;
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
	cell.text = self.question.options[indexPath.item];
	return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	CGFloat width = CGRectGetWidth(collectionView.bounds);
	NSString *headerText = self.question.question;
	CGFloat height = [PLVVodQuestionReusableView preferredHeightWithText:headerText inSize:CGSizeMake(width, CGFLOAT_MAX)];
	CGSize headerSize = CGSizeMake(width, height);
	return headerSize;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	PLVVodQuestionReusableView *header = (PLVVodQuestionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[PLVVodQuestionReusableView identifier] forIndexPath:indexPath];
	//header.text = @"POLYV保利威视不提供何种产品服务？";
	header.text = self.question.question;
	return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat margin = 15;
	CGFloat minWidth = 160;
	CGFloat collectionWidth = CGRectGetWidth(collectionView.bounds);
	CGFloat width = minWidth;
	if (collectionWidth < minWidth*2+margin) {
		width = collectionWidth;
	} else if ((collectionWidth - margin)/2 > minWidth) {
		width = (collectionWidth - margin)/2;
	}
	return CGSizeMake(width, 25);
}

#pragma mark - public method

- (void)scrollToTop {
	[self.optionCollectionView setContentOffset:CGPointZero animated:YES];
}

@end

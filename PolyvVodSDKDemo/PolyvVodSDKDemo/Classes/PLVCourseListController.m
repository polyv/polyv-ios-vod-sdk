//
//  PLVCourseListController.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseListController.h"
#import "PLVCourseBannerReusableView.h"
#import "PLVCourseCell.h"
#import "PLVCourseNetworking.h"

@interface PLVCourseListController ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *courses;

@end

@implementation PLVCourseListController

static NSString * const reuseIdentifier = @"PLVCourseCell";
static NSString * const reuseHeader = @"reuseHeader";

// theme bg color: E9EBF5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[PLVCourseCell class] forCellWithReuseIdentifier:reuseIdentifier];
//	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PLVCourseCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
	[self.collectionView registerClass:[PLVCourseBannerReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeader];
    
    // Do any additional setup after loading the view.
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestCoursesWithCompletion:^(NSArray<PLVCourse *> *courses) {
		weakSelf.courses = courses;
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.collectionView reloadData];
		});
	}];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.courses.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLVCourseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	cell.course = self.courses[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	return CGSizeMake(width, width/16*9);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	PLVCourseBannerReusableView *header = (PLVCourseBannerReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeader forIndexPath:indexPath];
	return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
	CGFloat itemWidth = (screenWidth - 15*2 - 10)/2;
	CGFloat preferredWidth = PLVCourseCellPreferredContentSize.width;
	if (preferredWidth < itemWidth) {
		itemWidth = preferredWidth;
	}
	CGFloat itemHeight = PLVCourseCellPreferredContentSize.height;
	return CGSizeMake(itemWidth, itemHeight);
}

@end

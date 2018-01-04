//
//  PLVCourseListController.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseListController.h"
#import "PLVCourseBannerReusableView.h"
#import "PLVTitleHeaderReusableView.h"
#import "PLVCourseCell.h"
#import "PLVCourseNetworking.h"
#import "PLVCourseDetailController.h"

@interface PLVCourseListController ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *courses;
@property (nonatomic, strong) NSArray *bannerCourses;
@property (nonatomic, strong) PLVCourse *selectedCourse;

@end

@implementation PLVCourseListController

static NSString * const cellId = @"PLVCourseCell";
static NSString * const bannerHeaderId = @"bannerHeader";
static NSString * const titleHeaderId = @"titleHeader";
static NSString * const detialSegueId = @"course_detail";

// theme bg color: E9EBF5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[PLVCourseCell class] forCellWithReuseIdentifier:reuseIdentifier];
//	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PLVCourseCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
	[self.collectionView registerClass:[PLVCourseBannerReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:bannerHeaderId];
	[self.collectionView registerClass:[PLVTitleHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:titleHeaderId];
    
    // Do any additional setup after loading the view.
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestCoursesWithCompletion:^(NSArray<PLVCourse *> *courses) {
		if (!courses.count) return;
		weakSelf.courses = courses;
		NSMutableArray *bannerCourses = [NSMutableArray array];
        NSMutableArray *indexes = [NSMutableArray array];
		while (bannerCourses.count < 3) {
			int i = arc4random() % courses.count;
			BOOL containIndex = NO;
            for (NSNumber *index in indexes) {
				if (index.intValue == i) {
					containIndex = YES;
					break;
				}
            }
			if (containIndex) {
				continue;
			}
            [indexes addObject:@(i)];
			[bannerCourses addObject:courses[i]];
		}
		weakSelf.bannerCourses = bannerCourses;
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.collectionView reloadData];
		});
	}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([UIDevice currentDevice].systemVersion.doubleValue > 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
		self.navigationController.navigationBar.prefersLargeTitles = YES;
		self.navigationController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
#pragma clang diagnostic pop
	}
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([UIDevice currentDevice].systemVersion.doubleValue > 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
		self.navigationController.navigationBar.prefersLargeTitles = NO;
		self.navigationController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
#pragma clang diagnostic pop
	}
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
	[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.destinationViewController isKindOfClass:[PLVCourseDetailController class]]) {
		PLVCourseDetailController *detail = segue.destinationViewController;
		detail.course = self.selectedCourse;
	}
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger number = self.courses.count;
	UILabel *emptyLabel = [[UILabel alloc] init];
	emptyLabel.text = @"暂无网校数据";
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	collectionView.backgroundView = number ? nil : emptyLabel;
	return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLVCourseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
	cell.course = self.courses[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger index = indexPath.item;
	if (!(index >= 0 && index < self.courses.count)) {
		return;
	}
	self.selectedCourse = self.courses[index];
	UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
	[self performSegueWithIdentifier:detialSegueId sender:cell];
}

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
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	CGSize headerSize = CGSizeMake(screenSize.width, screenSize.width/16*9);
	if (screenSize.height < screenSize.width) {
		headerSize.height = PLVTitleHeaderPreferredHeight;
	}
	return headerSize;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	if (screenSize.height >= screenSize.width) {
		PLVCourseBannerReusableView *header = (PLVCourseBannerReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:bannerHeaderId forIndexPath:indexPath];
		header.bannerCourses = self.bannerCourses;
		__weak typeof(self) weakSelf = self;
		__weak typeof(header) _header = header;
		header.courseDidClick = ^(PLVCourse *course) {
			weakSelf.selectedCourse = course;
			[weakSelf performSegueWithIdentifier:detialSegueId sender:_header];
		};
		return header;
	} else {
		PLVTitleHeaderReusableView *header = (PLVTitleHeaderReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:titleHeaderId forIndexPath:indexPath];
		header.title = @"热门课程";
		return header;
	}
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

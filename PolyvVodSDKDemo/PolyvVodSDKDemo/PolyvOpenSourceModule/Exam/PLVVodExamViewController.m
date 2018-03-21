//
//  PLVVodExamViewController.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodExamViewController.h"
#import "PLVVodQuestionView.h"
#import "PLVVodExplanationView.h"
#import <PLVVodSDK/PLVVodExam.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVVodExamViewController ()

@property (nonatomic, strong) IBOutlet PLVVodQuestionView *questionView;
@property (nonatomic, strong) IBOutlet PLVVodExplanationView *explanationView;

/// 之前的约束
@property (nonatomic, strong) NSArray *priorConstraints;

@property (nonatomic, strong) NSMutableArray<PLVVodExam *> *tempExams;
@property (nonatomic, strong) PLVVodExam *currentExam;

@property (nonatomic, assign) BOOL showing;

@end

@implementation PLVVodExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.clipsToBounds = YES;
	self.automaticallyAdjustsScrollViewInsets = NO;
	[self.view addSubview:self.questionView];
	self.priorConstraints = [self constrainSubview:self.questionView toMatchWithSuperview:self.view];
	
	__weak typeof(self) weakSelf = self;
	self.questionView.submitActionHandler = ^(NSArray<NSIndexPath *> *indexPathsForSelectedItems) {
		// 判断正误
		PLVVodExam *exam = weakSelf.currentExam;
		NSSet *referenceAnswer = [NSSet setWithArray:exam.correctIndex];
		NSMutableSet *userAnswer = [NSMutableSet set];
		for (NSIndexPath *indexPath in indexPathsForSelectedItems) {
			[userAnswer addObject:@(indexPath.row)];
		}
		BOOL correct = [referenceAnswer isEqualToSet:userAnswer];
		[weakSelf showExplanationIfCorrect:correct];
	};
	self.questionView.skipActionHandler = ^{
		PLVVodExam *exam = [weakSelf hideExam];
		if (weakSelf.examDidCompleteHandler) weakSelf.examDidCompleteHandler(exam, 0);
	};
	self.explanationView.confirmActionHandler = ^(BOOL correct) {
		PLVVodExam *exam = [weakSelf hideExam];
		NSTimeInterval backTime = correct ? 0 : exam.backTime;
		if (weakSelf.examDidCompleteHandler) weakSelf.examDidCompleteHandler(exam, backTime);
	};
	
	self.view.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - property

- (void)setExams:(NSArray<PLVVodExam *> *)exams {
	NSArray *sortedExams = [exams sortedArrayUsingComparator:^NSComparisonResult(PLVVodExam *obj1, PLVVodExam *obj2) {
		return [@(obj1.showTime) compare:@(obj2.showTime)];
	}];
	_exams = sortedExams;
	_tempExams = sortedExams.mutableCopy;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	if (currentTime+1 < _currentTime && _currentTime > 0) {
		[self hideExam];
		_tempExams = self.exams.mutableCopy;
		//NSLog(@"current: %f -> %f", _currentTime, currentTime);
	}
	_currentTime = currentTime;
}

#pragma mark - public method

- (void)synchronouslyShowExam {
	if (self.showing) {
		return;
	}
	
	PLVVodExam *exam = [self examAtTime:self.currentTime];
	if (!exam || exam.correct) {
		return;
	}
	
	if (self.examWillShowHandler) self.examWillShowHandler(exam);
	[self resetIfNeedWithCompletion:^{
		// 显示问答
		[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
			self.view.alpha = 1;
			self.showing = YES;
		}];
		PLVVodQuestion *question = [self questionForExam:exam];
		
		self.questionView.question = question;
		self.currentExam = exam;
	}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - private method

- (PLVVodQuestion *)questionForExam:(PLVVodExam *)exam {
	if (!exam || !exam.question.length) {
		return nil;
	}
	PLVVodQuestion *question = [[PLVVodQuestion alloc] init];
	question.question = exam.question;
	question.options = exam.options;
	question.skippable = exam.skippable;
	return question;
}

- (PLVVodExam *)examAtTime:(NSTimeInterval)time {
	if (!self.exams.count) {
		return nil;
	}
	NSInteger intTime = (NSInteger)time;
	
	PLVVodExam *exam = self.tempExams.firstObject;
	NSInteger showTime = (NSInteger)exam.showTime;
	
	if (showTime == intTime) { // hit
		[self.tempExams removeObjectAtIndex:0];
		return exam;
	} else if (showTime < intTime && self.tempExams.count) {
		[self.tempExams removeObjectAtIndex:0];
		[self examAtTime:time];
	}
	return nil;
}

- (PLVVodExam *)hideExam {
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.view.alpha = 0;
		self.showing = NO;
	}];
	PLVVodExam *exam = self.currentExam;
	self.currentExam = nil;
	return exam;
}

- (void)resetIfNeedWithCompletion:(void (^)(void))completion {
	if ([self.view.subviews containsObject:self.explanationView]) {
		NSArray *priorConstraints = self.priorConstraints;
		UIView *fromView = self.explanationView;
		UIView *toView = self.questionView;
		[UIView transitionFromView:fromView toView:toView duration:0 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
			if (priorConstraints != nil) {
				[self.view removeConstraints:priorConstraints];
			}
			[self.questionView scrollToTop];
			if (completion) completion();
		}];
		self.priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.view];
	} else {
		if (completion) completion();
	}
}

- (void)showExplanationIfCorrect:(BOOL)correct {
	PLVVodExam *exam = self.currentExam;
	if (!exam) {
		return;
	}
	self.currentExam.correct = correct;
	[self.explanationView setExplanation:[exam explanation] correct:correct];
	[self transitFromView:self.questionView toView:self.explanationView completion:^{
		[self.explanationView scrollToTop];
	}];
}

#pragma mark tool

// 执行动画视图转场
- (void)transitFromView:(UIView *)fromView toView:(UIView *)toView completion:(void (^)(void))completion {
	if (fromView == toView || !fromView || !toView) {
		return;
	}
	[self transitFromView:fromView toView:toView options:UIViewAnimationOptionTransitionCrossDissolve completion:completion];
}
- (void)transitFromView:(UIView *)fromView toView:(UIView *)toView options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
	NSArray *priorConstraints = self.priorConstraints;
	[UIView transitionFromView:fromView toView:toView duration:PLVVodAnimationDuration options:options completion:^(BOOL finished) {
		if (priorConstraints != nil) {
			[self.view removeConstraints:priorConstraints];
		}
		if (completion) completion();
	}];
	self.priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.view];
}

// makes "subview" match the width and height of "superview" by adding the proper auto layout constraints
- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview {
	subview.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
	
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:viewsDictionary];
	constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:viewsDictionary]];
	[superview addConstraints:constraints];
	
	return constraints;
}

@end

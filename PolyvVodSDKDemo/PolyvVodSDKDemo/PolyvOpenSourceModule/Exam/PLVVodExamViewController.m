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
#import "NSString+PLVVod.h"
#import "PLVFillBlankQuestionView.h"
#import "PLVToast.h"

@interface PLVVodExamViewController ()

@property (nonatomic, strong) IBOutlet PLVVodQuestionView *questionView;
@property (nonatomic, strong) IBOutlet PLVVodExplanationView *explanationView;

@property (nonatomic, strong) PLVFillBlankQuestionView *fillBlankQuestionView;//!< 填空题问题view

@property (nonatomic, strong) NSMutableArray<PLVVodExam *> *tempExams;
@property (nonatomic, strong) PLVVodExam *currentExam;

@property (nonatomic, assign) BOOL showing;

@property (nonatomic, strong) NSArray<NSNumber *> *answerIndexs;

@end

@implementation PLVVodExamViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self setupUI];
	
	__weak typeof(self) weakSelf = self;
    
    // 选择题的提交回调
    self.questionView.submitActionHandler = ^(NSArray<NSNumber *> *indexForSelectedItems) {
        
        if (indexForSelectedItems.count == 0) {
            [PLVToast showMessage:@"您还未选择任何答案"];
            return;
        }
        // 保存选项
        weakSelf.answerIndexs = [NSArray arrayWithArray:indexForSelectedItems];
        
        // 判断正误
        PLVVodExam *exam = weakSelf.currentExam;
        NSSet *referenceAnswer = [NSSet setWithArray:exam.correctIndex];
        NSSet *userAnswer = [NSSet setWithArray:indexForSelectedItems];
        BOOL correct = [referenceAnswer isEqualToSet:userAnswer];
        
        [weakSelf showExplanationIfCorrect:correct];
    };
    
    // 选择题的跳过回调
	self.questionView.skipActionHandler = ^{
		PLVVodExam *exam = [weakSelf hideExam];
		if (weakSelf.examDidCompleteHandler) weakSelf.examDidCompleteHandler(exam, -1, nil);
	};
    
    // 填空题的提交回调
    self.fillBlankQuestionView.submitFillBlankTopicActionHandler = ^(NSArray<NSString *> * _Nonnull answerItems) {
        BOOL allEmpty = YES;
        for (NSString *answer in answerItems) {
            if (answer.length > 0) {
                allEmpty = NO;
                break;
            }
        }
        
        if (allEmpty) {
            [PLVToast showMessage:@"请填写答案后提交"];
            return;
        }
        
        // 判断正误
        BOOL correct = [weakSelf judgeFillBlankTrueOrFalse:answerItems];
        [weakSelf showExplanationIfCorrect:correct];
    };
    
    //填空题的跳过回调
    self.fillBlankQuestionView.skipActionHandler = ^{
        PLVVodExam *exam = [weakSelf hideExam];
        if (weakSelf.examDidCompleteHandler) weakSelf.examDidCompleteHandler(exam, -1, nil);
    };
    
	self.explanationView.confirmActionHandler = ^(BOOL correct) {
		PLVVodExam *exam = [weakSelf hideExam];
		NSTimeInterval backTime = correct ? -1 : exam.backTime;
		if (weakSelf.examDidCompleteHandler) weakSelf.examDidCompleteHandler(exam, backTime, weakSelf.answerIndexs);
	};
	
	self.view.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI

-(void)setupUI
{
    self.view.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.explanationView.hidden = YES;
    self.questionView.hidden = YES;
    self.fillBlankQuestionView.hidden = YES;
    [self.view addSubview:self.explanationView];
    [self.view addSubview:self.questionView];
    [self.view addSubview:self.fillBlankQuestionView];
    
    self.explanationView.translatesAutoresizingMaskIntoConstraints = NO;
    self.questionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.fillBlankQuestionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray<NSLayoutConstraint *> *constrainsArray = [NSMutableArray array];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.explanationView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.explanationView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.explanationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.explanationView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.questionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.questionView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.questionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.questionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.fillBlankQuestionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.fillBlankQuestionView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.fillBlankQuestionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [constrainsArray addObject:[NSLayoutConstraint constraintWithItem:self.fillBlankQuestionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self.view addConstraints:constrainsArray];
}

#pragma mark - Setter

- (void)setExams:(NSArray<PLVVodExam *> *)exams {
	NSArray *sortedExams = [exams sortedArrayUsingComparator:^NSComparisonResult(PLVVodExam *obj1, PLVVodExam *obj2) {
		return [@(obj1.showTime) compare:@(obj2.showTime)];
	}];
	_exams = sortedExams;
	self.tempExams = sortedExams.mutableCopy;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	if (currentTime+1 < _currentTime && _currentTime > 0) {
        // 重置问题
		[self hideExam];
		self.tempExams = self.exams.mutableCopy;
		//NSLog(@"current: %f -> %f", _currentTime, currentTime);
	}
	_currentTime = currentTime;
}


#pragma mark - public method

/// 同步显示问答
- (void)synchronouslyShowExam {
	if (self.showing) {
		return;
	}
	
	PLVVodExam *exam = [self examAtTime:self.currentTime];
    
    //用于兼容以后题型增加，但是客户demo没有升级的情况
    if (exam.examType > 2) {
        NSLog(@"PLVVodExamViewController - 问题展示错误，exam.examType非法，请检查更新demo");
        return;
    }
    
	if (!exam || exam.correct) {
		return;
	}
    
    // 问答参数检查
    if (![exam.question checkStringLegal]) {
        NSLog(@"PLVVodExamViewController - 问题展示错误，exam.question非法，请检查");
        return;
    }
    
    if (exam.options.count == 0) {
        NSLog(@"PLVVodExamViewController - 问题展示错误，exam.options非法，请检查");
        return;
    }
    
    if (exam.correctIndex.count == 0
        && exam.examType < 2) {
        NSLog(@"PLVVodExamViewController - 问题展示错误，exam.correctIndex非法，请检查");
        return;
    }
	
	if (self.examWillShowHandler) self.examWillShowHandler(exam);
    
    if (exam.examType == 2) {
        //填空题
        self.fillBlankQuestionView.hidden = NO;
    }else {
        //选择题
        self.questionView.hidden = NO;
    }
    
    // 显示问答
    [UIView animateWithDuration:PLVVodAnimationDuration animations:^{
        self.view.alpha = 1;
        self.showing = YES;
    } completion:^(BOOL finished) {
        PLVVodQuestion *question = [self questionForExam:exam];
        if (exam.examType == 2) {
            self.fillBlankQuestionView.question = question;
            [self.fillBlankQuestionView scrollToTop];
        }else {
            self.questionView.question = question;
            [self.questionView scrollToTop];
        }
        self.currentExam = exam;
        self.answerIndexs = nil;
    }];
}

/// 更新问题
- (void)changeExams:(NSArray<PLVVodExam *> *)arrExam showTime:(NSTimeInterval)showTime{
    NSArray *tmpArr = [self updateExamArray:self.tempExams changeArray:arrExam showTime:showTime];
    _tempExams = [NSMutableArray arrayWithArray:tmpArr];
    _exams = [self updateExamArray:self.exams changeArray:arrExam showTime:showTime];
}

- (NSArray<PLVVodExam *> *)updateExamArray:(NSArray<PLVVodExam *> *)origArray changeArray:(NSArray<PLVVodExam *> *)changeArray showTime:(NSTimeInterval)showTime{
    // 删除旧问题
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:origArray];
    [origArray enumerateObjectsUsingBlock:^(PLVVodExam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.showTime == showTime){
            [tmpArray removeObject:obj];
        }
    }];
    // 插入更新后的问题
    [changeArray enumerateObjectsUsingBlock:^(PLVVodExam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PLVVodExam *arrObj = obj;
        [origArray enumerateObjectsUsingBlock:^(PLVVodExam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (arrObj.showTime <= obj.showTime){
                [tmpArray insertObject:arrObj atIndex:idx];
                *stop = YES;
            }
        }];
    }];
    
    NSArray *retArr = [NSMutableArray arrayWithArray:tmpArray];
    return retArr;
}

#pragma mark - private method

/// 判断填空题回答正确还是错误
/// @param answerArray 答案数组
-(BOOL)judgeFillBlankTrueOrFalse:(NSArray *)answerArray
{
    if (answerArray.count <= 0
        || answerArray.count != self.currentExam.options.count) {
        return NO;
    }
    for (NSInteger i = 0; i < self.currentExam.options.count; i++) {
        NSString *rightAnswer = self.currentExam.options[i];
        NSString *answer = answerArray[i];
        if (![rightAnswer isEqualToString:answer]) {
            return NO;
        }
    }
    return YES;
}

- (PLVVodQuestion *)questionForExam:(PLVVodExam *)exam {
	if (!exam) {
		return nil;
	}
	PLVVodQuestion *question = [[PLVVodQuestion alloc] init];
	question.question = exam.question;
	question.options = exam.options;
	question.skippable = exam.skippable;
    question.illustration = exam.illustration;
    question.isMultipleChoice = exam.correctIndex.count > 1 ? YES : NO;
    question.isFillBlankTopic = exam.examType == 2 ? YES : NO;
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


/// 隐藏问卷
- (PLVVodExam *)hideExam {
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.view.alpha = 0;
        self.explanationView.hidden = YES;
        self.questionView.hidden = YES;
        self.fillBlankQuestionView.hidden = YES;
		self.showing = NO;
	}];
	PLVVodExam *exam = self.currentExam;
	self.currentExam = nil;
	return exam;
}


/// 展示问答结果view
/// @param correct 回答正确还是错误
- (void)showExplanationIfCorrect:(BOOL)correct {
	PLVVodExam *exam = self.currentExam;
	if (!exam) {
		return;
	}
	self.currentExam.correct = correct;
	[self.explanationView setExplanation:[exam explanation] correct:correct];
    UIView *fromView = exam.examType == 2 ? self.fillBlankQuestionView : self.questionView;
    fromView.hidden = YES;
    self.explanationView.hidden = NO;
    [self.explanationView scrollToTop];
}


#pragma mark - Loadlazy

-(PLVFillBlankQuestionView *)fillBlankQuestionView
{
    if (_fillBlankQuestionView == nil) {
        _fillBlankQuestionView = [[PLVFillBlankQuestionView alloc]init];
    }
    return _fillBlankQuestionView;
}

@end

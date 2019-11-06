//
//  PLVPPTActionView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/1.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTActionView.h"
#import "PLVPPTActionViewCell.h"
#import <PLVVodSDK/PLVVodPPT.h>

static NSTimeInterval kDuration = 0.3;

@interface PLVPPTActionView ()<
UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) PLVVodPPT *ppt;
@property (nonatomic, strong) UIView *actionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRcog;

@end

@implementation PLVPPTActionView

- (instancetype)initWithPPT:(PLVVodPPT *)ppt {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        
        self.ppt = ppt;
        [self addSubview:self.actionView];
        [self addSubview:self.tableView];
        
        [self initObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter & Setter

- (UIView *)actionView {
    if (_actionView == nil) {
        _actionView = [[UIView alloc] initWithFrame:[self originRect]];
        _actionView.backgroundColor = [UIColor blackColor];
        _actionView.alpha = 0.7;
    }
    return _actionView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[self originRect] style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = [PLVPPTActionViewCell rowHeight];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UITapGestureRecognizer *)gestureRcog {
    if (!_gestureRcog) {
        _gestureRcog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmiss)];
        _gestureRcog.numberOfTapsRequired = 1;
        _gestureRcog.numberOfTouchesRequired = 1;
        _gestureRcog.delegate = self;
    }
    return _gestureRcog;
}

#pragma mark - Public Method

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addGestureRecognizer:self.gestureRcog];
    [window addSubview:self];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect mviewRc = self.actionView.frame;
    mviewRc.origin.x = self.frame.size.width - self.actionView.frame.size.width;
    self.actionView.frame = mviewRc;
    self.tableView.frame = mviewRc;
    [UIView commitAnimations];
}

- (void)dissmiss {
    if (self.superview == nil) {
        return;
    }
    
    [self.superview removeGestureRecognizer:self.gestureRcog];
    [UIView animateWithDuration:kDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect mviewRc = self.actionView.frame;
        mviewRc.origin.x = self.frame.size.width;
        self.actionView.frame = mviewRc;
        self.tableView.frame = mviewRc;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Private

- (CGRect)originRect {
    CGRect rect = self.frame;
    rect.size.width = 381;
    rect.origin.x = self.frame.size.width;
    return rect;
}

- (void)initObserver {
    // 横竖屏切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

#pragma mark - NSNotification

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (isLandscape == NO) {
        [self dissmiss];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    return (point.x < 0);
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ppt ? [self.ppt.pages count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    PLVPPTActionViewCell *cell = (PLVPPTActionViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PLVPPTActionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell configPPTPage:self.ppt.pages[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelectCellHandler) {
        self.didSelectCellHandler(indexPath.row);
    }
}
@end

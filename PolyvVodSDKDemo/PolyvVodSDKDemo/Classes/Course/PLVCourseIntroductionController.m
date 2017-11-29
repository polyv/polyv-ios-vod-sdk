//
//  PLVCourseIntroductionController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseIntroductionController.h"

@interface PLVCourseIntroductionController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, assign) BOOL contentDidLoad;

@end

@implementation PLVCourseIntroductionController

- (void)setHtmlContent:(NSString *)htmlContent {
	_htmlContent = htmlContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.webView.delegate = self;
	self.webView.scalesPageToFit = NO;
	self.webView.scrollView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.webView loadHTMLString:_htmlContent baseURL:nil];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return !self.contentDidLoad;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.contentDidLoad = YES;
}

@end

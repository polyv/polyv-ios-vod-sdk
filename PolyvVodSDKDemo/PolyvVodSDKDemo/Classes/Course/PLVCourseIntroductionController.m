//
//  PLVCourseIntroductionController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseIntroductionController.h"

@interface PLVCourseIntroductionController ()
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@end

@implementation PLVCourseIntroductionController

- (void)setHtmlContent:(NSString *)htmlContent {
	_htmlContent = htmlContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.htmlContent.length && ![self.htmlContent isKindOfClass:[NSNull class]]) {
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithData:[_htmlContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
		
		self.introLabel.attributedText = attributedText;
	} else {
		self.introLabel.text = @"暂无课程介绍";
	}
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

@end

//
//  PLVVodVidTestController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/5.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodVidTestController.h"
#import "PLVVodSkinPlayerController.h"
#import <PLVVodSDK/PLVVodSDK.h>

@interface PLVVodVidTestController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;

@property (weak, nonatomic) IBOutlet UITextView *videoInfoTextView;

/// 带皮肤播放器
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@end

@implementation PLVVodVidTestController

- (void)dealloc {
	NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
	[player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
	self.player = player;
}

- (BOOL)prefersStatusBarHidden {
	return self.player.prefersStatusBarHidden;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.player.preferredStatusBarStyle;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	self.editing = NO;
}

#pragma property

- (void)setVideo:(PLVVodVideo *)video {
	_video = video;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.player.video = video;
		self.videoInfoTextView.text = video.description;
	});
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSString *vid = textField.text;
	vid = [vid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (vid.length) {
		__weak typeof(self) weakSelf = self;
		[PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
			weakSelf.video = video;
		}];
	}
	
	[textField endEditing:YES];
	return NO;
}

#pragma mark - action

- (IBAction)doneAction:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(UIBarButtonItem *)sender {
	PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
	PLVVodDownloadInfo *info = [downloadManager downloadVideo:self.video];
	__weak typeof(self) weakSelf = self;
	info.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
		NSLog(@"downlaod %@ progress: %@", weakSelf.video.vid, [NSNumberFormatter localizedStringFromNumber:@(info.progress) numberStyle:NSNumberFormatterPercentStyle]);
	};
	[downloadManager startDownload];
}

@end

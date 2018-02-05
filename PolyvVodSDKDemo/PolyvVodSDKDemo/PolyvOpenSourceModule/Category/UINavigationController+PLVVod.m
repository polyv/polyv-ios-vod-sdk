//
//  UINavigationController+PLVVod.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/30.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "UINavigationController+PLVVod.h"

@implementation UINavigationController (PLVVod)

- (BOOL)shouldAutorotate {
	return [self.topViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return [self.topViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.topViewController;
}
- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.topViewController;
}

@end

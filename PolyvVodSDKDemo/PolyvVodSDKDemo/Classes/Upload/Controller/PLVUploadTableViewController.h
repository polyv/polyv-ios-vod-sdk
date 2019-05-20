//
//  PLVUploadTableViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/15.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVUploadTableViewControllerDelegate <NSObject>

- (void)reloadTableView;

@end

@interface PLVUploadTableViewController : UIViewController<
PLVUploadTableViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *openLibraryButton;

@end

NS_ASSUME_NONNULL_END

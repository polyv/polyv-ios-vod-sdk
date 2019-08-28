//
//  PLVPPTActionViewCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/5.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVVodPPTPage;

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTActionViewCell : UITableViewCell

+ (CGFloat)rowHeight;

- (void)configPPTPage:(PLVVodPPTPage *)pptPage;

@end

NS_ASSUME_NONNULL_END

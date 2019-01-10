//
//  PLVVodCoverView.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/25.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodCoverView : UIView // 封面图控件

// 封面图
@property (weak, nonatomic) IBOutlet UIImageView *coverImgV;

- (void)setCoverImageWithUrl:(NSString *)coverUrl;

@end

NS_ASSUME_NONNULL_END

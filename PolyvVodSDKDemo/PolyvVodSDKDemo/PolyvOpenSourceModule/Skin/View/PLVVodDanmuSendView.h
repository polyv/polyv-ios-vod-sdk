//
//  PLVVodDanmuSendView.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/11/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodDanmuSendView : UIView

@property (nonatomic, strong, readonly) NSString *danmuContent;
@property (nonatomic, assign, readonly) NSUInteger danmuColorHex;
@property (nonatomic, assign, readonly) int danmuFontSize;
@property (nonatomic, assign, readonly) NSInteger danmuMode;

@end

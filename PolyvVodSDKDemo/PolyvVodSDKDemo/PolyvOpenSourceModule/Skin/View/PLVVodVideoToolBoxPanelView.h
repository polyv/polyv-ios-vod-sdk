//
//  PLVVodVideoToolBoxPanelView.h
//  PolyvVodSDKDemo
//
//  Created by juno on 2022/9/14.
//  Copyright © 2022 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodVideoToolBoxPanelView : UIView

@property (nonatomic, assign) BOOL isVideoToolBox;
@property (nonatomic, copy) void (^videoToolBoxDidChangeBlock)(BOOL isVideoToolBox);
@property (nonatomic, copy) void (^videoToolBoxButtonDidClick)(UIButton *sender);

@end

NS_ASSUME_NONNULL_END

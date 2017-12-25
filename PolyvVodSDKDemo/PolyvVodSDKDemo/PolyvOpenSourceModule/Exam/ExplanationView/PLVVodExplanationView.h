//
//  PLVVodExplanationView.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodExplanationView : UIView

@property (nonatomic, copy) void (^confirmActionHandler)(BOOL correct);

- (void)setExplanation:(NSString *)explanation correct:(BOOL)correct;

- (void)scrollToTop;

@end

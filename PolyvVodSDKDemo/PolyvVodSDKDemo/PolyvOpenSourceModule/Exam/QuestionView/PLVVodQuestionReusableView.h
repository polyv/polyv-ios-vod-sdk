//
//  PLVVodQuestionReusableView.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodQuestionReusableView : UICollectionReusableView

@property (nonatomic, copy) NSString *text;

+ (NSString *)identifier;

+ (CGFloat)preferredHeightWithText:(NSString *)text inSize:(CGSize)maxSize;

@end

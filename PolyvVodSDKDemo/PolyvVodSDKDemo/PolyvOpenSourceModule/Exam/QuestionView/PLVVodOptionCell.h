//
//  PLVVodOptionCell.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodOptionCell : UICollectionViewCell

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL multipleChoiceType; // 是否多选样式

+ (NSString *)identifier;

+ (CGFloat)calculateCellWithHeight:(NSString *)s andWidth:(CGFloat)width;

@end

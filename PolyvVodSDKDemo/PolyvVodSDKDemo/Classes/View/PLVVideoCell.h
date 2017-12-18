//
//  PLVVideoCell.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVideoCell : UITableViewCell

@property (nonatomic, strong) id video;
@property (nonatomic, copy) void (^playButtonAction)(PLVVideoCell *cell, UIButton *sender);
@property (nonatomic, copy) void (^downloadButtonAction)(PLVVideoCell *cell, UIButton *sender);

+ (NSString *)identifier;

@end

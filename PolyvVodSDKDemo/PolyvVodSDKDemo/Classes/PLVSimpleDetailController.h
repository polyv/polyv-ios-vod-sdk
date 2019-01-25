//
//  PLVSimpleDetailController.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVVodVideo;

@interface PLVSimpleDetailController : UIViewController

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, strong) PLVVodVideo *localVideo;

@end

//
//  PLVSimpleDetailController.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVVodLocalVideo;

@interface PLVSimpleDetailController : UIViewController

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, strong) PLVVodLocalVideo *localVideo;

@end

//
//  PLVDownloadCompleteInfoModel.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/8/18.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVVodLocalVideo;
@class PLVVodDownloadInfo;

@interface PLVDownloadCompleteInfoModel : NSObject

@property (nonatomic, strong) PLVVodLocalVideo *localVideo;

@property (nonatomic, strong) PLVVodDownloadInfo *downloadInfo;

@end

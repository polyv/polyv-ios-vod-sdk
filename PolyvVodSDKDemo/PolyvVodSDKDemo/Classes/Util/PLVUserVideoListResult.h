//
//  PLVUserVideoListResult.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVUserVideoListItemModel;

@interface PLVUserVideoListResult : NSObject

@property (nonatomic, copy) NSString *pageSize;
@property (nonatomic, copy) NSString *pageNumber;
@property (nonatomic, copy) NSString *totalItems;

@property (nonatomic, strong) NSMutableArray<PLVUserVideoListItemModel *> *contents;

- (instancetype)initWithDic:(NSDictionary *)dict;

@end

@interface PLVUserVideoListItemModel : NSObject

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *cataid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *context;
@property (nonatomic, copy) NSString *times;
@property (nonatomic, copy) NSString *firstImage;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *aacLink;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *uploaderEmail;
@property (nonatomic, copy) NSString *ptime;

- (instancetype)initWithDic:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

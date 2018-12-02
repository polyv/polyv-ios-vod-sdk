//
//  PLVUserVideoListResult.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVUserVideoListResult.h"

@implementation PLVUserVideoListResult

- (instancetype)initWithDic:(NSDictionary *)dict{
    if (self = [super init]){
        _pageNumber = [NSString stringWithFormat:@"%@", dict[@"pageNumber"]];
        _pageSize = [NSString stringWithFormat:@"%@", dict[@"pageSize"]];
        _totalItems = [NSString stringWithFormat:@"%@", dict[@"totalItems"]];
        
        NSArray *contentArray = dict[@"contents"];
        if (contentArray.count > 0){
            _contents = [NSMutableArray arrayWithCapacity:0];
            [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *status = [NSString stringWithFormat:@"%@",[obj objectForKey:@"status"]];
                if ([status integerValue] >= 60){
                    PLVUserVideoListItemModel *item = [[PLVUserVideoListItemModel alloc] initWithDic:obj];
                    [_contents addObject:item];
                }
            }];
        }
    }
    
    return self;
}

@end


@implementation PLVUserVideoListItemModel

- (instancetype)initWithDic:(NSDictionary *)dict{
    if (self = [super init]){
        _cataid = [NSString stringWithFormat:@"%@", dict[@"cataid"]];
        _status = [NSString stringWithFormat:@"%@", dict[@"status"]];
        _firstImage = [NSString stringWithFormat:@"%@", dict[@"firstImage"]];
        _ptime = [NSString stringWithFormat:@"%@", dict[@"ptime"]];
        _vid = [NSString stringWithFormat:@"%@", dict[@"vid"]];
        _title = [NSString stringWithFormat:@"%@", dict[@"title"]];
        _context = [NSString stringWithFormat:@"%@", dict[@"context"]];
        _times = [NSString stringWithFormat:@"%@", dict[@"times"]];
        _tag = [NSString stringWithFormat:@"%@", dict[@"tag"]];
        _uploaderEmail = [NSString stringWithFormat:@"%@", dict[@"uploaderEmail"]];
        _aacLink = [NSString stringWithFormat:@"%@", dict[@"aacLink"]];
    }
    
    return self;
}

@end

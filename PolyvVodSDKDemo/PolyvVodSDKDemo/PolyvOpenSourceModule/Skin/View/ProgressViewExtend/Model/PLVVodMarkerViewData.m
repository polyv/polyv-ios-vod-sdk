//
//  PLVVodMarkerViewData.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/6.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodMarkerViewData.h"

/**
 
 markers: [
     { time: 10, title: '打点1', customId: '自定义参数1', color: 'green'},
     { time: 20, title: '打点2', customId: '自定义参数2', color: 'blue'},
     { time: 25, title: '打点超级长的打点超级长的打点超级长的打点超级长的', customId: '长的自定义参数长的自定义参数长的自定义参数长的自定义参数', color: 'black'},
     { time: 40, title: '打点3', customId: '自定义参数3', color: 'red'},
     { time: 60, title: '', customId: '', color: 'pink'},
     { time: 80, title: '打点4, customId: '自定义参数4', color: 'green'},
     { time: 100, title: '打点😣, customId: '自定义参数😣', color: 'yellow'},
   ]
 */

@implementation PLVVodMarkerViewData

+ (NSArray *)defautMarkerViewData{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    PLVVodMarkerViewData *item = [[PLVVodMarkerViewData alloc] init];
    item.time = 10;
    item.title = @"打点1";
    item.color = @"#ff0000";
    item.colorAlpha = 0.6;
    item.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item];
    
    PLVVodMarkerViewData *item1 = [[PLVVodMarkerViewData alloc] init];
    item1.time = 20;
    item1.title = @"打点2";
    item1.color = @"#0000ff";
    item1.colorAlpha = 0.6;
    item1.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item1];

    PLVVodMarkerViewData *item2 = [[PLVVodMarkerViewData alloc] init];
    item2.time = 25;
    item2.title = @"打点超级长的打点超级长的打点超级长的打点超级长的";
    item2.color = @"#ffffff";
    item2.colorAlpha = 0.6;
    item2.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item2];

    PLVVodMarkerViewData *item3 = [[PLVVodMarkerViewData alloc] init];
    item3.time = 40;
    item3.title = @"打点3";
    item3.color = @"#ff0000";
    item3.colorAlpha = 0.6;
    item3.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item3];

    PLVVodMarkerViewData *item4 = [[PLVVodMarkerViewData alloc] init];
    item4.time = 60;
    item4.title = @"";
    item4.color = @"#FFF0F5";
    item4.colorAlpha = 0.6;
    item4.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item4];

    PLVVodMarkerViewData *item5 = [[PLVVodMarkerViewData alloc] init];
    item5.time = 80;
    item5.title = @"打点4";
    item5.color = @"#008000";
    item5.colorAlpha = 0.6;
    item5.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item5];

    PLVVodMarkerViewData *item6 = [[PLVVodMarkerViewData alloc] init];
    item6.time = 100;
    item6.title = @"打点😣";
    item6.color = @"#FFEA00";
    item6.colorAlpha = 0.6;
    item6.totalVideoTime = 110; // 测试数据，以实际视频时长为准
    [data addObject:item6];

    /*
    for (int i=0; i< 10; i++){
        PLVVodMarkerViewData *item = [[PLVVodMarkerViewData alloc] init];
        item.title = [NSString stringWithFormat:@"%d", i];
        item.time = i * 10.0;
        item.totalVideoTime = 80;
        item.color = @"#000000";
        item.colorAlpha = 0.6;
        
        [data addObject:item];
    }*/
    
    return data;
}

- (instancetype)init{
    if (self = [super init]){
        _colorAlpha = 1.0;
    }
    return self;
}

@end

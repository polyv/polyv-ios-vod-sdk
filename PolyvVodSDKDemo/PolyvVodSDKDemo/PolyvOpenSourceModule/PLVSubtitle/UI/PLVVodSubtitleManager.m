//
//  PLVVodSubtitleManager.m
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSubtitleManager.h"
#import "PLVVodSubtitleParser.h"

@interface PLVVodSubtitleManager ()

@property (nonatomic, strong) PLVVodSubtitleParser *parser; // 双字幕时表示上方字幕
@property (nonatomic, strong) PLVVodSubtitleParser *parser2; // 双字幕时表示下方字幕，单字幕时不显示
@property (nonatomic, strong) PLVVodSubtitleViewModel *viewModel;

@end

@implementation PLVVodSubtitleManager

- (PLVVodSubtitleViewModel *)viewModel {
	if (!_viewModel) {
		_viewModel = [[PLVVodSubtitleViewModel alloc] init];
	}
	return _viewModel;
}

- (NSMutableArray *)subtitleItems {
	return self.parser.subtitleItems;
}

- (NSMutableArray *)subtitleItems2 {
    return self.parser2.subtitleItems;
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel error:(NSError **)error {
    return [self managerWithSubtitle:subtitle label:subtitleLabel topLabel:nil error:error];
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle style:(PLVVodSubtitleItemStyle *)style label:(UILabel *)subtitleLabel error:(NSError **)error {
    return [self managerWithSubtitle:subtitle style:style label:subtitleLabel topLabel:nil error:error];
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel error:(NSError **)error {
    return [self managerWithSubtitle:subtitle style:nil label:subtitleLabel topLabel:subtitleTopLabel error:error];
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle style:(PLVVodSubtitleItemStyle *)style label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel error:(NSError **)error {
    return [self managerWithSubtitle:subtitle style:style error:error subtitle2:nil style2:nil error2:nil label:subtitleLabel topLabel:subtitleTopLabel label2:nil topLabel2:nil];
}

+ (instancetype)managerWithSubtitle:(NSString *)subtitle style:(PLVVodSubtitleItemStyle *)style error:(NSError **)error subtitle2:(NSString *)subtitle2 style2:(PLVVodSubtitleItemStyle *)style2  error2:(NSError **)error2 label:(UILabel *)subtitleLabel topLabel:(UILabel *)subtitleTopLabel label2:(UILabel *)subtitleLabel2 topLabel2:(UILabel *)subtitleTopLabel2 {
    PLVVodSubtitleManager *manager = [[PLVVodSubtitleManager alloc] init];
    manager.parser = [PLVVodSubtitleParser parserWithSubtitle:subtitle error:error];
    manager.parser2 = [PLVVodSubtitleParser parserWithSubtitle:subtitle2 error:error2];
    
    BOOL subtitleEnable = subtitle && [subtitle isKindOfClass:NSString.class] && subtitle.length > 0;
    BOOL subtitle2Enable = subtitle2 && [subtitle2 isKindOfClass:NSString.class] && subtitle2.length > 0;
    BOOL doubleSubtitle = subtitleEnable && subtitle2Enable;
    
    if (doubleSubtitle) { // 双字幕
        // 底部字幕(下) 应用字幕样式2
        [manager.viewModel setSubtitleLabel:subtitleLabel style:style2];
        // 顶部字幕(上) 应用字幕样式
        [manager.viewModel setSubtitleTopLabel:subtitleTopLabel style:style];
        // 底部字幕(上) 应用字幕样式
        [manager.viewModel setSubtitleLabel2:subtitleLabel2 style:style];
        // 顶部字幕(下) 应用字幕样式2
        [manager.viewModel setSubtitleTopLabel2:subtitleTopLabel2 style:style2];
    } else {
        if (subtitleEnable) { // 单字幕应用字幕样式
            // 底部字幕(下) 应用字幕样式
            [manager.viewModel setSubtitleLabel:subtitleLabel style:style];
            // 顶部字幕(上) 应用字幕样式
            [manager.viewModel setSubtitleTopLabel:subtitleTopLabel style:style];
        } else { // 单字幕应用字幕样式2
            // 底部字幕(下) 应用字幕样式
            [manager.viewModel setSubtitleLabel:subtitleLabel style:style2];
            // 顶部字幕(上) 应用字幕样式
            [manager.viewModel setSubtitleTopLabel:subtitleTopLabel style:style2];
        }
        manager.viewModel.subtitleLabel2 = subtitleLabel2;
        manager.viewModel.subtitleTopLabel2 = subtitleTopLabel2;
    }
    
    
    return manager;
}

- (void)showSubtitleWithTime:(NSTimeInterval)time {
	NSDictionary * dic = [self.parser subtitleItemAtTime:time];
    NSDictionary * dic2 = [self.parser2 subtitleItemAtTime:time];
    
    BOOL dicEnable = dic && [dic isKindOfClass:NSDictionary.class] && dic.count > 0;
    BOOL dic2Enable = dic2 && [dic2 isKindOfClass:NSDictionary.class] && dic2.count > 0;
    BOOL doubleSubtitle = dicEnable && dic2Enable;
    
    PLVVodSubtitleItem *item;
    PLVVodSubtitleItem *itemAtTop;
    PLVVodSubtitleItem *item2;
    PLVVodSubtitleItem *itemAtTop2;
    if (doubleSubtitle) { // 双字幕
        item = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_bot"];
        itemAtTop = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_top"];
        item2 = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_bot"];
        itemAtTop2 = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_top"];
    } else {
        if (dicEnable) {
            item = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_bot"];
            itemAtTop = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_top"];
            item2 = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_bot"];
            itemAtTop2 = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_top"];
        } else {
            item = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_bot"];
            itemAtTop = (PLVVodSubtitleItem *)[dic2 objectForKey:@"subtitleItem_top"];
            item2 = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_bot"];
            itemAtTop2 = (PLVVodSubtitleItem *)[dic objectForKey:@"subtitleItem_top"];
        }
    }
    
    self.viewModel.subtitleItem = item;
    self.viewModel.subtitleAtTopItem = itemAtTop;
    self.viewModel.subtitleItem2 = item2;
    self.viewModel.subtitleAtTopItem2 = itemAtTop2;
}

@end

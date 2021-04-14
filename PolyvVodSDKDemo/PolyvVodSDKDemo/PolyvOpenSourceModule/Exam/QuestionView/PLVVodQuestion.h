//
//  PLVVodQuestion.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/22.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVVodQuestion : NSObject

@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, assign) BOOL skippable;
@property (nonatomic, assign) BOOL isMultipleChoice; // 是否多选题
@property (nonatomic, assign) BOOL isFillBlankTopic;    //!< 是否填空题
@property (nonatomic, copy) NSString *illustration;

@end

//
//  PLVKnowledgeModel.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVKnowledgeModel.h"

@implementation PLVKnowledgeModel

- (instancetype)init {
    if (self = [super init]) {
        self.buttonName = @"知识点";
        self.fullScreenStyle = NO;
        self.knowledgeWorkTypes = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setButtonName:(NSString *)buttonName {
    if (buttonName.length > 3) {
        NSLog(@"知识清单按钮限制3个字符");
        buttonName = [buttonName substringWithRange:NSMakeRange(0, 3)];
    }
    _buttonName = buttonName;
}

@end


@implementation PLVKnowledgeWorkType

- (instancetype)init {
    if (self = [super init]) {
        self.name = @"知识点";
        self.knowledgeWorkKeys = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setName:(NSString *)name {
    if (name.length > 5) {
        NSLog(@"知识点一级分类限制5个字符");
        name = [name substringWithRange:NSMakeRange(0, 5)];
    }
    _name = name;
}

@end


@implementation PLVKnowledgeWorkKey

- (instancetype)init {
    if (self = [super init]) {
        self.knowledgePoints = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

@end


@implementation PLVKnowledgePoint

- (void)setName:(NSString *)name {
    if (name.length > 16) {
        NSLog(@"知识点描述限制16个字符");
        name = [name substringWithRange:NSMakeRange(0, 16)];
    }
    _name = name;
}

@end

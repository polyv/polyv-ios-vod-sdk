//
//  PLVKnowledgeListViewController.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVKnowledgeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 知识清单控制器
@interface PLVKnowledgeListViewController : UIViewController

@property (nonatomic, strong) PLVKnowledgeModel *knowledgeModel;

@property (nonatomic, assign, readonly) BOOL showing;

/// 选中知识点回调
@property (nonatomic, copy) void (^selectKnowledgePointBlock)(PLVKnowledgePoint *point);

/// 展示知识清单
- (void)showKnowledgeListView;

/// 隐藏知识清单
- (void)hideKnowledgeListView;

@end

NS_ASSUME_NONNULL_END

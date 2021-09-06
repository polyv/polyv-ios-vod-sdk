//
//  PLVKnowledgeCategoryTableViewCell.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVKnowledgeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 二级分类cell
@interface PLVKnowledgeCategoryTableViewCell : UITableViewCell

+ (PLVKnowledgeCategoryTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) PLVKnowledgeWorkKey *workKeyModel;
@property (nonatomic, assign) BOOL isSelectCell;

@end

NS_ASSUME_NONNULL_END

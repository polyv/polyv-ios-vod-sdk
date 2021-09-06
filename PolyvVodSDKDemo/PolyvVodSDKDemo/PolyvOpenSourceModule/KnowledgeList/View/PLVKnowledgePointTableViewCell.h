//
//  PLVKnowledgePointTableViewCell.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/8/9.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVKnowledgeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 知识点cell
@interface PLVKnowledgePointTableViewCell : UITableViewCell

+ (PLVKnowledgePointTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) PLVKnowledgePoint *pointModel;
@property (nonatomic, assign) BOOL isSelectCell;
@property (nonatomic, assign) BOOL isShowDesc;

@end

NS_ASSUME_NONNULL_END

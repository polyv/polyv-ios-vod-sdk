//
//  PLVEmptyPPTViewCell.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/6.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVEmptyPPTViewCell.h"
#import "PLVPPTFailView.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVEmptyPPTViewCell ()

@property (nonatomic, strong) PLVPPTFailView *failView;

@end

@implementation PLVEmptyPPTViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *view = [[UIView alloc] init];
        [self.contentView addSubview:view];
        [view plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.center.plv_equalTo(self.contentView);
            make.size.plv_equalTo(CGSizeMake(165, 208));
        }];
        
        [view addSubview:self.failView];
        [self.failView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.edges.plv_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (PLVPPTFailView *)failView {
    if (!_failView) {
        _failView = [[PLVPPTFailView alloc] init];
        [_failView setLabelTextColor:[UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0]];
        [_failView.button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failView;
}

#pragma mark - Action

- (void)buttonAction {
    if (self.didTapButtonHandler) {
        self.didTapButtonHandler();
    }
}

@end

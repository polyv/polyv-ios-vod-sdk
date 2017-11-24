//
//  PLVCourseCell.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/16.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseCell.h"
#import "PLVTeacher.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVCourseCell ()

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *teacherButton;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation PLVCourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCourse:(PLVCourse *)course {
	_course = course;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.priceLabel.text = [NSString stringWithFormat:@"￥%1f", course.price];
		if (course.price == 0.0) {
			self.priceLabel.text = @"免费";
		}
		self.studentCountLabel.text = [NSString stringWithFormat:@"%zd人在学", course.studentCount];
		self.titleLabel.text = course.title;
		[self.teacherButton setTitle:course.teacher.name forState:UIControlStateNormal];
		[self.coverImageView yy_setImageWithURL:[NSURL URLWithString:course.coverUrl] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
	});
}

@end

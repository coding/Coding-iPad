//
//  COActivityCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/27.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProjectActivity.h"
#import "COAttributedLabel.h"

@interface COActivityFormater : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *date;

@end

@interface COActivityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet COAttributedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet COAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UIView *dot;
@property (weak, nonatomic) IBOutlet UIView *lineUp;
@property (weak, nonatomic) IBOutlet UIView *lineDown;
@property (weak, nonatomic) IBOutlet UIView *lineBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightLayout;
@property (copy, nonatomic) void(^avatarAction)(COUser *user);
@property (copy, nonatomic) void(^linkAction)(id obj);

- (void)assignWithActivity:(COProjectActivity *)activity;

@end

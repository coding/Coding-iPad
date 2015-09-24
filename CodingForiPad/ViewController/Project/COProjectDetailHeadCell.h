//
//  COProjectDetailHCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"

@interface COProjectDetailHeadCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

+ (CGFloat)cellHeight;

+ (COProjectDetailHeadCell *)cellWithTableView:(UITableView *)tableView;

- (void)assgnWithProject:(COProject *)project;

@end

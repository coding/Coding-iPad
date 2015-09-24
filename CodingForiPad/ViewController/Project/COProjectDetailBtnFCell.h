//
//  COProjectDetailBtnFCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CORedDotView.h"
#import "COProject.h"

@interface COProjectDetailBtnFCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CORedDotView *countView;

+ (CGFloat)cellHeight;

+ (COProjectDetailBtnFCell *)cellWithTableView:(UITableView *)tableView;

- (void)assignWithProject:(COProject *)project;

@end

//
//  COProjectDetailBtnCell.h
//  CodingForiPad
//
//  Created by zwm on 15/6/27.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CORedDotView.h"
#import "COProject.h"

@interface COProjectDetailBtnCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CORedDotView *countView;

+ (CGFloat)cellHeight;

+ (COProjectDetailBtnCell *)cellWithTableView:(UITableView *)tableView;

- (void)assignWithProject:(COProject *)project;

@end

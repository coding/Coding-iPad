//
//  COProjectDetailBtnCell.m
//  CodingForiPad
//
//  Created by zwm on 15/6/27.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDetailBtnCell.h"
#import <FBKVOController.h>

@implementation COProjectDetailBtnCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (COProjectDetailBtnCell *)cellWithTableView:(UITableView *)tableView
{
    COProjectDetailBtnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectDetailBtnCell"];
    
    return cell;
}

+ (CGFloat)cellHeight
{
    return 115;
}

- (void)assignWithProject:(COProject *)project
{
    [self.KVOController unobserveAll];
    
    [self.KVOController observe:project keyPath:@"unReadActivitiesCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, COProject *object, NSDictionary *change) {
        [self.countView updateCount:object.unReadActivitiesCount];
    }];
}

@end

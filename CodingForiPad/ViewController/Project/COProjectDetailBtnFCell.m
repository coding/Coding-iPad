//
//  COProjectDetailBtnFCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDetailBtnFCell.h"
#import <FBKVOController.h>

@implementation COProjectDetailBtnFCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (COProjectDetailBtnFCell *)cellWithTableView:(UITableView *)tableView
{
    COProjectDetailBtnFCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectDetailBtnFCell"];
    
    return cell;
}

+ (CGFloat)cellHeight
{
    return 170;
}

- (void)assignWithProject:(COProject *)project
{
    [self.KVOController unobserveAll];
    
    [self.KVOController observe:project keyPath:@"unReadActivitiesCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, COProject *object, NSDictionary *change) {
        [self.countView updateCount:object.unReadActivitiesCount];
    }];
}

@end

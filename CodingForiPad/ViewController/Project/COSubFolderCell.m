//
//  COSubFolderCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSubFolderCell.h"
#import "COUtility.h"

@implementation COSubFolderCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithFoler:(COFolder *)folder
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@（%ld）", folder.name, (unsigned long)[folder.subFolders count]];
    NSString *time = [COUtility timestampToBefore:folder.createdAt];
    self.descLabel.text = [NSString stringWithFormat:@"%@创建于%@", folder.ownerName, time];
}

@end

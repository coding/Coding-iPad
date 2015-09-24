//
//  COFolderCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFolderCell.h"

@implementation COFolderCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithFoler:(COFolder *)folder count:(NSInteger)count
{
   self.nameLabel.text = [NSString stringWithFormat:@"%@（%ld）", folder.name, (long)count];
}

@end

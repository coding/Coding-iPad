//
//  COTaskManagerCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskManagerCell.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"

@implementation COTaskManagerCell

- (void)awakeFromNib {
    // Initialization code
    _avatar.layer.cornerRadius = 15;
    _avatar.layer.masksToBounds = TRUE;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithMember:(COProjectMember *)member
{
    self.nameLabel.text = member.user.name;
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:member.user.avatar] placeholderImage:[COUtility placeHolder]];
}

@end

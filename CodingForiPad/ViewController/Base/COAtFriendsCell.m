//
//  COAtFriendsCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAtFriendsCell.h"
#import "COUser.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"
#import "COProject.h"

@implementation COAtFriendsCell

- (void)awakeFromNib {
    // Initialization code
    _icon.layer.cornerRadius = 15;
    _icon.layer.masksToBounds = TRUE;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithUser:(COUser *)user
{
    [_icon sd_setImageWithURL:[COUtility urlForImage:user.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = user.name;
}

- (void)assignWithMember:(COProjectMember *)member
{
    [_icon sd_setImageWithURL:[COUtility urlForImage:member.user.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = member.user.name;
}

@end

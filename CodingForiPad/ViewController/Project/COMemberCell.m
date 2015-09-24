//
//  COMemberCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMemberCell.h"
#import "COSession.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"

@implementation COMemberCell

- (void)awakeFromNib {
    // Initialization code
    self.avatar.layer.cornerRadius = 25.0;
    self.avatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithMember:(COProjectMember *)member
{
    self.nameLabel.text = member.user.name;
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:member.user.avatar] placeholderImage:[COUtility placeHolder]];

    if ([COSession session].user.userId == member.userId) {
        // 一键退出
        [self.actioBtn setTitle:@" 退出" forState:UIControlStateNormal];
        [self.actioBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.actioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.actioBtn setImage:[UIImage imageNamed:@"icon_line"] forState:UIControlStateNormal];
        [self.actioBtn setBackgroundImage:[UIImage imageNamed:@"button_small_red"] forState:UIControlStateNormal];
        if (member.type == 100) {
            self.actioBtn.hidden = YES;
        }
        else {
            self.actioBtn.hidden = NO;
        }
    }
    else {
        self.actioBtn.hidden = NO;
        [self.actioBtn setTitle:@" 私信" forState:UIControlStateNormal];
        [self.actioBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.actioBtn setTitleColor:[UIColor colorWithRGB:@"153,153,153"] forState:UIControlStateNormal];
        [self.actioBtn setImage:[UIImage imageNamed:@"icon_private"] forState:UIControlStateNormal];
        [self.actioBtn setBackgroundImage:[UIImage imageNamed:@"button_hollow_gray"] forState:UIControlStateNormal];
    }
    
    // owner
    if (member.type == 100) {
        self.ownerIcon.hidden = NO;
    }
    else {
        self.ownerIcon.hidden = YES;
    }
}

@end

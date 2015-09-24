//
//  COAddFriendsCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddFriendsCell.h"
#import "COUser.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "NSString+Common.h"
#import "COSession.h"

@implementation COAddFriendsCell

- (void)awakeFromNib {
    // Initialization code
    _avatarView.layer.cornerRadius = 15.0;
    _avatarView.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(COUser *)user isQuerying:(BOOL)isQuerying
{
    self.curUser = user;
    [_avatarView sd_setImageWithURL:[COUtility urlForImage:_curUser.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = _curUser.name;
    
    if ((user.userId == [COSession session].user.userId)
        || [user.globalKey isEqualToString:[COSession session].user.globalKey]) {
        _addBtn.hidden = YES;
        [_activityView stopAnimating];
    } else {
        _addBtn.hidden = NO;
    
        NSString *imageName = @"btn_followed_not";
        if (user.followed) {
            if (user.follow) {
                imageName = @"btn_followed_both";
            } else {
                imageName = @"btn_followed_yes";
            }
        }
        [_addBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        if (isQuerying) {
            [_activityView startAnimating];
        } else {
            [_activityView stopAnimating];
        }
    }
}

- (IBAction)rightBtnAction:(UIButton *)sender
{
    if (_btnBlock) {
        _btnBlock(_curUser);
    }
}

@end

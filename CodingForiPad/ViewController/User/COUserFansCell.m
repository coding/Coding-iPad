//
//  COUserFansCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserFansCell.h"
#import "COUser.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"

@implementation COUserFansCell

- (void)awakeFromNib {
    // Initialization code
    _icon.layer.cornerRadius = 25;
    _icon.layer.masksToBounds = TRUE;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(COUser *)curUser isQuerying:(BOOL)isQuerying
{
    self.curUser = curUser;
    
    [_icon sd_setImageWithURL:[COUtility urlForImage:_curUser.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = _curUser.name;
    
    _watchBtn.hidden = TRUE;
    if (_curUser.followed) {
        if (_curUser.follow) {
            // both
            [_watchBtn setImage:[UIImage imageNamed:@"icon_followed_copy"] forState:UIControlStateNormal];
        } else {
            [_watchBtn setImage:[UIImage imageNamed:@"icon_model_selected_gray"] forState:UIControlStateNormal];
        }
        _watchBtn.hidden = FALSE;
    }
    _unWatchBtn.hidden = !_watchBtn.hidden;
    
    if (isQuerying) {
        [_activityView startAnimating];
    } else {
        [_activityView stopAnimating];
    }
}

- (IBAction)rightBtnAction:(UIButton *)sender
{
    if (_btnBlock) {
        _btnBlock(_curUser);
    }
}

- (IBAction)avatarAction:(id)sender
{
    if (_avatarBlock) {
        _avatarBlock(_curUser);
    }
}

@end

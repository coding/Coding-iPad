//
//  COMemberAddCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMemberAddCell.h"
#import "COUser.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "NSString+Common.h"

@implementation COMemberAddCell

- (void)awakeFromNib {
    // Initialization code
    _avatarView.layer.cornerRadius = 15.0;
    _avatarView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(COUser *)user isInProject:(BOOL)isInProject isQuerying:(BOOL)isQuerying
{
    self.curUser = user;
    [_avatarView sd_setImageWithURL:[COUtility urlForImage:_curUser.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = _curUser.name;

    _addBtn.enabled = isInProject ? FALSE : TRUE;
    
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

@end

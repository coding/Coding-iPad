//
//  COAddLocationCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddLocationCell.h"

@implementation COAddLocationCell

- (void)awakeFromNib {
    // Initialization code
    _selectedView.hidden = TRUE;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCur:(BOOL)selected
{
    if (selected) {
        _titleLabel.textColor = [UIColor colorWithRed:59/255.0 green:190/255.0 blue:121/255.0 alpha:1.0];
        _selectedView.hidden = FALSE;
    } else {
        _titleLabel.textColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
        _selectedView.hidden = TRUE;
    }
}
@end

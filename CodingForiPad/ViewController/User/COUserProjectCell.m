//
//  COUserProjectCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserProjectCell.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"

@implementation COUserProjectCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithProject:(COProject *)project
{
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:project.icon resizeToView:_avatar] placeholderImage:[COUtility placeHolder]];
    self.nameLabel.text = project.name;
    self.descLabel.text = project.desc;
    self.markLabel.text = [NSString stringWithFormat:@"%ld", (long)project.watchCount];
    self.starLabel.text = [NSString stringWithFormat:@"%ld", (long)project.starCount];
    self.forkLabel.text = [NSString stringWithFormat:@"%ld", (long)project.forkCount];
}

@end

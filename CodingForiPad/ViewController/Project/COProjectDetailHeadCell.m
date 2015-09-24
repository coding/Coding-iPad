//
//  COProjectDetailHCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDetailHeadCell.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COSession.h"

@implementation COProjectDetailHeadCell

- (void)awakeFromNib {
    // Initialization code
    _icon.layer.cornerRadius = 2;
    _icon.layer.masksToBounds = TRUE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (COProjectDetailHeadCell *)cellWithTableView:(UITableView *)tableView
{
    COProjectDetailHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectDetailHeadCell"];
    
    return cell;
}

+ (CGFloat)cellHeight
{
    return 90;
}

- (void)assgnWithProject:(COProject *)project
{
    [self.icon sd_setImageWithURL:[COUtility urlForImage:project.icon] placeholderImage:[COUtility placeHolder]];
    
    self.pathLabel.text = [NSString stringWithFormat:@"%@/%@", project.ownerUserName, project.name];
    
    self.descLabel.text = project.desc;
    
    if ([COSession session].user.userId == project.ownerId) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end

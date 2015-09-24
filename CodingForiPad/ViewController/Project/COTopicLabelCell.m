//
//  COTopicLabelCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicLabelCell.h"

@implementation COTopicLabelCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

+ (CGFloat)cellHeight
{
    return 54;
}

@end

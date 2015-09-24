//
//  COTopicLabelCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "SWTableViewCell.h"

@interface COTopicLabelCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

+ (CGFloat)cellHeight;

@end

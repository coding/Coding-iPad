//
//  COTopicCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COTopic.h"

@class COTagLabel;
@interface COTopicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet COTagLabel *tag1Label;
@property (weak, nonatomic) IBOutlet COTagLabel *tag2Label;
@property (weak, nonatomic) IBOutlet COTagLabel *tag3Label;
@property (weak, nonatomic) IBOutlet COTagLabel *tag4Label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayout;

- (void)assignWithTopic:(COTopic *)topic;

@end

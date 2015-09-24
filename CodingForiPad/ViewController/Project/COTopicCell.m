//
//  COTopicCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicCell.h"
#import "COTagLabel.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"

@implementation COTopicCell

- (void)awakeFromNib {
    // Initialization code
    _icon.layer.cornerRadius = 15;
    _icon.clipsToBounds = TRUE;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithTopic:(COTopic *)topic
{
    [self.icon sd_setImageWithURL:[COUtility urlForImage:topic.owner.avatar] placeholderImage:[COUtility placeHolder]];
    self.titleLabel.text = topic.title;
    self.ownerLabel.text = topic.owner.name;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld条讨论", (long)topic.childCount];
    self.dateLabel.text = [COUtility timestampToBefore:topic.createdAt];
    
    [self.tag1Label setLabels:topic.labels.count > 0 ? ((COTopicLabel *)topic.labels[0]) : nil];
    [self.tag2Label setLabels:topic.labels.count > 1 ? ((COTopicLabel *)topic.labels[1]) : nil];
    [self.tag3Label setLabels:topic.labels.count > 2 ? ((COTopicLabel *)topic.labels[2]) : nil];
    COTopicLabel *labelInfo = nil;
    if (topic.labels.count > 3) {
        labelInfo = [[COTopicLabel alloc] init];
        labelInfo.name = @"...";
        labelInfo.color = @"#ffffff";
    }
    [self.tag4Label setLabels:labelInfo];
    
    if (topic.labels.count > 0) {
        _widthLayout.constant = 290;
    } else {
        _widthLayout.constant = 540;
    }
    [self.titleLabel layoutIfNeeded];
    [self.tag1Label layoutIfNeeded];
    [self.tag2Label layoutIfNeeded];
    [self.tag3Label layoutIfNeeded];
    [self.tag4Label layoutIfNeeded];
    if (topic.labels.count > 3) {
        NSLog(@"%f, %f, %f, %f", CGRectGetMaxX(self.tag1Label.frame), CGRectGetMaxX(self.tag2Label.frame), CGRectGetMaxX(self.tag3Label.frame), CGRectGetMaxX(self.tag4Label.frame));
    }
    if (CGRectGetMaxX(self.tag1Label.frame) > 530) {
        [self.tag1Label setLabels:labelInfo];
        self.tag2Label.hidden = TRUE;
        self.tag3Label.hidden = TRUE;
        self.tag4Label.hidden = TRUE;
    } else if (CGRectGetMaxX(self.tag2Label.frame) > 530) {
        [self.tag2Label setLabels:labelInfo];
        self.tag3Label.hidden = TRUE;
        self.tag4Label.hidden = TRUE;
    } else if (CGRectGetMaxX(self.tag3Label.frame) > 530) {
        [self.tag3Label setLabels:labelInfo];
        self.tag4Label.hidden = TRUE;
    } else if (topic.labels.count > 3 && CGRectGetMaxX(self.tag4Label.frame) > 530) {
        [self.tag3Label setLabels:labelInfo];
        self.tag4Label.hidden = TRUE;
    }
}

@end

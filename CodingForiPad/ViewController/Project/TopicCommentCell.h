//
//  TopicCommentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TopicComment @"TopicCommentCell"
#define kCellIdentifier_TopicComment_Media @"TopicCommentCell_Media"

#import <UIKit/UIKit.h>
#import "COAttributedLabel.h"
#import "COTopic.h"

@interface TopicCommentCell : UITableViewCell

@property (strong, nonatomic) COTopic *toComment;
@property (strong, nonatomic) COAttributedLabel *contentLabel;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end

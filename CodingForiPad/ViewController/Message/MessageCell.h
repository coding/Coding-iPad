//
//  MessageCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Message @"MessageCell"
#define kCellIdentifier_MessageMedia @"MessageMediaCell"

#import <UIKit/UIKit.h>
#import "UILongPressMenuImageView.h"
#import "COConversation.h"
#import "COAttributedLabel.h"

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) UILongPressMenuImageView *bgImgView;
@property (strong, nonatomic) COAttributedLabel *contentLabel;

- (void)setCurPriMsg:(COConversation *)curPriMsg andPrePriMsg:(COConversation *)prePriMsg;

@property (copy, nonatomic) void(^tapUserIconBlock)(COUser *sender);
@property (copy, nonatomic) void (^refreshMessageMediaCCellBlock)(CGFloat diff);
@property (copy, nonatomic) void (^resendMessageBlock)(COConversation *curPriMsg);

+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj;

@end

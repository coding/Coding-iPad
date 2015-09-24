//
//  CONotificationCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COConversation.h"
#import "COAttributedLabel.h"
#import "SWTableViewCell.h"

@interface CONotificationCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet COAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *dotView;

@property (copy, nonatomic) void(^linkClickedBlock)(HtmlMediaItem *item, CONotification *tip);

- (void)assignWithNotification:(CONotification *)notificaton;

+ (CGFloat)calcHeight:(CONotification *)notification;

@end

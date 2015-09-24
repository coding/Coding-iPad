//
//  CONotificationCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CONotificationCell.h"
#import "COHtmlMedia.h"
#import <FBKVOController.h>

@interface CONotificationCell () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) CONotification *notification;

@end

@implementation CONotificationCell

- (void)awakeFromNib {
    // Initialization code
    _contentLabel.numberOfLines = 0;
    _contentLabel.delegate = self;
    [_contentLabel configForTweetComment];
    self.dotView.layer.cornerRadius = 4.0;
    self.dotView.clipsToBounds = YES;
    self.dotView.hidden = YES;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)assignWithNotification:(CONotification *)notificaton
{
    self.notification = notificaton;
    
    if ([notificaton.targetType isEqualToString:@"UserFollow"]) {
        // 关注
        self.iconView.image = [UIImage imageNamed:@"icon_message_leftview_follow"];
    }
    else if ([notificaton.targetType isEqualToString:@"PullRequestBean"]) {
        // pullrequest
        self.iconView.image = [UIImage imageNamed:@"icon_message_leftview_follow"];
    }
    else if ([notificaton.targetType isEqualToString:@"TaskComment"]) {
        // 评论
        self.iconView.image = [UIImage imageNamed:@"icon_message_leftview_mentioned"];
    }
    else if ([notificaton.targetType isEqualToString:@"ProjectMember"]) {
        // 添加成员
        self.iconView.image = [UIImage imageNamed:@"icon_message_leftview_task"];
    }
    else {
        NSLog(@"--> %@", notificaton.targetType);
        self.iconView.image = [UIImage imageNamed:@"icon_message_leftview_task"];
    }
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:notificaton.content showType:MediaShowTypeNone];
    self.contentLabel.text = htmlMedia.contentDisplay;
    
    for (HtmlMediaItem *item in htmlMedia.mediaItems) {
        if (item.displayStr.length > 0
            && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    [self observeUnReadCount:notificaton];
}

- (void)observeUnReadCount:(CONotification *)notification
{
    [self.KVOController unobserveAll];
    
    [self.KVOController observe:notification keyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, CONotification *object, NSDictionary *change) {
        self.dotView.hidden = ([object.status integerValue] == 1);
    }];
}

+ (CGFloat)calcHeight:(CONotification *)notification
{
    static COAttributedLabel *label = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        label = [COAttributedLabel labelForTweetComment];
        label.numberOfLines = 0;
    });
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:notification.content showType:MediaShowTypeNone];
    label.text = htmlMedia.contentDisplay;
    CGSize size = [label sizeThatFits:CGSizeMake(270.0, 30.0)];
    return size.height + 40.0;
}

#pragma mark TTTAttributedLabelDelegate M
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *item = [components objectForKey:@"value"];
    if (item && self.linkClickedBlock) {
        self.linkClickedBlock(item, _notification);
    }
}

@end

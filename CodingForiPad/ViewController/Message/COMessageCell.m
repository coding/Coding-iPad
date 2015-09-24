//
//  COMessageCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMessageCell.h"
#import "UIImageView+WebCache.h"
#import "COHtmlMedia.h"
#import "COUtility.h"
#import <FBKVOController.h>

@implementation COMessageCell

- (void)awakeFromNib
{
    self.avatar.layer.cornerRadius = 25.0;
    self.avatar.layer.masksToBounds = YES;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)assignWithConversation:(COConversation *)conversation
{
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:conversation.friendUser.avatar] placeholderImage:[COUtility placeHolder]];
    
    self.nameLabel.text = conversation.friendUser.name;
    self.timeLabel.text = [COUtility timestampToBefore:conversation.createdAt];
    
    if (conversation.type == 1) {
        self.msgLabel.text = @"[语音]";
    }
    else {
        NSMutableString *textMsg = [[NSMutableString alloc] initWithString:conversation.content];
        if (conversation.hasMedia) {
            [textMsg appendString:@"[图片]"];
        }
        self.msgLabel.text = textMsg;
    }
    
    // tips
    [self observeUnReadCount:conversation];
}

- (void)observeUnReadCount:(COConversation *)conversation
{
    [self.KVOController unobserveAll];
    
    [self.KVOController observe:conversation keyPath:@"unreadCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, COConversation *object, NSDictionary *change) {
        [self.countView updateCount:object.unreadCount];
    }];
}

@end

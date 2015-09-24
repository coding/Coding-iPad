//
//  COHtmlContentView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/11.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COHtmlContentView.h"

@interface COHtmlContentView()<TTTAttributedLabelDelegate>


@end

@implementation COHtmlContentView

- (instancetype)initForTweetContent
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.contentLabel = [COAttributedLabel labelForTweetContent];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (instancetype)initForTweetComment;
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.contentLabel = [COAttributedLabel labelForTweetComment];
        self.contentLabel.delegate = self;
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    self.contentLabel = [[COAttributedLabel alloc] initWithFrame:self.bounds];
    self.contentLabel.delegate = self;
    self.contentLabel.inactiveLinkAttributes = kLinkAttributes;
    [self addSubview:_contentLabel];
}

- (void)addLinkBlock:(COItemLinkBlock)block
{
    self.itemLinkBlock = block;
//    [self.contentLabel addTapBlock:block];
}

- (void)setHtmlContent:(NSString *)html
{
    self.htmlMedia = [HtmlMedia htmlMediaWithString:html showType:MediaShowTypeNone];
    self.contentLabel.text = self.htmlMedia.contentDisplay;
    
    for (HtmlMediaItem *item in _htmlMedia.mediaItems) {
        if (item.displayStr.length > 0
            && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentLabel.frame = self.bounds;
}

- (void)configForTweetContent
{
    
}

- (void)configForTweetComment
{
    
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    if (_itemLinkBlock) {
        _itemLinkBlock([components objectForKey:@"value"]);
    }
}

@end

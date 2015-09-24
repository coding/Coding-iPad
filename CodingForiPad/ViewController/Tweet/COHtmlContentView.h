//
//  COHtmlContentView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/11.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COHtmlMedia.h"
#import "COAttributedLabel.h"

typedef void(^COItemLinkBlock)(id obj);

@interface COHtmlContentView : UIView

@property (nonatomic, strong) HtmlMedia *htmlMedia;
@property (nonatomic, strong) COAttributedLabel *contentLabel;
@property (nonatomic, copy) COItemLinkBlock itemLinkBlock;

- (void)addLinkBlock:(COItemLinkBlock)block;
- (void)setHtmlContent:(NSString *)html;

- (instancetype)initForTweetContent;
- (instancetype)initForTweetComment;

- (void)configForTweetContent;
- (void)configForTweetComment;

@end

//
//  COTweetCommentListView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/18.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetCommentListView.h"
#import "UIColor+Hex.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"
#import "COTweetViewController.h"

#define CODefaultCommentCount 5

@interface COTweetCommentFootView : UIView

@property (nonatomic, strong) UILabel *footTitleLabel;
@property (nonatomic, strong) UIButton *footBtn;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) COTweet *tweet;

@end

@implementation COTweetCommentFootView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
//        self.bgView.backgroundColor = [UIColor colorWithRGB:@"246,246,246"];
//        [self addSubview:_bgView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithRGB:@"221, 221, 221"];
        [self addSubview:_lineView];
        
        _footBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_footBtn addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_footBtn];
        
        _footTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _footTitleLabel.textColor = [UIColor colorWithRGB:@"34, 34, 34"];
//        _footTitleLabel.text = @"查看全部评论";
        _footTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _footTitleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_footTitleLabel];
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icom_more_comment"]];
        [self addSubview:_iconView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.lineView.frame = CGRectMake(0.0, 0.0, width, 0.5);
    
    _bgView.frame = CGRectMake(0.0, 10.0, width, height - 10.0 * 2);
    
    _footBtn.frame = self.bounds;
    [_footTitleLabel sizeToFit];
    CGRect frame = _footTitleLabel.frame;
    frame.size.width += 40.0;
    frame.origin.x = (width - frame.size.width ) / 2.0;
    frame.origin.y = 2;
    frame.size.height = height - 2;
    _footTitleLabel.frame = frame;
    
    CGRect iconFrame = _iconView.frame;
    iconFrame.origin.x = frame.origin.x - iconFrame.size.width;
    iconFrame.origin.y = (height - iconFrame.size.height ) / 2.0 + 2;
    
    _iconView.frame = iconFrame;
}

- (IBAction)showDetail:(id)sender
{
    if (self.tweet) {
        [[NSNotificationCenter defaultCenter] postNotificationName:COTweetDetailNotification object:self.tweet];
    }
}

@end


@implementation COTweetCommentCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.lineView.frame = CGRectMake(0.0, 0.5, width, 0.5);
    self.avatar.frame = CGRectMake(15.0, 16.0, 30.0, 30.0);
    self.infoLabel.frame = CGRectMake(65.0, height - 15.0 - 9.0, width - 50.0 - 20.0, 15.0);
    self.commentView.frame = CGRectMake(65.0, 16.0, width - 65.0 - 20.0, height - 16.0 - 9.0 * 2 - 14.0);
}

- (void)initSubviews
{
    self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 10.0, 30.0, 30.0)];
    self.avatar.layer.cornerRadius = 15.0;
    self.avatar.layer.masksToBounds = YES;
    [self addSubview:_avatar];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.lineView.backgroundColor = [UIColor colorWithRGB:@"221,221,221"];
    [self addSubview:_lineView];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.infoLabel.textColor = [UIColor colorWithRGB:@"153,153,153"];
    self.infoLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_infoLabel];
    
    self.commentView = [[COHtmlContentView alloc] initForTweetComment];
    [self addSubview:_commentView];
    
    //self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)hiddenLine:(BOOL)hidden
{
    self.lineView.hidden = hidden;
}

- (void)assignWithComment:(COTweetComment *)comment
{
    if (_avatar == nil) {
        [self initSubviews];
    }
    
    // TODO: 处理头像
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:comment.owner.avatar] placeholderImage:[COUtility placeHolder]];
    
    [_commentView setHtmlContent:comment.content];
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@ 发布于%@", comment.owner.name, [COUtility timestampToBefore:comment.createdAt]];
}

+ (CGFloat)calcHeight:(COTweetComment *)comment width:(CGFloat)width
{
    if (comment.contentHeight > 0.0) {
        return comment.contentHeight;
    }
    
    static COAttributedLabel *label = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        label = [COAttributedLabel labelForTweetComment];
        label.numberOfLines = 0;
    });
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:comment.content showType:MediaShowTypeNone];
    label.text = htmlMedia.contentDisplay;
    CGSize size = [label sizeThatFits:CGSizeMake(width - 85.0 - 79.0, 12.0)];
    comment.contentHeight = size.height + 50.0;
    return comment.contentHeight;
}

@end

@interface COTweetCommentListView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) COTweet *tweet;
@property (nonatomic, strong) COTweetCommentFootView *footView;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIView *likeLine;
@property (nonatomic, copy) COItemLinkBlock linkBlock;
@property (nonatomic, copy) COcommentDeleteBlock deleteBlock;

@end

@implementation COTweetCommentListView

- (void)addLinkBlock:(COItemLinkBlock)block
{
    self.linkBlock = block;
}

- (void)addDeleteBlock:(COcommentDeleteBlock)block
{
    self.deleteBlock = block;
}

- (void)awakeFromNib
{
    self.bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bgView.image = [UIImage imageNamed:@"tweet_comment_bg"];
    [self addSubview:_bgView];
    
    self.likeView = [[COTweetLikeView alloc] initWithFrame:CGRectZero];
    [self addSubview:_likeView];
    
    self.listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.scrollEnabled = NO;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_listView registerClass:[COTweetCommentCell class] forCellReuseIdentifier:@"COTweetCommentCell"];
    [self addSubview:_listView];
    
    self.footView = [[COTweetCommentFootView  alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 40.0)];
    self.likeLine =[[UIView alloc] initWithFrame:CGRectZero];
    _likeLine.backgroundColor = [UIColor colorWithRGB:@"221, 221, 221"];
    [self addSubview:_likeLine];
}

- (void)prepareForReuse
{
    [self.likeView prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.bgView.frame = CGRectMake(0, -10, width, height - 2);
    
    CGFloat offset = 0;
    if (_tweet.likes == 0) {
        self.likeView.frame = CGRectZero;
    }
    else {
        self.likeView.frame = CGRectMake(0.0, 0.0, width, 40.0);
        offset = 40.0;
    }
    
    self.likeLine.frame = CGRectMake(0.0, 40.0, width, 0.5);
    
    if (_tweet.comments == 0) {
        self.listView.frame = CGRectZero;
    }
    else {
        self.listView.frame = CGRectMake(0.0, offset, width, height - offset);
    }
}

- (void)assignWithTweet:(COTweet *)tweet
{
    self.tweet = tweet;
    if (tweet.likes > 0) {
        [self.likeView assignWithUsers:tweet.likeUsers];
        if (tweet.comments > 0) {
            self.likeLine.hidden = NO;
        }
        else {
            self.likeLine.hidden = YES;
        }
    }
    else {
        self.likeLine.hidden = YES;
    }
    
    if (tweet.comments > 0) {
        if (tweet.comments > 5) {
            self.footView.tweet = tweet;
            self.footView.footTitleLabel.text = [NSString stringWithFormat:@"查看全部 %ld 条评论", (long)tweet.comments];
            self.listView.tableFooterView = self.footView;
        }
        else {
            self.footView.tweet = nil;
            self.listView.tableFooterView = nil;
        }
        [self.listView reloadData];
    }
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweet.commentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTweetCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTweetCommentCell"];
    if (indexPath.row < self.tweet.commentList.count) {
        COTweetComment *comment = self.tweet.commentList[indexPath.row];
        [cell assignWithComment:comment];
        
        if (self.linkBlock) {
            [cell.commentView addLinkBlock:self.linkBlock];
        }
        
        if (indexPath.row == 0) {
            [cell hiddenLine:YES];
        }
        else {
            [cell hiddenLine:NO];
        }
    }
    else {
        NSLog(@"error");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTweetComment *comment = self.tweet.commentList[indexPath.row];
    return [COTweetCommentCell calcHeight:comment width:self.targetWith];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // @某人评论或删除自己评论
    COTweetComment *comment = self.tweet.commentList[indexPath.row];
    if (_deleteBlock) {
        _deleteBlock(comment);
    }
}

#pragma mark -
+ (CGFloat)heightForTweet:(COTweet *)tweet width:(CGFloat)width
{
    // TODO: 计算高度
    CGFloat height = 0.0;
    if (tweet.likes > 0) {
        height += 40.0;
    }
    
    NSInteger count = tweet.commentList.count;
    if (tweet.comments > count) {
        CGFloat footViewHeight = 40.0;
        height += footViewHeight;
    }
    
    for (COTweetComment *cmt in tweet.commentList) {
        height += [COTweetCommentCell calcHeight:cmt width:width];
    }
    
    return height - 2;
}

@end

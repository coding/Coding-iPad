//
//  TopicContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TopicContentCell.h"
#import "WebContentManager.h"
#import "COTopic+Ext.h"
#import "ProjectTopicLabelView.h"
#import "Masonry.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Common.h"
#import "NSString+Common.h"
#import "COTaskRequest.h"
#import "UIColor+Hex.h"

#define kTopicContentCell_FontTitle [UIFont boldSystemFontOfSize:14]

#define kTopicContentCell_ColorTitle [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]
#define kTopicContentCell_ColorContent [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]

#define kCell_Width 573
#define kPaddingLeftWidth 20

@implementation UIView (Common)

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end

@interface TopicContentCell () <UIWebViewDelegate>

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UILabel *commentCountLabel;
@property (strong, nonatomic) UIImageView *commentView;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) ProjectTopicLabelView *labelView;
@property (strong, nonatomic) UIButton *labelAddBtn;

@property (strong, nonatomic) COTopic *curTopic;

@end

@implementation TopicContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat curWidth = kCell_Width - 2 * kPaddingLeftWidth;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 20, curWidth, 30)];
            _titleLabel.textColor = kTopicContentCell_ColorTitle;
            _titleLabel.font = kTopicContentCell_FontTitle;
            [self.contentView addSubview:_titleLabel];
        }
        
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 30, 30)];
            _userIconView.layer.cornerRadius = 15;
            _userIconView.layer.masksToBounds = TRUE;
            [self.contentView addSubview:_userIconView];
        }
        
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 30 + 20, 0, curWidth - 30 - 20, 30)];
            _timeLabel.textColor = kTopicContentCell_ColorContent;
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        
        if (!_labelAddBtn) {
            _labelAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(kCell_Width - 44 - 8, 0, 44, 44)];
            [_labelAddBtn setImage:[UIImage imageNamed:@"icon_add_tag"] forState:UIControlStateNormal];
            [_labelAddBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
            [_labelAddBtn addTarget:self action:@selector(addtitleBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_labelAddBtn];
        }

        if (!self.webContentView) {
            self.webContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 10)];
            self.webContentView.delegate = self;
            self.webContentView.scrollView.scrollEnabled = NO;
            self.webContentView.scrollView.scrollsToTop = NO;
            self.webContentView.scrollView.bounces = NO;
            self.webContentView.backgroundColor = [UIColor clearColor];
            self.webContentView.opaque = NO;
            [self.contentView addSubview:self.webContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [self.contentView addSubview:_activityIndicator];
            [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.contentView);
            }];
        }
        
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 50)];
            _commentCountLabel.textColor = kTopicContentCell_ColorTitle;
            _commentCountLabel.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:_commentCountLabel];
        }
        if (!_commentView) {
            _commentView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 9)];
            [_commentView setImage:[UIImage imageNamed:@"separatpr_comment"]];
            [self.contentView addSubview:_commentView];
        }
        
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kCell_Width - 68, 0, 68, 50);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.deleteBtn];
        }
    }
    return self;
}

- (void)deleteBtnClicked:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (_deleteTopicBlock) {
        _deleteTopicBlock(weakSelf.curTopic);
    }
}

- (void)setCurTopic:(COTopic *)curTopic md:(BOOL)isMD
{
    if (curTopic) {
        _curTopic = curTopic;
    }

    CGFloat curBottomY = 0;
    CGFloat curWidth = kCell_Width - 2*kPaddingLeftWidth;
    if (isMD) {
        [_titleLabel setLongString:_curTopic.mdTitle withFitWidth:curWidth];
    } else {
        [_titleLabel setLongString:_curTopic.title withFitWidth:curWidth];
    }
    curBottomY += CGRectGetMaxY(_titleLabel.frame) + 20;

    [_userIconView sd_setImageWithURL:[COUtility urlForImage:_curTopic.owner.avatar] placeholderImage:[COUtility placeHolder]];
    [_userIconView setY:curBottomY];
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@    发布于 %@", _curTopic.owner.name, [COUtility timestampToBefore:_curTopic.createdAt * 1000]];

    curBottomY += 30 + 9;
    
    if (_labelView) {
        [_labelView removeFromSuperview];
    }
    _labelView = [[ProjectTopicLabelView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth- 32, 22) projectTopic:_curTopic md:isMD];
    __weak typeof(self) weakSelf = self;
    _labelView.delLabelBlock = ^(NSInteger index) {
       [weakSelf deltitleBtnClick:index];
    };
    [self.contentView insertSubview:_labelView belowSubview:_labelAddBtn];
    
    [_labelAddBtn setY:curBottomY];
    [_labelView setY:curBottomY];
    [_labelView setHeight:_labelView.labelH];
    
    // 讨论的内容
    curBottomY += _labelView.labelH;
    [self.webContentView setY:curBottomY];
    [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
    [self.webContentView setHeight:_curTopic.contentHeight];
    
    if (!_webContentView.isLoading) {
        if (isMD) {
            [_activityIndicator startAnimating];
            COMDtoHtmlRequest *reqeust = [COMDtoHtmlRequest request];
            reqeust.mdStr = _curTopic.mdContent;
            __weak typeof(self) weakSelf = self;
            [reqeust postWithSuccess:^(CODataResponse *responseObject) {
                NSString *contentStr = [WebContentManager topicPatternedWithContent:responseObject.data];
                [weakSelf.webContentView loadHTMLString:contentStr baseURL:nil];
            } failure:^(NSError *error) {
                NSString *contentStr = [WebContentManager topicPatternedWithContent:error.description];
                [weakSelf.webContentView loadHTMLString:contentStr baseURL:nil];
            }];
        } else {
            if (!_curTopic.htmlMedia) {
                _curTopic.htmlMedia = [HtmlMedia htmlMediaWithString:_curTopic.content showType:MediaShowTypeNone];
                _curTopic.content = _curTopic.htmlMedia.contentDisplay;
            }

            if (_curTopic.htmlMedia.contentOrigional) {
                [self.webContentView loadHTMLString:[WebContentManager topicPatternedWithContent:_curTopic.htmlMedia.contentOrigional] baseURL:nil];
            }
        }
    }
    
    curBottomY += _curTopic.contentHeight;
    [_commentCountLabel setY:curBottomY];
    [_commentView setY:curBottomY + 50 - 9];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld条评论", (long)_curTopic.childCount];
    
    if ([_curTopic canEdit] && !isMD) {
        _deleteBtn.hidden = NO;
        [_deleteBtn setY:curBottomY];
    } else {
        _deleteBtn.hidden = YES;
    }
}


+ (CGFloat)cellHeightWithObj:(id)obj md:(BOOL)isMD
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[COTopic class]]) {
        COTopic *topic = (COTopic *)obj;
        CGFloat curWidth = kCell_Width - 2*kPaddingLeftWidth;
        cellHeight += 20 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 20 + 30 + 9;
        
        cellHeight += [ProjectTopicLabelView heightWithObj:topic md:isMD];
        cellHeight += topic.contentHeight;
        cellHeight += 50;
    }
    return cellHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    NSLog(@"strLink=[%@]", strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    } else {
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshwebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _curTopic.contentHeight) > 5) {
        webView.scalesPageToFit = YES;
        _curTopic.contentHeight = scrollHeight;
        if (_cellHeightChangedBlock) {
            _cellHeightChangedBlock();
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
    if([error code] == NSURLErrorCancelled) {
        return;
    } else {
        NSLog(@"%@", error.description);
    }
}

- (void)refreshwebContentView
{
    if (_webContentView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark - click
- (void)addtitleBtnClick
{
    if (_addLabelBlock) {
        _addLabelBlock();
    }
}

- (void)deltitleBtnClick:(NSInteger)index
{
    if (_delLabelBlock) {
        _delLabelBlock(index);
    }
}

@end

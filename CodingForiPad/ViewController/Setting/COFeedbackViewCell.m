//
//  COFeedbackViewCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFeedbackViewCell.h"
#import "WebContentManager.h"
#import "COTopic.h"
#import "Masonry.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Common.h"
#import "NSString+Common.h"
#import "COTaskRequest.h"

#define kTopicContentCell_FontTitle [UIFont boldSystemFontOfSize:14]

#define kTopicContentCell_ColorTitle [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]
#define kTopicContentCell_ColorContent [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]

#define kCell_Width kRightView_Width
#define kPaddingLeftWidth 20

@implementation UIView (Common)

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end

@interface COFeedbackViewCell () <UIWebViewDelegate>

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation COFeedbackViewCell

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
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = selectedColor;
    }
    return self;
}

- (void)setCurTopic:(COTopic *)curTopic
{
    if (curTopic) {
        _curTopic = curTopic;
    }
    
    CGFloat curBottomY = 0;
    CGFloat curWidth = kCell_Width - 2*kPaddingLeftWidth;

    [_titleLabel setLongString:_curTopic.mdTitle withFitWidth:curWidth];
    curBottomY += CGRectGetMaxY(_titleLabel.frame) + 20;
    
    [_userIconView sd_setImageWithURL:[COUtility urlForImage:_curTopic.owner.avatar] placeholderImage:[COUtility placeHolder]];
    [_userIconView setY:curBottomY];
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@    发布于 %@", _curTopic.owner.name, [COUtility timestampToBefore:_curTopic.createdAt]];
    
    curBottomY += 30 + 10;
    
    // 讨论的内容
    [self.webContentView setY:curBottomY];
    [self.activityIndicator setCenter:CGPointMake(self.webContentView.center.x, curBottomY + 10)];
    [self.webContentView setHeight:_curTopic.contentHeight];
    
    if (!_webContentView.isLoading) {
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
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[COTopic class]]) {
        COTopic *topic = (COTopic *)obj;
        CGFloat curWidth = kCell_Width - 2*kPaddingLeftWidth;
        cellHeight += 20 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 20 + 30 + 10;
        
        cellHeight += topic.contentHeight;
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
//        if (_loadRequestBlock) {
//            _loadRequestBlock(request);
//        }
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

@end

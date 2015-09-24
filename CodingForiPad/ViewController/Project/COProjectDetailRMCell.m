//
//  OPProjectDetailRMCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDetailRMCell.h"
#import "WebContentManager.h"
#import "COGitRequest.h"

@implementation COProjectDetailRMCell

- (void)awakeFromNib {
    // Initialization code
    self.webView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (COProjectDetailRMCell *)cellWithTableView:(UITableView *)tableView
{
    COProjectDetailRMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectDetailRMCell"];
    
    return cell;
}

+ (CGFloat)cellHeight
{
    return 40;//
}


- (void)showReadMe:(COGitTree *)tree
{
    [_activityIndicator startAnimating];
    NSString *html = [WebContentManager markdownPatternedWithContent:tree.readme.preview];
    [self.webView loadHTMLString:html baseURL:nil];
}

#pragma mark -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strLink = request.URL.absoluteString;
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    }else{
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshWebContentView];
    [_activityIndicator stopAnimating];
//    webView.scrollView.scrollEnabled = NO;
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(self.contentHeight - scrollHeight - 40.0) > 5) {
        self.contentHeight = scrollHeight + 40.0;
        CGRect frame = self.webView.frame;
        frame.size.height = scrollHeight;
        self.webView.frame = frame;
        if (self.heightChangeBlock) {
            self.heightChangeBlock(self.contentHeight);
        }
    }
    if (scrollHeight < 556.0) {
        self.webViewHegiht.constant = scrollHeight;
    }
    [self setNeedsUpdateConstraints];
}

- (void)refreshWebContentView{
    if (_webView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webView.frame)];
        [_webView stringByEvaluatingJavaScriptFromString:meta];
    }
}
@end

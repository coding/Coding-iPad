//
//  COCodeView.m
//  CodingForiPad
//
//  Created by sgl on 15/6/29.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCodeView.h"
#import "WebContentManager.h"
#import "COGitRequest.h"

@interface COCodeView ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation COCodeView

- (void)load
{
    if (self.webView == nil) {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [self addSubview:_webView];
        _webView.delegate = self;
    }
    
    self.contentHeight = 0.0;
    
    if ([_gitFile.mode isEqualToString:@"image"]) {
        NSString *url = [NSString stringWithFormat:@"https://coding.net/u/%@/p/%@/git/raw/%@/%@", self.project.ownerUserName, self.project.name, self.ref, _gitFile.path ];
        NSURL *imageUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:imageUrl]];
    }
    else {
        COGitTreeFileRequest *request = [COGitTreeFileRequest request];
        request.filePath = _gitFile.path;
        request.ref = self.ref;
        request.backendProjectPath = _project.backendProjectPath;
        
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if (responseObject.error == nil
                && responseObject.code == 0) {
                [weakself showBlob:responseObject.data];
            }
        } failure:^(NSError *error) {
            // TODO: show error.
        }];
    }
}

- (void)showBlob:(COGitBlob *)blob
{
    NSString *html = [WebContentManager codePatternedWithContent:blob.file];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

@end

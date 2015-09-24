//
//  COCodePreViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCodePreViewController.h"
#import "COGitRequest.h"
#import "WebContentManager.h"
#import "UIViewController+Link.h"

@interface COCodePreViewController ()
@property (nonatomic, strong) COGitBlob *blob;
@end

@implementation COCodePreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadFile];
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFile
{
    if ([_gitFile.mode isEqualToString:@"image"]) {
        NSString *url = [NSString stringWithFormat:@"https://coding.net/u/%@/p/%@/git/raw/%@/%@", self.project.ownerUserName, self.project.name, self.ref, _gitFile.path ];
        NSURL *imageUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:imageUrl]];
    }
    else {
        COGitTreeFileRequest *request = [COGitTreeFileRequest request];
        request.filePath = _gitFile.path;
        request.ref = self.ref;
        request.backendProjectPath = self.backendProjectPath;
        
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                [weakself showBlob:responseObject.data];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}

- (void)showBlob:(COGitBlob *)blob
{
    NSString *html = [WebContentManager codePatternedWithContent:blob.file];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strLink = request.URL.absoluteString;
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    }else{
        [self analyseLinkStr:request.URL.absoluteString];
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshWebContentView];
}

- (void)refreshWebContentView{
    if (_webView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webView.frame)];
        [_webView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark -
- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    
    [self analyseVCFromLinkStr:linkStr showBlock:^(UIViewController *controller, COLinkShowType showType, NSString *link) {
        if (showType == COLinkShowTypeWeb) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeRight) {
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypePush) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeUnSupport) {
            
        }
    }];
}

@end

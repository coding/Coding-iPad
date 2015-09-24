//
//  CORegServiceViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORegServiceViewController.h"

@interface CORegServiceViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CORegServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *pathForServiceterms = [[NSBundle mainBundle] pathForResource:@"service_terms" ofType:@"html"];
    
    NSString *html = [[NSString alloc] initWithContentsOfFile:pathForServiceterms encoding:NSUTF8StringEncoding error:nil];
    
    _webView.delegate = self;
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAction:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end

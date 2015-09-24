//
//  COAddTaskDescribeController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddTaskDescribeController.h"
#import "CORootViewController.h"
#import "COTask.h"
#import "EaseMarkdownTextView.h"
#import "COAtMembersController.h"
#import "UIViewController+Utility.h"
#import "COTaskRequest.h"
#import "WebContentManager.h"

@interface COAddTaskDescribeController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet EaseMarkdownTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation COAddTaskDescribeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView.delegate = self;
    _activityView.hidesWhenStopped = YES;
    [_segmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    
    _inputTextView.curProject = _task.project;
    [_inputTextView setPlaceholder:@"任务描述"];
    
    if (_task.hasDescription) {
        _inputTextView.text = _task.taskDescription.markdown;
        _segmentedControl.selectedSegmentIndex = 1;
        [self loadPreView];
    } else {
        _inputTextView.text = @"";
        _segmentedControl.selectedSegmentIndex = 0;
        [self loadEditView];
    }
    
    __weak typeof(self) weakSelf = self;
    _inputTextView.atBlock = ^() {
        COAtMembersController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAtMembersController"];
        popoverVC.type = 0;
        popoverVC.projectId = _task.projectId;
        popoverVC.selectUserBlock = ^(COUser *selectedUser) {
            [weakSelf atSomeUser:selectedUser andRange:weakSelf.inputTextView.selectedRange];
        };

        [weakSelf.navigationController pushViewController:popoverVC animated:YES];
    };
    
    _okBtn.enabled = FALSE;
}

- (void)atSomeUser:(COUser *)curUser andRange:(NSRange)range
{
    if (curUser) {
        NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
        [_inputTextView insertText:appendingStr];
        [_inputTextView becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inputTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGFloat height = [COUtility getKeyboardHeight:paramNotification andCurve:&animationCurve andDuration:&animationDuration];

    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, 64, kPopWidth, kScreen_Height - height - 64 + 20);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];

    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, (kScreen_Height - kPopHeight) / 2, kPopWidth, kPopHeight);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)segmentedChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        // 编辑
        [self loadEditView];
    } else {
        // 预览
        [self loadPreView];
    }
}

- (void)loadEditView
{
    [_inputTextView becomeFirstResponder];
    _inputTextView.hidden = FALSE;
    _webView.hidden = TRUE;
    _activityView.hidden = TRUE;
}

- (void)loadPreView
{
    [_inputTextView resignFirstResponder];
    _webView.hidden = FALSE;
    _inputTextView.hidden = TRUE;
    _activityView.hidden = FALSE;
    [self previewLoadMDData];
}

- (void)previewLoadMDData
{
    [_activityView startAnimating];
    COMDtoHtmlRequest *reqeust = [COMDtoHtmlRequest request];
    reqeust.mdStr = _inputTextView.text;
    __weak typeof(self) weakSelf = self;
    [reqeust postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakSelf checkDataResponse:responseObject]) {
            NSString *contentStr = [WebContentManager markdownPatternedWithContent:responseObject.data];
            [weakSelf.webView loadHTMLString:contentStr baseURL:nil];
        } else {
            [_activityView stopAnimating];
        }
    } failure:^(NSError *error) {
        [_activityView stopAnimating];
        [weakSelf showError:error];
    }];
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"strLink=[%@]", request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshWebContentView];
    [_activityView stopAnimating];
}

- (void)refreshWebContentView
{
    if (_webView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webView.frame)];
        [_webView stringByEvaluatingJavaScriptFromString:meta];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorCancelled) {
        return;
    } else {
        NSLog(@"%@", error.description);
        [self showError:error];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _okBtn.enabled = FALSE;
    if (textView.text.length > 0) {
        _okBtn.enabled = TRUE;
        if (_task.hasDescription && [textView.text isEqualToString:_task.taskDescription.markdown]) {
            _okBtn.enabled = FALSE;
        }
    } else if (_task.hasDescription) {
        _okBtn.enabled = TRUE;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_inputTextView resignFirstResponder];
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    [_inputTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    [_inputTextView resignFirstResponder];
    
    if (_type == 0) {
        // 保存描述
        if (_inputTextView.text.length > 0 ) {
            _task.hasDescription = TRUE;
            _task.taskDescription = [COTaskDescription descriptionWithMdStr:_inputTextView.text];
        } else {
            _task.hasDescription = FALSE;
            _task.taskDescription = nil;
        }
        [self.navigationController popViewControllerAnimated:YES];
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
    } else {
        // 修改描述
        COTaskDescriptionRequest *request = [COTaskDescriptionRequest request];
        
        request.taskId = @(_task.taskId);
        request.descriptionStr = _inputTextView.text;

        __weak typeof(self) weakself = self;
        [request putWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                COTaskDescription *taskD = (COTaskDescription *)responseObject.data;
                weakself.task.hasDescription = (taskD.markdown.length > 0);
                weakself.task.taskDescription = taskD;
                [weakself.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    }
}

@end

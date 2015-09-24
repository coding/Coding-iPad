//
//  COFeedbackViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFeedbackViewController.h"
#import "EaseMarkdownTextView.h"
#import "COTopic.h"
#import "COAtMembersController.h"
#import "COUser.h"
#import "ProjectTopicLabelView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "COFeedbackViewCell.h"
#import "CORootViewController.h"
#import "COTopicRequest.h"
#import "NSString+Common.h"

@interface COFeedbackViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet EaseMarkdownTextView *markdownView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *editView;

@end

@implementation COFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    [self loadEditView];
    
    [_tableView registerClass:[COFeedbackViewCell class] forCellReuseIdentifier:kCellIdentifier_FeedbackContent];
    
    __weak typeof(self) weakSelf = self;
    _markdownView.atBlock = ^() {
        [weakSelf.view endEditing:YES];
        COAtMembersController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAtMembersController"];
        popoverVC.type = 1;
        popoverVC.projectId = _topic.projectId;
        popoverVC.selectUserBlock = ^(COUser *selectedUser) {
            [weakSelf atSomeUser:selectedUser andRange:weakSelf.markdownView.selectedRange];
        };
        
        [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
    };
    
    _markdownView.curProject = _topic.project;
    [_markdownView setPlaceholder:@"反馈内容"];
    _textField.text = _topic.mdTitle;
    _markdownView.text = _topic.mdContent;
    _okBtn.enabled = FALSE;
    
    // 内容
    @weakify(self);
    RAC(self.okBtn, enabled) = [RACSignal combineLatest:@[self.textField.rac_textSignal, self.markdownView.rac_textSignal] reduce:^id (NSString *title, NSString *content) {
        // 刚开始编辑content的时候，title传过来的总是nil
        @strongify(self);
        title = self.textField.text;
        content = self.markdownView.text;
        BOOL enabled = ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                        && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0);
        return @(enabled);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)atSomeUser:(COUser *)curUser andRange:(NSRange)range
{
    if (curUser) {
        NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
        [_markdownView insertText:appendingStr];
        [_markdownView becomeFirstResponder];
    }
}

- (void)segmentedChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        // 编辑
        [self loadEditView];
    } else {
        // 预览
        [self loadPreview];
    }
}

- (void)loadEditView
{
    _editView.hidden = NO;
    _tableView.hidden = YES;
}

- (void)loadPreview
{
    _tableView.hidden = NO;
    [_tableView reloadData];
    _editView.hidden = YES;
    [_editView endEditing:YES];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _topic ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        COFeedbackViewCell *contentCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_FeedbackContent forIndexPath:indexPath];
        
        _topic.mdTitle = _textField.text;
        _topic.mdContent = _markdownView.text;
        
        [contentCell setCurTopic:self.topic];
        __weak typeof(self) weakSelf = self;
        contentCell.cellHeightChangedBlock = ^(){
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        cell = contentCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [COFeedbackViewCell cellHeightWithObj:self.topic];
    }
    return cellHeight;
}

#pragma mark - action
- (IBAction)okBtnAction:(UIButton *)sender
{
    // 发送反馈
    [self.view endEditing:YES];
    sender.enabled = FALSE;
    _topic.mdTitle = _textField.text;
    _topic.mdContent = _markdownView.text;
    _topic.mdContent = [NSString stringWithFormat:@"%@\n%@", _topic.mdContent, [NSString userAgentStr]];
    COTopicAddRequest *requset = [COTopicAddRequest request];
    requset.projectId = @(_topic.projectId);
    requset.title = _topic.mdTitle;
    requset.content = _topic.mdContent;
    
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_topic.mdLabels.count];
    for (COTopicLabel *lbl in _topic.mdLabels) {
        [tempAry addObject:@(lbl.topicLabelId)];
    }
    requset.label = [tempAry componentsJoinedByString:@","];
    
    [self showProgressHudWithMessage:@"正在发送反馈信息"];
    __weak typeof(self) weakSelf = self;
    [requset postWithSuccess:^(CODataResponse *responseObject) {
        sender.enabled = TRUE;
        if ([weakSelf checkDataResponse:responseObject]) {
            [weakSelf showSuccess:@"反馈成功"];
            [weakSelf.navigationController popViewControllerAnimated:NO];
        }
    } failure:^(NSError *error) {
        sender.enabled = TRUE;
        [weakSelf showError:error];
    }];
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

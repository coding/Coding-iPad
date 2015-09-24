//
//  COTopicEditController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicEditController.h"
#import "COTopicLabelController.h"
#import "EaseMarkdownTextView.h"
#import "COTopic.h"
#import "COAtMembersController.h"
#import "COUser.h"
#import "ProjectTopicLabelView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "TopicContentCell.h"
#import "CORootViewController.h"
#import "COTopicRequest.h"

@interface COTopicEditController ()

@property (nonatomic, strong) UIViewController *popController;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIView *popShadowView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet EaseMarkdownTextView *markdownView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayout;
@property (weak, nonatomic) IBOutlet UIButton *labelAddBtn;

@property (strong, nonatomic) ProjectTopicLabelView *labelView;

@property (nonatomic, assign) BOOL okBtnEnabled;

@end

@implementation COTopicEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    [self loadEditView];
    
    [_tableView registerClass:[TopicContentCell class] forCellReuseIdentifier:kCellIdentifier_TopicContent];
    
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
    [_markdownView setPlaceholder:@"讨论内容"];
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
        BOOL enabled = self.okBtnEnabled || ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                        && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0
                        && (![title isEqualToString:self.topic.mdTitle] || ![content isEqualToString:self.topic.mdContent]));
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
    [self loadLabelView];
    
    CGRect frame = _labelView.frame;
    frame.size.height = _labelView.labelH;
    _labelView.frame = frame;
    _heightLayout.constant = _labelView.labelH - 34;
    
    _editView.hidden = NO;
    _tableView.hidden = YES;
}

- (void)loadLabelView
{
    if (_labelView) {
        [_labelView removeFromSuperview];
    }
    CGFloat curWidth = self.view.frame.size.width - 2*20;
    
    _labelView = [[ProjectTopicLabelView alloc] initWithFrame:CGRectMake(20, 20 + 14 + 9, curWidth - 32, 22) projectTopic:_topic md:YES];
    __weak typeof(self) weakSelf = self;
    _labelView.delLabelBlock = ^(NSInteger index){
        [weakSelf.topic.mdLabels removeObjectAtIndex:index];
        [weakSelf loadEditView];
        weakSelf.okBtn.enabled = TRUE;
        weakSelf.okBtnEnabled = TRUE;
    };
    [_editView insertSubview:_labelView belowSubview:_labelAddBtn];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        TopicContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicContent forIndexPath:indexPath];
        
        _topic.mdTitle = _textField.text;
        _topic.mdContent = _markdownView.text;
        
        [contentCell setCurTopic:self.topic md:YES];
        __weak typeof(self) weakSelf = self;
        contentCell.cellHeightChangedBlock = ^(){
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        contentCell.addLabelBlock = ^(){
            [weakSelf addtitleBtnClick];
        };
        contentCell.delLabelBlock = ^(NSInteger index) {
            [weakSelf.topic.mdLabels removeObjectAtIndex:index];
            [weakSelf loadPreview];
            weakSelf.okBtn.enabled = TRUE;
            weakSelf.okBtnEnabled = TRUE;
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
        cellHeight = [TopicContentCell cellHeightWithObj:self.topic md:YES];
    }
    return cellHeight;
}

#pragma mark - action
- (IBAction)backBtnAction:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    // 保存修改或创建新讨论
    [self.view endEditing:YES];
    sender.enabled = FALSE;
    _topic.mdTitle = _textField.text;
    _topic.mdContent = _markdownView.text;
    
    if (_type == 0) {
        COTopicAddRequest *requset = [COTopicAddRequest request];
        requset.projectId = @(_topic.projectId);
        requset.title = _topic.mdTitle;
        requset.content = _topic.mdContent;
        
        NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_topic.mdLabels.count];
        for (COTopicLabel *lbl in _topic.mdLabels) {
            [tempAry addObject:@(lbl.topicLabelId)];
        }
        requset.label = [tempAry componentsJoinedByString:@","];
        
        [self showProgressHudWithMessage:@"正在添加讨论"];
        __weak typeof(self) weakSelf = self;
        [requset postWithSuccess:^(CODataResponse *responseObject) {
            sender.enabled = TRUE;
            if ([weakSelf checkDataResponse:responseObject]) {
                [weakSelf showSuccess:@"添加讨论成功"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            sender.enabled = TRUE;
            [weakSelf showError:error];
        }];
    } else {
        COTopicUpdateRequest *requset = [COTopicUpdateRequest request];
        requset.topicId = @(_topic.topicId);
        requset.title = _topic.mdTitle;
        requset.content = _topic.mdContent;
        
        NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_topic.mdLabels.count];
        for (COTopicLabel *lbl in _topic.mdLabels) {
            [tempAry addObject:@(lbl.topicLabelId)];
        }
        requset.label = [tempAry componentsJoinedByString:@","];
        
        __weak typeof(self) weakSelf = self;
        [requset putWithSuccess:^(CODataResponse *responseObject) {
            sender.enabled = TRUE;
            if ([weakSelf checkDataResponse:responseObject]) {
                if (weakSelf.topicChangedBlock) {
                    weakSelf.topicChangedBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            sender.enabled = TRUE;
            [weakSelf showError:error];
        }];
    }
}

- (IBAction)labelAddBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    COTopicLabelController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicLabelController"];
    popoverVC.topic = _topic;
    popoverVC.isSaveChange = FALSE;
    __weak typeof(self) weakSelf = self;
    popoverVC.topicChangedBlock = ^(){
        [weakSelf loadEditView];
        weakSelf.okBtn.enabled = TRUE;
        weakSelf.okBtnEnabled = TRUE;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:popoverVC];
    nav.navigationBarHidden = YES;
    [self popoverController:nav withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

- (void)addtitleBtnClick
{
    [self.view endEditing:YES];
    
    COTopicLabelController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicLabelController"];
    popoverVC.topic = _topic;
    popoverVC.isSaveChange = FALSE;
    __weak typeof(self) weakSelf = self;
    popoverVC.topicChangedBlock = ^(){
        [weakSelf loadPreview];
        weakSelf.okBtn.enabled = TRUE;
        weakSelf.okBtnEnabled = TRUE;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:popoverVC];
    nav.navigationBarHidden = YES;
    [self popoverController:nav withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

#pragma mark - pop
- (void)popoverController:(UIViewController *)controller withSize:(CGSize)size
{
    BOOL reset = FALSE;
    if (self.popController) {
        reset = TRUE;
        _popShadowView.backgroundColor = [UIColor clearColor];
        [_popController.view removeFromSuperview];
        [_popController removeFromParentViewController];
        self.popController = nil;
    }
    
    if (self.maskView == nil) {
        self.maskView = [[UIButton alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [_maskView addTarget:self action:@selector(dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _popShadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _popShadowView.layer.shadowOpacity = 0.5;
        _popShadowView.layer.shadowRadius = 4;
        _popShadowView.layer.cornerRadius = 4;
        _popShadowView.layer.shadowOffset = CGSizeMake(1, 3);
        _popShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        [_maskView addSubview:_popShadowView];
    }
    
    CGRect frame = CGRectMake((_maskView.frame.size.width - size.width) / 2, (_maskView.frame.size.height - size.height) / 2, size.width, size.height);
    controller.view.frame = frame;
    _popShadowView.frame = frame;
    
    controller.view.layer.cornerRadius = 4;
    controller.view.layer.masksToBounds = TRUE;
    
    if (!reset) {
        _maskView.alpha = 0;
        controller.view.alpha = 0;
    }
    
    [self.view addSubview:_maskView];
    
    self.popController = controller;
    [self addChildViewController:controller];
    [_maskView addSubview:controller.view];
    
    _popShadowView.backgroundColor = [UIColor clearColor];
    
    [_popController viewWillAppear:YES];
    
    if (reset) {
        [UIView animateWithDuration:0.2 animations:^{
            controller.view.alpha = 1;
        } completion:^(BOOL finished) {
            _popShadowView.backgroundColor = [UIColor whiteColor];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            _maskView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                controller.view.alpha = 1;
            } completion:^(BOOL finished) {
                _popShadowView.backgroundColor = [UIColor whiteColor];
            }];
        }];
    }
}

- (void)dismissPopover
{
    [_popController viewWillDisappear:YES];
    _popShadowView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.1 animations:^{
        _popController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [_popController.view removeFromSuperview];
            [_popController removeFromParentViewController];
            [_maskView removeFromSuperview];
            self.popController = nil;
        }];
    }];
}

- (void)dismissBtnAction
{
    [_popController.view endEditing:YES];
}

@end

//
//  COAddTaskViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddTaskViewController.h"
#import "COTaskPriorityController.h"
#import "COPlaceHolderTextView.h"
#import "COTaskPriorityController.h"
#import "COTaskManagerController.h"
#import "COTaskDeadlineController.h"
#import "COAddTaskDescribeController.h"
#import "CORootViewController.h"
#import "COTask.h"
#import "COAddTask2ProjectController.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COTaskRequest.h"
#import "COSession.h"
#import "UIViewController+Utility.h"
#import "NSString+Emojize.h"
#import "COTaskListController.h"

@interface COAddTaskViewController ()

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *managerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *managerAvatar;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;


@end

@implementation COAddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _managerAvatar.layer.cornerRadius = 15;
    _managerAvatar.layer.masksToBounds = TRUE;
    
    [_textView setPlaceholder:@"任务概要"];
    
    // 什么情况下激活
    _okBtn.enabled = _task.content.length > 0 ? TRUE : FALSE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showData];

    CGRect frame = self.tableView.frame;
    frame.size.height = kPopHeight;
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.tableView.frame = frame;
    } completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.view.frame;
    frame.size.height = kPopHeight;
    self.tableView.frame = frame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showData
{
    //_titleLabel;// 任务描述改不改
    _textView.text = _task.content;
    
    _deadlineLabel.text = [COUtility YYYYMMDDToMMDD:_task.deadline];
    
    if (_task.owner) {
        [self.managerAvatar sd_setImageWithURL:[COUtility urlForImage:_task.owner.avatar] placeholderImage:[COUtility placeHolder]];
        _managerLabel.text = _task.owner.name;
    }
    _priorityLabel.text = [_task priorityDisplay];
}

#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_textView resignFirstResponder];
    
    if (indexPath.row == 2) {
        // 项目描述
        COAddTaskDescribeController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAddTaskDescribeController"];
        popoverVC.task = _task;
        [self.navigationController pushViewController:popoverVC animated:YES];
    } else if (indexPath.row == 4) {
        // 设置负责人
        COTaskManagerController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskManagerController"];
        popoverVC.task = _task;
        popoverVC.type = 1;
        [self.navigationController pushViewController:popoverVC animated:YES];
    } else if (indexPath.row == 5) {
        // 设置优先级
        COTaskPriorityController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskPriorityController"];
        popoverVC.task = _task;
        popoverVC.type = 1;
        [self.navigationController pushViewController:popoverVC animated:YES];
        
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeightSS)];
    } else if (indexPath.row == 6) {
        // 截止日期
        COTaskDeadlineController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDeadlineController"];
        popoverVC.task = _task;
        popoverVC.type = 1;
        [self.navigationController pushViewController:popoverVC animated:YES];
        
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeightSS)];
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
    _okBtn.enabled = (textView.text.length > 0) ? TRUE : FALSE;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _task.content = textView.text;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_textView resignFirstResponder];
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    [_textView resignFirstResponder];
    
    // 返回上一步
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    [_textView resignFirstResponder];
    
    // 发布任务！
    COTaskCreateRequest *request = [COTaskCreateRequest request];
    request.backendProjectPath = _task.project.backendProjectPath;
    
    request.content = _task.content;
    request.deadline = _task.deadline;
    if (_task.taskDescription.markdown.length > 0) {
        request.taskDescription = [_task.taskDescription.markdown aliasedString];
    }
    request.ownerId = [NSString stringWithFormat:@"%ld", (long)_task.ownerId];
    request.priority = @(_task.priority);
    
    __weak typeof(self) weakself = self;
    [self showProgressHud];
    [request postWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself dismissProgressHud];
            if ([weakself checkDataResponse:responseObject]) {
                [weakself showSuccess:@"发布成功了~"];
                [[CORootViewController currentRoot] dismissPopover];
                [[NSNotificationCenter defaultCenter] postNotificationName:COTaskReloadNotification object:nil];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself dismissProgressHud];
            [weakself showError:error];
        });
    }];
}

@end

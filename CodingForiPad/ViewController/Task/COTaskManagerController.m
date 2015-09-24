//
//  COTaskManagerController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskManagerController.h"
#import "COProjectRequest.h"
#import "COTaskManagerCell.h"
#import "UIViewController+Utility.h"
#import "CORootViewController.h"
#import "COTask.h"
#import "COAddTaskViewController.h"

@interface COTaskManagerController ()

@property (nonatomic, strong) NSArray *members;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation COTaskManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadMemebers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMemebers
{
    COProjectMembersRequest *request = [COProjectMembersRequest request];
    request.projectId = _task.projectId;
    request.page = 1;
    request.pageSize = 100;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showMembers:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (void)showMembers:(NSArray *)members
{
    self.members = members;
    [self.tableView reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTaskManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTaskManagerCell"];
    
    COProjectMember *member =_members[indexPath.row];
    [cell assignWithMember:member];
    
    cell.ownerIcon.hidden = (member.userId == _task.ownerId) ? NO : YES;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    COProjectMember *member =_members[indexPath.row];

    // 修改任务负责人
    _task.ownerId = member.userId;
    // 因为监控了owner，所以需要注意先修改ownerId，然后才能修改owner
    _task.owner = member.user;

    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - click
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

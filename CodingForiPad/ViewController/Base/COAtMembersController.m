//
//  COAtMembersController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAtMembersController.h"
#import "COAtFriendsCell.h"
#import "CORootViewController.h"
#import "COProjectRequest.h"
#import "COUser.h"
#import "UIViewController+Utility.h"
#import "COProject.h"

@interface COAtMembersController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *members;

@end

@implementation COAtMembersController

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
    request.projectId = self.projectId;
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COAtFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COAtFriendsCell" forIndexPath:indexPath];
    [cell assignWithMember:_members[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectUserBlock) {
        COProjectMember *member = _members[indexPath.row];
        self.selectUserBlock(member.user);
    }
    
    if (_type == 0) {
        // 任务描述@项目成员
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 讨论@项目成员
        [[CORootViewController currentRoot] dismissPopover];
    }
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    if (_type == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[CORootViewController currentRoot] dismissPopover];
    }
}

@end

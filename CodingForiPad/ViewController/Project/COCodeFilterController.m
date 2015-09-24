//
//  COCodeFilterController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCodeFilterController.h"
#import "COCodeFilterCell.h"
#import "COGitRequest.h"
#import "UIViewController+Utility.h"
#import "COGitTree.h"

@interface COCodeFilterController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *branchList;
@property (nonatomic, strong) NSArray *tagList;

@end

@implementation COCodeFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_segmentedControl setSelectedSegmentIndex:0];
    [self loadBranches];
}

- (IBAction)segmentedChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        // 显示分支
        [self loadBranches];
    } else if (sender.selectedSegmentIndex == 1) {
        // 显示标签
        [self loadTags];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBranches
{
    COGitListBranchesRequest *request = [COGitListBranchesRequest request];
    request.backendProjectPath = self.backendProjectPath;

    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showBranches:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showBranches:(NSArray *)data
{
    self.branchList = data;
    [self.tableView reloadData];
}

- (void)loadTags
{
    COGitListTagsRequest *request = [COGitListTagsRequest request];
    request.backendProjectPath = self.backendProjectPath;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showTags:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showTags:(NSArray *)data
{
    self.tagList = data;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == 0) {
        return _branchList.count;
    }
    return _tagList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COCodeFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COCodeFilterCell" forIndexPath:indexPath];
    COGitBranch *branch;
    if (_segmentedControl.selectedSegmentIndex == 0) {
        branch = _branchList[indexPath.row];
    } else {
        branch = _tagList[indexPath.row];
    }
    
    cell.nameLabel.text = branch.name;
    cell.backgroundColor = [UIColor whiteColor];
    if ([_ref isEqualToString:branch.name]) {
        cell.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 选中分支或标签
    COGitBranch *branch;
    if (_segmentedControl.selectedSegmentIndex == 0) {
        branch = _branchList[indexPath.row];
    } else {
        branch = _tagList[indexPath.row];
    }
    if (_selectedBranchTagBlock) {
        _selectedBranchTagBlock(branch.name);
    }
}

@end

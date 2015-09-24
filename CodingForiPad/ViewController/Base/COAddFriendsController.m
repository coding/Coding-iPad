//
//  COAddFriendsController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddFriendsController.h"
#import "COAddFriendsCell.h"
#import "COUser.h"
#import "COAccountRequest.h"
#import "UIViewController+Utility.h"
#import "CORootViewController.h"

@interface COAddFriendsController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *queryingArray;
@property (strong, nonatomic) NSMutableArray *searchedArray;

@end

@implementation COAddFriendsController

+ (void)popSelf
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    COAddFriendsController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"COAddFriendsController"];
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _queryingArray = [NSMutableArray array];
    _searchedArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self searchUserWithStr:_searchBar.text];
}

- (BOOL)userIsQuering:(COUser *)curUser
{
    for (COUser *item in _queryingArray) {
        if ([item.globalKey isEqualToString:curUser.globalKey]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"COAddFriendsCell";
    
    COAddFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    COUser *curUser = [_searchedArray objectAtIndex:indexPath.row];
    [cell setUser:curUser isQuerying:[self userIsQuering:curUser]];
    __weak typeof(self) weakSelf = self;
    cell.btnBlock = ^(COUser *clickedUser){
        if (![weakSelf userIsQuering:clickedUser]) {
            [weakSelf.queryingArray addObject:clickedUser];
            [weakSelf.tableView reloadData];
            
            COFollowedOrNot *reqeust = [COFollowedOrNot request];
            reqeust.isFollowed = clickedUser.followed;
            reqeust.users = clickedUser.globalKey ? clickedUser.globalKey : [NSString stringWithFormat:@"%ld", (long)clickedUser.userId];
            [reqeust postWithSuccess:^(CODataResponse *responseObject) {
                if ([weakSelf checkDataResponse:responseObject]) {
                    clickedUser.followed = !clickedUser.followed;
                }
                [weakSelf.queryingArray removeObject:clickedUser];
                [weakSelf.tableView reloadData];
            } failure:^(NSError *error) {
                [weakSelf.queryingArray removeObject:clickedUser];
                [weakSelf.tableView reloadData];
            }];
        }
    };
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange: %@", searchText);
    [self searchUserWithStr:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self searchUserWithStr:searchBar.text];
}

- (void)searchUserWithStr:(NSString *)string
{
    NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedStr.length > 0) {
        COUserSearch *reqeust = [COUserSearch request];
        reqeust.key = string;
        __weak typeof(self) weakSelf = self;
        [reqeust getWithSuccess:^(CODataResponse *responseObject) {
            if ([weakSelf checkDataResponse:responseObject]) {
                weakSelf.searchedArray = responseObject.data;
                [weakSelf.tableView reloadData];
            }
            
        } failure:^(NSError *error) {
            [weakSelf showErrorInHudWithError:error];
        }];
    } else {
        [_searchedArray removeAllObjects];
        [_tableView reloadData];
    }
    
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

@end

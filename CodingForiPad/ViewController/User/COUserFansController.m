//
//  COUserFansController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserFansController.h"
#import "COUserFansCell.h"
#import "COTweetRequest.h"
#import "COUser.h"
#import "COSession.h"
#import "CORootViewController.h"
#import "COAccountRequest.h"
#import "COUserController.h"

@interface COUserFansController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSDictionary *groupedDict;
@property (strong, nonatomic) NSMutableArray *queryingArray;
@property (assign, nonatomic) BOOL search;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSMutableArray *originData;

@end

@implementation COUserFansController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchBar.delegate = self;
    _queryingArray = @[].mutableCopy;
    self.tableView.sectionIndexColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    
    if (self.type == 0) {
        if ([[COSession session].user.globalKey isEqualToString:_globayKey]) {
            _titleLabel.text = @"关注我的人";
        } else {
            _titleLabel.text = @"Ta的粉丝";//[NSString stringWithFormat:@"%@的粉丝",]
        }
        [self loadFans];
    }
    else {
        if ([[COSession session].user.globalKey isEqualToString:_globayKey]) {
            _titleLabel.text = @"我关注的人";
        } else {
            _titleLabel.text = @"Ta关注的人";//[NSString stringWithFormat:@"%@的粉丝",]
        }
        [self loadFriend];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma makr -
- (void)loadFans
{
    COFollowersRequest *request = [COFollowersRequest request];
    request.globalKey = self.globayKey;
    request.pageSize = 99999;
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            // show data
            weakself.groupedDict = [weakself dictGroupedByPinyin:responseObject.data];
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)loadFriend
{
    COFriendsRequest *request = [COFriendsRequest request];
    request.globalKey = self.globayKey;
    request.pageSize = 99999;
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            // show data
            weakself.groupedDict = [weakself dictGroupedByPinyin:responseObject.data];
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (NSDictionary *)dictGroupedByPinyin:(NSMutableArray *)list
{
    self.originData = [NSMutableArray arrayWithArray:list];
    
    if (list.count <= 0) {
        return @{@"#" : [NSMutableArray array]};
    }
    
    NSMutableDictionary *groupedDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for (char c = 'A'; c < 'Z'+1; c++) {
        char key[2];
        key[0] = c;
        key[1] = '\0';
        [allKeys addObject:[NSString stringWithUTF8String:key]];
    }
    [allKeys addObject:@"#"];
    
    for (NSString *keyStr in allKeys) {
        [groupedDict setObject:[[NSMutableArray alloc] init] forKey:keyStr];
    }
    
    [list enumerateObjectsUsingBlock:^(COUser *obj, NSUInteger idx, BOOL *stop) {
        NSString *keyStr = nil;
        NSMutableArray *dataList = nil;
        
        if (obj.namePinyin.length > 1) {
            keyStr = [obj.namePinyin substringToIndex:1];
            if ([[groupedDict allKeys] containsObject:keyStr]) {
                dataList = [groupedDict objectForKey:keyStr];
            }
        }
        
        if (!dataList) {
            keyStr = @"#";
            dataList = [groupedDict objectForKey:keyStr];
        }
        
        [dataList addObject:obj];
        [groupedDict setObject:dataList forKey:keyStr];
    }];
    
    for (NSString *keyStr in allKeys) {
        NSMutableArray *dataList = [groupedDict objectForKey:keyStr];
        if (dataList.count <= 0) {
            [groupedDict removeObjectForKey:keyStr];
        } else if (dataList.count > 1) {
            [dataList sortUsingComparator:^NSComparisonResult(COUser *obj1, COUser *obj2) {
                return [obj1.namePinyin compare:obj2.namePinyin];
            }];
        }
    }
    
    return groupedDict;
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.search) {
        return 1;
    }
    
    NSInteger section = 1;
    if (self.groupedDict) {
        section = [[self groupedKeyList] count];
    }
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.search) {
        return self.searchResult.count;
    }
    
    NSInteger row = 0;
    if ([self groupedKeyList] && [[self groupedKeyList] count] > section) {
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:section]];
        row = [dataList count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COUserFansCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COUserFansCell" forIndexPath:indexPath];
    COUser *curUser = nil;
    if (self.search) {
        curUser = self.searchResult[indexPath.row];
    }
    else {
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:indexPath.section]];
        curUser = [dataList objectAtIndex:indexPath.row];
    }
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
    
    cell.avatarBlock = ^(COUser *clckedUser) {
        COUser *user = clckedUser;
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
        controller.user = user;
        [[CORootViewController currentRoot] dismissPopover];
        // TODO: 重构显示方式
        [[CORootViewController currentRoot].navigationController pushViewController:controller animated:YES];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    headView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headView.frame.size.width - 40, 20)];
    headLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    headLabel.font = [UIFont systemFontOfSize:14];
    
    if ([self groupedKeyList].count > section && section > 0) {
        headLabel.text = [[self groupedKeyList] objectAtIndex:section];
    }
    
    [headView addSubview:headLabel];
    return headView;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.search) {
        return nil;
    }
    return [self groupedKeyList];
}

- (NSArray *)groupedKeyList
{
    if (self.groupedDict.count <= 0) {
        return nil;
    }
    NSMutableArray *keyList = [NSMutableArray arrayWithArray:self.groupedDict.allKeys];
    [keyList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    if ([keyList containsObject:@"#"]) {
        [keyList removeObject:@"#"];
        [keyList addObject:@"#"];
    }
    [keyList insertObject:UITableViewIndexSearch atIndex:0];
    return keyList;
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark -
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.search = YES;
    searchBar.showsCancelButton = YES;
    
    for (id cc in [searchBar.subviews[0] subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *sbtn = (UIButton *)cc;
            [sbtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [sbtn setTitleColor:[UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *result = [NSMutableArray array];
    for (COUser *user in self.originData) {
        NSRange range = [[user.name lowercaseString] rangeOfString:[searchText lowercaseString] options:0];
        if (range.location != NSNotFound) {
            [result addObject:user];
            continue;
        }
        range = [[user.globalKey lowercaseString] rangeOfString:[searchText lowercaseString] options:0];
        if (range.location != NSNotFound) {
            [result addObject:user];
            continue;
        }
    }
    
    self.searchResult = [NSMutableArray arrayWithArray:result];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    self.search = NO;
    [self.searchResult removeAllObjects];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

@end

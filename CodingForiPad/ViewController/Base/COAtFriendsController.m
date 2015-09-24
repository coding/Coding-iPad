//
//  COSelectFriendsController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAtFriendsController.h"
#import "COAtFriendsCell.h"
#import "CORootViewController.h"
#import "COAddMsgController.h"
#import "COTweetRequest.h"
#import "COUser.h"
#import "COSession.h"
#import "UIViewController+Utility.h"

@interface COAtFriendsController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSDictionary *groupedDict;

@property (assign, nonatomic) BOOL search;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSMutableArray *originData;

@end

@implementation COAtFriendsController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate = self;
    
    self.tableView.sectionIndexColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    
    [self loadFriend];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriend
{
    COFriendsRequest *request = [COFriendsRequest request];
    request.page = 1;
    request.pageSize = 9999;
    request.globalKey = [COSession session].user.globalKey;
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
    COAtFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COAtFriendsCell" forIndexPath:indexPath];
    COUser *curUser = nil;
    if (self.search) {
        curUser = self.searchResult[indexPath.row];
    } else {
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:indexPath.section]];
        curUser = [dataList objectAtIndex:indexPath.row];
    }
    [cell assignWithUser:curUser];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    COUser *curUser = nil;
    if (self.search) {
        curUser = self.searchResult[indexPath.row];
    } else {
        NSArray *dataList = [self.groupedDict objectForKey:[[self groupedKeyList] objectAtIndex:indexPath.section]];
        curUser = [dataList objectAtIndex:indexPath.row];
    }
    if (_type == 0) {
        // 进入发私信页面
        
        COAddMsgController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAddMsgController"];
        popoverVC.user = curUser;
        [self.navigationController pushViewController:popoverVC animated:YES];

        //[[CORootViewController currentRoot] dismissPopover];
        //[[CORootViewController currentRoot] chatToGlobalKey:curUser.globalKey];
    } else {
        // 选择@好友
        if (self.selectUserBlock) {
            self.selectUserBlock(curUser);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

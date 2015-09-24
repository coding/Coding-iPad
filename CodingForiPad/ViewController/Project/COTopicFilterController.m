//
//  COTopicFilterController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicFilterController.h"
#import "CORootViewController.h"

@interface COTopicFilterController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation COTopicFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTopicFilterCell"];
    
    UILabel *tempLbl = (UILabel *)[cell viewWithTag:110];
    if (_numbers) {
        tempLbl.text = [NSString stringWithFormat:@"%@（%d）", _titles[indexPath.row], [_numbers[indexPath.row]  intValue]];
    } else {
        tempLbl.text = _titles[indexPath.row];
    }
    
    UIImageView *selectIcon = (UIImageView *)[cell viewWithTag:120];
    selectIcon.hidden = (_defaultIndex == indexPath.row) ? FALSE : TRUE;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 改变筛选条件
    if (_indexDelegate && indexPath.row != _defaultIndex) {
        [_indexDelegate changeIndex:indexPath.row withSegmentIndex:_segmentIndex];
    }
    
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark - click
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

@end

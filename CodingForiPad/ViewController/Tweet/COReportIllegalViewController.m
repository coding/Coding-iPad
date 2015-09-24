//
//  COReportIllegalViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COReportIllegalViewController.h"
#import "CORootViewController.h"
#import <Masonry.h>
#import "UIColor+Hex.h"
#import "COAccountRequest.h"
#import "COSession.h"

#define kColorTableSectionBg [UIColor colorWithHexString:@"0xeeeeee"]

@implementation COIllegalCell


@end

@interface COReportIllegalViewController ()
@property (nonatomic, assign) NSInteger selectedIndex;
@property (strong, nonatomic) NSArray *dataList;
@end

@implementation COReportIllegalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataList = @[
                  @"淫秽色情",
                  @"垃圾广告",
                  @"敏感信息",
                  @"抄袭内容",
                  @"侵犯版权",
                  @"骚扰我"
                  ];
    self.submitBtn.enabled = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = kColorTableSectionBg;
    self.selectedIndex = _dataList.count;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)submitAction:(id)sender
{
    COReportIllegalContentRequest *request = [COReportIllegalContentRequest request];
    request.type = @"tweet";
    request.content = self.content;
    request.user = [COSession session].user.globalKey;
    request.reason = self.dataList[self.selectedIndex];
    
    [request postWithSuccess:^(CODataResponse *responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error) {
        //
    }];
    
    [self showSuccess:@"举报信息已发送"];
    
    [self cancelAction:nil];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COIllegalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COIllegalCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.valueLabel.text = self.dataList[indexPath.row];
    if (indexPath.row == self.selectedIndex) {
        cell.markImageView.image = [UIImage imageNamed:@"cell_checkmark"];
    }
    else {
        cell.markImageView.image = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.submitBtn.enabled = YES;
    self.selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    headerView.backgroundColor = kColorTableSectionBg;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.font = [UIFont systemFontOfSize:15];
    headerLabel.textColor = [UIColor lightGrayColor];
    [headerView addSubview:headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(20);
        make.right.equalTo(headerView).offset(-20);
        make.bottom.equalTo(headerView).offset(-5);
        make.height.mas_equalTo(20);
    }];
    
    headerLabel.text = @"举报类型";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

@end

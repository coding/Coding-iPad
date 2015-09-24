//
//  COMenuController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMenuController.h"
#import "COPopMenuBackgroundView.h"
#import "CORootViewController.h"
#import "COAddTask2ProjectController.h"
#import "COAddTweetController.h"
#import "COAddMsgController.h"
#import "COAtFriendsController.h"
#import "COAddProjectController.h"
#import "COAddFriendsController.h"
#import "UIColor+Hex.h"

@implementation COMenuCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIView *lineView = [self viewWithTag:1];
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithRGB:@"43,197,124"];
        lineView.backgroundColor = [UIColor clearColor];
    }
    else {
        self.contentView.backgroundColor = [UIColor whiteColor];
        lineView.backgroundColor = [UIColor colorWithRGB:@"238,238,238"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    UIView *lineView = [self viewWithTag:1];
    if (highlighted) {
//        self.contentView.backgroundColor = [UIColor colorWithRGB:@"43,197,124"];
        self.contentView.backgroundColor = [UIColor colorWithHex:@"#f2f2f2"];
        lineView.backgroundColor = [UIColor clearColor];
    }
    else {
        self.contentView.backgroundColor = [UIColor whiteColor];
        lineView.backgroundColor = [UIColor colorWithRGB:@"238,238,238"];
    }
}

@end

@interface COMenuController ()

@property (nonatomic, strong) UIPopoverController *popVC;

@end

@implementation COMenuController

+ (void)popFromBarButtonItem:(UIBarButtonItem *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    COMenuController *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"COMenuController"];
    
    UIPopoverController *popVC = [[UIPopoverController alloc] initWithContentViewController:menuVC];
    popVC.popoverBackgroundViewClass = [COPopMenuBackgroundView class];
    popVC.popoverContentSize = CGSizeMake(200, 270);
    [popVC presentPopoverFromBarButtonItem:sender
                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                  animated:YES];
    menuVC.popVC = popVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 控制圆角
    self.view.superview.layer.cornerRadius = 4.0;
    self.view.superview.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIColor *color = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = color;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.popVC dismissPopoverAnimated:YES];
    self.popVC = nil;
    
    if (indexPath.row == 0) {
        // 发布项目
        [COAddProjectController popSelf];
    } else if (indexPath.row == 1) {
        // 发布任务
        [COAddTask2ProjectController popSelf];
    } else if (indexPath.row == 2) {
        // 发布冒泡
        [COAddTweetController popSelf];
    } else if (indexPath.row == 3) {
        // 发布私信
        [COAddMsgController popSelf];
    } else if (indexPath.row == 4) {
        // 添加好友
        [COAddFriendsController popSelf];
    }
}

@end

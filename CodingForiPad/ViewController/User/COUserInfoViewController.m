//
//  COUserInfoViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserInfoViewController.h"
#import "COSession.h"
#import "UIButton+WebCache.h"
#import "COUtility.h"
#import "ZLPhoto.h"
#import "COUserController.h"
#import "COUserFansController.h"
#import "COAddFriendsController.h"
#import "COAccountRequest.h"
#import "CORootViewController.h"
#import "COUserProjectsController.h"
#import "COTweetViewController.h"
#import "COUserController.h"
#import "COAccountRequest.h"
#import <KVOController/FBKVOController.h>
#import "StartImagesManager.h"
#import "COUserProjectsViewController.h"
#import "COAddMsgController.h"

@interface COUserInfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (weak, nonatomic) IBOutlet UITableViewCell *headCell;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconSex;
@property (weak, nonatomic) IBOutlet UIButton *watchBtn;
@property (weak, nonatomic) IBOutlet UIButton *watchedBtn;

@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *fansBtn;
@property (weak, nonatomic) IBOutlet UIButton *watchCountBtn;

@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UILabel *watchLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;

@end

@implementation COUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headCell.layer.zPosition = -1;
    _iconBtn.imageView.layer.cornerRadius = _iconBtn.frame.size.width / 2;
    _iconBtn.imageView.layer.borderWidth = 1;
    _iconBtn.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
 
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0);
    
    [_backImageView setImage:[StartImagesManager shareManager].curImage.image];
    
    [self assignWithUser:_user];
    
    if (_user.userId == [COSession session].user.userId) {
        [self.KVOController observe:[COSession session] keyPath:@"user" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            self.user = [COSession session].user;
            [self assignWithUser:_user];
        }];
    }
}

- (void)dealloc
{
    if (_user.userId == [COSession session].user.userId) {
        [self.KVOController unobserveAll];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assignWithUser:(COUser *)user
{
    if (user.userId == [COSession session].user.userId) {
        self.projectLabel.text = @"我的项目";
        self.tweetLabel.text = @"我的冒泡";
    }
    else {
        self.projectLabel.text = @"TA的项目";
        self.tweetLabel.text = @"TA的冒泡";
    }
    [self loadDetail:user.globalKey];
}

- (void)showUser:(COUser *)user
{
    self.user = user;
    [_iconBtn sd_setImageWithURL:[COUtility urlForImage:user.avatar] forState:UIControlStateNormal placeholderImage:[COUtility placeHolder]];
    
    _nameLabel.text = user.name;
    _cityLabel.text = [user.location length] > 0? user.location : @"未填写";
    _sloganLabel.text = [user.slogan length] > 0 ? user.slogan : @"未填写";
    _descLabel.text = [user.tagsStr length] > 0 ? user.tagsStr : @"未填写";
    
    [_iconSex setImage:[UIImage imageNamed:user.sex == 0 ? @"icon_male" :@"icon_female"]];
    _iconSex.hidden = (user.sex == 0 || user.sex == 1) ? FALSE : TRUE;
    
    if (user.userId == [COSession session].user.userId) {
        self.watchBtn.hidden = YES;
        self.watchedBtn.hidden = YES;
    }
    else {
        self.watchBtn.hidden = user.followed ? YES : NO;
        if (user.follow) {
            // both
            [_watchedBtn setImage:[UIImage imageNamed:@"icon_followed_copy"] forState:UIControlStateNormal];
        } else {
            [_watchedBtn setImage:[UIImage imageNamed:@"icon_model_selected_gray"] forState:UIControlStateNormal];
        }
        
        self.watchedBtn.hidden = !_watchBtn.hidden;
    }
    
    if (user.userId == [COSession session].user.userId) {
//        [self.messageBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        self.messageBtn.hidden = YES;
    } else {
        self.messageBtn.hidden = NO;
        [self.messageBtn setTitle:@"发消息" forState:UIControlStateNormal];
    }
    
    self.fansLabel.text = [NSString stringWithFormat:@"%ld 粉丝", (long)user.fansCount];
    self.watchLabel.text = [NSString stringWithFormat:@"%ld 关注", (long)user.followsCount];
}

- (void)loadDetail:(NSString *)globalKey
{
    COAccountUserInfoRequest *request = [COAccountUserInfoRequest request];
    request.globalKey = globalKey;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showUser:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _topLayout.constant = -200 - scrollView.contentOffset.y * 0.3f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        COUserController *uc = (COUserController *)self.parentViewController;
        [uc showDetail];
    }
    else if (indexPath.row == 3) {
//        COUserProjectsController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserProjectsController"];
//        controller.user = self.user;
//        [self rootPushViewController:controller animated:YES];
        COUserProjectsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserProjectsViewController"];
        controller.user = self.user;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        nav.navigationBarHidden = YES;
        COUserController *uc = (COUserController *)self.parentViewController;
        [uc chageController:nav];
    }
    else if (indexPath.row == 4) {
        COTweetViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"COTweetViewController"];
        c.user = self.user;
        COUserController *uc = (COUserController *)self.parentViewController;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
        nav.navigationBarHidden = YES;
        [uc chageController:nav];
    }
}

#pragma mark - action
- (IBAction)avatarBtnAction:(UIButton *)sender
{
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    [browserVc showHeadPortrait:sender originUrl:_user.lavatar];
}

- (IBAction)watchBtnAction:(UIButton *)sender
{
    // 关注或取关此人
    COFollowedOrNot *request = [COFollowedOrNot request];
    request.isFollowed = _user.followed;
    request.users = _user.globalKey ? _user.globalKey : [NSString stringWithFormat:@"%ld", (long)_user.userId];
    
    [self showProgressHud];
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:weakself.watchBtn.hidden ? @"取消关注成功~" : @"关注成功~"];
            [weakself loadDetail:weakself.user.globalKey];
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (IBAction)messageBtnAction:(UIButton *)sender
{
    if (_user.userId == [COSession session].user.userId) {
        // 添加好友入口
        [COAddFriendsController popSelf];
    } else {
        // 给此人发消息
        COAddMsgController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAddMsgController"];
        popoverVC.type = 1;
        popoverVC.user = _user;
        [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
    
        //[[CORootViewController currentRoot] chatToGlobalKey:self.user.globalKey];
    }
}

- (IBAction)fansBtnAction:(UIButton *)sender
{
    // 前往粉丝列表
    COUserFansController *fans = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserFansController"];
    fans.globayKey = self.user.globalKey;
    [[CORootViewController currentRoot] popoverController:fans withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

- (IBAction)watchCountBtnAction:(UIButton *)sender
{
    // 前往关注者列表
    COUserFansController *fans = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserFansController"];
    fans.globayKey = self.user.globalKey;
    fans.type = 1;
    [[CORootViewController currentRoot] popoverController:fans withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

@end

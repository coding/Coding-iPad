//
//  COUserDetailViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserDetailViewController.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "CORootViewController.h"
#import "COUserReNameController.h"
#import "COUserReTagController.h"
#import "COUserRePositionController.h"
#import "COUserBirthdateController.h"
#import "ZLPhoto.h"
#import "AddressManager.h"
#import "JobManager.h"
#import "TagsManager.h"
#import "COAccountRequest.h"
#import "UIViewController+Utility.h"
#import "NSDate+Helper.h"
#import "COSession.h"
#import "CODataRequest+Image.h"
#import <KVOController/FBKVOController.h>

@interface COUserDetailViewController () <ZLPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *domainLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mottoLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

@property (strong, nonatomic) JobManager *curJobManager;
@property (strong, nonatomic) TagsManager *curTagsManager;

@property (strong, nonatomic) COAccountUpdateInfoRequest *request;

@end

@implementation COUserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _avatar.layer.cornerRadius = _avatar.frame.size.width / 2;
    _avatar.layer.masksToBounds = TRUE;
    
    [self assignWithUser:_user];
    
    _curJobManager = [[JobManager alloc] init];
    _curTagsManager = [[TagsManager alloc] init];
    __weak typeof(self) weakself = self;
    COUserJobArrayRequest *reqeust = [COUserJobArrayRequest request];
    [reqeust getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            weakself.curJobManager.jobDict = responseObject.data;
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
    COUserTagArrayRequest *tagReqeust = [COUserTagArrayRequest request];
    [tagReqeust getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            weakself.curTagsManager.tagArray = responseObject.data;
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
    
    [self.KVOController observe:[COSession session] keyPath:@"user" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        self.user = [COSession session].user;
        [self assignWithUser:_user];
    }];
}

- (void)dealloc
{
    [self.KVOController unobserveAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.user = nil;
    self.curJobManager = nil;
    self.curTagsManager = nil;
}

- (void)assignWithUser:(COUser *)user
{
    [_avatar sd_setImageWithURL:[COUtility urlForImage:user.avatar] placeholderImage:[COUtility placeHolder]];
    _nameLabel.text = user.name;
    _joinLabel.text = [COUtility timestampToDay:user.createdAt];
    _activityLabel.text = [COUtility timestampToDay:user.lastActivityAt];
    _domainLabel.text = user.globalKey;
    _sexLabel.text = user.sex == 0 ? @"男" : (user.sex == 1 ? @"女" : @"未知");
    _dateLabel.text = [user.birthday length] > 0 ? user.birthday : @"未填写";
    _locationLabel.text = [user.location length] > 0 ? user.location : @"未填写";
    _mottoLabel.text = [user.slogan length] > 0 ? user.slogan : @"未填写";
    _companyLabel.text = [user.company length] > 0 ? user.company : @"未填写";
    _positionLabel.text = [user.jobStr length] > 0? user.jobStr : @"未填写";
    _tagLabel.text = [user.tagsStr length] > 0? user.tagsStr : @"未填写";
    [self.tableView reloadData];
}

- (COAccountUpdateInfoRequest *)getUpdateRequest
{
    COAccountUpdateInfoRequest *requset = [COAccountUpdateInfoRequest request];
    [requset assignWithUser:_user];
    requset.userID = @(_user.userId);
    requset.globalKey = _user.globalKey;
    requset.avatar = _user.avatar ? _user.avatar : [NSString stringWithFormat:@"/static/fruit_avatar/Fruit-%d.png", (rand()%20)+1];
    requset.location = _user.location ? _user.location : @"";
    requset.slogan = _user.slogan ? _user.slogan : @"";
    
    requset.email = _user.email ? _user.email : @"";
    
    requset.name = _user.name ? _user.name : @"";
    requset.sex = @(_user.sex);
    
    requset.birthday = _user.birthday ? _user.birthday : @"";
    requset.company = _user.company ? _user.company : @"";
    requset.job = @(_user.job);
    requset.tags = _user.tags ? _user.tags : @"";
    return requset;
}

- (void)sendUpdateRequest
{
    [self showProgressHudWithMessage:@"正在修改个人信息"];
    __weak typeof(self) weakself = self;
    [_request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"个人信息修改成功"];
            [[COSession session] updateUserInfo];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 125;
    }
    if (indexPath.row == 9) {
        [_tagLabel setNeedsLayout];
        [_tagLabel layoutIfNeeded];
        return _tagLabel.frame.size.height + 18 + 19;
    }
    return 54;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.user.userId != [[[COSession session] user] userId]) {
        return FALSE;
    }
    return TRUE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.user.userId != [[[COSession session] user] userId]) {
        return;
    }
    
    switch (indexPath.row) {
        case 3:
        {   // 性别
            COUserRePositionController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserRePositionController"];
            popoverVC.type = @"性别";
            popoverVC.infoAry = @[@[@"男", @"女", @"未知"]];
            popoverVC.selectedIndex = @[@(_user.sex)];

            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSArray *selectedIndex, NSArray *selectedValue) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.sex = [selectedIndex firstObject];
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }   break;
        case 4:
        {   // 生日
            NSDate *curDate = [NSDate dateFromString:_user.birthday withFormat:@"yyyy-MM-dd"];
            if (!curDate) {
                curDate = [NSDate dateFromString:@"1990-01-01" withFormat:@"yyyy-MM-dd"];
            }
            
            COUserBirthdateController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserBirthdateController"];
            popoverVC.selectedDate = curDate;
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSDate *selectedDate) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.birthday = [selectedDate stringWithFormat:@"yyyy-MM-dd"];
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }   break;
        case 5:
        {   // 所在地
            NSNumber *firstLevel = nil, *secondLevel = nil;
            if (_user.location && _user.location.length > 0) {
                NSArray *locationArray = [_user.location componentsSeparatedByString:@" "];
                if (locationArray.count == 2) {
                    firstLevel = [AddressManager indexOfFirst:[locationArray firstObject]];
                    secondLevel = [AddressManager indexOfSecond:[locationArray lastObject] inFirst:[locationArray firstObject]];
                }
            }
            if (!firstLevel) {
                firstLevel = [NSNumber numberWithInteger:0];
            }
            if (!secondLevel) {
                secondLevel = [NSNumber numberWithInteger:0];
            }
            
            COUserRePositionController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserRePositionController"];
            popoverVC.type = @"所在地";
            popoverVC.infoAry = @[[AddressManager firstLevelArray], [AddressManager secondLevelMap]];
            popoverVC.selectedIndex = @[firstLevel, secondLevel];
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSArray *selectedIndex, NSArray *selectedValue) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.location = [selectedValue componentsJoinedByString:@" "];
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }   break;
        case 6:
        {   // 座右铭
            COUserReNameController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserReNameController"];
            popoverVC.type = @"座右铭";
            popoverVC.content = _user.slogan;
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSString *content) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.slogan = content;
                [weakself sendUpdateRequest];
            };

            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }   break;
        case 7:
        {   // 公司
            COUserReNameController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserReNameController"];
            popoverVC.type = @"公司";
            popoverVC.content = _user.company;
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSString *content) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.company = content;
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }   break;
        case 8:
        {   // 职位
            NSArray *jobNameArray = _curJobManager.jobNameArray;
            NSNumber *index = [_curJobManager indexOfJobName:_user.jobStr];
            
            COUserRePositionController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserRePositionController"];
            popoverVC.type = @"职位";
            popoverVC.infoAry = @[jobNameArray];
            popoverVC.selectedIndex = @[index];
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSArray *selectedIndex, NSArray *selectedValue) {
                weakself.request = [weakself getUpdateRequest];
                weakself.request.job = @([selectedIndex.firstObject integerValue] + 1);
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
        }  break;
        case 9:
        {   // 标签
            NSArray *selectedTags = nil;
            if (_user.tags && _user.tags.length > 0) {
                selectedTags = [_user.tags componentsSeparatedByString:@","];
            }
            
            COUserReTagController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserReTagController"];
            popoverVC.allTags = _curTagsManager.tagArray;
            popoverVC.selectedTags = selectedTags;
            
            __weak typeof(self) weakself = self;
            popoverVC.selectedBlock = ^(NSArray *selectedTags) {
                weakself.request = [weakself getUpdateRequest];
                
                NSString *tags = @"";
                if (selectedTags.count > 0) {
                    tags = [selectedTags componentsJoinedByString:@","];
                }
                weakself.request.tags = tags;
                [weakself sendUpdateRequest];
            };
            
            [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
        }   break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 40)];
    backView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(tableView.frame) - 40, 40)];
    titleLbl.textColor = [UIColor blackColor];
    titleLbl.font = [UIFont systemFontOfSize:14];
    titleLbl.text = @"详细信息";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLbl];
    return backView;
}

- (IBAction)nameBtnAction:(UIButton *)sender
{
    if (self.user.userId != [[[COSession session] user] userId]) {
        return;
    }
    
    COUserReNameController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserReNameController"];
    popoverVC.type = @"用户名";
    popoverVC.content = _nameLabel.text;
    
    __weak typeof(self) weakself = self;
    popoverVC.selectedBlock = ^(NSString *content) {
        weakself.request = [weakself getUpdateRequest];
        weakself.request.name = content;
        [weakself sendUpdateRequest];
    };
    
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
}

- (IBAction)avatarBtnAction:(UIButton *)sender
{
    if (self.user.userId != [[[COSession session] user] userId]) {
        return;
    }
    
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.minCount = 1;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.delegate = self;
    [pickerVc show];
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    ZLPhotoAssets *imageInfo = assets[0];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageInfo];
//    CGSize maxSize = CGSizeMake(800, 800);
//    if (imageInfo.thumbImage.size.width > maxSize.width || imageInfo.thumbImage.size.height > maxSize.height) {
//        imageInfo.thumbImage = [imageInfo.thumbImage scaleToSize:maxSize usingMode:NYXResizeModeAspectFit];
//    }
    [self showProgressHudWithMessage:@"正在上传头像"];
    __weak typeof(self) weakself = self;
    COAccountUpdateAvatarRequest *request = [COAccountUpdateAvatarRequest request];
    [request uploadImage:photo.thumbImage//TODO: 用不用原图
            successBlock:^(CODataResponse *responseObject) {
                      if ([weakself checkDataResponse:responseObject]) {
                          [weakself showSuccess:@"上传头像成功"];
                          [weakself.avatar setImage:photo.thumbImage];
                          //TODO: 用户信息刷新？左边头像刷新
                          [[COSession session] updateUserInfo];
                      }
                  } failureBlock:^(NSError *error) {
                      [weakself showErrorInHudWithError:error];
                  } progerssBlock:^(CGFloat progressValue) {
                      
                  }];
}

- (void)pickerCollectionViewSelectCamera:(ZLPhotoPickerViewController *)pickerVc
{
    // 点击Cell通知拍照代理
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    [pickerVc presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
//        CGSize maxSize = CGSizeMake(800, 800);
//        if (editedImage.size.width > maxSize.width || editedImage.size.height > maxSize.height) {
//            editedImage = [editedImage scaleToSize:maxSize usingMode:NYXResizeModeAspectFit];
//        }
        
        COAccountUpdateAvatarRequest *request = [COAccountUpdateAvatarRequest request];
        
        [self showProgressHudWithMessage:@"正在上传头像"];
        __weak typeof(self) weakself = self;
        [request uploadImage:editedImage
                successBlock:^(CODataResponse *responseObject) {
                    if ([weakself checkDataResponse:responseObject]) {
                        [weakself showSuccess:@"上传头像成功"];
                        [weakself.avatar setImage:editedImage];
                        //TODO: 用户信息刷新？左边头像刷新
                    }
                } failureBlock:^(NSError *error) {
                    [weakself showErrorInHudWithError:error];
                } progerssBlock:^(CGFloat progressValue) {
                    
                }];
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
            UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"请在真机使用!");
    }
}

#pragma mark - save image

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        [self showSuccess:@"成功保存到相册"];
    } else {
        [self showErrorWithStatus:@"保存失败"];
    }
}

@end

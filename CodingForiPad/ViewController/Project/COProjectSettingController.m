//
//  COProjectSettingController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectSettingController.h"
#import "COProject.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COProjectRequest.h"
#import "UIImage+Common.h"
#import "CORootViewController.h"
#import "UIActionSheet+Common.h"
#import "CODataRequest+Image.h"

@implementation UIViewController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end

@implementation UIImagePickerController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end


@interface COProjectSettingController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation COProjectSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.icon.layer.cornerRadius = 2;
    self.icon.layer.masksToBounds = YES;
    
    if (_project) {
        [self.icon sd_setImageWithURL:[COUtility urlForImage:_project.icon] placeholderImage:[COUtility placeHolder]];
        self.pathLabel.text = [NSString stringWithFormat:@"%@/%@", _project.ownerUserName, _project.name];
        self.textView.text = _project.desc;
    }
    else {
        self.textView.text = @"";
    }
    
    UITapGestureRecognizer *tapProjectImageViewGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProjectImage)];
    [self.icon addGestureRecognizer:tapProjectImageViewGR];
    self.icon.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectProjectImage
{
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"选择照片" buttonTitles:@[@"拍照", @"从相册选择"] destructiveTitle:nil cancelTitle:@"" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 1) {
            // 相册选择
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            picker.allowsEditing = YES;
            [[CORootViewController currentRoot] presentViewController:picker animated:YES completion:nil];
        }
        else if (index == 0) {
            // 拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.delegate = self;
                picker.allowsEditing = YES;
                [[CORootViewController currentRoot] presentViewController:picker animated:YES completion:nil];
            }
        }
    }];
    
    [sheet showInView:self.view];
}

#pragma mark - action
- (IBAction)saveBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([self.textView.text length] == 0) {
        [self showAlert:@"错误" message:@"请输入描述"];
        return;
    }
    
    if ([self.textView.text isEqualToString:_project.desc]) {
        return;
    }
    
    COProjectUpdateRequest *request = [COProjectUpdateRequest request];
    request.projectId = @(_project.projectId);
    request.projectName = _project.name;
    request.projectDesc = _textView.text;
    
    [self showProgressHud];
    __weak typeof(self) weakself = self;
    [request putWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"修改成功"];
            weakself.project.desc = self.textView.text;
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (IBAction)settingBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];

}

- (IBAction)backAction:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"projectAdvaceSetting"]) {
        [segue.destinationViewController setValue:_project forKey:@"project"];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
    COProjectUpdateIconRequest *request = [COProjectUpdateIconRequest request];
    request.projectId = @(_project.projectId);
        
    [self showProgressHudWithMessage:@"正在上传项目图标"];
    __weak typeof(self) weakself = self;
    UIImage *simg = [editedImage scaledToSize:CGSizeMake(300.0, 300.0)];
    [request uploadImage:simg successBlock:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"更新项目图标成功"];
            [weakself.icon setImage:editedImage];

            self.project.icon = responseObject.data[@"icon"];
            [[[SDWebImageManager sharedManager] imageCache] storeImage:simg forKey:self.project.icon];
            [[NSNotificationCenter defaultCenter] postNotificationName:OPProjectListReloadNotification object:nil userInfo:@{@"projectID" : @(weakself.project.projectId), @"icon" : weakself.project.icon}];
        }
    } failureBlock:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    } progerssBlock:^(CGFloat progressValue) {
                    
    }];
        
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

@end

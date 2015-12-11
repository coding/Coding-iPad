//
//  COAddProjectController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddProjectController.h"
#import "COPlaceHolderTextView.h"
#import "CORootViewController.h"
#import "COProjectRequest.h"
#import "UIViewController+Utility.h"
#import "ZLPhoto.h"
#import "UIButton+WebCache.h"
#import "COProjectController.h"

@interface COAddProjectController () <ZLPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *nameView;
@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *describeView;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIImage *projectIconImage;

@end

@implementation COAddProjectController

+ (void)popSelf
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    COAddProjectController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"COAddProjectController"];
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_nameView setPlaceholder:@"项目名称"];
    [_describeView setPlaceholder:@"项目描述"];
    
    _segmentedControl.selectedSegmentIndex = 0;
    
    _okBtn.enabled = FALSE;
    
    static NSString *projectIconURLString = @"https://coding.net/static/project_icon/scenery-%d.png";
    int x = arc4random() % 24 + 1;
    NSString *randomIconURLString = [NSString stringWithFormat:projectIconURLString,x];
    [_imageBtn sd_setImageWithURL:[NSURL URLWithString:randomIconURLString] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder_coding_square_55"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.projectIconImage = image;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility getKeyboardHeight:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, 64, kPopWidth, kPopHeight);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, (kScreen_Height - kPopHeight) / 2, kPopWidth, kPopHeight);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (textView == _nameView) {
            [_describeView becomeFirstResponder];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _okBtn.enabled = FALSE;
    if (_nameView.text.length > 1) {
        _okBtn.enabled = TRUE;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
   
    NSString *projectName = [_nameView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([projectName length] < 2 || [projectName length] > 31) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入2 ~ 31位以内的项目名称" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
        return;
    }
    if (![self projectNameVerification:projectName]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"项目名只允许字母、数字或者下划线(_)、中划线(-)，必须以字母或者数字开头,且不能以.git结尾" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
    }
    
    NSDictionary *fileDic = nil;
    if (_projectIconImage) {
        fileDic = @{@"image":_projectIconImage,@"name":@"icon",@"fileName":@"icon.jpg"};
    }
    
    // 发布项目
    [self showProgressHudWithMessage:@"正在创建项目"];
    COProjectCreateRequest *request = [COProjectCreateRequest request];
    request.name = projectName;
    request.desc = [_describeView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    request.type = _segmentedControl.selectedSegmentIndex == 0 ? 2 : 1;
    request.gitEnabled = @"true";
    request.gitReadmeEnabled = @"true";
    request.gitIgnore = @"no";
    request.gitLicense = @"no";
    //request.importFrom = @"no";
    request.vcsType = @"git";
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself dismissProgressHud];
            if ([weakself checkDataResponse:responseObject]) {
                [weakself showSuccess:@"项目创建成功~"];
                [[CORootViewController currentRoot] dismissPopover];
                [[NSNotificationCenter defaultCenter] postNotificationName:OPProjectReloadNotification object:nil userInfo:@{@"data":responseObject.data}];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself dismissProgressHud];
            [weakself showError:error];
        });
    } file:fileDic];
}

- (IBAction)imageBtnAction:(UIButton *)sender
{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.minCount = 1;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.delegate = self;
    [pickerVc show];
}

- (BOOL)projectNameVerification:(NSString *)projectName
{
    NSString * regex = @"^[a-zA-Z0-9][a-zA-Z0-9_-]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:projectName];
    return isMatch;
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    ZLPhotoAssets *imageInfo = assets[0];
    [_imageBtn setImage:imageInfo.thumbImage forState:UIControlStateNormal];
    self.projectIconImage = imageInfo.originImage;
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
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [_imageBtn setImage:originalImage forState:UIControlStateNormal];
        self.projectIconImage = originalImage;
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
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

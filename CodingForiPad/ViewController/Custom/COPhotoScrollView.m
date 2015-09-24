//
//  OPPhotoScrollView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COPhotoScrollView.h"
#import "ZLPhoto.h"
#import "UIButton+WebCache.h"

#define kPhotoBtnSpeace 20

@interface COPhotoScrollView () <ZLPhotoPickerViewControllerDelegate, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray *_photoBtnAry;
    CGFloat _btnWH;
}

@property (nonatomic, copy) NSString *addBtnStr;

@end

@implementation COPhotoScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self initUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.contentSize = self.frame.size;
}

- (void)initUI
{
    _photoBtnAry = @[].mutableCopy;
    self.imageAry = @[].mutableCopy;
    _btnWH = 60;
    _addBtnStr = @"icon_add_pic";
    
    [self resetUI];
}

- (void)delBtnClick:(UIButton *)sender
{
    UIAlertView *removeAlert = [[UIAlertView alloc]
                                initWithTitle:@"确定要删除此图片？"
                                message:nil
                                delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"确定", nil];
    removeAlert.tag = sender.tag;
    [removeAlert show];
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSInteger index = 1999;
        [_imageAry removeObjectAtIndex:alertView.tag - index];
        if (_photoDelegate) {
            [_photoDelegate photoChanged:_imageAry];
        }
        [self resetUI];
    }
}

#pragma mark - 选择相册
- (void)selectPhotosBtnClick:(UIButton *)sender
{
    UIButton *btn = [_photoBtnAry lastObject];
    if (_imageAry.count == kPhotoMax || sender.tag != btn.tag) {
        [self setupPhotoBrowser:sender.tag - 999];
    } else {
        [self setupPhotoPicker];
    }
}

- (BOOL)setupPhotoPicker
{
    if (_imageAry.count < kPhotoMax) {
        ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
        pickerVc.topShowPhotoPicker = YES;
        pickerVc.minCount = kPhotoMax - _imageAry.count;
        pickerVc.status = PickerViewShowStatusCameraRoll;
        pickerVc.delegate = self;
        [pickerVc show];
        return TRUE;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您已经选满了图片呦." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
    }
    return FALSE;
}

- (void)setupPhotoBrowser:(NSInteger)curIndex
{
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = YES;
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:curIndex inSection:0];
    [pickerBrowser show];
}

- (void)resetUI
{
    for (NSLayoutConstraint *con in self.constraints) {
        if (con.firstAttribute == NSLayoutAttributeHeight) {
            con.constant = _imageAry.count > 3 ? 150 : (_imageAry.count > 0 ? 80 : 0);
        }
    }
    
    NSInteger btnCount = _imageAry.count < kPhotoMax ? (_imageAry.count > 0 ? _imageAry.count + 1 : 0) : kPhotoMax;
    while (_photoBtnAry.count > btnCount) {
        UIButton *btn = [_photoBtnAry lastObject];
        UIButton *delBtn = (UIButton *)[self viewWithTag:btn.tag + 1000];
        [delBtn removeFromSuperview];
        [btn removeFromSuperview];
        [_photoBtnAry removeLastObject];
    }
    
    NSInteger curBtnCount = _photoBtnAry.count;
    for (NSInteger i = curBtnCount; i < btnCount; i++) {
        CGFloat y = 10;
        CGFloat x = kPhotoBtnSpeace + i * (_btnWH + kPhotoBtnSpeace);
        if (i >= 4) {
            y += _btnWH + 10;
            x = kPhotoBtnSpeace + (i - 4) * (_btnWH + kPhotoBtnSpeace);
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, _btnWH, _btnWH)];

        UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(x + _btnWH - 20, y - 10, 40, 30)];
        [delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
        [delBtn setImage:[UIImage imageNamed:@"icon_cancel"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn addTarget:self action:@selector(selectPhotosBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        delBtn.tag = 1999 + i;
        btn.tag = 999 + i;
        [self addSubview:btn];
        [self addSubview:delBtn];
        [_photoBtnAry addObject:btn];
    }
   
    if (_imageAry.count < kPhotoMax) {
        UIButton *btn = [_photoBtnAry lastObject];
        [btn setImage:[UIImage imageNamed:_addBtnStr] forState:UIControlStateNormal];
        [self viewWithTag:btn.tag + 1000].hidden = TRUE;
    }

    NSInteger index = 999;
    for (ZLPhotoAssets *imageInfo in _imageAry) {
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [self viewWithTag:btn.tag + 1000].hidden = FALSE;
        // 判断类型来获取Image
        if ([imageInfo isKindOfClass:[ZLPhotoAssets class]]) {
            [btn setImage:imageInfo.thumbImage forState:UIControlStateNormal];
        } else if ([imageInfo isKindOfClass:[NSString class]]){
            [btn sd_setImageWithURL:[NSURL URLWithString:(NSString *)imageInfo] forState:UIControlStateNormal placeholderImage:nil];
        } else if([imageInfo isKindOfClass:[UIImage class]]){
            [btn setImage:(UIImage *)imageInfo forState:UIControlStateNormal];
        }
        index++;
    }
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    [_imageAry addObjectsFromArray:assets];
    while (_imageAry.count > kPhotoMax) {
        [_imageAry removeLastObject];
    }
    if (_photoDelegate) {
        [_photoDelegate photoChanged:_imageAry];
    }
    [self resetUI];
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
        [_imageAry addObject:originalImage];
        if (_photoDelegate) {
            [_photoDelegate photoChanged:_imageAry];
        }
        [self resetUI];
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"请在真机使用!");
    }
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDelegate
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除照片时调用
    if (indexPath.row > [_imageAry count]) return;
    [_imageAry removeObjectAtIndex:indexPath.row];
    if (_photoDelegate) {
        [_photoDelegate photoChanged:_imageAry];
    }
    [self resetUI];
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    return _imageAry.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 999;
    UIButton *btn = (UIButton *)[self viewWithTag:index + indexPath.row];
    
    ZLPhotoAssets *imageInfo = [_imageAry objectAtIndex:indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageInfo];
    photo.toView = btn;
    return photo;
}

@end

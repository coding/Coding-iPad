//
//  EaseMarkdownTextView.m
//  Coding_iOS
//
//  Created by Ease on 15/2/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EaseMarkdownTextView.h"
#import "RFKeyboardToolbar.h"
#import "RFToolbarButton.h"
#import <RegexKitLite/RegexKitLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "COUser.h"
#import "COProject.h"

#import "Coding_FileManager.h"
#import <SVProgressHUD.h>
#import "NSDate+Helper.h"
#import "ZLPhoto.h"

#define kNotificationUploadCompled @"notification_upload_compled"

@interface EaseMarkdownTextView () <ZLPhotoPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSString *uploadingPhotoName;

@end


@implementation EaseMarkdownTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.inputAccessoryView = [RFKeyboardToolbar toolbarWithButtons:[self buttons]];
    
    //监听-上传文件成功
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        //{NSURLResponse: response, NSError: error, ProjectFile: data}
        NSDictionary *userInfo = [aNotification userInfo];
        [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
    }];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.inputAccessoryView = [RFKeyboardToolbar toolbarWithButtons:[self buttons]];
        
        //监听-上传文件成功
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
            //{NSURLResponse: response, NSError: error, ProjectFile: data}
            NSDictionary *userInfo = [aNotification userInfo];
            [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
        }];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSString *actionName = NSStringFromSelector(action);
    if ([actionName isEqualToString:@"_addShortcut:"]) {
        return NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (NSArray *)buttons
{
    return @[
             [self createButtonWithTitle:@"@" andEventHandler:^{ [self doAT]; }],
             
             [self createButtonWithTitle:@"#" andEventHandler:^{ [self insertText:@"#"]; }],
             [self createButtonWithTitle:@"*" andEventHandler:^{ [self insertText:@"*"]; }],
             [self createButtonWithTitle:@"`" andEventHandler:^{ [self insertText:@"`"]; }],
             [self createButtonWithTitle:@"-" andEventHandler:^{ [self insertText:@"-"]; }],
             
             [self createButtonWithTitle:@"照片" andEventHandler:^{ [self doPhoto]; }],
             
             [self createButtonWithTitle:@"标题" andEventHandler:^{ [self doTitle]; }],
             [self createButtonWithTitle:@"粗体" andEventHandler:^{ [self doBold]; }],
             [self createButtonWithTitle:@"斜体" andEventHandler:^{ [self doItalic]; }],
             [self createButtonWithTitle:@"代码" andEventHandler:^{ [self doCode]; }],
             [self createButtonWithTitle:@"引用" andEventHandler:^{ [self doQuote]; }],
             [self createButtonWithTitle:@"列表" andEventHandler:^{ [self doList]; }],
             
             [self createButtonWithTitle:@"链接" andEventHandler:^{
                 NSString *tipStr = @"在此输入链接地址";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 5;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"[链接](%@)", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"图片链接" andEventHandler:^{
                 NSString *tipStr = @"在此输入图片地址";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 6;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"![图片](%@)", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"分割线" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 NSString *insertStr = [self needPreNewLine]? @"\n\n------\n": @"\n------\n";
                 
                 selectionRange.location += insertStr.length;
                 selectionRange.length = 0;
                 
                 [self insertText:insertStr];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"_" andEventHandler:^{ [self insertText:@"_"]; }],
             [self createButtonWithTitle:@"+" andEventHandler:^{ [self insertText:@"+"]; }],
             [self createButtonWithTitle:@"~" andEventHandler:^{ [self insertText:@"~"]; }],
             [self createButtonWithTitle:@"=" andEventHandler:^{ [self insertText:@"="]; }],
             [self createButtonWithTitle:@"[" andEventHandler:^{ [self insertText:@"["]; }],
             [self createButtonWithTitle:@"]" andEventHandler:^{ [self insertText:@"]"]; }],
             [self createButtonWithTitle:@"<" andEventHandler:^{ [self insertText:@"<"]; }],
             [self createButtonWithTitle:@">" andEventHandler:^{ [self insertText:@">"]; }]
             ];
}

- (BOOL)needPreNewLine
{
    NSString *preStr = [self.text substringToIndex:self.selectedRange.location];
    return !(preStr.length == 0
            || [preStr isMatchedByRegex:@"[\\n\\r]+[\\t\\f]*$"]);
}

- (RFToolbarButton *)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler
{
    return [RFToolbarButton buttonWithTitle:title andEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelectionRange:(NSRange)range
{
    UIColor *previousTint = self.tintColor;
    
    self.tintColor = UIColor.clearColor;
    self.selectedRange = range;
    self.tintColor = previousTint;
}

#pragma mark md_Method
- (void)doTitle
{
    [self doMDWithLeftStr:@"## " rightStr:@" ##" tipStr:@"在此输入标题" doNeedPreNewLine:YES];
}

- (void)doBold
{
    [self doMDWithLeftStr:@"**" rightStr:@"**" tipStr:@"在此输入粗体文字" doNeedPreNewLine:NO];
}

- (void)doItalic
{
    [self doMDWithLeftStr:@"*" rightStr:@"*" tipStr:@"在此输入斜体文字" doNeedPreNewLine:NO];
}

- (void)doCode
{
    [self doMDWithLeftStr:@"```\n" rightStr:@"\n```" tipStr:@"在此输入代码片段" doNeedPreNewLine:YES];
}

- (void)doQuote
{
    [self doMDWithLeftStr:@"> " rightStr:@"" tipStr:@"在此输入引用文字" doNeedPreNewLine:YES];
}

- (void)doList
{
    [self doMDWithLeftStr:@"- " rightStr:@"" tipStr:@"在此输入列表项" doNeedPreNewLine:YES];
}

- (void)doMDWithLeftStr:(NSString *)leftStr
               rightStr:(NSString *)rightStr
                 tipStr:(NSString *)tipStr
       doNeedPreNewLine:(BOOL)doNeedPreNewLine
{
    BOOL needPreNewLine = doNeedPreNewLine? [self needPreNewLine]: NO;
    
    if (!leftStr || !rightStr || !tipStr) {
        return;
    }
    NSRange selectionRange = self.selectedRange;
    NSString *insertStr = [self.text substringWithRange:selectionRange];
    
    if (selectionRange.length > 0) {//已有选中文字
        //撤销
        if (selectionRange.location >= leftStr.length && selectionRange.location + selectionRange.length + rightStr.length <= self.text.length) {
            NSRange expandRange = NSMakeRange(selectionRange.location- leftStr.length, selectionRange.length +leftStr.length +rightStr.length);
            expandRange = [self.text rangeOfString:[NSString stringWithFormat:@"%@%@%@", leftStr, insertStr, rightStr] options:NSLiteralSearch range:expandRange];
            if (expandRange.location != NSNotFound) {
                selectionRange.location -= leftStr.length;
                selectionRange.length = insertStr.length;
                [self setSelectionRange:expandRange];
                [self insertText:insertStr];
                [self setSelectionRange:selectionRange];
                return;
            }
        }
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, insertStr, rightStr];
    } else {//未选中任何文字
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        selectionRange.length = tipStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, tipStr, rightStr];
    }
    [self insertText:insertStr];
    [self setSelectionRange:selectionRange];
}

#pragma mark AT
- (void)doAT
{
    if (self.curProject) {
        // @项目成员
        if (_atBlock) {
            _atBlock();
        }
    }
}

#pragma mark Photo
- (void)doPhoto
{
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
    // 上传照片
    if (assets.count > 0) {
        ZLPhotoAssets *imageInfo = assets[0];
        [self doUploadPhoto:imageInfo.originImage];
    }
}

- (void)pickerCollectionViewSelectCamera:(ZLPhotoPickerViewController *)pickerVc
{
    // 点击Cell通知拍照代理
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    [pickerVc presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && originalImage) {
        UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
    }

    // 上传照片
    [picker dismissViewControllerAnimated:YES completion:^{
        if (originalImage) {
            [self doUploadPhoto:originalImage];
        }
    }];
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

- (void)doUploadPhoto:(UIImage *)image
{
    //保存到app内
    NSString *dateMarkStr = [[NSDate date] stringWithFormat:@"yyyyMMdd_HHmmss"];
    NSString *originalFileName = [NSString stringWithFormat:@"%@.jpg", dateMarkStr];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.curProject.projectId, @"0", originalFileName];
    if ([Coding_FileManager writeUploadDataWithName:fileName andImage:image]) {
        [SVProgressHUD showProgress:0 status:@"正在上传图片..." maskType:SVProgressHUDMaskTypeBlack];
        self.uploadingPhotoName = originalFileName;
        Coding_UploadTask *uploadTask =[[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:_curProject.isPublic];
        [RACObserve(uploadTask, progress.fractionCompleted) subscribeNext:^(NSNumber *fractionCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:MAX(0, fractionCompleted.floatValue-0.05) status:@"正在上传图片..." maskType:SVProgressHUDMaskTypeBlack];
            });
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ 文件处理失败", originalFileName] maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (void)completionUploadWithResult:(id)responseObject error:(NSError *)error
{
    [SVProgressHUD dismiss];
    
    //移除文件（共有项目不能自动移除）
    NSString *diskFileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.curProject.projectId, @"0", self.uploadingPhotoName];
    [Coding_FileManager deleteUploadDataWithName:diskFileName];

    if (!responseObject) {
        return;
    }
    NSString *fileName = nil, *fileUrlStr = @"";
    if ([responseObject isKindOfClass:[NSString class]]) {
        fileUrlStr = responseObject;
    } else if ([responseObject isKindOfClass:[COFile class]]) {
        COFile *curFile = responseObject;
        fileName = curFile.name;
        fileUrlStr = curFile.ownerPreview;
    }
    if (!fileName || [fileName isEqualToString:self.uploadingPhotoName]) {
        //插入文字
        NSString *photoLinkStr = [NSString stringWithFormat:[self needPreNewLine]? @"\n![图片](%@)\n": @"![图片](%@)\n", fileUrlStr];
        [self insertText:photoLinkStr];
        [self becomeFirstResponder];
    }
}

@end

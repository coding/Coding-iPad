//
//  COCreateFolderViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCreateFolderViewController.h"
#import "CORootViewController.h"
#import "COFileRequest.h"
#import "COFileViewController.h"

@interface COCreateFolderViewController ()

@end

@implementation COCreateFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_rename) {
        _nameField.text = _content;
        _titleLabel.text = @"重命名文件夹";
    }
    else {
        _titleLabel.text = @"新建文件夹";
    }
    
    [_nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChange:(UITextField *)textField
{
    _doneBtn.enabled = FALSE;
    if (textField.text.length > 0 && ![textField.text isEqualToString:_content]) {
        _doneBtn.enabled = TRUE;
    }
}

- (IBAction)cancelAction:(id)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)doneAction:(id)sender
{
    if (_rename) {
        CORenameFolderRequest *request = [CORenameFolderRequest request];
        request.projectId = _projectId;
        request.folderId = _parentId;
        request.name = _nameField.text;
        
        __weak typeof(self) weakself = self;
        [request putWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:COReloadFileNotification object:nil];
                [[CORootViewController currentRoot] dismissPopover];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
    else {
        COCreateFolderRequest *request = [COCreateFolderRequest request];
        request.projectId = _projectId;
        request.parentId = _parentId;
        request.name = _nameField.text;
        
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:COReloadFileNotification object:nil];
                [[CORootViewController currentRoot] dismissPopover];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}

@end

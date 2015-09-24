//
//  COTopicLabelReNameController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicLabelResetController.h"
#import "COTopicRequest.h"
#import "COTopic.h"
#import "UIViewController+Utility.h"

@interface COTopicLabelResetController ()

@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation COTopicLabelResetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _textField.text = _ptLabel.name;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _okBtn.enabled = FALSE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    sender.enabled = FALSE;
    COProjectTopicLabelMedifyRequest *reqeust = [COProjectTopicLabelMedifyRequest request];
    reqeust.projectOwnerName = _topic.project.ownerUserName;
    reqeust.projectName = _topic.project.name;
    reqeust.labelId = @(_ptLabel.topicLabelId);
    reqeust.name = _textField.text;
    reqeust.color = _ptLabel.color;
    __weak typeof(self) weakself = self;
    [reqeust putWithSuccess:^(CODataResponse *responseObject) {
        sender.enabled = TRUE;
        if ([weakself checkDataResponse:responseObject]) {
            if (weakself.topicChangedBlock) {
                weakself.topicChangedBlock(weakself.ptLabel);
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        sender.enabled = TRUE;
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    _okBtn.enabled = textField.text.length > 0 && ![textField.text isEqualToString:_ptLabel.name] ? TRUE : FALSE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end

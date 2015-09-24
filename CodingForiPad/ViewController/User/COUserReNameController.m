//
//  COUserReNameController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserReNameController.h"
#import "CORootViewController.h"
#import "COUserReNameCell.h"

@interface COUserReNameController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation COUserReNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleLabel.text = _type;
    _okBtn.enabled = FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    // 发送修改
    if (_selectedBlock) {
        COUserReNameCell *cell = (COUserReNameCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        _selectedBlock(cell.textField.text);
    }
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COUserReNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COUserReNameCell"];
    
    cell.textField.text = _content;
    cell.textField.delegate = self;
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    return cell;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    _okBtn.enabled = FALSE;
    if (textField.text.length > 0 && ![textField.text isEqualToString:_content]) {
        _okBtn.enabled = TRUE;
    }
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

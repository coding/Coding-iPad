//
//  COUserBirthdateController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserBirthdateController.h"
#import "CORootViewController.h"

@interface COUserBirthdateController ()

@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation COUserBirthdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_datePicker setDate:self.selectedDate animated:NO];
    [_datePicker addTarget:self action:@selector(eventForDatePicker:) forControlEvents:UIControlEventValueChanged];

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
        _selectedBlock(_datePicker.date);
    }
    [[CORootViewController currentRoot] dismissPopover];
}

- (void)eventForDatePicker:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    _okBtn.enabled = ![self.selectedDate isEqualToDate:datePicker.date];
}

@end

//
//  COUserRePositionController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserRePositionController.h"
#import "CORootViewController.h"

@interface COUserRePositionController ()

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation COUserRePositionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (NSInteger i=0; i<_selectedIndex.count; i++) {
        [_pickerView selectRow:[_selectedIndex[i] integerValue] inComponent:i animated:NO];
    }
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
        NSMutableArray *selectedIndex = @[].mutableCopy;
        NSMutableArray *selectedValue = @[].mutableCopy;
        NSArray *ary = _infoAry[0];
        NSString *selectedStr = ary[[_pickerView selectedRowInComponent:0]];
        [selectedIndex addObject:@([_pickerView selectedRowInComponent:0])];
        [selectedValue addObject:selectedStr];
        for (NSInteger i = 0; i < _infoAry.count - 1; i++) {
            NSDictionary *dic = _infoAry[i + 1];
            ary = [dic objectForKey:selectedStr];
            selectedStr = ary[[_pickerView selectedRowInComponent:i + 1]];
            [selectedIndex addObject:@([_pickerView selectedRowInComponent:i + 1])];
            [selectedValue addObject:selectedStr];
        }
        _selectedBlock(selectedIndex, selectedValue);
    }
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _infoAry.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *ary = _infoAry[0];
    NSString *selectedStr = ary[[pickerView selectedRowInComponent:0]];
    for (NSInteger i = 0; i < component; i++) {
        NSDictionary *dic = _infoAry[i + 1];
        ary = [dic objectForKey:selectedStr];
        selectedStr = ary[[pickerView selectedRowInComponent:i + 1]];
    }
    return ary.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *ary = _infoAry[0];
    NSString *selectedStr = ary[[pickerView selectedRowInComponent:0]];
    for (NSInteger i = 0; i < component; i++) {
        NSDictionary *dic = _infoAry[i + 1];
        ary = [dic objectForKey:selectedStr];
        selectedStr = ary[[pickerView selectedRowInComponent:i + 1]];
    }
    return ary[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component + 1 < _selectedIndex.count) {
        NSArray *ary = _infoAry[0];
        NSString *selectedStr = ary[[pickerView selectedRowInComponent:0]];
        for (NSInteger i = 0; i < component + 1; i++) {
            NSDictionary *dic = _infoAry[i + 1];
            ary = [dic objectForKey:selectedStr];
            if ([pickerView selectedRowInComponent:i + 1] >= ary.count) {
                [_pickerView selectRow:ary.count - 1 inComponent:component + 1 animated:NO];
            }
            selectedStr = ary[[pickerView selectedRowInComponent:i + 1]];
            [pickerView reloadComponent:i + 1];
        }
    }
    _okBtn.enabled = FALSE;
    if ([_selectedIndex[component] integerValue] != row) {
        _okBtn.enabled = TRUE;
        return;
    };
    for (NSInteger i=0; i<_selectedIndex.count; i++) {
        if ([_selectedIndex[i] integerValue] != [_pickerView selectedRowInComponent:i]) {
            _okBtn.enabled = TRUE;
            break;
        };
    }
}

@end

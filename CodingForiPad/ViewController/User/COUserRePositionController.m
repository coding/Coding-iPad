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
@property (strong, nonatomic) NSMutableArray *selectionArray;

@end

@implementation COUserRePositionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *ary = _infoAry[0];
    NSString *selectedStr = ary[[_selectedIndex[0] integerValue]];
    _selectionArray = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<_selectedIndex.count; i++) {
        if (i < (_selectedIndex.count - 1)) {
            NSDictionary *dic = _infoAry[i + 1];
            ary = [dic objectForKey:selectedStr];
            [_selectionArray addObject:@{selectedStr:ary}];
            selectedStr = ary[[_selectedIndex[i+1] integerValue]];
        } else {
            [_selectionArray addObject:@{selectedStr:@[]}];
        }
    }
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
        NSString *selectedStr = [[((NSDictionary *)_selectionArray[0]) allKeys] firstObject];
        [selectedIndex addObject:@([ary indexOfObject:selectedStr])];
        [selectedValue addObject:selectedStr];
        for (NSInteger i = 0; i < _infoAry.count - 1; i++) {
            NSDictionary *dic = _infoAry[i + 1];
            ary = [dic objectForKey:selectedStr];
            selectedStr = [[((NSDictionary *)_selectionArray[i+1]) allKeys] firstObject];
            [selectedIndex addObject:@([ary indexOfObject:selectedStr])];
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
    NSString *selectedStr = [[((NSDictionary *)_selectionArray[0]) allKeys] firstObject];
    for (NSInteger i = 0; i < component; i++) {
        NSDictionary *dic = _infoAry[i + 1];
        ary = [dic objectForKey:selectedStr];
        selectedStr = [[((NSDictionary *)_selectionArray[i]) allKeys] firstObject];
    }
    return ary.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *ary = _infoAry[0];
    NSString *selectedStr = [[((NSDictionary *)_selectionArray[0]) allKeys] firstObject];
    for (NSInteger i = 0; i < component; i++) {
        NSDictionary *dic = _infoAry[i + 1];
        ary = [dic objectForKey:selectedStr];
        selectedStr = [[((NSDictionary *)_selectionArray[i]) allKeys] firstObject];
    }
    return ary[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component + 1 < _selectedIndex.count) {
        NSArray *ary = _infoAry[0];
        NSString *selectedStr = (component == 0)?ary[row]:[[((NSDictionary *)_selectionArray[0]) allKeys] firstObject];
        for (NSInteger i = 0; i < component + 1; i++) {
            NSDictionary *dic = _infoAry[i + 1];
            ary = [dic objectForKey:selectedStr];
            _selectionArray[i] = @{selectedStr:ary};
            if ([pickerView selectedRowInComponent:i + 1] >= ary.count) {
                [_pickerView selectRow:ary.count - 1 inComponent:component + 1 animated:NO];
            }
            selectedStr = (component == i)?ary[0]:[[((NSDictionary *)_selectionArray[i]) allKeys] firstObject];
            [pickerView reloadComponent:i + 1];
        }
    } else {
        if (component == 0) {
            NSArray *ary = _infoAry[0];
            _selectionArray[0] = @{ary[row]:@[]};
        } else {
            NSString *selectedStr = [[((NSDictionary *)_selectionArray[component - 1]) allKeys] firstObject];
            NSDictionary *dic = _infoAry[component];
            NSArray *ary = [dic objectForKey:selectedStr];
            _selectionArray[component] = @{ary[row]:@[]};
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

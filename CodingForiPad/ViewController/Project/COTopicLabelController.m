//
//  COTopicLabelController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicLabelController.h"
#import "COTopicLabelCell.h"
#import "COTopicRequest.h"
#import "COTopic.h"
#import "UIViewController+Utility.h"
#import "UIActionSheet+Common.h"
#import "NSString+Emojize.h"
#import "COTopicDetailController.h"
#import "COTopicEditController.h"
#import "COTopicLabelResetController.h"

@interface COTopicLabelController () <UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *_tempLabel;
    NSMutableArray *_tempArray;
}

@property (strong, nonatomic) NSMutableArray *labels;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation COTopicLabelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _labels = [[NSMutableArray alloc] initWithCapacity:4];
    _tempArray = [NSMutableArray arrayWithArray:_topic.mdLabels];

    _textField.delegate = self;
    _textField.layer.cornerRadius = 4;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, _textField.frame.size.height)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _okBtn.enabled = FALSE;
    _addBtn.enabled = FALSE;
    
    [self loadTopicLabelInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTopicLabelInfo
{
    // 项目的所有标签及被使用计数
    COProjectTopicLabelsRequest *request = [COProjectTopicLabelsRequest request];
    request.projectId = _topic.projectId;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself parseLabelInfo:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
}

- (void)parseLabelInfo:(NSArray *)labelInfo
{
    [_labels removeAllObjects];
    [_labels addObjectsFromArray:labelInfo];
    for (COTopicLabel *lbl in _labels) {
        for (COTopicLabel *tLbl in _topic.mdLabels) {
            if (lbl.topicLabelId == tLbl.topicLabelId) {
                tLbl.name = lbl.name;
                break;
            }
        }
        for (COTopicLabel *tLbl in _tempArray) {
            if (lbl.topicLabelId == tLbl.topicLabelId) {
                tLbl.name = lbl.name;
                break;
            }
        }
    }
    [_tableView reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTopicLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTopicLabelCell" forIndexPath:indexPath];
    
    COTopicLabel *ptLabel = _labels[indexPath.row];
    cell.tagLabel.text = ptLabel.name;
    
    cell.selectedView.hidden = TRUE;
    for (COTopicLabel *lbl in _topic.mdLabels) {
        if (lbl.topicLabelId == ptLabel.topicLabelId) {
            cell.selectedView.hidden = FALSE;
            break;
        }
    }
   
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:[COTopicLabelCell cellHeight]];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    COTopicLabelCell *cell = (COTopicLabelCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selectedView.hidden = !cell.selectedView.hidden;
    
    COTopicLabel *lbl = _labels[indexPath.row];
    
    if (!cell.selectedView.hidden) {
        BOOL add = TRUE;
        for (COTopicLabel *tempLbl in _tempArray) {
            if (tempLbl.topicLabelId == lbl.topicLabelId) {
                add = FALSE;
                break;
            }
        }
        if (add) {
            [_tempArray addObject:lbl];
            _okBtn.enabled = YES;
        }
    } else {
        for (COTopicLabel *tempLbl in _tempArray) {
            if (tempLbl.topicLabelId == lbl.topicLabelId) {
                [_tempArray removeObject:tempLbl];
                _okBtn.enabled = YES;
                break;
            }
        }
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_model_settag_rename"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:255/255.0 green:69/255.0 blue:98/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_model_settag_delete"]];
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (index == 0) {
        [self renameBtnClick:indexPath.row];
    } else {
        [self deleteBtnClick:indexPath.row];
    }
}

- (void)renameBtnClick:(NSInteger)index
{
    COTopicLabelResetController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicLabelResetController"];
    vc.ptLabel = [_labels objectAtIndex:index];
    vc.topic = _topic;
    __weak typeof(self) weakself = self;
    vc.topicChangedBlock = ^(COTopicLabel *ptLabel) {
        for (COTopicLabel *label in weakself.topic.mdLabels) {
            if (label.topicLabelId == ptLabel.topicLabelId) {
                [weakself loadTopicLabelInfo];
                if (weakself.topicChangedBlock) {
                    weakself.topicChangedBlock();
                    break;
                }
            }
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteBtnClick:(NSInteger)labelIndex
{
    __weak typeof(self) weakself = self;
    COTopicLabel *ptLabel = [_labels objectAtIndex:labelIndex];
    NSString *tip = [NSString stringWithFormat:@"确定要删除标签:%@？", ptLabel.name];
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:tip buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
           
            COProjectTopicLabelDelRequest *request = [COProjectTopicLabelDelRequest request];
            request.projectId = @(_topic.projectId);
            request.labelId = @(ptLabel.topicLabelId);
            
            [request deleteWithSuccess:^(CODataResponse *responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakself checkDataResponse:responseObject]) {
                        [weakself deleteLabel:labelIndex];
                    }
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showError:error];
                });
            }];
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)deleteLabel:(NSInteger)index
{
    COTopicLabel *lbl = _labels[index];
    for (COTopicLabel *tempLbl in _tempArray) {
        if (tempLbl.topicLabelId == lbl.topicLabelId) {
            [_tempArray removeObject:tempLbl];
            _okBtn.enabled = YES;
            break;
        }
    }
    [self.labels removeObjectAtIndex:index];
    [self.tableView reloadData];
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    id controller = self.navigationController.parentViewController;
    if ([controller isKindOfClass:[COTopicDetailController class]]) {
        [((COTopicDetailController *)controller) dismissPopover];
    } else if ([controller isKindOfClass:[COTopicEditController class]]) {
        [((COTopicEditController *)controller) dismissPopover];
    }
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    _topic.mdLabels = _tempArray;
    
    _okBtn.enabled = NO;
    if (_isSaveChange) {
        
        __weak typeof(self) weakself = self;
        COProjectTopicLabelChangesRequest *request = [COProjectTopicLabelChangesRequest request];
        request.projectName = _topic.project.name;
        request.topicId = @(_topic.topicId);
        request.projectOwnerName = _topic.project.ownerUserName;
        
        NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_topic.mdLabels.count];
        for (COTopicLabel *lbl in _topic.mdLabels) {
            [tempAry addObject:@(lbl.topicLabelId)];
        }
        request.labelIds = [tempAry componentsJoinedByString:@","];
 
        [request postWithSuccess:^(CODataResponse *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _okBtn.enabled = YES;
                if ([weakself checkDataResponse:responseObject]) {
                    _topic.labels = [NSMutableArray arrayWithArray:_topic.mdLabels];
                    if (self.topicChangedBlock) {
                        self.topicChangedBlock();
                    }
                    [self cancelBtnAction:nil];
                }
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself showError:error];
            });
        }];
    } else {
        if (self.topicChangedBlock) {
            self.topicChangedBlock();
        }
        [self cancelBtnAction:nil];
    }
}

- (IBAction)addBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (_tempLabel.length > 0) {
        __weak typeof(self) weakSelf = self;
        
        COProjectTopicLabelAddRequest *request = [COProjectTopicLabelAddRequest request];
        request.projectId = _topic.projectId;
        request.name = [_tempLabel aliasedString];
        request.color = @"#d8f3e4";
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself checkDataResponse:responseObject]) {
                    COTopicLabel *ptLabel = [[COTopicLabel alloc] init];
                    ptLabel.name = _tempLabel;
                    ptLabel.topicLabelId = [responseObject.data integerValue];
                    ptLabel.ownerId = _topic.projectId;
                    ptLabel.color = @"#d8f3e4";
                    [weakSelf.labels addObject:ptLabel];
                    [weakSelf.tableView reloadData];
                    _tempLabel = @"";
                    weakSelf.textField.text = @"";
                    [weakSelf showSuccess:@"添加标签成功^^"];
                    sender.enabled = FALSE;
                }
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself showError:error];
            });
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    _tempLabel = textField.text;
    BOOL enabled = _tempLabel.length > 0 ? TRUE : FALSE;
    if (enabled) {
        for (COTopicLabel *lbl in _labels) {
            if ([lbl.name isEqualToString:_tempLabel]) {
                enabled = FALSE;
                break;
            }
        }
    }
    
    _addBtn.enabled = enabled;
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

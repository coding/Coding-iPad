//
//  COCreateFolderViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"

@interface COCreateFolderViewController : COBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) NSNumber *projectId;
@property (nonatomic, copy) NSNumber *parentId;

@property (nonatomic, assign) BOOL rename;
@property (nonatomic, copy) NSString *content;

@end

//
//  COFileMoveViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileBaseViewController.h"

@interface COFileMoveViewController : COFileBaseViewController

@property (nonatomic, strong) NSArray *srcFiles;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UIButton *moveBtn;

@end

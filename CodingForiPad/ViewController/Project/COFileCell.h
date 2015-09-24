//
//  COFileCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COFolder.h"
#import "SWTableViewCell.h"
#import "ASProgressPopUpView.h"

typedef void(^COFileCellShowBlock)(COFile *file);

@interface COFileCell : SWTableViewCell<ASProgressPopUpViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;

@property (nonatomic, copy) COFileCellShowBlock showBlock;

@property (strong, nonatomic) ASProgressPopUpView *progressView;
@property (strong, nonatomic) NSProgress *progress;

- (void)assignWithFile:(COFile *)file projectId:(NSInteger)projectId;

@end
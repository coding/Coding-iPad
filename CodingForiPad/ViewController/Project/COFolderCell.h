//
//  COFolderCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COFolder.h"
#import "SWTableViewCell.h"

@interface COFolderCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)assignWithFoler:(COFolder *)folder count:(NSInteger)count;

@end

//
//  COReportIllegalViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

@interface COIllegalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;

@end

@interface COReportIllegalViewController : COBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (nonatomic, strong) NSString *content;

@end

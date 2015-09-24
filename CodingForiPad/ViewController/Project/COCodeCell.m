//
//  COCodeCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCodeCell.h"
#import "COUtility.h"

@implementation COCodeCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithGitFile:(COGitFile *)file
{
    if ([file.mode isEqualToString:@"tree"]) {
        self.icon.image = [UIImage imageNamed:@"pic_folder"];
    }
    else {
        self.icon.image = [UIImage imageNamed:@"pic_file"];
    }
    
    self.nameLabel.text = file.name;
    
    self.descLabel.text = [NSString stringWithFormat:@"%@ %@", file.lastCommitter.name, [COUtility timestampToBefore:file.lastCommitDate]];
}

@end

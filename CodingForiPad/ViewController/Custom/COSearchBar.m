//
//  COSearchBar.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSearchBar.h"

@implementation COSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self initUI];
}

- (void)initUI
{
    UITextField *searchField = [self valueForKey:@"_searchField"];
    searchField.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    searchField.font = [UIFont systemFontOfSize:12];
    [searchField setValue:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.backgroundImage = [UIImage new];
    self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

@end

//
//  CORegMailTipsView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORegMailTipsView.h"

@interface CORegMailTipsView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *mailList;
@property (nonatomic, strong) NSString *selectedText;
@property (nonatomic, weak)   UITextField *textField;

@end

@implementation CORegMailTipsView

- (instancetype)initForTextField:(UITextField *)textField height:(CGFloat)height
{
    CGRect frame = textField.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    frame.size.height = height;
    frame.origin.x -= 15.0;
    frame.size.width += 2 * 15.0;
    self = [super initWithFrame:frame];
    if (self) {
        self.mailList = [NSMutableArray array];
        self.textField = textField;
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        self.hidden = YES;
        [self.textField.superview addSubview:self];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length == 0
        || [textField.text isEqualToString:self.selectedText]) {
        self.hidden = YES;
        [self.mailList removeAllObjects];
    }
    else {
        self.hidden = NO;
        [self buildSource:textField.text];
    }
}

- (void)buildSource:(NSString *)text
{
    NSRange range = [text rangeOfString:@"@"];
    @synchronized(self) {
        [self.mailList removeAllObjects];
        if (NSNotFound == range.location
            || range.location == text.length - 1) {
            [self.mailList addObjectsFromArray:[self defaultMailList]];
        }
        else {
            NSString *m = [text substringFromIndex:range.location + 1];
            NSArray *list = [self defaultMailList];
            for (NSString *one in list) {
                if ([one hasPrefix:m]) {
                    [self.mailList addObject:one];
                }
            }
        }
    }
    if (self.mailList.count == 0) {
        self.hidden = YES;
    }
    [self.tableView reloadData];
}

- (NSArray *)defaultMailList
{
    static NSArray *list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emailListStr = @"qq.com, 163.com, gmail.com, 126.com, sina.com, sohu.com, hotmail.com, tom.com, sina.cn, foxmail.com, yeah.net, vip.qq.com, 139.com, live.cn, outlook.com, aliyun.com, yahoo.com, live.com, icloud.com, msn.com, 21cn.com, 189.cn, me.com, vip.sina.com, msn.cn, sina.com.cn";
        list = [emailListStr componentsSeparatedByString:@", "];
    });
    
    return list;
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MailTipsViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@@%@", [[_textField.text componentsSeparatedByString:@"@"] firstObject], _mailList[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedText = cell.textLabel.text;
    _textField.text = self.selectedText;
    self.hidden = YES;
}

@end

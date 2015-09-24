//
//  COActivityCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/27.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COActivityCell.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COHtmlMedia.h"
#import "NSDate+Common.h"

@interface COActivityCell()<TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableString *actionStr;
@property (nonatomic, strong) NSMutableString *contentStr;
@property (nonatomic, strong) NSMutableArray *actionMediaItems;
@property (nonatomic, strong) NSMutableArray *contentMediaItems;
@property (nonatomic, strong) COProjectActivity *activity;

@end

@implementation COActivityFormater


@end

@implementation COActivityCell

- (void)awakeFromNib {
    // Initialization code
    _dot.layer.cornerRadius = _dot.frame.size.width / 2;
    _dot.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
    _dot.layer.borderWidth = 2;
    _icon.layer.cornerRadius = 15.0;
    _icon.layer.masksToBounds = YES;
    self.titleLabel.delegate = self;
    self.contentLabel.delegate = self;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithActivity:(COProjectActivity *)activity
{
    self.activity = activity;
    self.actionStr = [[NSMutableString alloc] init];
    self.contentStr = [[NSMutableString alloc] init];
    self.actionMediaItems = [NSMutableArray array];
    self.contentMediaItems = [NSMutableArray array];
    [_icon sd_setImageWithURL:[COUtility urlForImage:activity.user.avatar] placeholderImage:[COUtility placeHolder]];
    
    NSString *type = activity.targetType;
    SEL parser = NSSelectorFromString([NSString stringWithFormat:@"format%@:", type]);
    if ([self respondsToSelector:parser]) {
        @try {
        IMP imp = [self methodForSelector:parser];
        void (*function)(id, SEL, COProjectActivity *) = (__typeof__(function))imp;
        function(self, parser, activity);
//        [self performSelector:parser withObject:activity];
        }
        @catch (NSException *exception) {
            // TODO: 处理错误数据
        }
        @finally {
        }
    }
    
    [self.titleLabel configForTweetComment];
    self.titleLabel.text = _actionStr;
    
    for (HtmlMediaItem *item in _actionMediaItems) {
        if (item.displayStr.length > 0
            && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_titleLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    [self.contentLabel configForTweetComment];
    self.contentLabel.text = _contentStr;
    self.dateLabel.text = [COUtility timestampToA_HH_MM:activity.createdAt];
    
    if (activity.height == 0.0) {
        CGSize s1 =  [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width - 114.0, 12.0)];
        CGSize s2 = [self.contentLabel sizeThatFits:CGSizeMake(self.frame.size.width - 114.0, 12.0)];
        activity.height =  s1.height + s2.height + 68.0;
    }
}

- (void)addActionUser:(COUser *)curUser
{
    if (curUser) {
        [_actionStr appendString:@" "];
        [HtmlMedia addMediaItemUser:curUser toString:_actionStr andMediaItems:_actionMediaItems];
        [_actionStr appendString:@" "];
    }
}

- (void)formatProject:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    [_actionStr appendString:@"项目"];
    
    [_contentStr appendString:activity.project.fullName];
}

- (void)formatProjectMember:(COProjectActivity *)activity
{
    if ([activity.action isEqualToString:@"quit"]) {
        [self addActionUser:activity.user];
        [_actionStr appendFormat:@"%@项目", activity.actionMsg];
        [_contentStr appendString:activity.project.fullName];
    }else{
        [self addActionUser:activity.user];
        [_actionStr appendFormat:@"%@项目成员", activity.actionMsg];
        [_contentStr appendString:activity.targetUser.name];
    }
}

- (void)formatTask:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.action isEqualToString:@"update_priority"]) {
        [_actionStr appendFormat:@"更新了任务「%@」的优先级", activity.task.title];
        [_contentStr appendFormat:@"「%@」", [activity.task priorityDisplay]];
        
    }else if ([activity.action isEqualToString:@"update_deadline"]) {
        if (activity.task.deadline && activity.task.deadline.length > 0) {
            [_actionStr appendFormat:@"更新了任务「%@」的截止日期", activity.task.title];
            [_contentStr appendFormat:@"「%@」", [NSDate convertStr_yyyy_MM_ddToDisplay:activity.task.deadline]];
        }else{
            [_actionStr appendFormat:@"移除了任务「%@」的截止日期", activity.task.title];
        }
    }else if ([activity.action isEqualToString:@"update_description"]) {
        [_actionStr appendFormat:@"更新了任务「%@」的描述", activity.task.title];
        [_contentStr appendFormat:@"%@", activity.task.textDesc];
    }else{
        if ([activity.actionMsg length] > 0) {
            [_actionStr appendString:activity.actionMsg];
        }
        if (activity.originTask.owner) {
            [self addActionUser:activity.originTask.owner];
            [_actionStr appendString:@"的"];
        }
        [_actionStr appendString:@"任务"];
        
        if ([activity.action isEqualToString:@"reassign"]) {
            [_actionStr appendString:@"给"];
            [self addActionUser:activity.task.owner];
        }
        [_contentStr appendString:activity.task.title];
    }
}

- (void)formatTaskComment:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    [_actionStr appendFormat:@"%@任务「%@」的评论", activity.actionMsg, activity.task.title];
    if (activity.taskComment.content) {
        HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:activity.taskComment.content showType:MediaShowTypeImageAndMonkey];
        [_contentStr appendString:htmlMedia.contentDisplay];
    }
}

- (void)formatProjectTopic:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    [_actionStr appendString:@"讨论"];
    if ([activity.action isEqualToString:@"comment"]) {
        if (activity.projectTopic.parent) {
            [_actionStr appendFormat:@"「%@」", activity.projectTopic.parent.title];
        }
        else {
            [_actionStr appendFormat:@"「%@」", activity.projectTopic.title];
        }
        if ([activity.projectTopic.content length] > 0) {
            // TODO: 少图片
            HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:activity.projectTopic.content showType:MediaShowTypeImageAndMonkey];
            [_contentStr appendString:htmlMedia.contentDisplay];
        }
    }
    else {
        if ([activity.projectTopic.title length] > 0) {
            [_contentStr appendString:activity.projectTopic.title];
        }
    }
}

- (void)formatProjectFile:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    if (activity.file.type == 0) {
        [_actionStr appendString:@"文件夹"];
    }
    else {
        [_actionStr appendString:@"文件"];
    }
    
    if ([activity.file.name length] > 0) {
        [_contentStr appendString:activity.file.name];
    }
}

- (void)formatDepot:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    if ([activity.action isEqualToString:@"push"]) {
        [_actionStr appendFormat:@"项目 分支「%@」", activity.ref];
    }else if ([activity.action isEqualToString:@"fork"]){
        [_actionStr appendFormat:@"项目「%@」到 「%@」", activity.sourceDepot.name, activity.depot.name];//_source_depot.name, _depot.name];
    }
    
    if (activity.commits && [activity.commits count] > 0) {
        COGitTreeCommit *curCommit = activity.commits.firstObject;
        if ([curCommit.shortMessage length] > 0) {
            [_contentStr appendString:curCommit.shortMessage];
        }
        
        for (int i = 1; i<[activity.commits count]; i++) {
            curCommit = [activity.commits objectAtIndex:i];
            if ([curCommit.shortMessage length] > 0) {
                [_contentStr appendFormat:@"\n%@",curCommit.shortMessage];
            }
        }
    }
}

- (void)formatQcTask:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」的质量分析任务", activity.project.fullName];
    
    // TODO: qctask
//    [_contentStr saveAppendString:_qc_task.link];
}

- (void)formatProjectStar:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendString:activity.project.fullName];
    [_contentStr appendString:activity.project.fullName];
}

- (void)formatProjectWatcher:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    [_actionStr appendString:activity.project.fullName];
    
    [_contentStr appendString:activity.project.fullName];
}

- (void)formatPullRequestBean:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」中的 Pull Request", activity.depot.name];
    
    [_contentStr appendString:activity.pullRequestTitle];
}

- (void)formatPullRequestComment:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」中的 Pull Request 「%@」", activity.depot.name, activity.pullRequestTitle];
    
    [_contentStr appendString:activity.commentContent];
}

- (void)formatMergeRequestBean:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」中的 Merge Request", activity.depot.name];
    
    [_contentStr appendString:activity.mergeRequestTitle];
}

- (void)formatMergeRequestComment:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」中的 Merge Request 「%@」", activity.depot.name, activity.mergeRequestTitle];
    
    [_contentStr appendString:activity.commentContent];
}

- (void)formatCommitLineNote:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"项目"];
    
    [_actionStr appendFormat:@"「%@」的 %@「%@」", activity.project.fullName, activity.lineNote.noteableType, activity.lineNote.noteableTitle];
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:activity.lineNote.content showType:MediaShowTypeImageAndMonkey];
    [_contentStr appendFormat:@"%@", htmlMedia.contentDisplay];
}

- (void)formatProjectFileComment:(COProjectActivity *)activity
{
    [self addActionUser:activity.user];
    if ([activity.actionMsg length] > 0) {
        [_actionStr appendString:activity.actionMsg];
    }
    
    [_actionStr appendString:@"文件"];
    
    [_actionStr appendFormat:@"「%@」的评论", activity.projectFile.title];
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:activity.fileComment.content showType:MediaShowTypeImageAndMonkey];
    [_contentStr appendFormat:@"%@", htmlMedia.contentDisplay];
}

#pragma mark -
- (IBAction)avatarAction:(id)sender
{
    if (self.avatarAction) {
        self.avatarAction(self.activity.user);
    }
}

#pragma mark TTTAttributedLabelDelegate M
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *item = [components objectForKey:@"value"];
    if (item && self.linkAction) {
        self.linkAction(item);
    }
}

@end

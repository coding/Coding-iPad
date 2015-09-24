//
//  COProjectActivity.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectActivity.h"

@implementation COProjectFileComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"content" : @"content",
             @"owner" : @"owner",
             @"fileCommentId" : @"id",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end

@implementation COProjectActivity

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"activityID" : @"id",
             @"targetType" : @"target_type",
             @"actionMsg"  : @"action_msg",
             @"action"     : @"action",
             @"createdAt"  : @"created_at",
             @"user"       : @"user",
             @"project"    : @"project",
             // 任务
             @"originTask" : @"origin_task",
             @"task" : @"task",
             // 任务评论
             @"taskComment" : @"taskComment",
             @"originTaskComment" : @"origin_taskComment",
             // 讨论
             @"projectTopic" : @"project_topic",
             // 文件
             @"fileType"      : @"type",
             @"file"      : @"file",
             // 代码
             @"depot"      : @"depot",
             @"sourceDepot" : @"source_depot",
             @"refPath"      : @"ref_path",
             @"oldShaPath"      : @"old_sha_path",
             @"oldSha"      : @"oldSha",
             @"ref"      : @"ref",
             
             @"commits" : @"commits",
             // pull request
             @"pullRequestTitle" : @"pull_request_title",
             @"pullRequestPath" : @"pull_request_path",
             // merge request
             @"mergeRequestTitle" : @"merge_request_title",
             @"mergeRequestPath" : @"merge_request_path",
             // 成员（其他）
             @"targetUser" : @"target_user",
             // line note
             @"lineNote" : @"line_note",
             @"commentContent" : @"comment_content",
             // 文件评论
             @"fileComment" : @"projectFileComment",
             @"projectFile"      : @"projectFile",
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProject class]];
}

+ (NSValueTransformer *)depotJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitDepot class]];
}

+ (NSValueTransformer *)sourceDepotJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitDepot class]];
}

+ (NSValueTransformer *)fileJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COFile class]];
}

+ (NSValueTransformer *)targetUserJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)originTaskJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTask class]];
}

+ (NSValueTransformer *)taskJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTask class]];
}

+ (NSValueTransformer *)taskCommentJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTaskComment class]];
}
+ (NSValueTransformer *)originTaskCommentJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTaskComment class]];
}

+ (NSValueTransformer *)projectTopicJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTopic class]];
}

+ (NSValueTransformer *)lineNoteJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProjectLineNote class]];
}

+ (NSValueTransformer *)commitsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COGitTreeCommit class]];
}

+ (NSValueTransformer *)fileCommentJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProjectFileComment class]];
}

+ (NSValueTransformer *)projectFileJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COFile class]];
}

@end

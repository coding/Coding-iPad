//
//  COGitTree.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COGitTree.h"

@implementation COGitDepot

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"path"    : @"path",
             @"name"    : @"name",
             };
}
@end

@implementation COGitFile

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"data"               : @"data",
             @"lang"               : @"lang",
             @"size"               : @"size",
             @"previewed"          : @"previewed",
             @"preview"            : @"preview",
             @"lastCommitDate"     : @"lastCommitDate",
             @"lastCommitId"       : @"lastCommitId",
             @"lastCommitter"      : @"lastCommitter",
             @"mode"               : @"mode",
             @"path"               : @"path",
             @"name"               : @"name",
             @"lastCommitMessage"  : @"lastCommitMessage",
             @"flattenPath"  : @"flatten_path",
             };
}

+ (NSValueTransformer *)lastCommitterJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end

@implementation COGitCommit

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"fullMessage"  : @"fullMessage",
             @"shortMessage" : @"shortMessage",
             @"allMessage"   : @"allMessage",
             @"commitId"     : @"commitId",
             @"commitTime"   : @"commitTime",
             @"committer"    : @"committer",
             @"notesCount"   : @"notesCount",
             };
}

+ (NSValueTransformer *)committerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end

@implementation COGitTree

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"path"               : @"path",
             @"ref"                : @"ref",
             @"files"              : @"files",
             @"isHead"             : @"isHead",
             @"can_edit"           : @"can_edit",
             @"lastCommit"         : @"lastCommit",
             @"readme"             : @"readme",
             @"headCommit"         : @"headCommit",
             @"lastCommitter"      : @"lastCommitter",
             };
}

+ (NSValueTransformer *)readmeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitFile class]];
}

+ (NSValueTransformer *)filesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COGitFile class]];
}

+ (NSValueTransformer *)lastCommitJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitCommit class]];
}

+ (NSValueTransformer *)headCommitJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitCommit class]];
}

+ (NSValueTransformer *)lastCommitterJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end

@implementation COGitTreeInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"infos" : @"infos" };
}

+ (NSValueTransformer *)infosJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COGitFile class]];
}

@end

@implementation COGitBlob

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"ref"                : @"ref",
             @"file"               : @"file",
             @"isHead"             : @"isHead",
             @"can_edit"           : @"can_edit",
             @"headCommit"         : @"headCommit"
             };
}

+ (NSValueTransformer *)fileJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitFile class]];
}

+ (NSValueTransformer *)headCommitJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COGitCommit class]];
}

@end

@implementation COGitTreeCommit

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"committers" : @"committers",
             @"shortMessage" : @"short_message",
             @"sha" : @"sha",
             };
}

+ (NSValueTransformer *)committersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COUser class]];
}

@end

@implementation COGitBranch

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"name" : @"name",
             @"isDefaultBranch" : @"is_default_branch",
             @"isProtected" : @"is_protected",
             };
}

@end
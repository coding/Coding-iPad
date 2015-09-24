//
// COProject.m
//

#import "COProject.h"

@implementation COProject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"lastUpdated" : @"last_updated",
             @"pin" : @"pin",
             @"updatedAt" : @"updated_at",
             @"currentUserRoleId" : @"current_user_role_id",
             @"forked" : @"forked",
             @"ownerUserPicture" : @"owner_user_picture",
             @"watched" : @"watched",
             @"projectId" : @"id",
             @"currentUserRole" : @"current_user_role",
             @"projectPath" : @"project_path",
             @"starCount" : @"star_count",
             @"httpsUrl" : @"https_url",
             @"recommended" : @"recommended",
             @"backendProjectPath" : @"backend_project_path",
             @"forkCount" : @"fork_count",
             @"type" : @"type",
             @"ownerId" : @"owner_id",
             @"status" : @"status",
             @"desc" : @"description",
             @"stared" : @"stared",
             @"maxMember" : @"max_member",
             @"ownerUserName" : @"owner_user_name",
             @"unReadActivitiesCount" : @"un_read_activities_count",
             @"gitUrl" : @"git_url",
             @"ownerUserHome" : @"owner_user_home",
             @"sshUrl" : @"ssh_url",
             @"isPublic" : @"is_public",
             @"groupId" : @"groupId",
             @"icon" : @"icon",
             @"depotPath" : @"depot_path",
             @"name" : @"name",
             @"createdAt" : @"created_at",
             @"watchCount" : @"watch_count",
             @"path" : @"path",
             @"fullName" : @"full_name",
             };
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stared = _watched = NO;
        _recommended = 0;
    }
    return self;
}

+ (COProject *)project_FeedBack
{
    COProject *pro = [[COProject alloc] init];
    pro.projectId = 162547;//iPad公开项目
    pro.isPublic = YES;
    return pro;
}

@end

@implementation COProjectMember

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"memberId"    : @"id",
             @"projectId"   : @"project_id",
             @"userId"      : @"user_id",
             @"type"        : @"type",
             @"createdAt"   : @"created_at",
             @"user"        : @"user",
             @"lastVisitAt" : @"last_visit_at",
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end

// COProjectLineNote
@implementation COProjectLineNote

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"noteableId" : @"noteable_id",
             @"path" : @"path",
             @"noteableTitle" : @"noteable_title",
             @"noteableType" : @"noteable_type",
             @"lineNoteId": @"id",
             @"noteableUrl" : @"noteable_url",
             @"content" : @"content",
             };
}

@end

@implementation COProjectMemberTaskCount

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"userId" : @"user",
             @"processing" : @"processing",
             @"done" : @"done",
             };
}

@end
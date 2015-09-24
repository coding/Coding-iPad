//
// COTask.m
//

#import "COTask.h"

NSArray *TaskPriorityDisplay = nil;

@implementation COTask

+ (void)load
{
    TaskPriorityDisplay = @[@"有空再看", @"正常处理", @"优先处理", @"十万火急"];
}

- (NSString *)priorityDisplay
{
    if (self.priority >= 0 && self.priority < TaskPriorityDisplay.count) {
        return TaskPriorityDisplay[self.priority];
    }
    // TODO: 默认值
    return @"正常处理";
}

- (void)setPriorityFormDisplay:(NSString *)display
{
    for (NSInteger priority=0; priority<TaskPriorityDisplay.count; priority++) {
        if ([display isEqualToString:TaskPriorityDisplay[priority]]) {
            self.priority = priority;
            break;
        }
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"status" : @"status",
             @"content" : @"content",
             @"title" : @"title",
             @"path" : @"path",
             @"project" : @"project",
             @"creator" : @"creator",
             @"createdAt" : @"created_at",
             @"currentUserRoleId" : @"current_user_role_id",
             @"comments" : @"comments",
             @"updatedAt" : @"updated_at",
             @"priority" : @"priority",
             @"creatorId" : @"creator_id",
             @"deadline" : @"deadline",
             @"owner" : @"owner",
             @"projectId" : @"project_id",
             @"hasDescription" : @"has_description",
             @"taskId" : @"id",
             @"ownerId" : @"owner_id",
             @"textDesc" : @"description",  // 用于动态
             @"taskDescription" : @"task_description",
             };
}

+ (NSValueTransformer *)taskDescriptionJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTaskDescription class]];
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProject class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (COTask *)taskWithTask:(COTask *)task
{
    COTask *curTask = [[COTask alloc] init];
    [curTask copyDataFrom:task];
    return curTask;
}

- (void)copyDataFrom:(COTask *)task
{
    self.taskId = task.taskId;
    self.project = task.project;
    self.projectId = task.projectId;
    self.creator = task.creator;
    self.creatorId = task.creatorId;
    self.owner = task.owner;
    self.ownerId = task.ownerId;
    self.status = task.status;
    self.content = task.content;
    self.title = task.title;
    self.createdAt = task.createdAt;
    self.updatedAt = task.updatedAt;
    self.priority = task.priority;
    self.comments = task.comments;
    self.deadline = task.deadline;
    
    self.hasDescription = task.hasDescription;
    self.taskDescription = task.taskDescription;
}

- (BOOL)isSameToTask:(COTask *)task
{
    if (!task) {
        return NO;
    }
    return ([self.content isEqualToString:task.content]
            && self.ownerId == task.ownerId
            && self.priority == task.priority
            && self.status == task.status
            && ((!self.deadline && !task.deadline) || [self.deadline isEqualToString:task.deadline]));
}

@end

@implementation COTaskDescription

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"descriptionMine" : @"description_mine",
             @"markdown"    : @"markdown",
             };
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.markdown = @"";
        self.descriptionMine = @"";
    }
    return self;
}

+ (instancetype)defaultDescription{
    return [[COTaskDescription alloc] init];
}

+ (instancetype)descriptionWithMdStr:(NSString *)mdStr{
    COTaskDescription *taskD = [COTaskDescription defaultDescription];
    taskD.markdown = mdStr;
    return taskD;
}

@end

@implementation COTaskComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"taskCommentId"   : @"id",
             @"taskId"     : @"taskId",
             @"ownerId"   : @"owner_id",
             @"owner"      : @"owner",
             @"content"    : @"content",
             @"createdAt" : @"created_at",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

- (HtmlMedia *)htmlMedia
{
    if (!_htmlMedia) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:_content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
    return _htmlMedia;
}

@end

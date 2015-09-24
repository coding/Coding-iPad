//
// COTask.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COProject.h"
#import "COUser.h"
#import "COHtmlMedia.h"

@class COTaskDescription;
@interface COTask : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) COProject *project;
@property (nonatomic, strong) COUser *creator;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *currentUserRoleId;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, assign) NSInteger updatedAt;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger creatorId;
@property (nonatomic, copy) NSString *deadline;
@property (nonatomic, copy) NSString *textDesc;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) BOOL hasDescription;
@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, strong) COTaskDescription *taskDescription;

@property (nonatomic, assign) BOOL isRequesting;

- (NSString *)priorityDisplay;
- (void)setPriorityFormDisplay:(NSString *)display;

+ (COTask *)taskWithTask:(COTask *)task;
- (BOOL)isSameToTask:(COTask *)task;

@end

@interface COTaskDescription : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *descriptionMine;
@property (nonatomic, copy) NSString *markdown;

+ (instancetype)defaultDescription;
+ (instancetype)descriptionWithMdStr:(NSString *)mdStr;

@end

@interface COTaskComment : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger taskCommentId;
@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSTimeInterval createdAt;

@property (assign, nonatomic) float contentHeight;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@end
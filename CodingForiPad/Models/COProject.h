//
// COProject.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"

#define OPProjectListReloadNotification @"OPProjectListReloadNotification"

@interface COProject : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger lastUpdated;
@property (nonatomic, assign) BOOL pin;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, assign) NSInteger currentUserRoleId;
@property (nonatomic, assign) BOOL forked;
@property (nonatomic, copy) NSString *ownerUserPicture;
@property (nonatomic, assign) BOOL watched;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, copy) NSString *currentUserRole;
@property (nonatomic, copy) NSString *projectPath;
@property (nonatomic, assign) NSInteger starCount;
@property (nonatomic, copy) NSString *httpsUrl;
@property (nonatomic, assign) NSInteger recommended;
@property (nonatomic, copy) NSString *backendProjectPath;
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL stared;
@property (nonatomic, assign) NSInteger maxMember;
@property (nonatomic, copy) NSString *ownerUserName;
@property (nonatomic, assign) NSInteger unReadActivitiesCount;
@property (nonatomic, copy) NSString *gitUrl;
@property (nonatomic, copy) NSString *ownerUserHome;
@property (nonatomic, copy) NSString *sshUrl;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *depotPath;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSInteger watchCount;

// 动态中使用
@property (nonatomic, copy) NSString *path;
// 动态中使用
@property (nonatomic, copy) NSString *fullName;

+ (COProject *)project_FeedBack;

@end

@interface COProjectMember : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger memberId;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, strong) COUser  *user;
@property (nonatomic, assign) NSTimeInterval lastVisitAt;

@end

@interface COProjectLineNote : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *noteableId;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *noteableTitle;
@property (nonatomic, copy) NSString *noteableType;
@property (nonatomic, assign) NSInteger lineNoteId;
@property (nonatomic, copy) NSString *noteableUrl;
@property (nonatomic, copy) NSString *content;

@end

@interface COProjectMemberTaskCount : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger processing;
@property (nonatomic, assign) NSInteger done;

@end


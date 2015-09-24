//
// COComment.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COProject.h"
#import "COUser.h"

@interface COComment : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) COProject *project;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger parentId;
@property (nonatomic, assign) NSInteger currentUserRoleId;
@property (nonatomic, assign) NSInteger childCount;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, assign) NSInteger ownerId;

@end

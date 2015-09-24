//
// COTopic.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COProject.h"
#import "COUser.h"
#import "COHtmlMedia.h"

@interface COTopicLabel : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger topicLabelId;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *color;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, assign) NSInteger count;

@end

@interface COTopic : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *path; // 在动态中使用
@property (nonatomic, strong) COProject *project;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, assign) NSInteger updatedAt;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger parentId;
@property (nonatomic, strong) COTopic  *parent;
@property (nonatomic, assign) NSInteger currentUserRoleId;
@property (nonatomic, assign) NSInteger childCount;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger topicId;
@property (nonatomic, assign) NSInteger ownerId;

@property (nonatomic, strong) NSMutableArray *mdLabels;
@property (strong, nonatomic) NSString *mdTitle, *mdContent;

@property (assign, nonatomic) float contentHeight;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@end

@interface COTopicDetail : MTLModel<MTLJSONSerializing>


@end


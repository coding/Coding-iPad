//
// COUser.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface COUser : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) BOOL followed;
@property (nonatomic, assign) NSInteger isMember;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger fansCount;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) NSString *namePinyin;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *globalKey;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSString *lavatar;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, assign) NSTimeInterval lastLoginedAt;
@property (nonatomic, assign) NSInteger tweetsCount;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) NSInteger job;
@property (nonatomic, copy) NSString *jobStr;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, assign) NSTimeInterval lastActivityAt;
@property (nonatomic, copy) NSString *tagsStr;
@property (nonatomic, assign) NSInteger followsCount;
@property (nonatomic, copy) NSString *slogan;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *gravatar;
@property (nonatomic, copy) NSString *avatar;

@end

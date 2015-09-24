//
// COTweet.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"
#import "COTweetComment.h"
#import <UIKit/UIKit.h>

@interface COTweet : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) NSInteger activityId;
@property (nonatomic, copy) NSString *coord;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *device;
@property (nonatomic, strong) NSMutableArray *commentList;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, assign) NSInteger tweetId;
@property (nonatomic, strong) NSArray *likeUsers;
@property (nonatomic, assign) NSInteger ownerId;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat imagesHeight;
@property (nonatomic, assign) CGFloat commentHeight;

- (void)cleanHeight;

@end
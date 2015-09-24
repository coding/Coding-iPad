//
// COTweetcomment.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"

@interface COTweetComment : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger tweetId;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, assign) NSInteger tweetcommentId;
@property (nonatomic, assign) NSInteger ownerId;

@property (nonatomic, assign) float contentHeight;

@end

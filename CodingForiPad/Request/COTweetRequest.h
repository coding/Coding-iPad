//
//  COTweetRequest.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"

@interface COTweetRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSNumber *lastId;
@property (nonatomic, copy) COQueryParameters NSString *sort;
@property (nonatomic, copy) COQueryParameters NSString *userId;

@end

/**
 *
 朋友圈
api/activities/user_tweet:
{
    "last_id" = 99999999;
}
 */
@interface COFriendTweetRequest : COTweetRequest

@end

/**
广场
api/tweet/public_tweets:
{
    "last_id" = 99999999;
    sort = time;
}
 */

@interface COPublicTweetRequest : COTweetRequest

@end
/**
热门
api/tweet/public_tweets:
{
    "last_id" = 99999999;
    sort = hot;
}
 */

/**
我的冒泡
api/tweet/user_public:
{
    "last_id" = 99999999;
    "user_id" = 54909;
}

 */
COGetRequest
@interface COUserPublicTweetRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSNumber *lastId;
@property (nonatomic, copy) COQueryParameters NSNumber *userId;

@end

// 发送冒泡
@interface COTweetSendRequest : COTweetRequest

@property (nonatomic, copy) COFormParameters NSString *content;
@property (nonatomic, copy) COFormParameters NSString *location;
@property (nonatomic, copy) COFormParameters NSString *coord;
@property (nonatomic, copy) COFormParameters NSString *address;
// 还有图片内容，地址内容

@end

// 发送冒泡图片
@interface COTweetSendImageRequest : COTweetRequest

@end

@interface COTweetLikeRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;

@end

@interface COTweetUnlikeRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;

@end

@interface COTweetCommentRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;
@property (nonatomic, copy) COFormParameters NSString *content;

@end

@interface COTweetCommentDeleteRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;
@property (nonatomic, copy) COUriParameters NSNumber *commentId;

@end

@interface COFollowersRequest : COPageRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;

@end

@interface COFriendsRequest : COPageRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;

@end

COGetRequest
@interface COTweetCommentsRequest : COPageRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;

@end

CODeleteRequest
@interface COTweetDeleteRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *tweetId;

@end

COGetRequest
@interface COTweetDetailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;
@property (nonatomic, copy) COUriParameters NSNumber *tweetId;

@end

//
//  COTweetRequest.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetRequest.h"
#import "COTweet.h"

@implementation COTweetRequest

- (NSDictionary *)parametersMap
{
    return @{
             @"lastId" : @"last_id",
             @"sort" : @"sort",
             @"userId" : @"user_id",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweet class] responseType:CODataResponseTypeList];
}

@end

@implementation COFriendTweetRequest

- (void)prepareForRequest
{
    self.path = @"/activities/user_tweet";
}

@end

@implementation COPublicTweetRequest

- (void)prepareForRequest
{
    self.path = @"/tweet/public_tweets";
}

@end

@implementation COUserPublicTweetRequest

- (void)prepareForRequest
{
    self.path = @"/tweet/user_public";
}

- (NSDictionary *)parametersMap
{
    return @{@"lastId" : @"last_id",
             @"userId" : @"user_id",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweet class] responseType:CODataResponseTypeList];
}

@end

@implementation COTweetSendRequest

- (void)prepareForRequest
{
    self.path = @"/tweet";
}

- (NSDictionary *)parametersMap
{
    return @{@"content" : @"content",
             @"location" : @"location",
             @"coord" : @"coord",
             @"address" : @"address"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweet class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTweetSendImageRequest

- (void)prepareForRequest
{
    self.path = @"/tweet/insert_image";
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COTweetLikeRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/like", self.tweetId];
}

@end

@implementation COTweetUnlikeRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/unlike", self.tweetId];
}

@end

@implementation COTweetCommentRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/comment", self.tweetId];
}

- (NSDictionary *)parametersMap
{
    return @{@"content" : @"content"};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweetComment class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTweetCommentDeleteRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/comment/%@", self.tweetId, self.commentId];
}

@end

@implementation COFollowersRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/followers/%@", self.globalKey];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypePage];
}

@end

@implementation COFriendsRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/friends/%@", self.globalKey];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypePage];
}

@end


@implementation COTweetCommentsRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/comments", self.tweetId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweetComment class] responseType:CODataResponseTypePage];
}

@end

@implementation COTweetDeleteRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@", self.tweetId];
}

@end

@implementation COTweetDetailRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/tweet/%@/%@", self.globalKey, self.tweetId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTweet class] responseType:CODataResponseTypeDefault];
}

@end
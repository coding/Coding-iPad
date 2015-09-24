//
//  CODataRequest+Image.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest+Image.h"
#import "COSession.h"

@implementation CODataRequest (Image)

- (void)uploadImage:(UIImage *)image
       successBlock:(void (^)(CODataResponse * responseObject))success
       failureBlock:(void (^)(NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress
{
    [self prepareForRequest];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, self.path];
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ((float)data.length/1024 > 1000) {
        data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", [COSession session].user.globalKey, str];
    NSLog(@"\nuploadImageSize\n%@ : %.0f", fileName, (float)data.length/1024);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"tweetImg" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        if (success) success([self postResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        if (failure) failure(error);
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progress) {
            progress(progressValue);
        }
    }];
    [operation start];
}

@end

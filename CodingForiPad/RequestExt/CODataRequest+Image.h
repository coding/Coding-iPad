//
//  CODataRequest+Image.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"
#import <UIKit/UIKit.h>

@interface CODataRequest (Image)

- (void)uploadImage:(UIImage *)image
       successBlock:(void (^)(CODataResponse * responseObject))success
       failureBlock:(void (^)(NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress;

@end

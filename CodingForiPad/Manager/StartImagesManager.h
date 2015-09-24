//
//  StartImagesManager.h
//  Coding_iOS
//
//  Created by Ease on 14/12/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

@class StartImage;
@class Group;

@interface StartImagesManager : NSObject
+ (instancetype)shareManager;

- (StartImage *)randomImage;
- (StartImage *)curImage;

- (void)refreshImagesPlist;
- (void)startDownloadImages;

@end

@interface StartImage : MTLModel<MTLJSONSerializing>
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *descriptionStr;
@property (strong, nonatomic) NSString *pathDisk;

+ (StartImage *)defautImage;

- (UIImage *)image;
- (void)startDownloadImage;

@end

@interface Group : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSString *name, *author;

@end
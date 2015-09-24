//
//  COTopicFilterController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol COTopicFilterControllerDelegate <NSObject>

@required
- (void)changeIndex:(NSInteger)index withSegmentIndex:(NSInteger)segmentIndex;

@end

@interface COTopicFilterController : UIViewController

@property (nonatomic, assign) id<COTopicFilterControllerDelegate> indexDelegate;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *numbers;
@property (nonatomic, assign) NSInteger defaultIndex;
@property (nonatomic, assign) NSInteger segmentIndex;

@end

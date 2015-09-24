//
//  COChangeSegue.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COChangeSegue.h"

@implementation COChangeSegue

//- (void)perform
//{
//    UIViewController* source = (UIViewController*)self.sourceViewController;
//    UIViewController* destination = (UIViewController*)self.destinationViewController;
//    
//    UIViewController *selectedController = nil;
//    UIView *container = nil;
//    
//    @try {
//        selectedController = [source valueForKey:@"selectedController"];
//        container = [source valueForKey:@"container"];
//    }
//    @catch (NSException *exception) {
//        container = nil;
//    }
//    @finally {
//        
//    }
//    
//    if (selectedController == destination) {
//        return;
//    }
//    
//    NSAssert(nil != container, @"%@ 不支持使用该segue", NSStringFromClass([source class]));
//    if (selectedController) {
//        [selectedController viewWillDisappear:NO];
//        [selectedController.view removeFromSuperview];
//        [selectedController viewDidDisappear:NO];
//    }
//    
//    [destination viewWillAppear:NO];
//    destination.view.frame = container.bounds;
//    [container addSubview:destination.view];
//    [destination viewDidAppear:NO];
//    [source setValue:destination forKey:@"selectedController"];
//}

@end

//
//  COUserProjectsController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserProjectsController.h"
#import "COProjectController.h"

@interface COUserProjectsController ()

@property (nonatomic, strong) COProjectController *projectController;
@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation COUserProjectsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _container.layer.masksToBounds = YES;
    _container.layer.cornerRadius = 4.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userProjects"]) {
        self.projectController = segue.destinationViewController;
        self.projectController.user = self.user;
    }
}

@end

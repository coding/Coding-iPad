//
//  COTopicViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicViewController.h"
#import "COTopic.h"
#import "COTopicRequest.h"
#import "COTopicCell.h"
#import "COTopicFilterController.h"
#import "CORootViewController.h"
#import "COTopicDetailController.h"
#import "COTopic+Ext.h"
#import "COTopicEditController.h"

typedef NS_ENUM(NSInteger, TopicQueryType){
    TopicQueryTypeAll = 0,
    TopicQueryTypeMe
};

typedef NS_ENUM(NSInteger, LabelOrderType){
    LabelOrderTypeUpdate = 51,
    LabelOrderTypeCreate = 49,
    LabelOrderTypeHot = 53,
};

@interface COTopicViewController () <COTopicFilterControllerDelegate>
{
    NSArray *_one;
    NSMutableArray *_two;
    NSArray *_three;
    NSArray *_total;
    NSMutableArray *_oneNumber;
    NSMutableArray *_twoNumber;
    NSMutableArray *_totalIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *allmeBtn;
@property (weak, nonatomic) IBOutlet UIButton *labelBtn;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, assign) NSInteger labelId;
@property (nonatomic, assign) TopicQueryType type;
@property (nonatomic, assign) NSInteger orderBy;
@property (nonatomic, assign) NSInteger page;

@property (strong, nonatomic) NSMutableArray *labelsAll;
@property (strong, nonatomic) NSMutableArray *labelsMy;

@end

@implementation COTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [NSString stringWithFormat:@"%@：讨论", self.project.name];

    self.topics = [NSMutableArray array];
    self.page = 1;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.type = TopicQueryTypeAll;
    self.orderBy = 0;
    
    _one = @[@"全部讨论", @"我的讨论"];
    _two = [NSMutableArray arrayWithObjects:@"全部标签", nil];
    _three = @[@"最后评论排序", @"发布时间排序", @"热门排序"];
    _total = @[_one, _two, _three];
    _oneNumber = [NSMutableArray arrayWithObjects:@0, @0, nil];
    _twoNumber = [NSMutableArray arrayWithObjects:@0, nil];
    _totalIndex = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
    
    _labelsAll = [[NSMutableArray alloc] initWithCapacity:4];
    _labelsMy = [[NSMutableArray alloc] initWithCapacity:4];
    
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 刷刷更健康
    [self loadTopic];
    [self loadTopicLabelInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 下载列表

- (void)refresh
{
    self.page = 1;
    [self loadTopic];
}

- (void)loadMore
{
    self.page += 1;
    [self loadTopic];
}

- (void)loadTopic
{
    COTopicRequest *request = [COTopicRequest request];
    request.backendProjectPath = self.backendProjectPath;
    request.type = self.type == TopicQueryTypeAll ? @"all" : @"my";
    switch (self.orderBy) {
        case 0:
            request.orderBy = @(LabelOrderTypeUpdate);
            break;
        case 1:
            request.orderBy = @(LabelOrderTypeCreate);
            break;
        case 2:
            request.orderBy = @(LabelOrderTypeHot);
            break;
        default:
            break;
    }
    request.page = self.page;
    request.topicLabelId = [NSString stringWithFormat:@"%ld", (long)self.labelId];
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [COEmptyView removeFormView:weakself.view];
            [weakself.refreshCtrl endRefreshing];
            [weakself.tableView.infiniteScrollingView stopAnimating];
            if ([weakself checkDataResponse:responseObject]) {
                [weakself reloadData:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakself showError:error];
            [weakself.refreshCtrl endRefreshing];
            [weakself.tableView.infiniteScrollingView stopAnimating];
            [weakself showErrorReloadView:^{
                [weakself loadTopic];
            } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
        });
    }];
}

- (void)reloadData:(NSArray *)data
{
    @synchronized(self) {
        if (1 == self.page) {
            [self.topics removeAllObjects];
        }
        if (data.count == 0 && self.topics.count == 0) {
            [self showEmptyView];
        }
        else {
            [self removeEmptyView];
        }
        if (data.count < 20) {
            self.tableView.infiniteScrollingView.enabled = NO;
        }
        else {
            self.tableView.infiniteScrollingView.enabled = YES;
        }
    }
    
    [self.topics addObjectsFromArray:data];
    
    [self.tableView reloadData];
}
- (void)showEmptyView
{
    COEmptyView *view = [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"这里怎么空空的\n发个讨论让它热闹点吧"];
    [view showInView:self.view padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTopicCell"];
    
    [cell assignWithTopic:_topics[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    COTopicDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicDetailController"];
    controller.topic = _topics[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - click
- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addBtnClick:(UIButton *)sender
{
    // 添加讨论
    COTopicEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicEditController"];
    controller.topic = [COTopic topicWithPro:_project];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)typeAllMeBtnClick:(UIButton *)sender
{
    [self openList:0];
}

- (IBAction)typeTagBtnClick:(UIButton *)sender
{
    [self openList:1];
}

- (IBAction)typeOrderBtnClick:(UIButton *)sender
{
    [self openList:2];
}

#pragma mark -
- (void)loadTopicLabelInfo
{
    // 项目的所有标签及被使用计数
    COProjectTopicLabelsRequest *request = [COProjectTopicLabelsRequest request];
    request.projectId = _project.projectId;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself parseLabelInfo:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
    
    // 项目所有、我参与的讨论数目
    COProjectTopicCountRequest *requestCount = [COProjectTopicCountRequest request];
    requestCount.projectId = _project.projectId;
    
    [requestCount getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself parseCountInfo:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
    
    // 项目我参与的讨论的标签
    COProjectTopicLabelMyRequest *requestMy = [COProjectTopicLabelMyRequest request];
    requestMy.projectName = _project.name;
    requestMy.ownerName = _project.ownerUserName;
    
    [requestMy getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself parseCountMyInfo:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
}

- (void)parseLabelInfo:(NSArray *)labelInfo
{
    if ([_totalIndex[0] integerValue] == 0) {
        NSInteger tempIndex = 0;
        COTopicLabel *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsAll[[_totalIndex[1] integerValue] - 1] : nil;
        
        [_labelsAll removeAllObjects];
        [_two removeAllObjects];
        [_two addObject:@"全部标签"];
        [_twoNumber removeAllObjects];
        [_twoNumber addObject:_oneNumber[0]];
        for (COTopicLabel *lbl in labelInfo) {
            if (lbl.count > 0) {
                [_labelsAll addObject:lbl];
                [_two addObject:lbl.name];
                [_twoNumber addObject:[NSNumber numberWithInteger:lbl.count]];
                
                if (tempLbl && tempLbl.topicLabelId ==lbl.topicLabelId) {
                    tempIndex = _two.count - 1;
                }
            }
        }
        
        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [_labelBtn setTitle:_two[tempIndex] forState:UIControlStateNormal];
        
        [self changeOrder];
    } else {
        [_labelsAll removeAllObjects];
        [_twoNumber removeAllObjects];
        [_twoNumber addObject:_oneNumber[0]];
        for (COTopicLabel *lbl in labelInfo) {
            if (lbl.count > 0) {
                [_labelsAll addObject:lbl];
                [_twoNumber addObject:[NSNumber numberWithInteger:lbl.count]];
            }
        }
    }
}

- (void)parseCountInfo:(NSDictionary *)dic
{
    _oneNumber[0] = [dic objectForKey:@"all"];
    _oneNumber[1] = [dic objectForKey:@"my"];
    _twoNumber[0] = _oneNumber[0];
}

- (void)parseCountMyInfo:(NSArray *)labelInfo
{
    if ([_totalIndex[0] integerValue] == 1) {
        NSInteger tempIndex = 0;
        COTopicLabel *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsMy[[_totalIndex[1] integerValue] - 1] : nil;
        
        [_labelsMy removeAllObjects];
        [_labelsMy addObjectsFromArray:labelInfo];
        [_two removeAllObjects];
        [_two addObject:@"全部标签"];
        for (COTopicLabel *lbl in labelInfo) {
            [_two addObject:lbl.name];
            
            if (tempLbl && tempLbl.topicLabelId == lbl.topicLabelId) {
                tempIndex = _two.count - 1;
            }
        }
        
        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [_labelBtn setTitle:_two[tempIndex] forState:UIControlStateNormal];
        
        [self changeOrder];
    } else {
        [_labelsMy removeAllObjects];
        [_labelsMy addObjectsFromArray:labelInfo];
    }
}

- (void)changeIndex:(NSInteger)index withSegmentIndex:(NSInteger)segmentIndex
{
    [_totalIndex replaceObjectAtIndex:segmentIndex withObject:[NSNumber numberWithInteger:index]];
    if (segmentIndex == 0) {
        NSInteger tempIndex = 0;
        if (index == 0) {
            COTopicLabel *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsMy[[_totalIndex[1] integerValue] - 1] : nil;
            [_two removeAllObjects];
            [_two addObject:@"全部标签"];
            for (int i=0; i<_labelsAll.count; i++) {
                COTopicLabel *lbl = _labelsAll[i];
                [_two addObject:lbl.name];
                
                if (tempLbl && tempLbl.topicLabelId == lbl.topicLabelId) {
                    tempIndex = i + 1;
                }
            }
        } else {
            COTopicLabel *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsAll[[_totalIndex[1] integerValue] - 1] : nil;
            [_two removeAllObjects];
            [_two addObject:@"全部标签"];
            for (int i=0; i<_labelsMy.count; i++) {
                COTopicLabel *lbl = _labelsMy[i];
                [_two addObject:lbl.name];
                
                if (tempLbl && tempLbl.topicLabelId == lbl.topicLabelId) {
                    tempIndex = i + 1;
                }
            }
        }
        
        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [_labelBtn setTitle:_two[tempIndex] forState:UIControlStateNormal];
    }
    
    if (segmentIndex == 0) {
        [_allmeBtn setTitle:_total[segmentIndex][index] forState:UIControlStateNormal];
    } else if (segmentIndex == 1) {
        [_labelBtn setTitle:_total[segmentIndex][index] forState:UIControlStateNormal];
    } else if (segmentIndex == 2) {
        [_orderBtn setTitle:_total[segmentIndex][index] forState:UIControlStateNormal];
    }
    
    [self changeOrder];
}

- (void)changeOrder
{
    if ([_totalIndex[1] integerValue] > 0) {
        if ([_totalIndex[0] integerValue] > 0) {
            COTopicLabel *lbl = _labelsMy[[_totalIndex[1] integerValue] - 1];
            [self setOrder:[_totalIndex[2] integerValue] withLabelID:lbl.topicLabelId andType:[_totalIndex[0] integerValue]];
        } else {
            COTopicLabel *lbl = _labelsAll[[_totalIndex[1] integerValue] - 1];
            [self setOrder:[_totalIndex[2] integerValue] withLabelID:lbl.topicLabelId andType:[_totalIndex[0] integerValue]];
        }
    } else {
        [self setOrder:[_totalIndex[2] integerValue] withLabelID:0 andType:[_totalIndex[0] integerValue]];
    }
}

- (void)openList:(NSInteger)segmentIndex
{
    NSArray *lists = (NSArray *)_total[segmentIndex];
    
    NSArray *nAry = nil;
    if (segmentIndex == 0) {
        nAry = _oneNumber;
    } else if (segmentIndex == 1 && [_totalIndex[0] integerValue] == 0) {
        nAry = _twoNumber;
    }
    
    COTopicFilterController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicFilterController"];
    popoverVC.titles = lists;
    popoverVC.numbers = nAry;
    popoverVC.defaultIndex = [_totalIndex[segmentIndex] integerValue];
    popoverVC.segmentIndex = segmentIndex;
    popoverVC.indexDelegate = self;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
}

- (void)setOrder:(NSInteger)order withLabelID:(NSInteger)labelID andType:(TopicQueryType)type
{
    if (self.orderBy != order  || self.labelId != labelID || self.type != type) {
        self.orderBy = order;
        self.labelId = labelID;
        self.type = type;
        
        // 重新加载列表（需要判断网络请求是否正在进行中先吧）
        [self loadTopic];
    }
}

@end

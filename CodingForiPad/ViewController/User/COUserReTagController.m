//
//  COUserReTagController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserReTagController.h"
#import "CORootViewController.h"
#import "COUserReTagCell.h"
#import "TagsManager.h"

@interface COUserReTagController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray *mySelectedTags;

@end

@implementation COUserReTagController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_selectedTags && _selectedTags.count > 0) {
        _mySelectedTags = [_selectedTags mutableCopy];
    } else {
        _mySelectedTags = [NSMutableArray array];
    }
    
    _okBtn.enabled = FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    // 发送修改
    if (_selectedBlock) {
        _selectedBlock(_mySelectedTags);
    }
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _allTags.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    COUserReTagCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:@"COUserReTagCell" forIndexPath:indexPath];
    COTag *curTag = [_allTags objectAtIndex:indexPath.row];
    ccell.tagLabel.text = curTag.name;
    
    if ([_mySelectedTags containsObject:[NSString stringWithFormat:@"%ld", (long)curTag.tagId]]) {
        ccell.tagLabel.textColor = [UIColor whiteColor];
        ccell.backgroundColor = [_okBtn titleColorForState:UIControlStateNormal];
    } else {
        ccell.tagLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        ccell.backgroundColor = self.view.backgroundColor;
    }
    
    return ccell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    COTag *curTag = [_allTags objectAtIndex:indexPath.row];
    NSString *tagId = [NSString stringWithFormat:@"%ld", (long)curTag.tagId];
    
    if ([_mySelectedTags containsObject:tagId]) {
        [_mySelectedTags removeObject:tagId];
    } else {
        [_mySelectedTags addObject:tagId];
    }
    _okBtn.enabled = [self tagsHasChanged];
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (BOOL)tagsHasChanged
{
    BOOL tagsHasChanged = NO;
    NSSet *oldSet = [NSSet setWithArray:_selectedTags];
    NSSet *newSet = [NSSet setWithArray:_mySelectedTags];
    tagsHasChanged = ![newSet isEqualToSet:oldSet];
    return tagsHasChanged;
}

@end

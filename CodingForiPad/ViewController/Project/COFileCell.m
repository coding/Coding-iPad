//
//  COFileCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileCell.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"
#import "Coding_FileManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "NSString+Common.h"
#import "COFile+Ext.h"

@interface COFileCell ()

@property (nonatomic, strong) COFile *file;

@end

@implementation COFileCell

- (void)awakeFromNib {
    // Initialization code
    if (!_progressView) {
//        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat width = CGRectGetWidth(self.bounds);
        _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(10.0, 85.0 - 3.0, width - 20.0, 2.0)];
        
        _progressView.popUpViewCornerRadius = 12.0;
        _progressView.delegate = self;
        _progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
        [_progressView setTrackTintColor:[UIColor colorWithHexString:@"0xe6e6e6"]];
        _progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:@"0x3bbd79"]];
        _progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
    }
    
    [_stateButton addTarget:self action:@selector(stateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithFile:(COFile *)file projectId:(NSInteger)projectId
{
    self.file = file;
    self.file.projectId = projectId;
    self.nameLabel.text = file.name;
    if (file.preview && file.preview.length > 0) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:file.preview]];
    }else{
        _iconView.image = [UIImage imageNamed:[file fileIconName]];
    }
    NSString *time = [COUtility timestampToBefore:file.createdAt];
    self.descLabel.text = [NSString stringWithFormat:@"%@创建于%@", file.owner.name, time];
    self.sizeLabel.text = [NSString sizeDisplayWithByte:file.size * 1.0];
    if ([_file hasBeenDownload]) {
        //已下载
        if (self.progressView) {
            self.progressView.hidden = YES;
        }
    }else{
        Coding_DownloadTask *cDownloadTask = [_file cDownloadTask];
        if (cDownloadTask) {
            self.progress = cDownloadTask.progress;
        }
//        if (_file.size * 1.0/1024/1024 > 5.0) {//大于5M的文件，下载时显示百分比
//            [_progressView showPopUpViewAnimated:NO];
//        }else{
//            [_progressView hidePopUpViewAnimated:NO];
//        }
//        [self showProgress:cDownloadTask.progress belongSelf:YES];
    }
    [self changeToState:_file.downloadState];
}

- (IBAction)stateBtnAction:(id)sender
{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskDownloadUrlForFile:_file.diskFileName];
    if (fileUrl) {//已经下载到本地了
        if (_showBlock) {
            _showBlock(self.file);
        }
    }else{//要下载
        NSURLSessionDownloadTask *downloadTask;
        if (_file.cDownloadTask) {//暂停或者重新开始
            downloadTask = _file.cDownloadTask.task;
            switch (downloadTask.state) {
                case NSURLSessionTaskStateRunning:
                    [downloadTask suspend];
                    [self changeToState:DownloadStatePausing];
                    
                    break;
                case NSURLSessionTaskStateSuspended:
                    [downloadTask resume];
                    [self changeToState:DownloadStateDownloading];
                    break;
                default:
                    break;
            }
        }else{//新建下载
            
            __weak typeof(self) weakSelf = self;
            Coding_DownloadTask *cDownloadTask = [manager addDownloadTaskForFile:self.file completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                    [weakSelf changeToState:DownloadStateDefault];
//                    [weakSelf showError:error];

                }else{
                    [weakSelf changeToState:DownloadStateDownloaded];
                }
            }];
            
            self.progress = cDownloadTask.progress;
            _progressView.progress = 0.0;
            _progressView.hidden = NO;
            [self changeToState:DownloadStateDownloading];
        }
    }
}

- (void)changeToState:(DownloadState)state{
    NSString *stateTitle;
    switch (state) {
        case DownloadStateDefault:
            stateTitle = @"下载";
            break;
        case DownloadStateDownloading:
            stateTitle = @"暂停";
            break;
        case DownloadStatePausing:
            stateTitle = @"继续";
            break;
        case DownloadStateDownloaded:
            stateTitle = @"查看";
            break;
        default:
            break;
    }
    
    _nameLabel.text = _file.name;
    
    [self.progressView setHidden:!(state == DownloadStateDownloading || state == DownloadStatePausing)];
    [_stateButton setTitle:stateTitle forState:UIControlStateNormal];
    if (state == DownloadStateDownloaded) {
        //[_stateButton defaultStyle];
    }else{
        //[_stateButton primaryStyle];
    }
}

- (void)setProgress:(NSProgress *)progress{
    _progress = progress;
    __weak typeof(self) weakSelf = self;
    if (_progress) {
        [RACObserve(self, progress.fractionCompleted) subscribeNext:^(NSNumber *fractionCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updatePregress:fractionCompleted.doubleValue];
            });
        }];
    }else{
        _progressView.hidden = YES;
    }
}

- (void)updatePregress:(double)fractionCompleted{
    //更新进度
    self.progressView.progress = fractionCompleted;
    if (ABS(fractionCompleted - 1.0) < 0.0001) {
        //已完成
        [self.progressView hidePopUpViewAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            [self changeToState:DownloadStateDownloaded];
        });
    }else{
        self.progressView.hidden = NO;
    }
}

#pragma mark ASProgressPopUpViewDelegate
- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

- (void)progressViewDidHidePopUpView:(ASProgressPopUpView *)progressView{
    progressView.hidden = YES;
}

@end

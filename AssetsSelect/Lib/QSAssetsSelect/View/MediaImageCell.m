//
//  MediaImageCell.m
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/8.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "MediaImageCell.h"
#import "MediaItem.h"
#import "UIView+Extension.h"
//#import "UIImageView+WebCache.h"
#import "MediaUploadView.h"
#import "UIImage+QS.h"
#import  "UIAlertController+QS.h"
#import "NSFileManager+QS.h"

@interface MediaImageCell ()
@property (nonatomic, weak) UIView      *customView;

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImageView *videoImageView;

@property (nonatomic, weak) UIView      *touchView;
@property (nonatomic, weak) UIButton    *uploadStatusBtn;
@property (nonatomic, weak) UIButton    *deleteBtn;

@property (nonatomic, weak) MediaUploadView  *progressView;
//@property (nonatomic, strong) NSProgress *progress;
@end

@implementation MediaImageCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupFrame];
}

#pragma mark - 外部方法
- (void)setItem:(MediaItem *)item
{
    _item = item;

    [self setupUI];
    [self setupData];
    [self setupFrame];
    
    if(item.mediaType != kMediaItemTypeAddAsset &&
       item.UpdataState != MediaUpdataStateNothing) {
        [self uploadProcessing];
    }
}

#pragma mark - 内部实现
- (void)setupUI
{
    [self imageView];

    [self touchView];
    [self uploadStatusBtn];
    [self deleteBtn];
}

- (void)setupData
{
    CGLog(@"---%@---",_item.image);
    
    if(_item.mediaType == kMediaItemTypeImage) {
//        _uploadStatusBtn.hidden = YES;
        _deleteBtn.hidden = NO;
        _videoImageView.hidden = YES;
        self.imageView.image = _item.image;
//        _item.image ? (self.imageView.image = _item.image) : [self.imageView qs_setImageWithUrlStr:self.item.mediaUrl completion:nil];
        
        if(_item.UpdataState == MediaUpdataStateUpdataFailure) {
            [self updataFailure];
        }
        else {
            self.touchView.backgroundColor = [UIColor clearColor];
            self.uploadStatusBtn.hidden = YES;
        }
    }
    if(_item.mediaType == kMediaItemTypeVideo) {
//        _uploadStatusBtn.hidden = YES;
        _deleteBtn.hidden = NO;
        if(_item.mediaUrl.length) {
            if(_item.UpdataState == MediaUpdataStateNothing)  self.videoImageView.hidden = NO;
            UIImage *image = [UIImage getThumbailImageRequestWithUrlString:_item.mediaUrl];
            self.imageView.image = image;
        }
        else if(_item.fileUrl && _item.UpdataState == MediaUpdataStateUpdataSucced) {
            // 从草稿中读取
            self.videoImageView.hidden = NO;
            UIImage *image = [UIImage getThumbailImageRequestWithUrlString:_item.fileUrl.absoluteString];
            self.imageView.image = image ? image : [UIImage imageNamed:@"listPlaceHolder"];
        }
        else {
            self.imageView.image = _item.image;
//            _item.image ? (self.imageView.image = _item.image) : [self.imageView qs_setImageWithUrlStr:self.item.mediaUrl completion:nil];
            if(_item.UpdataState == MediaUpdataStateUpdataSucced) {
                self.videoImageView.hidden = NO;
            }else {
                self.videoImageView.hidden = YES;
            }
        }
        
        if(_item.UpdataState == MediaUpdataStateUpdataFailure) {
            [self updataFailure];
        }
        else {
            self.touchView.backgroundColor = [UIColor clearColor];
            self.uploadStatusBtn.hidden = YES;
        }
    }
    if(_item.mediaType == kMediaItemTypeAddAsset) {
        self.touchView.backgroundColor = [UIColor clearColor];
        _uploadStatusBtn.hidden = YES;
        _videoImageView.hidden = YES;
        _deleteBtn.hidden = YES;
        self.imageView.image = _item.image;
//        _item.image ? (self.imageView.image = _item.image) : [self.imageView qs_setImageWithUrlStr:self.item.mediaUrl completion:nil];
    }
}

- (void)setupFrame
{
    CGFloat x = 0;
    CGFloat y = 0;
//    CGFloat w = kPicWidth;
//    CGFloat h = kPicWidth;
//    self.width = w;
//    self.height = h;
    CGFloat w = self.width;
    CGFloat h = self.height;
    
    self.customView.frame = CGRectMake(x, y, w, h);
    self.imageView.frame = CGRectMake(x, y, w, h);
    CGLog(@"---%@---",NSStringFromCGRect(self.imageView.frame));
    self.touchView.frame = self.imageView.bounds;
    self.progressView.frame = self.imageView.bounds;
    
    w = kIPadSuitFloat(40);
    h = kIPadSuitFloat(40);
    x = (self.imageView.width - w) * 0.5;
    y = (self.imageView.height - w) * 0.5;
    self.videoImageView.frame = CGRectMake(x, y, w, h);
    if(_item.mediaType == kMediaItemTypeAddAsset) self.videoImageView.frame = CGRectZero;
    
    w = self.deleteBtn.width;
    h = self.deleteBtn.height;
    x = self.width - w;
    y = self.height - h;
    self.deleteBtn.frame = CGRectMake(x, y, w, h);
    
    self.uploadStatusBtn.frame = self.touchView.bounds;
}

- (void)uploadProcessing
{
    if(_item.mediaType == kMediaItemTypeVideo) {
        if(_item.UpdataState == MediaUpdataStateNotUpdata) {
            self.progressView.fileType = kMediaTypeVideo;
            [self startUpdating];
            [self handlingFileUploads];
        }
    }
    
    if(_item.mediaType == kMediaItemTypeImage) {
        if(_item.UpdataState == MediaUpdataStateNotUpdata) {
            self.progressView.fileType = kMediaTypeImage;
            [self startUpdating];
            AFTER(0.5, ^{
                [self handlingFileUploads];
            });
        }
    }
}

- (void)startUpdating
{
    _item.UpdataState = MediaUpdataStateUploading;
    self.videoImageView.hidden = YES;
    [self.progressView startUpdating];
}

- (void)finishUpdating
{
    [self.progressView finishUpdating];
}

- (void)updataFailure
{
    [self.progressView updataFailure];
    self.touchView.backgroundColor = QSColor(0, 0, 0, 0.3);
    self.uploadStatusBtn.hidden = NO;
}

- (CGFloat)fileSize
{
    NSString *filePath = _item.fileUrl.absoluteString;
    if([filePath containsString:@"file://"]) {
        NSString *tempStr = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:tempStr]){
            CGFloat size = [[fileManager attributesOfItemAtPath:tempStr error:nil] fileSize];
            CGLog(@"视频大小%g",size/(1024.0*1024));
            return size;
        }
    }
    return 0;
}

- (void)setItemValue:(NSDictionary *)data
{
    if([data isKindOfClass:[NSDictionary class]] && data.count) {

        if(_item.mediaType == kMediaItemTypeImage) {
            NSString *photo = data[@"photo"];
            if(photo.length) {
                _item.UpdataState = MediaUpdataStateUpdataSucced;
                _item.value = photo;
                
                _videoImageView.hidden = YES;
                
                if([_delegate respondsToSelector:@selector(mediaDidUploadedSuccesed:)]) {
                    [_delegate mediaDidUploadedSuccesed:_item];
                }
            }
        }
        else if(_item.mediaType == kMediaItemTypeVideo) {
            NSString *videopic = data[@"videopic"];
            NSString *video = data[@"video"];
          
            if(video.length) {
                _item.UpdataState = MediaUpdataStateUpdataSucced;
                _item.value = video;
                
                self.videoImageView.hidden = NO;
            }
            if(videopic.length)
                _item.videopic = videopic;
            
            if(video.length) {
                if([_delegate respondsToSelector:@selector(mediaDidUploadedSuccesed:)]) {
                    [_delegate mediaDidUploadedSuccesed:_item];
                }
            }
        }
        else {
            _item.UpdataState = MediaUpdataStateUpdataFailure;
            _item.value = nil;
        }
    }
    else {
        _item.UpdataState = MediaUpdataStateUpdataFailure;
        _item.value = nil;
    }
}

- (void)renewalProgress:(NSProgress *)progress
{
    //获取观察的新值
    CGFloat value = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
    //打印
    CGLog(@"资源上传进度 --- %g, 已上传 --- %lld, 总大小 --- %lld", value, progress.completedUnitCount, progress.totalUnitCount);
    if(value >= 1) return;

    self.progressView.progress = value;
}

#pragma mark - 网络链接
- (void)handlingFileUploads
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:App_Delegate.AppToken forKey:@"token"];
    
//    NSProgress *progress = nil;
    

    NSString *url;
    UIImage *image;
    NSString *filePath;
    if(_item.mediaType == kMediaItemTypeImage) {
        url = @"avatar/upimg";
        filePath = nil;
        image = _item.image;
    }
    else if(_item.mediaType == kMediaItemTypeVideo) {
        url = @"avatar/upvideo";
        filePath = _item.fileUrl.absoluteString;
        image = nil;
    }
    
    NSMutableDictionary *dictsM = [NSMutableDictionary dictionary];
    [dictsM setValue:@"https://fc3tn.baidu.com/it/u=1828352163,1863235503&fm=202&src=add_wise_exp" forKey:@"photo"];
    [dictsM setValue:@"33" forKey:@"video"];
    NSDictionary *dict = dictsM;
    self.progressView.progress = 1.0;
    [self finishUpdating];
    [self setItemValue:dict];
    
//    [QSRequestManger uploadVideoURL:url
//                             params:params
//                          videoPath:filePath
//                              image:image
//                      progressBlock:^(NSProgress *progress) {
//                          [self renewalProgress:progress];
//                      }
//                    completionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
//
////                        [progress removeObserver:self
////                                      forKeyPath:@"fractionCompleted"
////                                         context:NULL];
//                        if (error) {
//                            [self finishUpdating];
//                            CGLog(@"response = %@",response);
//                            CGLog(@"Error: %@", error);
//                            [self updataFailure];
//                            [self setItemValue:nil];
//                        } else {
//                            CGLog(@"%@ %@", response, responseObject);
//                            NSDictionary *backDict=(NSDictionary *)responseObject;
//                            NSString *status = [backDict[@"status"] safeString];
//                            if(status.integerValue == 200) {
//                                NSDictionary *dict = [backDict[@"data"] safeDict];
//                                self.progressView.progress = 1.0;
//                                [self finishUpdating];
//                                [self setItemValue:dict];
//                            } else {
//                                [self finishUpdating];
//                                [self updataFailure];
//                                [self setItemValue:nil];
//                            }
//                        }
//
//    }];
}

#pragma mark 事件
- (void)toucheViewDidClick
{
    if(_item.touchClickBlock) _item.touchClickBlock(_item);
    // 图片预览
    if (_item.mediaType == kMediaItemTypeImage) {
        NSLog(@"%s-图片预览",__func__);
    }
    // 视频播放
    if(_item.mediaType == kMediaItemTypeVideo) {
        NSLog(@"%s-视频播放",__func__);
    }
    // 添加
    if(_item.mediaType == kMediaItemTypeAddAsset) {
        NSLog(@"%s-添加",__func__);
    }
}

- (void)deleteBtnDidClick
{
    if(_item.removeItemBlock) _item.removeItemBlock(_item);
    // 删除
    NSLog(@"%s-删除",__func__);
}

- (void)againUpadta:(UIButton *)sender
{
    self.touchView.backgroundColor = [UIColor clearColor];
    sender.hidden = YES;
    [self startUpdating];
    [self handlingFileUploads];
}

#pragma mark - 懒加载
- (UIView *)customView
{
    if(_customView == nil) {
        UIView *customView = [[UIView alloc] init];
        [self addSubview:customView];
        _customView = customView;
    }
    return _customView;
}
- (UIImageView *)imageView
{
    if(_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [self.customView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}
- (UIImageView *)videoImageView
{
    if (_videoImageView == nil) {
        UIImage *image = [UIImage imageNamed:@"sv_pauseStatus"]; // sv_player
        UIImageView *videoImageView = [[UIImageView alloc] initWithImage:image];
        videoImageView.hidden = YES;
        [self.imageView addSubview:videoImageView];
        _videoImageView = videoImageView;
    }
    return _videoImageView;
}

- (UIView *)touchView
{
    if (_touchView == nil) {
        UIView *touchView = [[UIView alloc] init];
//         touchView.backgroundColor = [UIColor blueColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toucheViewDidClick)];
        [touchView addGestureRecognizer:tap];
        [self.customView addSubview:touchView];
        _touchView = touchView;
    }
    return _touchView;
}
- (UIButton *)deleteBtn
{
    if(_deleteBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"icons8-Trash Can Filled Copy 3"];
        UIButton *deleteBtn = [[UIButton alloc] init];
        [deleteBtn setImage:image forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
//        [deleteBtn sizeToFit];
        deleteBtn.size = CGSizeMake(35, 35);
        [self.touchView addSubview:deleteBtn];
        _deleteBtn = deleteBtn;
    }
    return _deleteBtn;
}

- (MediaUploadView *)progressView
{
    if(_progressView == nil) {
        MediaUploadView *progressView = [[MediaUploadView alloc] initWithFrame:self.bounds];
        progressView.hidden = YES;
        [self.customView addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}

- (UIButton *)uploadStatusBtn
{
    if(_uploadStatusBtn == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:@"上传失败\n点击重试" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:kIPadSuitFloat(10)];
        btn.titleLabel.numberOfLines = 2;
        [btn addTarget:self action:@selector(againUpadta:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentMode = UIViewContentModeCenter;
        [btn sizeToFit];
        btn.hidden = YES;
        [self.touchView addSubview:btn];
        _uploadStatusBtn = btn;
    }
    return _uploadStatusBtn;
}


///**
// KVO回调方法
// */
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    //获取观察的新值
//    CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
//    //打印
//    NSLog(@"fractionCompleted --- %f, localizedDescription --- %@, localizedAdditionalDescription --- %@", value, self.progress.localizedDescription, self.progress.localizedAdditionalDescription);
//    if(value >= 1) return;
//    //通知主线程刷新
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.progressView.progress = value;
//    });
//}


@end

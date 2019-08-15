//
//  MediaSelectCell.m
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/8.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "MediaSelectCell.h"

#import "UIColor+HexColor.h"
#import "MediaItem.h"

#import "MLSelectPhotoAssets.h"
#import "MLSelectPhotoPickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "IJSImagePickerController.h"
#import "IJSImageManager.h"
#import "IJSExtension.h"
#import "IJSMapViewModel.h"
#import <IJSFoundation/IJSFoundation.h>
#import <Photos/Photos.h>

#import "NSData+Base64.h"

#import "MediaImageCell.h"
#import "MWPhotoBrowser.h"
// 相机
#import "MediaCameraController.h"
#import "MediaPickContoller.h"
// 视频预览
#import "MediaPlayerController.h"
#import "LEEAlert.h"

#import "NSFileManager+QS.h"

#import "MediaCacheItem.h"

#define kLimitMaxSeconds 60

@interface HCFormImageButton : UIButton
@end

@implementation HCFormImageButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat width = self.currentImage.size.width;
    CGFloat height = self.currentImage.size.height;
    CGFloat x = (self.width - width) * 0.5;
    CGFloat y = (self.height - height) * 0.5;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat width = self.width;
    CGFloat height = kIconFont.lineHeight;
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.imageView.frame) + 8;
    return CGRectMake(x, y, width, height);
}
@end



@interface MediaSelectCell () <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,IJSImagePickerControllerDelegate,MWPhotoBrowserDelegate,MediaImageDelegate>
@property (nonatomic, weak) UIView *customContentView;

@property (nonatomic, strong) MediaItem *addPicItem;
@property (nonatomic, weak) MediaImageCell *addPicIcon;
@property (nonatomic, weak) HCFormImageButton *addPicBtn;
@property (nonatomic, weak) UIView *picsContentView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *valueArray;
@property (nonatomic, strong) NSArray *addedMediaItems;

@property (nonatomic, strong) NSMutableArray *mapDataArr;

/** MWPhoto对象数组 */
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videopic;

@property (nonatomic, assign) NSInteger videoIndex; // 视频的位置
@end

@implementation MediaSelectCell
#pragma mark - 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupAttributed];
        [self setupUI];
        [self setupFrame];
        [self setupVideoTime];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"MediaSelectCell";
    MediaSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MediaSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.tableView = tableView;
    return cell;
}

#pragma mark - 外部方法
- (void)setRowItem:(HCFormRowItem *)rowItem
{
    _rowItem = rowItem;
    if ([_rowItem.value isKindOfClass:[NSArray class]] && [_rowItem.value count]) {
        self.addedMediaItems = [self originalItemsWithDicts:_rowItem.value];
    }
    else {
        [self setupFrame];
    }
}

- (void)setOriginalVideo:(NSString *)videoUrl videoPic:(NSString *)videoPic
{
    _videoUrl = videoUrl;
    _videopic = videoPic;
    
    if(videoUrl.length) {
        _allowPickingVideo = NO;
        MediaItem *item = [[MediaItem alloc] init];
        item.mediaUrl = videoUrl;
        item.videopic = videoPic;
        item.mediaType = kMediaItemTypeVideo;
        item.UpdataState = MediaUpdataStateNothing;
        [self setBlockItem:item];
        
        if(item) self.addedMediaItems = @[item];
    }
}

- (NSArray *)originalItemsWithDicts:(NSArray *)originalData
{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *string in originalData) {
        MediaItem *item = [[MediaItem alloc] init];
        item.mediaUrl = string;
        item.mediaType = kMediaItemTypeImage;
        item.UpdataState = MediaUpdataStateNothing;
        [self setBlockItem:item];
        [arrM addObject:item];
    }
    return arrM;
}

- (void)setImageViews:(NSArray *)imageViews
{
    NSMutableArray *views = [NSMutableArray arrayWithArray:imageViews];
    [views removeObject:self.addPicIcon];

    if(views.count) {
        self.addPicBtn.hidden = YES;
        BOOL hasVideo = NO;
        for (MediaImageCell *view in views) {
            MediaItem *item = view.item;
            if (item.mediaType == kMediaItemTypeVideo) {
                hasVideo = YES;
                break;
            }
        }
        
        if(hasVideo) {
           self.addPicIcon.hidden = YES;
        } else {
            if(views.count < 9 && _showAddBtn) {
                [views addObject:self.addPicIcon];
                self.addPicIcon.hidden = NO;
            }
            else {
                self.addPicIcon.hidden = YES;
            }
        }
    }
    else {
        self.addPicBtn.hidden = NO;
        self.addPicIcon.hidden = YES;
    }
    _imageViews = views;
}

- (void)getVideoComplete:(void(^)(NSString *videoStr,NSString *videopic,BOOL uploading,BOOL failure, BOOL NotUpdata))completeHandle
{
    NSString *videoStr;
    NSString *videopic;
    BOOL uploading = NO;
    BOOL failure = NO;
    BOOL NotUpdata = NO;
    
     for (MediaImageCell *view in _imageViews) {
         MediaItem *item = view.item;

        if(item.mediaType == kMediaItemTypeAddAsset) continue;
        if(item.mediaType == kMediaItemTypeImage) continue;
         
        if(item.mediaType == kMediaItemTypeVideo) {
            if(item.UpdataState == MediaUpdataStateNothing) { // 不用上传
                videoStr = item.mediaUrl;
                videopic = item.videopic;
            }
            else if(item.UpdataState == MediaUpdataStateUpdataSucced) { // 上传成功
                videoStr = item.value;
                videopic = item.videopic;
            }
            else if(item.UpdataState == MediaUpdataStateUploading) { // 上传中
                uploading = YES;
            }
            
            else if(item.UpdataState == MediaUpdataStateUpdataFailure) { // 上传失败
                failure = YES;
            }
            else if(item.UpdataState == MediaUpdataStateNotUpdata) { // 未上传
                NotUpdata = YES;
            }
        }
     }
    
    if(completeHandle) completeHandle(videoStr,videopic,uploading,failure,NotUpdata);
}

- (void)getPhotosComplete:(void(^)(NSArray *origPhotos,NSArray *succePhotos,NSInteger numberOffailure,NSInteger numberOfuploading,NSInteger numberOfNotUpdata))completeHandle
{
    NSMutableArray *origAssets = [NSMutableArray array];        // 初始资源
    NSMutableArray *succeAssets = [NSMutableArray array];       // 上传成功
    NSInteger numberOfuploading = 0;
    NSInteger numberOfFailure = 0;
    NSInteger numberOfNotUpdata = 0;
    for (MediaImageCell *view in _imageViews) {
        MediaItem *item = view.item;
        
        if(item.mediaType == kMediaItemTypeAddAsset) continue;
        if(item.mediaType == kMediaItemTypeVideo) continue;
        
        if(item.mediaType == kMediaItemTypeImage) {
            if(item.UpdataState == MediaUpdataStateNothing) { // 不用上传
                [origAssets addObject:item.mediaUrl];
            }
            else if(item.UpdataState == MediaUpdataStateUpdataSucced) { // 上传成功
                [succeAssets addObject:item.value];
            }
            else if(item.UpdataState == MediaUpdataStateUploading) { // 上传中
                numberOfuploading++;
            }
            else if(item.UpdataState == MediaUpdataStateUpdataFailure) { // 上传失败
                numberOfFailure++;
            }
            else if(item.UpdataState == MediaUpdataStateNotUpdata) { // 未上传
                numberOfNotUpdata++;
            }
        }
    }
    if(completeHandle) completeHandle(origAssets,succeAssets,numberOfFailure,numberOfuploading,numberOfNotUpdata);
}

/** 设置草稿信息 */
- (void)setupDraftInfo:(NSArray *)photo video:(NSString *)videoString completeBack:(void(^)(void))completeBack
{
    
}

#pragma mark - 内部实现
- (void)setupUI {
    self.height = kPicsViewHeight(0) + kIPadSuitFloat(15);
    self.backgroundColor = [UIColor colorWithHexValue:0xf3f3f3];
    [self addPicBtn];
}

- (void)setupAttributed
{
    self.allowPickingVideo = YES;
    self.showAddBtn = NO;
    self.limitAssetCount = 9;
    _imageArray = [NSMutableArray array];
    _videoIndex = -1;
}

- (void)setAddedMediaItems:(NSArray *)addedMediaItems
{
    if (addedMediaItems == nil || addedMediaItems.count == 0) {
        return;
    }
    _addedMediaItems = addedMediaItems;

    // 创建视图
    NSMutableArray *imageViewsM = [NSMutableArray arrayWithArray:self.imageViews];
    
    for (int i = 0; i < addedMediaItems.count; i ++) {
        MediaItem *item = addedMediaItems[i];
        if([item isKindOfClass:[MediaItem class]]) {
            MediaImageCell *imageView = [[MediaImageCell alloc] init];
            imageView.pushViewController = self.pushViewController;
            imageView.backgroundColor = [UIColor colorWithHexValue:0xf3f3f3];
            imageView.delegate = self;
            imageView.catId = self.catId;
            imageView.item = item;
            if(item.mediaType == kMediaItemTypeVideo) {
                _videoIndex = imageViewsM.count;
                _allowPickingVideo = NO;
            }
            [self.picsContentView addSubview:imageView];
            [imageViewsM addObject:imageView];
            
            [self.imageArray addObject:item.image];
        }
    }
    self.imageViews = imageViewsM;
    
    [self setupFrame];
    
    if([_delegate respondsToSelector:@selector(didSelectMediaCell:)]) {
        [_delegate didSelectMediaCell:self];
    }
}

- (void)setupFrame
{
    NSInteger colCount = floor((kPicsViewWidth - 2 * kMargin20) / kPicWidth);
    
    if(_showBigAddBtn) {
        NSInteger colCount = floor((kPicsViewWidth - 2 * kMargin20) / kPicWidth);
        for (int i = 0; i < self.imageViews.count; i ++) {
            NSInteger col = i % colCount;
            NSInteger row = i / colCount;
            CGFloat x = kMargin20 + col * (kPicWidth + kPadding10);
            CGFloat y = kMargin20 + row * (kPicWidth + kPadding10);
            UIImageView *imageView = self.imageViews[i];
            imageView.frame = CGRectMake(x, y, kPicWidth, kPicWidth);
        }
        
        self.picsContentView.height = kPicsViewHeight(self.imageViews.count);
    }
    else {
        if(self.imageViews.count == 1) {
            UIImageView *imageView = self.imageViews.firstObject;
            imageView.x = kMargin20;
            imageView.y = 0;
            imageView.width = (kPicsViewWidth - 2 * kMargin20);
            imageView.height = (kPicsViewWidth - 2 * kMargin20);
        }
        else if(self.imageViews.count > 1){
            for (int i = 0; i < self.imageViews.count; i ++) {
                NSInteger col = i % colCount;
                NSInteger row = i / colCount;
                CGFloat x = kMargin20 + col * (kPicWidth + kPadding10);
                CGFloat y = row * (kPicWidth + kPadding10) + (_showBigAddBtn ? kMargin20 : 0);
                UIImageView *imageView = self.imageViews[i];
                imageView.frame = CGRectMake(x, y, kPicWidth, kPicWidth);
            }
        }
        self.picsContentView.height = CGRectGetMaxY([(UIView *)(self.imageViews.lastObject) frame]) + kMargin20;
    }
    
    self.customContentView.height = CGRectGetMaxY(self.picsContentView.frame);
    self.height = self.customContentView.height + 1;
    
    _rowItem.cellHeight = self.height;
    [self.tableView reloadData];
}

- (void)addImages:(NSArray *)images
{
    if (!images.count) {
        return;
    }
    
    self.addedMediaItems = images;
}

// 删除选中的模型
- (void)removeSelectedItem:(MediaItem *)item
{
    // 清视图
    NSMutableArray *imageViews = [NSMutableArray arrayWithArray:self.imageViews];
    for (MediaImageCell *imageView in imageViews) {
        if(imageView.item == item) {
            [imageViews removeObject:imageView];
            [imageView removeFromSuperview];
        
            if (item.mediaType == kMediaItemTypeImage) {
                [self.imageArray removeObject:item.image];
                /// 移除沙盒文件
                [self removeStoragePhoto:item.value];
            }
            else if (item.mediaType == kMediaItemTypeVideo) {
                /// 移除视频缓存
                [self removeStorageVideo];
                _videoIndex = -1;
            }
        
            break;
        }
    }

    self.addPicIcon.hidden = NO;
    self.imageViews = imageViews;

    [UIView animateWithDuration:0.3 animations:^{
        [self setupFrame];
        
        if([self->_delegate respondsToSelector:@selector(didSelectMediaCell:)]) {
            [self->_delegate didSelectMediaCell:self];
        }
    }];
    
    // 判断是否包含视频资源
    [self judgeHasVideo];
}

- (void)judgeHasVideo
{
    BOOL hasVideo = NO;
    for (MediaImageCell *view in _imageViews) {
        MediaItem *item = view.item;
        if (item.mediaType == kMediaItemTypeVideo) {
            hasVideo = YES;
            break;
        }
    }
    _allowPickingVideo = !hasVideo;
}

- (void)showCustomAlert {
    __weak typeof(self) weakSelf = self;
    NSString *videoTitle = @"立即拍摄";
    
    [LEEAlert actionsheet].config
    .LeeAddAction(^(LEEAction *action) {
        action.title = videoTitle;
        UIImage *image = [UIImage imageNamed:@"media_rectangle"];
        action.image = image;
        action.highlightImage = image;
        CGFloat imgW = image.size.width;
        action.titleEdgeInsets = UIEdgeInsetsMake(0, -imgW, 0, 0);
        
        CGFloat width = [action.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}].width;
        width = width + 0.5 * imgW + 5;
        action.imageEdgeInsets = UIEdgeInsetsMake(-18, width, 0, -width);
        action.clickBlock = ^{
            CGLog(@"选择拍摄");
            [weakSelf openCamera];
        };
    })
    
    .LeeAddAction(^(LEEAction *action) {
        action.height = 60.0f;
        action.title = @"选择本地";
        action.clickBlock = ^{
            CGLog(@"选择本地");
            [weakSelf openAlbum];
        };
    })
    .LeeCancelAction(@"取消", nil)
    .LeeShow();
}

// 打开相册
- (void)openAlbum
{
    __weak typeof(self) weakSelf = self;
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
    imageVc.fromCamera = YES;
    imageVc.minImagesCount = 1;
    imageVc.maxImagesCount = self.limitAssetCount - (self.imageViews.count - [self.imageViews containsObject:_addPicIcon]);

    imageVc.maxVideoCut = _videoMaxTime;
    
    imageVc.allowPickingVideo = _allowPickingVideo; // 是否允许选视频
    imageVc.didFinishUserPickingImageHandle = ^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto, IJSPExportSourceType sourceType) {
        if (sourceType == IJSPImageType)
        {
            NSArray *items = [MediaItem itemsWithPhotos:photos];
            for (MediaItem *item in items) {
                [self setBlockItem:item];
            }
            [weakSelf addImages:items];
        }
        
        if (sourceType == IJSPVideoType) {
            [self isAllowUploadVideoWithSureHandler:^{
                NSURL *url = (NSURL *)avPlayers.firstObject;
                UIImage *image = [[IJSImageManager shareManager] firstFrameWithVideoURL:url size:CGSizeZero];
                
                MediaItem *item = [[MediaItem alloc] init];
                item.image = image;
                item.fileUrl = url;
                item.mediaType = kMediaItemTypeVideo;
                [self setBlockItem:item];
                
                if(item)
                    [weakSelf addImages:@[item]];
                
                self.allowPickingVideo = NO;
            }];
        }
    };
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
        imageVc.mapImageArr = self.mapDataArr;
        [self.pushViewController presentViewController:imageVc animated:YES completion:nil];
    }];
}

// 打开相机
- (void)openCamera
{
    __weak typeof(self) weakSelf = self;
    MediaCameraController *mediaVc = [[MediaCameraController alloc] init];
    mediaVc.maxTime = _videoMaxTime;
    mediaVc.maxImagesCount = self.limitAssetCount - (self.imageViews.count - [self.imageViews containsObject:_addPicIcon]);
    mediaVc.allowPickingVideo = _allowPickingVideo;

    mediaVc.takeBlock = ^(id item) {
        
        if([item isKindOfClass:[NSArray class]]) {
            NSArray *items = (NSArray *)item;
            for (MediaItem *item in items) {
                [weakSelf setBlockItem:item];
                if(item.mediaType == kMediaItemTypeVideo) self->_allowPickingVideo = NO;
            }
            [weakSelf addImages:items];
        }
        
        else if([item isKindOfClass:[MediaItem class]]) {
            MediaItem *t_item = (MediaItem *)item;
            if(t_item.mediaType == kMediaItemTypeVideo) {
                [self isAllowUploadVideoWithSureHandler:^{
                    [weakSelf setBlockItem:t_item];
                    [weakSelf addImages:@[t_item]];
                    self->_allowPickingVideo = NO;
                }];
            }
            else {
                [weakSelf setBlockItem:t_item];
                [weakSelf addImages:@[t_item]];
            }
        }
    };
    MediaPickContoller *imagePickerController = [[MediaPickContoller alloc] initWithRootViewController:mediaVc];
    imagePickerController.dismissBlock = ^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    };
    [self.pushViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)setBlockItem:(MediaItem *)item
{
    __weak typeof(self) weakSelf = self;
    if(item.mediaType == kMediaItemTypeVideo) {
        item.touchClickBlock = ^(MediaItem *item) {
            // 播放视频
            CGLog(@"播放视频");
            [weakSelf previewVideo:item];
        };
        item.removeItemBlock = ^(MediaItem *item) {
            // 删除视频
            CGLog(@"删除视频");
            [self removeSelectedItem:item];
        };
    }
    else {
        item.touchClickBlock = ^(MediaItem *item) {
            // 预览图片
            CGLog(@"预览图片");
            [self browserPhoto:item];
        };
        item.removeItemBlock = ^(MediaItem *item) {
            // 删除图片
            CGLog(@"删除图片");
            [self removeSelectedItem:item];
        };
    }

}

- (void)isAllowUploadVideoWithSureHandler:(void(^)(void))sureHandler
{
//    [QSRequestManger isConnectionAvailable:^(AFNetworkReachabilityStatus status) {
//        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
//        if(status == AFNetworkReachabilityStatusReachableViaWWAN) {
//            CGLog(@"3G|4G");
//            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"当前非WiFi网络环境，确定要上传视频吗？" preferredStyle:UIAlertControllerStyleAlert cancel:@"取消" done:@"确定" doneHandler:^(UIAlertAction *action) {
//                if(sureHandler) sureHandler();
//            }];
//            [self.pushViewController presentViewController:alertVc animated:YES completion:nil];
//        }
//        else {
            if(sureHandler) sureHandler();
//        }
//    }];
}

/// 设置最大视频上传秒数
- (void)setupVideoTime
{
    _videoMaxTime = 10;
}

#pragma mark - 事件
- (void)addPicIconClicked
{
    [self showCustomAlert];
}

- (void)previewVideo:(MediaItem *)item
{
    MediaPlayerController *vc = [[MediaPlayerController alloc] init];
    vc.item = item;
    [self.pushViewController.navigationController pushViewController:vc animated:YES];
}

// 预览图片
- (void)browserPhoto:(MediaItem *)item
{

    NSInteger index = 0;
    CGLog(@"预览图片");
    
    _photos = [NSMutableArray array];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.alwaysShowControls = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.displayNavArrows = NO;
    browser.startOnGrid = NO;
    browser.enableGrid = YES;
   
    for (MediaImageCell *view in _imageViews) {
        MediaItem *model = view.item;
        MWPhoto *photo = [MWPhoto photoWithImage:model.image];
        if(model == item) index = _photos.count;
        if (model.mediaType == kMediaItemTypeImage) {
            if(model.image) {
                photo = [MWPhoto photoWithImage:model.image];
            }
            else {
                NSURL *url = nil;
                if (model.mediaUrl.length) {
                    url = [NSURL URLWithString:model.mediaUrl];
                } else if(model.fileUrl){
                    url = model.fileUrl;
                }
                photo = [MWPhoto photoWithURL:url];
            }
            [_photos addObject:photo];
        }
    }
    [browser setCurrentPhotoIndex:index];
    [self.pushViewController.navigationController pushViewController:browser animated:YES];
}

#pragma mark - 懒加载
- (UIView *)customContentView
{
    if (_customContentView == nil) {
        UIView *customContentView = [[UIView alloc] init];
        [self.contentView addSubview:customContentView];
        _customContentView = customContentView;
        customContentView.backgroundColor = [UIColor colorWithHexValue:0xf3f3f3];
        customContentView.frame = CGRectMake(0, 0, ScreenWidth, kPicsViewHeight(0));
    }
    return _customContentView;
}

- (HCFormImageButton *)addPicBtn
{
    if (_addPicBtn == nil) {
        HCFormImageButton *addPicBtn = [[HCFormImageButton alloc] init];
        [self.picsContentView addSubview:addPicBtn];
        _addPicBtn = addPicBtn;
        addPicBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        addPicBtn.titleLabel.font = kIconFont;
        [addPicBtn setTitleColor:[UIColor colorWithHexValue:0x333333] forState:UIControlStateNormal];
        [addPicBtn setTitle:@"添加照片或视频，最多9张" forState:UIControlStateNormal];
        [addPicBtn setImage:[UIImage imageNamed:@"add-pic-icon-noborder"] forState:UIControlStateNormal];
        addPicBtn.frame = self.picsContentView.bounds;
        [addPicBtn addTarget:self action:@selector(addPicIconClicked) forControlEvents:UIControlEventTouchUpInside];
        
//        // 获取当前显示的添加按钮frame
//        _addCenterPoint = CGPointMake(kMargin12 + addPicBtn.centerX, addPicBtn.centerY + self.picsContentView.y);
    }
    return _addPicBtn;
}

- (UIView *)picsContentView
{
    if (_picsContentView == nil) {
        UIView *picsContentView = [[UIView alloc] init];
        [self.customContentView addSubview:picsContentView];
        _picsContentView = picsContentView;
        picsContentView.backgroundColor = [UIColor whiteColor];
        picsContentView.frame = CGRectMake(kMargin12, 0, kPicsViewWidth, kPicsViewHeight(0));
    }
    return _picsContentView;
}

- (MediaItem *)addPicItem
{
    if(_addPicItem == nil) {
        __weak typeof(self) weakSelf = self;
        MediaItem *item = [[MediaItem alloc] init];
        item.image = [UIImage imageNamed:@"add-pic-icon"];
        item.touchClickBlock = ^(MediaItem *item) {
            [weakSelf showCustomAlert];
        };
        item.mediaType = kMediaItemTypeAddAsset;
        _addPicItem = item;
    }
    return _addPicItem;
}

- (MediaImageCell *)addPicIcon
{
    if (_addPicIcon == nil) {
        MediaImageCell *imageView = [[MediaImageCell alloc] init];
        imageView.item = self.addPicItem;
        imageView.hidden = YES;
        [self.picsContentView addSubview:imageView];
        _addPicIcon = imageView;
    }
    return _addPicIcon;
}


- (NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr = [NSMutableArray array];
    }
    return _mapDataArr;
}

#pragma mark - <MWPhotoBrowserDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

#pragma mark - MediaImageDelegate
- (void)mediaDidUploadedSuccesed:(MediaItem *)mediaItem
{
    [self saveStorageMedia:mediaItem];
}

@end



#pragma mark - MediaSelectCell (Draft)
/*! @brief MediaSelectCell (Draft)
 *
 * 处理草稿相关逻辑
 */
@implementation MediaSelectCell (Draft)
/** 获取草稿信息 */
- (void)setupDraftPhoto:(NSArray *)photos completeBack:(void(^)(void))completeBack
{
//    NSMutableArray *itemArray = [NSMutableArray array];
//    /// 组装图片数据
//    for (NSString *photo in photos) {
//        NSString *url = [kPictureServerURL stringByAppendingPathComponent:photo];
//
//        NSString *name = [NSString stringWithFormat:@"/%@.jpg",photo.md5String];
//        NSString *filePath = [self getExportVideoPathForName:name atDirectory:@"photo"];
//        UIImage *image = [NSFileManager imageForStorageFilePath:filePath];
//        if(image) {
//            MediaItem *item = [MediaItem new];
//            item.image = image;
//            item.value = photo;
//            item.mediaType = kMediaItemTypeImage;
//            item.uploadOK = YES;
//            item.UpdataState = MediaUpdataStateUpdataSucced;
//            [self setBlockItem:item];
//            [itemArray addObject:item];
//        }
//        else {
//            MediaItem *item = [MediaItem new];
//            item.mediaUrl = url;
//            item.value = photo;
//            item.mediaType = kMediaItemTypeImage;
//            item.uploadOK = YES;
//            item.UpdataState = MediaUpdataStateUpdataSucced;
//            [self setBlockItem:item];
//            [itemArray addObject:item];
//        }
//    }
//
//    // 组装视频数据
//    NSString *tableName = [NSString stringWithFormat:@"LifeReleaseDraft_Video_%@",self.catId];
//
//    MediaCacheItem *videoInfoItem = [MediaCacheItem bg_firstObjet:tableName];
//    if(videoInfoItem) {
//        NSInteger index = videoInfoItem.index;
//
//        MediaItem *item = [MediaItem new];
//
//        NSString *fileName = [NSString stringWithFormat:@"/%@.mp4",videoInfoItem.videoUrl.md5String];
//        NSString *fileString = [self getExportVideoPathForName:fileName atDirectory:@"voide"];
//        NSURL *outputURL = [NSURL fileURLWithPath:fileString];
//
//        item.fileUrl = outputURL;
//        item.videopic = videoInfoItem.videopic;
//        item.value = videoInfoItem.videoUrl;
//        item.mediaType = kMediaItemTypeVideo;
//        item.uploadOK = YES;
//        item.UpdataState = MediaUpdataStateUpdataSucced;
//        [self setBlockItem:item];
//
//        if(itemArray.count) {
//            if(index >=0 && itemArray.count > index) {
//                [itemArray insertObject:item atIndex:index];
//            }
//        }
//        else {
//            [itemArray addObject:item];
//        }
//    }
//
//    /// UI显示
//    if(itemArray.count) {
//        [self addImages:itemArray];
//    }
}

- (void)saveStorageMedia:(MediaItem *)item
{
//    /// 图片写入到沙盒，用于草稿中访问
//    if(item.mediaType == kMediaItemTypeImage) {
//        [self saveImage:item.image toDocumentFileName:item.value];
//
//    }
//    else if(item.mediaType == kMediaItemTypeVideo) {
//        NSString *fileName = [NSString stringWithFormat:@"/%@.mp4",item.value.md5String];
//        NSString *fileString = [self getExportVideoPathForName:fileName atDirectory:@"voide"];
//        NSURL *outputURL = [NSURL fileURLWithPath:fileString];
//
//        [NSFileManager saveVideoSourceUrl:item.fileUrl outputURL:outputURL];
//
//        [self saveVideoUrl:item.value videopic:item.videopic];
//    }
}

/// 生成文件和目录全路径
- (NSString *)getExportVideoPathForName:(NSString *)fileName atDirectory:(NSString *)directory
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath =[documentPath stringByAppendingPathComponent:@"ReleaseDraft"];
    if (![fileManager isDirectoryExists:tmpPath])
    {
        [fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [tmpPath stringByAppendingPathComponent:self.catId];
    if (![fileManager isDirectoryExists:filePath])
    {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(directory.length) {
        filePath = [filePath stringByAppendingPathComponent:directory];
        
        if (![fileManager isDirectoryExists:filePath])
        {
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    if(fileName.length) {
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
    
    return filePath;
}

- (void)saveVideoUrl:(NSString *)videoUrl videopic:(NSString *)videopic
{
//    if(!videoUrl.length) return;
//
//    NSString *tableName = [NSString stringWithFormat:@"LifeReleaseDraft_Video_%@",self.catId];
//
//    MediaCacheItem *item = [[MediaCacheItem alloc] init];
//    item.bg_tableName = tableName;
//    item.index = _videoIndex;
//    item.videoUrl = videoUrl;
//    item.videopic = videopic;
//
//    [item bg_coverAsync:nil];
}

- (void)saveImage:(UIImage *)image toDocumentFileName:(NSString *)fileName
{
//    if(!image || !fileName.length) return;
//
//    NSString *name = [NSString stringWithFormat:@"/%@.jpg",fileName.md5String];
//    NSString *fileString = [self getExportVideoPathForName:name atDirectory:@"photo"];
//    [NSFileManager storageImage:image filePath:fileString];
    
}

/** 移除缓存视频相关信息 */
- (void)removeStorageVideo
{
//    NSString *tableName = [NSString stringWithFormat:@"LifeReleaseDraft_Video_%@",self.catId];
//    [MediaCacheItem bg_clearAsync:tableName complete:nil];
//
//    [self cleanVideos];
}

/// 清除.MP4
- (void)cleanVideos
{
    NSString *directoryForVoidePath = [self getExportVideoPathForName:nil atDirectory:@"voide"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:directoryForVoidePath error:nil];
}

/** 移除图片文件夹 */
- (void)removeStorageAllPhoto
{
    NSString *directoryForPhotoPath = [self getExportVideoPathForName:nil atDirectory:@"photo"];
    [[NSFileManager defaultManager] removeItemAtPath:directoryForPhotoPath error:nil];
}

/** 移除存储图片 */
- (void)removeStoragePhoto:(NSString *)photo
{
//    NSString *name = [NSString stringWithFormat:@"/%@.jpg",photo.md5String];
//    NSString *directoryForPhotoPath = [self getExportVideoPathForName:name atDirectory:@"photo"];
//    [NSFileManager removeStorageFilePath:directoryForPhotoPath];
}

@end





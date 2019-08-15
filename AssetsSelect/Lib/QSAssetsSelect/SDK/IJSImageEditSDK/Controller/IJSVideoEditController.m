//
//  IJSVideoEditController.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/21.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoEditController.h"
#import "IJSImageNavigationView.h"
#import "IJSImageToolView.h"
#import "IJSVideoDrawingView.h"
#import "IJSImageConst.h"
#import "IJSIMapViewExportView.h"
#import "IJSIImputTextExportView.h"
#import "IJSIImputTextView.h"
#import "IJSLodingView.h"
#import "IJSVideoTrimView.h"
#import "IJSMapView.h"

#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

#import "IJSImagePickerController.h"

@interface IJSVideoEditController () <IJSVideoTrimViewDelegate>
@property (nonatomic, weak) IJSImageNavigationView *navigationgView; // 导航栏
@property (nonatomic, weak) UIView *playView;                        // 播放的界面----全屏
@property (nonatomic, weak) IJSImageToolView *toolView;              // 工具条
@property (nonatomic, strong) AVPlayer *player;                      // 播放器
@property (nonatomic, strong) IJSVideoDrawingView *videoDrawView;    // 绘画控制器
@property (nonatomic, weak) IJSMapView *mapView;                     // 贴图
@property (nonatomic, weak) IJSIMapViewExportView *exportView;       // 导出的贴图
@property (nonatomic, weak) IJSIImputTextExportView *exportTextView; // 导出的文字视图
@property (nonatomic, weak) IJSIImputTextView *imputTextView;        // 文字导出视图
@property (nonatomic, weak) UIView *placeholderToolView;             // 工具站位视图
@property (nonatomic, strong) AVAsset *resultAvasset;                // 根据分析不同的界面得到的数据进行统一的调制
@property (nonatomic, assign) CGSize videoSize;                      // 视频的尺寸
@property (nonatomic, assign) BOOL isDoing;                          // 正在处理中
@property (nonatomic, strong) NSTimer *listenPlayerTimer;            // 监听的时间
@property (nonatomic, assign) CGFloat videoDuraing;                  // 视频长度
@property (nonatomic, assign) BOOL isPlaying;                        // 正在播放
@property (nonatomic, weak) UIView *cutHodelView;                    // 裁剪工具条
@property (nonatomic, weak) IJSVideoTrimView *trimView;              // 裁剪
@property (nonatomic, weak) IJSImageNavigationView *trimNavigation;  // 裁剪时的导航控制器
@property (nonatomic, assign) CGFloat setVideoHeight;                // 计算出的视频需要加载的高度
@property (nonatomic, assign) CGFloat startTime;                     // 开始时间
@property (nonatomic, assign) CGFloat endTime;                       // 结束时间
@property (nonatomic, assign) CGFloat backStartPosition;            // 回到开始位置
@property(nonatomic,assign) CGRect temporaryPlayViewRect;;  // 临时存储之前的play的尺寸
@end

@implementation IJSVideoEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    self.resultAvasset = [AVAsset assetWithURL:self.outputPath];
    self.videoDuraing = CMTimeGetSeconds([self.resultAvasset duration]);

    self.videoSize = [IJSVideoManager getVideSizeFromAvasset:self.resultAvasset];
    self.isPlaying = YES;
    [self _setupUI];
    [self _setupPlayer]; // 解析数据
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.player pause];
    [self removeListenPlayerTimer];
}
#pragma mark 重新布局UI
- (void)_setupUI
{
    /*
     h 720                jh
     -    ==              --  -------
     w 1280         jw 375
     */
    // 视频播放层
    self.setVideoHeight = JSScreenWidth * (self.videoSize.height / self.videoSize.width);
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarAndNavigationBarHeight, JSScreenWidth, _setVideoHeight)];
    playView.center = self.view.center;
    [self.view addSubview:playView];
    self.playView = playView;
    self.playView.backgroundColor = [UIColor blackColor];
    if (playView.js_height > JSScreenHeight - IJSGTabbarHeight - IJSGNavigationBarHeight)
    {
        playView.js_height = JSScreenHeight - IJSGStatusBarAndNavigationBarHeight - IJSGNavigationBarHeight - IJSGTabbarSafeBottomMargin;
        playView.js_top = IJSGStatusBarAndNavigationBarHeight;
    }
    _temporaryPlayViewRect = playView.frame;
    // 涂鸦层
    // 工具站位视图
    UIView *placeholderToolView = [[UIView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - JSScreenHeight * 230 / 667 - IJSGTabbarSafeBottomMargin, JSScreenWidth, JSScreenHeight * 230 / 667)];
    placeholderToolView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:placeholderToolView];
    placeholderToolView.hidden = YES;
    self.placeholderToolView = placeholderToolView;

    // 导航条
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle localizedStringForKey:@"Done"] style:(UIBarButtonItemStylePlain) target:self action:@selector(_didFinishEditVideoAction)];

    // 工具条
    IJSImageToolView *toolView = [[IJSImageToolView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - IJSGTabbarSafeBottomMargin - ToolBarMarginBottom, JSScreenWidth, ToolBarMarginBottom)];
    [toolView setupUIForVideoEditController];
    toolView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolView];
    self.toolView = toolView;

    //裁剪的工具
    CGFloat ipxMargin = 0;
    if (IJSGiPhoneX)
    {
        ipxMargin = 8;
    }
    UIView *cutHodelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.js_height - IJSVideoSecondCuttrimViewHeight - IJSGTabbarSafeBottomMargin + ipxMargin, JSScreenWidth, IJSVideoSecondCuttrimViewHeight)];
   
    [self.view addSubview:cutHodelView];
    self.cutHodelView = cutHodelView;
    // 裁剪器
    IJSImagePickerController *imagePick = (IJSImagePickerController *) self.navigationController;

    IJSVideoTrimView *trimView = [[IJSVideoTrimView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSVideoSecondCuttrimViewHeight * 0.7) minCutTime:imagePick.minVideoCut ?: 4 maxCutTime:imagePick.maxVideoCut ?: 10 assetDuration:CMTimeGetSeconds([self.resultAvasset duration]) avAsset:self.resultAvasset];

    [cutHodelView addSubview:trimView];
    self.trimView = trimView;
    trimView.delegate = self;
    [trimView getVideoLenghtThenNotifyDelegate]; // 通知代理获取视频开始数据

   //裁剪控制器
    IJSImageNavigationView *trimNavigation = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(trimView.frame), JSScreenWidth, CGRectGetHeight(cutHodelView.frame) - CGRectGetHeight(trimView.frame))];
    [cutHodelView addSubview:trimNavigation];
    trimNavigation.backgroundColor = [UIColor clearColor];
    self.trimNavigation = trimNavigation;

    cutHodelView.hidden = YES;

    ///UI 的点击事件
    [self _buttonAction];
    
    // 前置工具条
    [self.view bringSubviewToFront:self.toolView];
}
/// 解析数据
- (void)_setupPlayer
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:self.resultAvasset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, self.playView.js_width, self.playView.js_height);
    playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    [self.playView.layer addSublayer:playerLayer];
    [self.player play];
    [self startListenPlayerTimer];
}
#pragma mark - 点击事件
/// 按钮事件
- (void)_buttonAction
{
    __weak typeof(self) weakSelf = self;
    //取消
    self.navigationgView.cancleBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    // 完成
    self.navigationgView.finishBlock = ^{
        [weakSelf _didProcessingData];
    };
    /// 工具条事件
    // 画笔
    self.toolView.panButtonBlock = ^(UIButton *button) {
        [weakSelf _hiddenVideoDrawingViewSubView:NO];
        [weakSelf _videoDrawToolSubViewUnableUserInteractionEnabled:YES];
        weakSelf.placeholderToolView.hidden = YES;
    };
    // 贴图
    self.toolView.smileButtonBlock = ^(UIButton *button) {
        [weakSelf _hiddenVideoDrawingViewSubView:YES];
        [weakSelf _videoDrawToolSubViewUnableUserInteractionEnabled:NO];
        weakSelf.placeholderToolView.hidden = NO;
        weakSelf.mapView.hidden = NO; // 传图
    };
    // 文字
    self.toolView.textButtonBlock = ^(UIButton *button) {
        [weakSelf _hiddenVideoDrawingViewSubView:YES];
        [weakSelf _videoDrawToolSubViewUnableUserInteractionEnabled:NO];
        weakSelf.placeholderToolView.hidden = YES;
        weakSelf.imputTextView.hidden = NO;
        if (weakSelf.navigationController)
        {
            [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
        }
    };
    // 裁剪
    self.toolView.clipButtonBlock = ^(UIButton *button) {
        [weakSelf _hiddenVideoDrawingViewSubView:YES]; //隐藏画板
        [weakSelf _videoDrawToolSubViewUnableUserInteractionEnabled:NO];  // 不允许交互
        weakSelf.cutHodelView.hidden = NO;
        weakSelf.placeholderToolView.hidden = YES;
        [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
        weakSelf.toolView.hidden = YES;  // 隐藏工具条
        [weakSelf.view bringSubviewToFront:weakSelf.cutHodelView];
         [weakSelf resetTrimView];  //重新加预览条
    };

    //裁剪时候取消
    self.trimNavigation.cancleBlock = ^{
        weakSelf.cutHodelView.hidden = YES;
        weakSelf.playView.frame =weakSelf.temporaryPlayViewRect;
        [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
        weakSelf.toolView.hidden = NO;  // 不隐藏工具条
    };
    // 裁剪完成了
    self.trimNavigation.finishBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.cutHodelView.hidden = YES;
            weakSelf.playView.frame = weakSelf.temporaryPlayViewRect;
            weakSelf.playView.center = weakSelf.view.center;
            [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
            weakSelf.toolView.hidden = NO;  // 不隐藏工具条
            [weakSelf.player pause];
        });
        if (weakSelf.isDoing)
        {
            return;
        }
        weakSelf.isDoing = YES;

//        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//        [SVProgressHUD showWithStatus:@"正在处理中"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:weakSelf.resultAvasset startTime:weakSelf.startTime endTime:weakSelf.endTime completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {

//            [SVProgressHUD dismiss];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            weakSelf.isDoing = NO;
            if (error)
            {
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"裁剪短一些更精彩哦!"] preferredStyle:(UIAlertControllerStyleActionSheet)];
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                    [alertView dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertView addAction:cancle];
                [weakSelf presentViewController:alertView animated:YES completion:nil];
            }
            else
            {
                weakSelf.resultAvasset = [AVAsset assetWithURL:outputPath];
                [weakSelf _setupPlayer];
                weakSelf.videoDuraing = CMTimeGetSeconds([weakSelf.resultAvasset duration]);
            }
        }];
    };
}
#pragma mark - 满足要求完成选择
- (void)_didFinishEditVideoAction
{
    [self _didProcessingData];
}
///完成选择功能实现
- (void)_didProcessingData
{
    if (self.isDoing)
    {
        return;
    }
    self.isDoing = YES;

//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    [SVProgressHUD showWithStatus:@"正在处理中"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;

    [self _completeCallback:^(UIImage *image) {

        [IJSVideoManager addWatermarkForVideoAsset:weakSelf.resultAvasset waterImage:image describe:IJSLOG completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {

//            [SVProgressHUD dismiss];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            weakSelf.isDoing = NO;
            if (error)
            {
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"请将裁剪时长变小"] preferredStyle:(UIAlertControllerStyleActionSheet)];
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                    [alertView dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertView addAction:cancle];
                [weakSelf presentViewController:alertView animated:YES completion:nil];
            }
            else
            {
                if (weakSelf.navigationController)
                {
                    if(((IJSImagePickerController *)weakSelf.navigationController).fromCamera) {
                        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                            [weakSelf _outputVideoPath:outputPath error:error state:state];
                        }];
                    }
                    else {
                        [weakSelf _outputVideoPath:outputPath error:error state:state];
                        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                else
                {
                    if(((IJSImagePickerController *)weakSelf.navigationController).fromCamera) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            [weakSelf _outputVideoPath:outputPath error:error state:state];
                        }];
                    }
                    else{
                        [weakSelf _outputVideoPath:outputPath error:error state:state];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
        }];
    }];
}
/// 私有方法
-(void)_outputVideoPath:(NSURL *)outputPath error:(NSError *)error state:(IJSVideoState)state
{
    IJSImagePickerController *imagePickVc = (IJSImagePickerController *) self.navigationController;
    if (imagePickVc.didFinishUserPickingImageHandle)
    {
        imagePickVc.didFinishUserPickingImageHandle(nil, @[outputPath], nil, nil, NO, IJSPVideoType);
    }
    if ([imagePickVc.imagePickerDelegate respondsToSelector:@selector(imagePickerController:isSelectOriginalPhoto:didFinishPickingPhotos:assets:infos:avPlayers:sourceType:)])
    {
        [imagePickVc.imagePickerDelegate imagePickerController:imagePickVc isSelectOriginalPhoto:NO didFinishPickingPhotos:nil assets:nil infos:nil avPlayers:@[outputPath] sourceType:IJSPVideoType];
    }
    if ([self.delegate respondsToSelector:@selector(didFinishEditVideoWithController:outputPath:error:state:)])
    {
        [self.delegate didFinishEditVideoWithController:self outputPath:outputPath error:error state:state];
    }
}


#pragma mark 懒加载区域
//画笔
- (IJSVideoDrawingView *)videoDrawView
{
    if (_videoDrawView == nil)
    {
        if (IJSGiPhoneX)
        {
            _videoDrawView = [[IJSVideoDrawingView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarAndNavigationBarHeight, JSScreenWidth, JSScreenHeight - IJSGStatusBarAndNavigationBarHeight -IJSGTabbarSafeBottomMargin - ToolBarMarginBottom) drawingViewSize:CGSizeMake(self.playView.js_width, self.playView.js_height)];
        }
        else
        {
            _videoDrawView = [[IJSVideoDrawingView alloc] initWithFrame:CGRectMake(0, IJSGNavigationBarHeight, JSScreenWidth, JSScreenHeight - IJSGNavigationBarHeight  - ToolBarMarginBottom) drawingViewSize:CGSizeMake(self.playView.js_width, self.playView.js_height)];
        }
        _videoDrawView.controller = self;
        [self.view addSubview:_videoDrawView];
    }
    return _videoDrawView;
}
// 贴图
- (IJSMapView *)mapView
{
    if (_mapView == nil)
    {
        __weak typeof(self) weakSelf = self;
        if (((IJSImagePickerController *) (self.navigationController)).mapImageArr)
        {
            NSMutableArray *mapDataArr = ((IJSImagePickerController *) (self.navigationController)).mapImageArr;
            IJSMapView *mapView = [[IJSMapView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, JSScreenHeight * 230 / 667) imageData:mapDataArr];
            [self.placeholderToolView addSubview:mapView];
            _mapView = mapView;
            // 点击回调添加图片
            mapView.didClickItemCallBack = ^(NSInteger index, UIImage *indexImage) {
                weakSelf.exportView.backImage = indexImage;
                weakSelf.placeholderToolView.hidden = YES;
            };
            mapView.cancelCallBack = ^{
                weakSelf.placeholderToolView.hidden = YES;
            };
        }
    }
     [self.view bringSubviewToFront:self.placeholderToolView];
    return _mapView;
}

// 文字视图
- (IJSIImputTextView *)imputTextView
{
    __weak typeof(self) weakSelf = self;
    if (_imputTextView == nil)
    {
        IJSIImputTextView *imputView = [[IJSIImputTextView alloc] initWithFrame:self.view.bounds];
        imputView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:imputView];
        [self.view bringSubviewToFront:imputView];
        _imputTextView = imputView;
        //确定按钮
        _imputTextView.textCallBackBlock = ^(UITextView *textView) {
            weakSelf.placeholderToolView.hidden = YES;
            weakSelf.exportTextView.textView = textView;
            if (weakSelf.navigationController)
            {
                [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
            }
        };
        // 取消
        _imputTextView.textCancelCallBack = ^{
            if (weakSelf.navigationController)
            {
                [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
            }
        };
    }
    return _imputTextView;
}

//导出贴图视图
- (IJSIMapViewExportView *)exportView
{
    IJSIMapViewExportView *exportView = [[IJSIMapViewExportView alloc] initWithFrame:CGRectMake(0, 0, IJSIMapViewExportViewImageHeight, IJSIMapViewExportViewImageHeight)];
    exportView.center = self.videoDrawView.drawingView.center;
    [self.videoDrawView addSubview:exportView];
    exportView.backgroundColor = [UIColor clearColor];
    _exportView = exportView;

    __weak typeof(exportView) weakexPortView = exportView;
    __weak typeof(self) weakSelf = self;

    exportView.mapViewExpoetViewTapCallBack = ^{
        [weakexPortView hiddenSquareViewState:NO];
    };
    //改变导出视图的中心点
    exportView.mapViewExpoetViewPanCallBack = ^(CGPoint viewPoint) {

        // x
        if (viewPoint.x < 0 ||
            viewPoint.x > JSScreenWidth)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
        // y
        if (viewPoint.y < weakSelf.videoDrawView.drawingView.js_top - weakexPortView.js_width * 0.3 ||
            viewPoint.y > weakSelf.videoDrawView.drawingView.js_bottom + weakexPortView.js_width * 0.3)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
        // 最大值
        if (viewPoint.y < IJSVideoEditNavigationHeight ||
            viewPoint.y > JSScreenHeight - IJSVideoEditNavigationHeight - ToolBarMarginBottom)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
    };

    return _exportView;
}

// 文字文字视图
- (IJSIImputTextExportView *)exportTextView
{
    IJSIImputTextExportView *exportTextView = [[IJSIImputTextExportView alloc] initWithFrame:CGRectMake(0, 0, IJSIMapViewExportViewImageHeight, IJSIMapViewExportViewImageHeight)];
    exportTextView.center = self.videoDrawView.drawingView.center;
    [self.videoDrawView addSubview:exportTextView];
    exportTextView.backgroundColor = [UIColor clearColor];
    _exportTextView = exportTextView;
    // 单击
    __weak typeof(self) weakSelf = self;
    __weak typeof(exportTextView) weakexPortView = exportTextView;

    exportTextView.handleSingleTap = ^(UITextView *textView, BOOL isTap) {
        weakSelf.imputTextView.tapTextView = textView;
         [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
    };
    // 改变坐标
    exportTextView.textViewExpoetViewPanCallBack = ^(CGPoint viewPoint) {
        // x
        if (viewPoint.x < -weakexPortView.js_width * 0.3 ||
            viewPoint.x > JSScreenWidth + weakexPortView.js_width * 0.3)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
        // y
        if (viewPoint.y < weakSelf.videoDrawView.drawingView.js_top - weakexPortView.js_width * 0.3 ||
            viewPoint.y > weakSelf.videoDrawView.drawingView.js_bottom + weakexPortView.js_width * 0.3)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
        // 最大值
        if (viewPoint.y < IJSVideoEditNavigationHeight ||
            viewPoint.y > JSScreenHeight - IJSVideoEditNavigationHeight - ToolBarMarginBottom)
        {
            weakexPortView.center = weakSelf.videoDrawView.drawingView.center;
        }
    };

    return _exportTextView;
}

/*------------------------------------私有方法-------------------------------*/
///隐藏画笔的子视图
- (void)_hiddenVideoDrawingViewSubView:(BOOL)state
{
    self.videoDrawView.colorView.hidden = state;
    self.videoDrawView.toolBarView.hidden = state;
}
/// 移除videoDrawView的
- (void)_removeVideoDrawViewToolView
{
    [self.videoDrawView.colorView removeFromSuperview];
    [self.videoDrawView.toolBarView removeFromSuperview];
}
/// 便利UI 让子视图不能交互
- (void)_videoDrawToolSubViewUnableUserInteractionEnabled:(BOOL)state
{
    self.videoDrawView.drawingView.userInteractionEnabled = state;
}
/// 新建一个预览图
-(void)resetTrimView
{
    [self.trimView removeFromSuperview];
    IJSImagePickerController *imagePick = (IJSImagePickerController *) self.navigationController;
    IJSVideoTrimView *trimView = [[IJSVideoTrimView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSVideoSecondCuttrimViewHeight * 0.7) minCutTime:imagePick.minVideoCut ?: 4 maxCutTime:imagePick.maxVideoCut ?: 10 assetDuration:CMTimeGetSeconds([self.resultAvasset duration]) avAsset:self.resultAvasset];
    [self.cutHodelView addSubview:trimView];
    self.trimView = trimView;
    trimView.delegate = self;
    [trimView getVideoLenghtThenNotifyDelegate]; // 通知代理获取视频开始数据
}
/*------------------------------------逻辑处理-------------------------------*/
#pragma mark 绘制DrawViewd的所有子视图成图片
- (void)_completeCallback:(void (^)(UIImage *image))completeCallback
{
    [self _removeVideoDrawViewToolView]; //移除工具条

    UIGraphicsBeginImageContextWithOptions(self.playView.frame.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [self.videoDrawView.drawingView.layer renderInContext:ctx];

    for (UIView *subView in self.videoDrawView.subviews)
    {
        if ([subView isKindOfClass:[IJSIMapViewExportView class]] || [subView isKindOfClass:[IJSIImputTextExportView class]]) //贴图
        {
            UIImage *tempImage = [self.class _screenshot:subView orientation:UIDeviceOrientationPortrait usePresentationLayer:YES];
            CGRect newRect = [subView convertRect:CGRectMake(0, 0, 0, 0) toView:self.videoDrawView.drawingView]; //计算想对位置
            [tempImage drawInRect:CGRectMake(newRect.origin.x, newRect.origin.y, subView.js_width, subView.js_height)];
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *endimage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
        if (completeCallback)
        {
            completeCallback(endimage);
        }
    });
}
/// 或者成图片
//绘制的方法
+ (UIImage *)_screenshot:(UIView *)view orientation:(UIDeviceOrientation)orientation usePresentationLayer:(BOOL)usePresentationLayer
{
    CGSize size = view.bounds.size;
    CGSize targetSize = CGSizeMake(size.width * view.layer.js_transformScaleX, size.height * view.layer.js_transformScaleY);
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
#pragma mark - touch方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isPlaying)
    {
        [self.player play];
        self.placeholderToolView.hidden = YES;
    }
    else
    {
        [self.player pause];
    }
}

#pragma mark - 播放监听器
#pragma mark 开始定时器
- (void)startListenPlayerTimer
{
    [self removeListenPlayerTimer];
    self.listenPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(listenPlayerTimerResetTimerInEditVc) userInfo:nil repeats:YES];
}
#pragma mark 清空定时器
- (void)removeListenPlayerTimer
{
    if (self.listenPlayerTimer)
    {
        [self.listenPlayerTimer invalidate];
        self.listenPlayerTimer = nil;
    }
}
#pragma mark 监听播放的状态
// 播放中
- (void)listenPlayerTimerResetTimerInEditVc
{
    self.backStartPosition = CMTimeGetSeconds([self.player currentTime]);
    [self.trimView changeTrackerViewOriginX:self.backStartPosition];
    if (self.backStartPosition >= self.endTime)
    {
        self.backStartPosition = self.startTime;
        [self seekVideoToPos:self.startTime];
        [self.trimView changeTrackerViewOriginX:self.startTime];
    }
}
// 播放结束
- (void)seekVideoToPos:(CGFloat)position
{    
    self.backStartPosition = position;
    CMTime time = CMTimeMakeWithSeconds(self.backStartPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
#pragma mark - IJSVideoTrimViewDelegate 代理方法
- (void)trimView:(IJSVideoTrimView *)trimView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoLength:(CGFloat)length
{
    if (startTime != self.startTime)
    {
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    self.endTime = endTime;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end

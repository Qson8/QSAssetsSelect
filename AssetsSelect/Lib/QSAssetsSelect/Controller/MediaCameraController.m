//
//  MediaCameraController.m
//  SydneyToday
//
//  Created by Qson on 2017/12/12.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import "MediaCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <IJSFoundation/IJSFFilesManager.h>
#import "UINavigationController+FDFullscreenPopGesture.h"

#import "MediaItem.h"
#import "MediaPickContoller.h"
#import "HCPlayerView.h"

#import "MediaProgressView.h"
#import "IJSImageManager.h"
#import "IJSVideoManager.h"
#import "UIImage+QS.h"
#import "NSString+QS.h"

#import "IJSPhotoPickerController.h"
#import "IJSImagePickerController.h"
#import "IJSImageManager.h"

#import "IJSMapViewModel.h"

#import "UAProgressView.h"
#import "DeviceOrientation.h"
#import <AudioToolbox/AudioToolbox.h>

//时间大于这个就是视频，否则为拍照
#define TimeMax 0.5
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface MediaCameraController () <AVCaptureFileOutputRecordingDelegate,IJSImagePickerControllerDelegate,DeviceOrientationDelegate>

@property (nonatomic, strong) DeviceOrientation *deviceMotion;
@property (nonatomic, assign) UIImageOrientation direction; // 记录设备拍摄前设备方向
@property (nonatomic, assign) BOOL      animatedTag;
/** UI */
@property (nonatomic, weak) UIView      *topBar;
@property (nonatomic, weak) UIButton    *flashBtn;
@property (nonatomic, weak) UIButton    *closeBtn;

@property (nonatomic, weak) UIView      *shootView;
@property (nonatomic, weak) UIImageView *shootBgView;
@property (nonatomic, weak) UIImageView *focusCursor; //聚焦光标

@property (nonatomic, weak) UIView      *bottomView;
@property (nonatomic, weak) UILabel     *desLabel;
@property (nonatomic, weak) UIButton    *timeBtn;
@property (nonatomic, weak) UIView      *toolBar;

@property (nonatomic, weak) UIView *    shutterView;
@property (nonatomic, weak) UIImageView *takePhotoView;
@property (nonatomic, weak) UIImageView *innerRingView;
@property (nonatomic, weak) UAProgressView *progressView;

// 拍摄前
@property (nonatomic, weak) UIButton    *albumBtn;
@property (nonatomic, weak) UIButton    *switchCameraBtn;
// 拍摄后
@property (nonatomic, weak) UIButton    *backBtn;
@property (nonatomic, weak) UIButton    *editBtn;
@property (nonatomic, weak) UIButton    *playBtn;

/** video */
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
//负责输入和输出设备之间的数据传递
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;
//视频输出流
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;
//是否在对焦
@property (assign, nonatomic) BOOL isFocus;
//是否是摄像 YES 代表是录制  NO 表示拍照
@property (assign, nonatomic) BOOL isVideo;
//后台任务标识
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (assign,nonatomic) UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier;

@property (strong, nonatomic) UIImage *takeImage;
@property (strong, nonatomic) UIImageView *takeImageView;
//记录需要保存视频的路径
@property (strong, nonatomic) NSURL *saveVideoUrl;
//记录录制的时间
@property (assign, nonatomic) CGFloat seconds;
@property (assign, nonatomic) CGFloat progress;

@property (nonatomic, strong) NSMutableArray *mapDataArr;
@end

@implementation MediaCameraController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allowPickingVideo = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupNavi];
    
    self.deviceMotion = [[DeviceOrientation alloc]initWithDelegate:self];
    if(self.limitMaxSeconds == 0) self.limitMaxSeconds = _maxTime;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:UIApplicationWillResignActiveNotification object:nil];

    [[AVAudioSession sharedInstance] setActive:YES withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
//    [self customCamera];
//    [self.session startRunning];
    [self requestGranted];
//    [self setFlash:self.flashBtn.selected];
    
}

// 处理界面交互（非授权下关闭交互）
- (void)setInteractionEnabled:(BOOL)enabled
{
    self.bottomView.userInteractionEnabled = enabled;
}

- (void)requestGranted {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        CGLog(@"是否授权相机 = %d ",granted);
        if(granted) { // 用户允许
            dispatch_async(dispatch_get_main_queue(), ^{
                [self customCamera];
                [self.session startRunning];
                [self setInteractionEnabled:YES];
            });
        }
        else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"您没有授权访问相机的权限,请到设置中开启" preferredStyle:UIAlertControllerStyleAlert cancel:@"好的" done:nil doneHandler:nil];
                 [self presentViewController:alertController animated:YES completion:nil];
                 [self setInteractionEnabled:NO];
             });
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startMonitor]; // 开始监控屏幕方向
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
//    [self setFlash:NO];
    [self stop]; // 停止监控屏幕方向
}

- (void)dealloc
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:NO withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    CGLog(@"%s",__func__);
}

#pragma mark - 初始化
- (void)setupNavi
{
    // 隐藏状态栏
    self.fd_prefersNavigationBarHidden = YES;
}
- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self setupFrame];
    
    if(self.cameraTip.length) {
        self.desLabel.text = self.cameraTip;
    }
    else {
        if(self.allowPickingVideo == NO) {
            self.desLabel.text = @"轻触拍照";
        }
    }
}

- (void)setupFrame
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = ScreenWidth;
    CGFloat h = 0;
    
    // 0. content
//    h = ScreenHeight - kMargin167;
    h = ScreenHeight;
    self.shootView.frame = CGRectMake(x, y, w, h);
    self.shootBgView.frame =  CGRectMake(x, y, w, h);
    
    // 1. top
    h = kMargin40;
    w = self.closeBtn.width;
    y = (kStatusBarHeight - 20) + kMargin24;
    x = ScreenWidth - w - kMargin20;
    self.topBar.frame = CGRectMake(x, y, w, h);

    // 1.1 close
    self.closeBtn.frame = self.topBar.bounds;
    // 1.2 flash
//    x = kMargin12;
//    y = (kStatusBarHeight - 20) + kMargin24;
//    w = kMargin40;
//    h = kMargin40;
//    self.flashBtn.frame = CGRectMake(x, y, w, h);
    
    // 2. bottom
    x = 0;
    h = kMargin167;
    y = ScreenHeight - kMargin167;
    w = ScreenWidth;
    self.bottomView.frame = CGRectMake(x, y, w, h);
    // 2.1 文字
    w = self.bottomView.width;
    h = self.desLabel.height;
    x = 0;
    y = kMargin20;
    self.desLabel.frame = CGRectMake(x, y, w, h);
    // 2.2 底部操控区
    x = 0;
    y = CGRectGetMaxY(self.desLabel.frame);
    w = ScreenWidth;
    h = self.bottomView.height - y;
    self.toolBar.frame = CGRectMake(x, y, w, h);
    // 2.2.1 圈
    w = self.progressView.width;
    h = w;
    y = self.toolBar.height - kMargin32 - h;
    x = (self.toolBar.width - w) * 0.5;
    self.shutterView.frame = CGRectMake(x, y, w, h);
    
    x = 0;
    y = 0;
    self.progressView.frame = CGRectMake(x, y, w, h);
    // 快门键
    h = self.takePhotoView.width;
    w = h;
    y = (self.shutterView.width - w) * 0.5;
    x = (self.shutterView.width - w) * 0.5;;
    self.takePhotoView.frame = CGRectMake(x, y, w, h);
    // 2.2.2 相册
    x = kMargin20;
    w = kMargin40;
    h = w;
    y = self.toolBar.height - kMargin52 - h;
    self.albumBtn.frame = CGRectMake(x, y, w, h);
    // 2.2.3 摄像头
    w = kMargin40;
    h = w;
    x = self.toolBar.width - kMargin20 - w;
    y = self.toolBar.height - kMargin52 - h;
    self.switchCameraBtn.frame = CGRectMake(x, y, w, h);
    // 2.2.4 时间
    h = self.timeBtn.height;
    w = self.timeBtn.imageView.width + self.timeBtn.titleLabel.width + kMargin4;
    x = (self.toolBar.width - w) * 0.5;
    y = self.shutterView.y - kMargin4 - h;
    self.timeBtn.frame = CGRectMake(x, y, w, h);
    
    // 拍摄后
    self.backBtn.frame = self.albumBtn.frame;
    self.editBtn.frame = self.switchCameraBtn.frame;
    
    w = self.playBtn.width;
    h = self.playBtn.height;
    x = (self.shootBgView.width - w) * 0.5;
    y = (self.shootBgView.height - h) * 0.5;
    self.playBtn.frame = CGRectMake(x, y, w, h);
}

- (void)customCamera {
    //初始化会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];
    //设置分辨率 (设备支持的最高分辨率)
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    //取得后置摄像头
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    //初始化输入设备
    NSError *error = nil;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        CGLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //添加音频
    error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        CGLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //输出对象
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    
    //将输入设备添加到会话
    if ([self.session canAddInput:self.captureDeviceInput]) {
        [self.session addInput:self.captureDeviceInput];
        [self.session addInput:audioCaptureDeviceInput];
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.shootBgView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    [self.shootBgView.layer addSublayer:self.previewLayer];
    
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
}

#pragma mark - 内部实现
/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point
{
    if (!self.isFocus) {
        self.isFocus = YES;
        self.focusCursor.center=point;
        self.focusCursor.transform = CGAffineTransformMakeScale(1.25, 1.25);
        self.focusCursor.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.focusCursor.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.5];
        }];
    }
}

/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        //曝光模式
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        //聚焦
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        
        //聚焦点的位置
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

//拍摄完成时调用
- (void)showSuccessToolBar
{
    self.albumBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    
    self.backBtn.hidden = NO;
    self.editBtn.hidden = NO;
    if (self.isVideo && _allowPickingVideo) {
        self.playBtn.hidden = NO;
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [MBProgressHUD hiddenAllHUDForView:self.view animated:YES];
}

- (void)changeLayout {

    self.flashBtn.hidden = YES;
//    self.closeBtn.hidden = YES;
    self.takePhotoView.userInteractionEnabled = NO;
    if (self.isVideo && _allowPickingVideo) {
        [self.shootBgView bringSubviewToFront:self.playBtn];
    }
    self.desLabel.hidden = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.takePhotoView.transform = CGAffineTransformIdentity;
        self.progressView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.animatedTag = YES;
        if (self.isVideo && self.allowPickingVideo) {
            self.timeBtn.hidden = NO;
        }
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
//        [self.view layoutIfNeeded];
    }];
    
    self.lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    [self.session stopRunning];
}

//重新拍摄时调用
- (void)recoverLayout
{
    [self.shootBgView.layer addSublayer:self.previewLayer];
    
    self.animatedTag = NO;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [MBProgressHUD hiddenAllHUDForView:self.view animated:YES];
    [self startMonitor]; // 开始监控屏幕方向
    self.saveVideoUrl = nil;
    if (self.isVideo && _allowPickingVideo) {
        self.isVideo = NO;
        [self.player pause];
        self.player = nil;
        [_playerLayer removeFromSuperlayer];
        self.playBtn.hidden = YES;
        self.timeBtn.hidden = YES;
        self.progressView.progress = 0;
        [self scaleView:NO];
    }
    [self.session startRunning];
    if (!self.takeImageView.hidden) {
        self.takeImageView.hidden = YES;
    }
    self.takePhotoView.userInteractionEnabled = YES;
    self.desLabel.hidden = NO;
    self.flashBtn.hidden = NO;
    self.albumBtn.hidden = NO;
//    self.closeBtn.hidden = NO;
    self.switchCameraBtn.hidden = NO;
    self.backBtn.hidden = YES;
    self.editBtn.hidden = YES;
    
//    [self setFlash:self.flashBtn.selected];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)onStartTranscribe:(NSURL *)fileURL
{
    if ([self.captureMovieFileOutput isRecording]) {

        if (self.seconds >= 0 && _allowPickingVideo) {
            if (self.limitMaxSeconds - self.seconds >= TimeMax && !self.isVideo) {
                self.isVideo = YES;//长按时间超过TimeMax 表示是视频录制
                self.progress = 0;
//                self.progressView.timeMax = self.seconds;
            }
            if(self.isVideo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView setProgress:1 - (self.seconds) / self.limitMaxSeconds];
                    [self renewTimeView];
                });
            }
            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.05];
        } else {
            if ([self.captureMovieFileOutput isRecording]) {
                [self.captureMovieFileOutput stopRecording];
            }
        }
        
//        if(self.isVideo && self.progress <= self.limitMaxSeconds) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CGLog(@"倒计时 %g----%g --- %g",self.seconds,self.progress,self.progress / self.limitMaxSeconds);
////                [self.progressView setProgress:1 - (self.seconds + TimeMax) / self.limitMaxSeconds];
//                [self.progressView setProgress:self.progress / self.limitMaxSeconds];
//                [self renewTimeView];
//            });
//        }
//        if(self.progress <= self.limitMaxSeconds) {
//            self.progress += 0.05;
//            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.05];
//        }

        self.seconds -= 0.05;
    }
}
- (void)scaleView:(BOOL)isScale
{
    [UIView animateWithDuration:0.15 animations:^{
        if(isScale)
            self.takePhotoView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        else
            self.takePhotoView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

- (void)renewTimeView
{
//        self.timeBtn.hidden = NO;
        CGLog(@"%f---%f",self.limitMaxSeconds,self.seconds);
        NSString *secStr = [NSString stringWithFormat:@"%d秒",(int)(round(self.limitMaxSeconds - (self.seconds)))];
        [self.timeBtn setTitle:secStr forState:UIControlStateNormal];
        [self.timeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, kMargin4)];
        
        CGFloat titleW = [secStr sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:self.timeBtn.titleLabel.font].width;
        CGFloat h = self.timeBtn.height;
        CGFloat y = self.timeBtn.y;
        CGFloat w = self.timeBtn.imageView.width + titleW + kMargin4;
        CGFloat x = (self.toolBar.width - w) * 0.5;
        self.timeBtn.frame = CGRectMake(x, y, w, h);
}

#pragma mark - 事件
- (void)closeBtnDidClick
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    MediaPickContoller *naviVc = (MediaPickContoller *)self.navigationController;
    if(naviVc.dismissBlock) naviVc.dismissBlock();
    [naviVc dismissViewControllerAnimated:YES completion:nil];
    
    CGLog(@"%@",naviVc.presentingViewController);
}

- (void)presentCurrentVcWithCompleted:(void(^)(void))completeBlock
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    MediaPickContoller *naviVc = (MediaPickContoller *)self.navigationController;
    if(naviVc.dismissBlock) naviVc.dismissBlock();
    [naviVc dismissViewControllerAnimated:YES completion:^{
        if(completeBlock)completeBlock();
    }];
}
/*
- (void)flashBtnDidClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    BOOL on = sender.selected;
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"flashState"];
    [self setFlash:on];
}
 */

- (void)setFlash:(BOOL)on
{
    if (on) { //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }
    else{//关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)albumBtnDidClick
{
    CGLog(@"点击相册");

    __weak typeof(self) weakSelf = self;
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
    imageVc.fromCamera = YES;
    imageVc.allowPickingVideo = _allowPickingVideo; // 不能选视频
    imageVc.minImagesCount = 1;
    imageVc.maxImagesCount = _maxImagesCount;
    imageVc.maxVideoCut = _maxTime;
    imageVc.didFinishUserPickingImageHandle = ^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto, IJSPExportSourceType sourceType) {

        if (sourceType == IJSPImageType)
        {
            NSArray *items = [MediaItem itemsWithPhotos:photos];
            if(weakSelf.takeBlock) weakSelf.takeBlock(items);
        }
        else if (sourceType == IJSPVideoType)
        {
            NSURL *url = (NSURL *)avPlayers.firstObject;
            UIImage *image = [[IJSImageManager shareManager] firstFrameWithVideoURL:url size:CGSizeZero];
            
            MediaItem *item = [[MediaItem alloc] init];
            item.image = image;
            item.fileUrl = url;
            item.mediaType = kMediaItemTypeVideo;
            if(weakSelf.takeBlock) weakSelf.takeBlock(@[item]);
        }
        
        [self closeBtnDidClick];
        /*
        if (sourceType == IJSPImageType)
        {
            NSArray *items = [MediaItem itemsWithPhotos:photos];
            [weakSelf addImages:items];
            [weakSelf.tableView reloadData];

            for (MediaItem *item in items) {
                [self setBlockItem:item];
            }
            
            // 上传图片
            [self uploadAssets:items];
        }
        
        if (sourceType == IJSPVideoType)
        {
            NSURL *url = (NSURL *)avPlayers.firstObject;
            UIImage *image = [[IJSImageManager shareManager] firstFrameWithVideoURL:url size:CGSizeZero];
            
            MediaItem *item = [[MediaItem alloc] init];
            item.image = image;
            item.fileUrl = url;
            item.mediaType = kMediaItemTypeVideo;
            [self setBlockItem:item];

            if(item)
                [weakSelf addImages:@[item]];
            [weakSelf.tableView reloadData];
            
            self.hasVideo = YES;
            
            // 上传视频
            [self uploadAssets:@[item]];
        }
         */
    };
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [weakSelf.mapDataArr addObject:model];
        imageVc.mapImageArr = weakSelf.mapDataArr;
        [weakSelf.navigationController presentViewController:imageVc animated:YES completion:nil];
    }];
    
    /*
    IJSPhotoPickerController *vc = [[IJSPhotoPickerController alloc] init];
//    vc.columnNumber = self.columnNumber; //列数
    __weak typeof(self) weakSelf = self;
    __weak typeof(vc) weakVc = vc;
    [[IJSImageManager shareManager] getCameraRollAlbumContentImage:YES contentVideo:YES completion:^(IJSAlbumModel *model) {
        weakVc.albumModel = model;
        [weakSelf.navigationController pushViewController:vc animated:YES];
//        _didPushPhotoPickerVc = YES;
    }];
     */
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer
{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.shootBgView addGestureRecognizer:tapGesture];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture
{
    if ([self.session isRunning]) {
        CGPoint point= [tapGesture locationInView:self.shootBgView];
        //将UI坐标转化为摄像头坐标
        CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
        [self setFocusCursorWithPoint:point];
        
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
    }
}

- (void)onHiddenFocusCurSorAction
{
    self.focusCursor.alpha=0;
    self.isFocus = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([[touches anyObject] view] == self.takePhotoView) {
        
        [self stop]; // 停止监控屏幕方向
        CGLog(@"开始录制");
        //根据设备输出获得连接
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeAudio];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
            
            //如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            if (self.saveVideoUrl) {
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            }
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.previewLayer connection].videoOrientation;
            NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
            CGLog(@"save path is :%@",outputFielPath);
            NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
            CGLog(@"fileUrl:%@",fileUrl);
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            [self.captureMovieFileOutput stopRecording];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([[touches anyObject] view] == self.takePhotoView) {
        CGLog(@"结束触摸");
        if (!self.isVideo || !_allowPickingVideo) {
            [self performSelector:@selector(endRecord) withObject:nil afterDelay:0.3];
        } else {
            [self endRecord];
        }
    }
}

- (void)endRecord
{
    [self.captureMovieFileOutput stopRecording];//停止录制
}

- (void)onAfreshAction:(UIButton *)sender
{
    CGLog(@"重新录制");
    [self recoverLayout];
}

- (void)onEnsureAction:(UIButton *)sender
{
    CGLog(@"确定 这里进行保存或者发送出去");

    if (self.saveVideoUrl) {
        __weak typeof(self) weakSelf = self;

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc] init];
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.saveVideoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            CGLog(@"outputUrl:%@",weakSelf.saveVideoUrl);

//            [[NSFileManager defaultManager] removeItemAtURL:weakSelf.saveVideoUrl error:nil];
            if (weakSelf.lastBackgroundTaskIdentifier!= UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:weakSelf.lastBackgroundTaskIdentifier];
            }
            if (error) {
                [QSHUD hiddenAllHUDForView:self.view animated:NO];
                [QSHUD showErrorHudWithText:self.view withText:@"写入相册权限未开启"];
                CGLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
            
            } else {
                UIImage *image = [[IJSImageManager shareManager] firstFrameWithVideoURL:weakSelf.saveVideoUrl size:CGSizeZero];
                MediaItem *item = [[MediaItem alloc] init];
                item.image = image;
                item.fileUrl = weakSelf.saveVideoUrl;
                item.mediaType = kMediaItemTypeVideo;
                
                [weakSelf presentCurrentVcWithCompleted:^{
                    if (weakSelf.takeBlock) weakSelf.takeBlock(item);
                }];
                CGLog(@"成功保存视频到相簿.");
            }
        }];
        
    } else {
        //照片
        UIImageWriteToSavedPhotosAlbum(self.takeImage, self, nil, nil);
        if (self.takeBlock) {
            MediaItem *item = [[MediaItem alloc] init];
            item.image = self.takeImage;
            item.mediaType = kMediaItemTypeImage;
            self.takeBlock(item);
        }
        CGLog(@"---%@---",self.takeImage);
        [self closeBtnDidClick];
    }
}

//前后摄像头的切换
- (void)onCameraAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    CGLog(@"切换摄像头");
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;//前
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;//后
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.session commitConfiguration];
}

- (void)backBtnDidClick
{
    [self onAfreshAction:nil];
    CGLog(@"返回");
}

- (void)doneBtnDidClick
{
    [self onEnsureAction:nil];
}

- (void)tapAction
{
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [_player play];
        [_playBtn setImage:nil forState:UIControlStateNormal];
//        _toHiddToolStatus = YES;
//        [self isHiddenStatus:_toHiddToolStatus];
    } else {
        [_player pause];
        [_playBtn setImage:[UIImage imageNamed:@"sv_pauseStatus"] forState:UIControlStateNormal];
//        _toHiddToolStatus = NO;
//        [self isHiddenStatus:_toHiddToolStatus];
    }
}

- (void)pausePlayerAndShowNaviBar
{
    [_player pause];
    [_playBtn setImage:[UIImage imageNamed:@"sv_pauseStatus"] forState:UIControlStateNormal];
//    _toHiddToolStatus = NO;
//    [self isHiddenStatus:_toHiddToolStatus];
}

#pragma mark - 通知
//注册通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    
}

//进入后台就退出视频录制
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self closeBtnDidClick];
}

/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice
{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice
{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification
{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession
{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动根据环境条件开启闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        CGLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

-(void)areaChange:(NSNotification *)notification
{
    CGLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification
{
    CGLog(@"会话发生错误.");
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

// 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    CGLog(@"开始录制...");
    self.seconds = self.limitMaxSeconds;

    AFTER(0.3, ^{
        self.desLabel.hidden = YES;
        if(!self.animatedTag) {
            [self scaleView:YES];
            [UIView animateWithDuration:0.5 animations:^{
                self.progressView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            } completion:^(BOOL finished) {
                self.animatedTag = NO;
            }];
        }
    });

    [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.1];
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [QSHUD showLoaderText:@"" view:self.view];
    [self changeLayout];
    AVURLAsset *asset = [AVURLAsset assetWithURL:outputFileURL];
    if (self.isVideo && _allowPickingVideo) {
        
        [IJSVideoManager exportVideoWithVideoAsset:asset startTime:0 endTime:MIN((asset.duration.value / asset.duration.timescale),_maxTime) deviceDirection:_direction completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
            if(!error && outputPath) {
                weakSelf.saveVideoUrl = outputPath;
                if (!weakSelf.player) {
                    weakSelf.player = [AVPlayer playerWithURL:outputPath];
                    weakSelf.playerLayer = [AVPlayerLayer playerLayerWithPlayer:weakSelf.player];
                    weakSelf.playerLayer.frame = weakSelf.view.bounds;
                    [weakSelf.shootBgView.layer addSublayer:weakSelf.playerLayer];
                    [weakSelf.previewLayer removeFromSuperlayer];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:weakSelf.player.currentItem];
                    
//                    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
                    
                    CGLog(@"视频录制完成.");
                    [weakSelf showSuccessToolBar];
                } else {
                    [weakSelf recoverLayout];
                    [QSHUD hiddenAllHUDForView:weakSelf.view animated:NO];
                    [QSHUD showErrorWithStatus:@"拍摄失败，请重新拍摄"];
                    CGLog(@"视频录制失败.%@",error.localizedDescription);
                }
            } else {
                [weakSelf recoverLayout];
                [QSHUD hiddenAllHUDForView:weakSelf.view animated:NO];
                [QSHUD showErrorWithStatus:@"拍摄失败，请重新拍摄"];
            }
        }];
//        [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:asset startTime:0 endTime:(asset.duration.value / asset.duration.timescale)  completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
//            if(!error && outputPath) {
//                self.saveVideoUrl = outputFileURL;
//                if (!self.player) {
//                    _player = [AVPlayer playerWithURL:outputFileURL];
//                    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//                    _playerLayer.frame = self.view.bounds;
//                    [self.shootBgView.layer addSublayer:_playerLayer];
//
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
//                } else {
//                }
//            }
//        }];
    } else {
        //照片
        self.saveVideoUrl = nil;
        [self videoHandlePhoto:outputFileURL];
    }
    CGLog(@"视频录制完成.");
}

- (void)videoHandlePhoto:(NSURL *)url {
    CGLog(@"url = %@",url);
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    NSError *error = nil;
    Float64 duration = CMTimeGetSeconds([urlSet duration]);
    CMTime time = CMTimeMakeWithSeconds(duration / 2.0, 30);
//    CMTime time = CMTimeMake(0,30);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        CGLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);

    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:_direction];
    CGImageRelease(cgImage);
    if (image) {
        CGLog(@"视频截取成功");
        image = [image fixOrientation];
        self.takeImage = image;
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
        if (!self.takeImageView) {
            self.takeImageView = [[UIImageView alloc] initWithFrame:self.shootBgView.frame];
            self.takeImageView.backgroundColor = [UIColor blackColor];
            self.takeImageView.clipsToBounds = YES;
            self.takeImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.shootBgView addSubview:self.takeImageView];
            [self.previewLayer removeFromSuperlayer];
        }
        self.takeImageView.hidden = NO;
        self.takeImageView.image = self.takeImage;
        [self showSuccessToolBar];
    } else {
        [self.previewLayer removeFromSuperlayer];
        CGLog(@"视频截取失败");
        [self recoverLayout];
        [QSHUD hiddenAllHUDForView:self.view animated:NO];
        [QSHUD showErrorWithStatus:@"拍照失败，请重新拍摄"];
    }
    
}

#pragma mark - 设备方向处理
- (void)startMonitor
{
    [_deviceMotion startMonitor];
}
- (void)stop
{
    //不用时请关掉
    [_deviceMotion stop];
}

- (void)directionChange:(TgDirection)direction
{
//    _direction = direction;
    switch (direction) {
        case TgDirectionPortrait:
            _direction = UIImageOrientationUp;
            CGLog(@"protrait");
            break;
        case TgDirectionDown:
            _direction = UIImageOrientationDown;
            CGLog(@"down");
            break;
        case TgDirectionRight:
            _direction = UIImageOrientationRight;
            CGLog(@"right");
            break;
        case TgDirectionleft:
            _direction = UIImageOrientationLeft;
             CGLog(@"left");
            break;
        default:
            _direction = UIImageOrientationUp;
            break;
    }
}

#pragma mark - 懒加载
- (UIView *)topBar
{
    if(_topBar == nil) {
        UIView *topBar = [[UIView alloc] init];
        topBar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:topBar];
        _topBar = topBar;
    }
    return _topBar;
}
- (UIButton *)closeBtn
{
    if(_closeBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"media_close"];
        UIButton *closeBtn = [[UIButton alloc] init];
        [closeBtn setImage:image forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn sizeToFit];
        [self.topBar addSubview:closeBtn];
        _closeBtn = closeBtn;
    }
    return _closeBtn;
}
/*
- (UIButton *)flashBtn
{
    if(_flashBtn == nil) {
        UIImage *image_off = [UIImage imageNamed:@"media_flash_off"];
        UIImage *image_on = [UIImage imageNamed:@"media_flash_on"];
        UIButton *flashBtn = [[UIButton alloc] init];
        [flashBtn setImage:image_off forState:UIControlStateNormal];
        [flashBtn setImage:image_on forState:UIControlStateSelected];
        [flashBtn addTarget:self action:@selector(flashBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL on = [[NSUserDefaults standardUserDefaults] boolForKey:@"flashState"];
        flashBtn.selected = on;
        
        [flashBtn sizeToFit];
        [self.view addSubview:flashBtn];
        _flashBtn = flashBtn;
    }
    return _flashBtn;
}
 */

- (UIView *)shootView
{
    if(_shootView == nil) {
        UIView *shootView = [[UIView alloc] init];
        [self.view addSubview:shootView];
        _shootView = shootView;
    }
    return _shootView;
}
- (UIImageView *)shootBgView
{
    if(_shootBgView == nil) {
        UIImageView *shootBgView = [[UIImageView alloc] init];
        shootBgView.userInteractionEnabled = YES;
        [self.shootView addSubview:shootBgView];
        _shootBgView = shootBgView;
    }
    return _shootBgView;
}

- (UIImageView *)focusCursor
{
    if(_focusCursor == nil) {
        UIImage *image = [UIImage imageNamed:@"media_focusBox"];
        UIImageView *focusCursor = [[UIImageView alloc] initWithImage:image];
        focusCursor.size = CGSizeMake(60, 60);
        [self.shootView addSubview:focusCursor];
        _focusCursor = focusCursor;
    }
    return _focusCursor;
}
- (UIView *)bottomView
{
    if(_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = QSColor(0, 0, 0, 0.5);
        [self.view addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}
- (UILabel *)desLabel
{
    if(_desLabel == nil) {
        UILabel *desLabel = [[UILabel alloc] init];
        desLabel.font = kFont12;
        desLabel.text = @"轻触拍照  按住摄影";
        desLabel.textColor = [UIColor whiteColor];
        desLabel.textAlignment = NSTextAlignmentCenter;
        [desLabel sizeToFit];
        [self.bottomView addSubview:desLabel];
        _desLabel = desLabel;
    }
    return _desLabel;
}
- (UIView *)toolBar
{
    if(_toolBar == nil) {
        UIView *toolBar = [[UIView alloc] init];
        [self.bottomView addSubview:toolBar];
        _toolBar = toolBar;
    }
    return _toolBar;
}
- (UIButton *)timeBtn
{
    if(_timeBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"media_onvedio"];
        UIButton *timeBtn = [[UIButton alloc] init];
        [timeBtn setImage:image forState:UIControlStateNormal];
        [timeBtn setTitle:@"0秒" forState:UIControlStateNormal];
        [timeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, kMargin4)];
        [timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        timeBtn.titleLabel.font = kFont12;
        timeBtn.userInteractionEnabled = NO;
        timeBtn.hidden = YES;
        [timeBtn sizeToFit];
        [self.toolBar addSubview:timeBtn];
        _timeBtn = timeBtn;
    }
    return _timeBtn;
}
// takePhotoView albumBtn switchCameraBtn;
- (UIView *)shutterView
{
    if(_shutterView == nil) {
        UIView *shutterView = [[UIView alloc] init];
        [self.toolBar addSubview:shutterView];
        _shutterView = shutterView;
    }
    return _shutterView;
}
/*
- (MediaProgressView *)progressView
{
    if(_progressView == nil) {
        CGFloat w = kMargin68;
        CGFloat h = kMargin68;
        CGFloat x = (ScreenWidth - w) * 0.5;
        CGFloat y = (ScreenHeight - h) * 0.5;
        MediaProgressView *progressView = [[MediaProgressView alloc] init];
        progressView.clipsToBounds = YES;
        progressView.frame = CGRectMake(x, y, w, h);
        progressView.layer.cornerRadius = w/2;
        progressView.backgroundColor = QSColor(170, 170, 170, 0.5);
        [self.shutterView addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}
*/

- (UAProgressView *)progressView
{
    if(_progressView == nil) {
        CGFloat w = kMargin68;
        CGFloat h = kMargin68;
        CGFloat x = (ScreenWidth - w) * 0.5;
        CGFloat y = (ScreenHeight - h) * 0.5;

        UAProgressView *progressView = [[UAProgressView alloc] init];
        progressView.backgroundColor = QSColor(170, 170, 170, 0.5);
        progressView.tintColor = [UIColor whiteColor];
        progressView.clipsToBounds = YES;
        progressView.frame = CGRectMake(x, y, w, h);
        progressView.borderWidth = 0;
        progressView.lineWidth = 8.0;
        progressView.progress = 0;
        progressView.layer.cornerRadius = w/2;
        [self.shutterView addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}

- (UIImageView *)takePhotoView
{
    if(_takePhotoView == nil) {
        // 中圈
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = kMargin60;
        CGFloat h = kMargin60;
        
        UIImageView *takePhotoView = [[UIImageView alloc] init];
        takePhotoView.frame = CGRectMake(x, y, w, h);
        takePhotoView.layer.cornerRadius = w/2;
        takePhotoView.backgroundColor = [UIColor clearColor];
        takePhotoView.userInteractionEnabled = YES;
        [self.shutterView addSubview:takePhotoView];
        
        // 内圈
        w = kMargin52;
        h = kMargin52;
        x = (kMargin60 - w)  * 0.5;
        y = (kMargin60 - h)  * 0.5;;
        UIImageView *innerRingView = [[UIImageView alloc] init];
        innerRingView.layer.cornerRadius = w/2;
        innerRingView.frame = CGRectMake(x, y, w, h);
        innerRingView.backgroundColor = [UIColor whiteColor];
        [takePhotoView addSubview:innerRingView];
        
        _takePhotoView = takePhotoView;
        _innerRingView = innerRingView;
    }
    return _takePhotoView;
}


- (UIButton *)albumBtn
{
    if(_albumBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"media_pic"];
        UIButton *albumBtn = [[UIButton alloc] init];
        [albumBtn setImage:image forState:UIControlStateNormal];
        [albumBtn addTarget:self action:@selector(albumBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:albumBtn];
        [albumBtn sizeToFit];
        _albumBtn = albumBtn;
    }
    return _albumBtn;
}
- (UIButton *)switchCameraBtn
{
    if(_switchCameraBtn == nil) {
        UIImage *image_n = [UIImage imageNamed:@"media_frontc"];
        UIImage *image_s = [UIImage imageNamed:@"media_frontb"];

        UIButton *switchCameraBtn = [[UIButton alloc] init];
        [switchCameraBtn setImage:image_n forState:UIControlStateNormal];
        [switchCameraBtn setImage:image_s forState:UIControlStateSelected];
        [switchCameraBtn addTarget:self action:@selector(onCameraAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:switchCameraBtn];
        [switchCameraBtn sizeToFit];
        _switchCameraBtn = switchCameraBtn;
    }
    return _switchCameraBtn;
}
- (UIButton *)backBtn
{
    if(_backBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"media_back"];
        UIButton *backBtn = [[UIButton alloc] init];
        [backBtn setImage:image forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        backBtn.hidden = YES;
        [self.toolBar addSubview:backBtn];
        [backBtn sizeToFit];
        _backBtn = backBtn;
    }
    return _backBtn;
}
- (UIButton *)editBtn
{
    if(_editBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"media_next"];
        UIButton *editBtn = [[UIButton alloc] init];
        [editBtn setImage:image forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(doneBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        editBtn.hidden = YES;
        [self.toolBar addSubview:editBtn];
        [editBtn sizeToFit];
        _editBtn = editBtn;
    }
    return _editBtn;
}
- (UIButton *)playBtn
{
    if(_playBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"sv_pauseStatus"];
        UIButton *playBtn = [[UIButton alloc] init];
        [playBtn setImage:image forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        playBtn.hidden = YES;
        [self.view addSubview:playBtn];
        [playBtn sizeToFit];
        _playBtn = playBtn;
    }
    return _playBtn;
}

- (NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr = [NSMutableArray array];
    }
    return _mapDataArr;
}

@end

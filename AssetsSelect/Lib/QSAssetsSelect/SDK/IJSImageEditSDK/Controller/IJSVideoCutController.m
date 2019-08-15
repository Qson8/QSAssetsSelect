//
//  IJSVideoCutController.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoCutController.h"
#import "IJSVideoTrimView.h"

#import "IJSImageNavigationView.h"
#import "IJSImageManager.h"
#import "IJSImageConst.h"
#import "IJSVideoManager.h"J
#import "IJSVideoEditController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "IJSImagePickerController.h"

@interface IJSVideoCutController () <IJSVideoTrimViewDelegate>
@property (nonatomic, weak) IJSImageNavigationView *navigationView; // 导航条
@property (nonatomic, weak) IJSVideoTrimView *trimView;             // 视频裁剪试图
@property (nonatomic, assign) BOOL isPlaying;                       // 正在播放
@property (nonatomic, assign) CGFloat startTime;                    // 开始时间
@property (nonatomic, assign) CGFloat videoLenght;                  // 视频的长度
@property (nonatomic, assign) CGFloat endTime;                      // 结束时间
@property (nonatomic, weak) UIView *playView;                       // 播放视频的view
@property (nonatomic, weak) UIButton *playButton;                   // 播放按钮
@property (nonatomic, strong) AVPlayer *player;                     // 播放控制
@property (nonatomic, strong) NSTimer *listenPlayerTimer;           // 监听的时间
@property (nonatomic, assign) CGFloat backStartPosition;            // 回到开始位置
@property (nonatomic, assign) BOOL isDoing;                         // 正在处理
@end

@implementation IJSVideoCutController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.isPlaying = YES;
    self.canEdit = NO; // 关闭编辑
    
    [self _setupUI];        // 重置UI
//    [self _didclickAction]; //点击事件
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.player pause];
    [self removeListenPlayerTimer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark 设置UI
- (void)_setupUI
{
    // 播放层
    UIView *playView;
    CGRect rect;
    if (IJSGiPhoneX)
    {
        rect = CGRectMake(0, IJSGStatusBarHeight, JSScreenWidth, JSScreenHeight - IJSGStatusBarHeight - IJSGTabbarSafeBottomMargin - IJSVideoBottomViewHeight);
    }
    else
    {
        rect = CGRectMake(0, 0, JSScreenWidth, JSScreenHeight - IJSVideoBottomViewHeight);
    }
    playView= [[UIView alloc] initWithFrame:rect];
    
    playView.backgroundColor = [UIColor blackColor];
    self.playView = playView;
    [self.view addSubview:playView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [playView addGestureRecognizer:tap];

    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:self.avasset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, self.playView.js_width, self.playView.js_height);
    playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.playView.layer addSublayer:playerLayer];

    // 播放按钮
    UIButton *playButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIImage *image = [UIImage imageNamed:@"sv_pauseStatus"];
    [playButton setImage:image forState:UIControlStateNormal];
//    [playButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:@"" grandson:@"" imageName:@"MMVideoPreviewPlay@2x" imageType:@"png"] forState:UIControlStateNormal];
    [self.view addSubview:playButton];
    [self.view bringSubviewToFront:playButton];
    playButton.frame = CGRectMake(0, 0, 80, 80);
    playButton.center = self.playView.center;
    playButton.userInteractionEnabled = NO;
    self.playButton = playButton;

    // 导航条
    IJSImageNavigationView *navigationView;
    if (IJSGiPhoneX)
    {
        navigationView = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarHeight, JSScreenWidth, IJSVideoEditNavigationHeight)];
    }
    else
    {
      navigationView = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSVideoEditNavigationHeight)];
    }
    navigationView.hidden = YES;
    navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navigationView];
    self.navigationView = navigationView;
    [self.view bringSubviewToFront:navigationView];
    
    // 底部的UI 在数据请求完成再加载
    Float64 duration = CMTimeGetSeconds([self.avasset duration]);
    if (self.maxCutTime >= duration)
    {
        self.maxCutTime = duration;
    }
    if (duration <= self.minCutTime)
    {
        self.minCutTime = duration;
    }

    IJSVideoTrimView *trimView = [[IJSVideoTrimView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.playView.frame) + kIPadSuitFloat(20), JSScreenWidth, IJSVideotrimViewHeight) minCutTime:self.minCutTime ?: 4 maxCutTime:self.maxCutTime ?: 10 assetDuration:duration avAsset:self.avasset];
    trimView.clipsToBounds = YES;
    trimView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:trimView];
    trimView.delegate = self;
    self.trimView = trimView;
    [trimView getVideoLenghtThenNotifyDelegate]; // 通知代理获取视频开始数据
    
    // 底部Bar
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    y = CGRectGetMaxY(self.trimView.frame) + kIPadSuitFloat(5);
    w = JSScreenWidth;
    h = kIPadSuitFloat(40);
    UIView *controlBar = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [self.view addSubview:controlBar];
    image = [UIImage imageNamed:@"media_back"];
    x = kIPadSuitFloat(20);
    y = 0;
    w = kIPadSuitFloat(40);
    h = kIPadSuitFloat(40);
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:backBtn];
    
    image = [UIImage imageNamed:@"media_next"];
    x = controlBar.width - kIPadSuitFloat(20) - kIPadSuitFloat(40);
    y = 0;
    w = kIPadSuitFloat(40);
    h = kIPadSuitFloat(40);
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [doneBtn setImage:image forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:doneBtn];
    
    x = CGRectGetMaxX(backBtn.frame) + kIPadSuitFloat(10);
    w = CGRectGetMinX(doneBtn.frame) - x - 2 * kIPadSuitFloat(10);
    y = 0;
    h = kIPadSuitFloat(40);
    UILabel *warmLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,y,w,h)];
    CGFloat maxCut = ((IJSImagePickerController *) self.navigationController).maxVideoCut ?: kMAXTIME;
    warmLabel.text = [NSString stringWithFormat:@"请拖动滑块，选择%g秒以内视频",maxCut];
    warmLabel.font = [UIFont systemFontOfSize:((IS_IPHONE_5 || IS_IPHONE_4) ? 11 : kIPadSuitFloat(12))];
    warmLabel.textColor = QSColorFromRGB(0xffffff);
    warmLabel.textAlignment = NSTextAlignmentCenter;
    [controlBar addSubview:warmLabel];
}

#pragma mark 点击方法
- (void)doneBtnDidClick
{
    if (self.isDoing)
    {
        return;
    }
    self.isDoing = YES;
    if (self.videoLenght == 0)
    {
        self.videoLenght = self.maxCutTime;
    }
    if (self.startTime == 0)
    {
        self.startTime = 0;
    }
    if (self.endTime == 0)
    {
        CGFloat maxCut = ((IJSImagePickerController *) self.navigationController).maxVideoCut ?: kMAXTIME;
        self.endTime = maxCut;
    }
//    IJSLodingView *lodingView = [IJSLodingView showLodingViewAddedTo:self.view title:@"正在处理中... ..."];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    [SVProgressHUD showWithStatus:@"正在处理中"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:self.avasset startTime:self.startTime endTime:self.endTime completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
//        [lodingView removeFromSuperview];
//        [SVProgressHUD dismiss];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error)
        {
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                [alertView dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertView addAction:cancle];
            [self presentViewController:alertView animated:YES completion:nil];
        }
        else
        {
            if (self.canEdit)
            {
                IJSVideoEditController *videoEditVc = [[IJSVideoEditController alloc] init];
                videoEditVc.outputPath = outputPath;
                videoEditVc.mapImageArr = self.mapImageArr;
                [self.navigationController pushViewController:videoEditVc animated:YES];
            }
            else
            {
                /*
                if ([self.delegate respondsToSelector:@selector(didFinishCutVideoWithController:outputPath:error:state:)])
                {
                    [self.delegate didFinishCutVideoWithController:self outputPath:outputPath error:nil state:state];
                }
                
                if (self.navigationController)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                 */
                __weak typeof(self) weakSelf = self;
                
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
                    else {
                        [weakSelf _outputVideoPath:outputPath error:error state:state];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
        }
        self.isDoing = NO;
    }];
}
- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_didclickAction
{
    __weak typeof(self) weakSelf = self;
    //取消
    self.navigationView.cancleBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    //完成
    self.navigationView.finishBlock = ^{
        
        if (weakSelf.isDoing)
        {
            return;
        }
        weakSelf.isDoing = YES;
        if (weakSelf.videoLenght == 0)
        {
            weakSelf.videoLenght = weakSelf.maxCutTime;
        }
        if (weakSelf.startTime == 0)
        {
            weakSelf.startTime = 0;
        }
        if (weakSelf.endTime == 0)
        {
            CGFloat maxCut = ((IJSImagePickerController *) weakSelf.navigationController).maxVideoCut ?: kMAXTIME;
            weakSelf.endTime = maxCut;
        }

//        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//        [SVProgressHUD showWithStatus:@"正在处理中"];
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:weakSelf.avasset startTime:weakSelf.startTime endTime:weakSelf.endTime completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
//            [SVProgressHUD dismiss];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error)
            {
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                    [alertView dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertView addAction:cancle];
                [weakSelf presentViewController:alertView animated:YES completion:nil];
            }
            else
            {
                if (weakSelf.canEdit)
                {
                    IJSVideoEditController *videoEditVc = [[IJSVideoEditController alloc] init];
                    videoEditVc.outputPath = outputPath;
                    videoEditVc.mapImageArr = weakSelf.mapImageArr;
                    [weakSelf.navigationController pushViewController:videoEditVc animated:YES];
                }
                else
                {
                    if ([weakSelf.delegate respondsToSelector:@selector(didFinishCutVideoWithController:outputPath:error:state:)])
                    {
                        [weakSelf.delegate didFinishCutVideoWithController:weakSelf outputPath:outputPath error:nil state:state];
                    }
                    if (weakSelf.navigationController)
                    {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            weakSelf.isDoing = NO;
        }];
    };
}

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
}

#pragma mark 点击事件
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (self.isPlaying)
    {
        [self.player play];
        self.playButton.hidden = YES;
        [self startListenPlayerTimer];
    }
    else
    {
        [self.player pause];
        self.playButton.hidden = NO;
        [self removeListenPlayerTimer];
    }
    self.isPlaying = !self.isPlaying;
}

#pragma mark 开始定时器
- (void)startListenPlayerTimer
{
    [self removeListenPlayerTimer];
    self.listenPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(listenPlayerTimerResetTimerInCutVc) userInfo:nil repeats:YES];
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
- (void)listenPlayerTimerResetTimerInCutVc
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
#pragma mark 滑块的代理方法,保存截取的时间数据
- (void)trimView:(IJSVideoTrimView *)trimView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoLength:(CGFloat)length
{
    if (startTime != self.startTime)
    {
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    self.videoLenght = length;
    self.endTime = endTime;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}







@end

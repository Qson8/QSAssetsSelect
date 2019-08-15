//
//  HCVideoPlayer.m
//  HCVideoPlayer
//
//  Created by chc on 2017/6/3.
//  Copyright © 2017年 chc. All rights reserved.
//
#define kHCVP_BottomBarHeight 66
#define kHCVP_BtnWidth 50

#import "HCVideoPlayer.h"
#import "HCOrientController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HCProgressView.h"
#import "HCQualitySheet.h"
#import "AppDelegate+VP.h"
#import "HCSharePanel.h"
#import "HCMorePanel.h"
#import "HCImageShareView.h"
#import "HCHorButton.h"
#import "UIView+Tap.h"
#import "HCGoogleCastTool.h"
#import "UIViewController+VP.h"
#import "HCAirplayCastTool.h"

@interface HCVideoPlayer ()<HCPlayerViewDelegate, HCProgressViewDelegate, HCOrientControllerDelegate, HCSharePanelDelegate, HCMorePanelDelegate>
{
    __weak HCSharePanel *_sharePanel;
    __weak HCMorePanel *_morePanel;
}
@property (nonatomic, strong) HCPlayerView *urlPlayer; // url播放器

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *loadErrorLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) UILabel *loadSpeedLabel;

/// 控制容器
@property (nonatomic, weak) UIView *controllContentView;

// 播放控制界面控件
// 顶部
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *topBar;
@property (nonatomic, weak) UIButton *zoomBtn;
@property (nonatomic, weak) UIButton *tvBtn;
@property (nonatomic, weak) UIButton *shareBtn;
@property (nonatomic, weak) UIButton *moreBtn;
// 底部
@property (nonatomic, weak) UIButton *playerBtn;
@property (nonatomic, weak) HCProgressView *progressView;
@property (nonatomic, weak) UIButton *qualityBtn;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIButton *nextBtn; // 下一集
@property (nonatomic, weak) UIButton *episodeBtn; // 选集
@property (nonatomic, weak) UIImageView *bottomBar;
//
@property (nonatomic, weak) UIButton *cameraBtn;
@property (nonatomic, weak) UIButton *switchBtn; // 切换线路
@property (nonatomic, weak) HCImageShareView *imageShareView;
@property (nonatomic, weak) HCQualitySheet *qualitySheet;
@property (nonatomic, weak) UIView *controllView;

// 锁屏界面
@property (nonatomic, weak) UIView *lockContentView;
@property (nonatomic, weak) UIImageView *lockTopBar;
@property (nonatomic, weak) UIImageView *lockBottomBar;
// 锁屏按钮
@property (nonatomic, weak) UIButton *lockBtn;

@property (nonatomic, weak) UILabel *progressLabel;
@property (nonatomic, weak) UILabel *messageLabel;


// 保存滑动时progressView的滑动开始点的进度
@property (nonatomic, assign) CGFloat panStartProgress;
@property (nonatomic, assign) BOOL isPan;

// 缩放、旋转
@property (nonatomic, weak) HCOrientController *orVC;
@property (nonatomic, assign) CGRect orgRect;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, weak) UIView *playSuperView;
@property (nonatomic, assign) HCVideoPlayerZoomStatus zoomStatus;
@property (nonatomic, copy) void (^toZoomInCompleteBlock)(void);
@property (nonatomic, assign) UIStatusBarStyle orgStatusBarStyle;
@property (nonatomic, assign) BOOL orgStatusBarHidden;
@property (nonatomic, assign) BOOL isOnRotaion;

// 系统音量
@property (nonatomic, strong) UISlider* volumeViewSlider;
@property (nonatomic, assign) CGFloat volumeLastY;
// 屏幕亮度
@property (nonatomic, assign) CGFloat brightLastY;
// 当前滑动播放时间
@property (nonatomic, assign) CGFloat currentPanContentViewTime;
// 上次滑动播放时间
@property (nonatomic, assign) CGFloat lastPanContentViewTime;
// -1 为上下方向、0 为没定方向、1 为左右方向
@property (nonatomic, assign) NSInteger slideDirection;

// 没有缩小模式
@property (nonatomic, assign) BOOL noZoomInShowModel;

// present方向根控制器
@property (nonatomic, weak) UIViewController *rootPresentVc;

@end

/// 用于AirPlay投屏下，保存播放器.
HCVideoPlayer *g_airPlayVideoPlayer;
@implementation HCVideoPlayer

#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
        contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (HCPlayerView *)urlPlayer
{
    if (_urlPlayer == nil) {
        HCPlayerView *urlPlayer = [[HCPlayerView alloc] init];
        [self.contentView addSubview:urlPlayer];
        urlPlayer.delegate = self;
        _urlPlayer = urlPlayer;
    }
    return _urlPlayer;
}

- (UIView *)controllContentView
{
    if (_controllContentView == nil) {
        UIView *controllContentView = [[UIView alloc] init];
        [self.contentView addSubview:controllContentView];
        _controllContentView = controllContentView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllContentViewClicked)];
        [controllContentView addGestureRecognizer:tap];
    }
    return _controllContentView;
}

- (UILabel *)loadErrorLabel
{
    if (_loadErrorLabel == nil) {
        UILabel *loadErrorLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:loadErrorLabel];
        _loadErrorLabel = loadErrorLabel;
        loadErrorLabel.font = [UIFont systemFontOfSize:14];
        loadErrorLabel.textColor = [UIColor whiteColor];
        loadErrorLabel.numberOfLines = 0;
        loadErrorLabel.text = @"视频加载失败!\n点击重试";
        loadErrorLabel.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadErrorLabelClicked)];
        [loadErrorLabel addGestureRecognizer:tap];
        loadErrorLabel.userInteractionEnabled = YES;
        loadErrorLabel.hidden = YES;
    }
    return _loadErrorLabel;
}

- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self.topBar addSubview:backBtn];
        _backBtn = backBtn;
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_back"] forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.topBar addSubview:titleLabel];
        _titleLabel = titleLabel;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UIButton *)shareBtn
{
    if (_shareBtn == nil) {
        UIButton *shareBtn = [[UIButton alloc] init];
        [self.topBar addSubview:shareBtn];
        _shareBtn = shareBtn;
        [shareBtn setImage:[UIImage vp_imageWithName:@"vp_share"] forState:UIControlStateNormal];
        [shareBtn sizeToFit];
        [shareBtn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIButton *)moreBtn
{
    if (_moreBtn == nil) {
        UIButton *moreBtn = [[UIButton alloc] init];
        [self.topBar addSubview:moreBtn];
        _moreBtn = moreBtn;
        [moreBtn setImage:[UIImage vp_imageWithName:@"vp_more"] forState:UIControlStateNormal];
        [moreBtn sizeToFit];
        [moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)tvBtn
{
    if (_tvBtn == nil) {
        UIButton *tvBtn = [[UIButton alloc] init];
        [self.topBar addSubview:tvBtn];
        _tvBtn = tvBtn;
        [tvBtn setImage:[UIImage vp_imageWithName:@"vp_airplay"] forState:UIControlStateNormal];
        [tvBtn sizeToFit];
        [tvBtn addTarget:self action:@selector(tvBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tvBtn;
}

- (UIButton *)zoomBtn
{
    if (_zoomBtn == nil) {
        UIButton *zoomBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:zoomBtn];
        _zoomBtn = zoomBtn;
        [zoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage vp_imageWithName:@"vp_zoom"] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage vp_imageWithName:@"vp_zoom"] forState:UIControlStateSelected];
        [zoomBtn addTarget:self action:@selector(zoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomBtn;
}

- (UIButton *)playerBtn
{
    if (_playerBtn == nil) {
        UIButton *playerBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:playerBtn];
        _playerBtn = playerBtn;
        [playerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_play"] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_pause"] forState:UIControlStateSelected];
        [playerBtn addTarget:self action:@selector(playerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerBtn;
}

- (HCProgressView *)progressView
{
    if (_progressView == nil) {
        HCProgressView *progressView = [[HCProgressView alloc] init];
        [self.bottomBar addSubview:progressView];
        _progressView = progressView;
        progressView.progressHeight = 2.0;
        progressView.delegate = self;
    }
    return _progressView;
}

- (UIButton *)qualityBtn
{
    if (_qualityBtn == nil) {
        UIButton *qualityBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:qualityBtn];
        _qualityBtn = qualityBtn;
        [qualityBtn setTitle:@"标清" forState:UIControlStateNormal];
        [qualityBtn addTarget:self action:@selector(qualityBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qualityBtn;
}

- (HCQualitySheet *)qualitySheet
{
    if (_qualitySheet == nil) {
        HCQualitySheet *qualitySheet = [[HCQualitySheet alloc] init];
        [self.controllView addSubview:qualitySheet];
        _qualitySheet = qualitySheet;
        qualitySheet.clipsToBounds = YES;
        qualitySheet.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        qualitySheet.hidden = YES;
    }
    return _qualitySheet;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:timeLabel];
        _timeLabel = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = @"00:00 / 00:00";
    }
    return _timeLabel;
}

- (UIButton *)nextBtn
{
    if (_nextBtn == nil) {
        UIButton *nextBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:nextBtn];
        _nextBtn = nextBtn;
        [nextBtn setImage:[UIImage vp_imageWithName:@"vp_next"] forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)episodeBtn
{
    if (_episodeBtn == nil) {
        UIButton *episodeBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:episodeBtn];
        _episodeBtn = episodeBtn;
        [episodeBtn setTitle:@"选集" forState:UIControlStateNormal];
        episodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [episodeBtn sizeToFit];
        [episodeBtn addTarget:self action:@selector(episodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _episodeBtn;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (_activityIndicator == nil) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.controllContentView addSubview:activityIndicator];
        _activityIndicator = activityIndicator;
        activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}

- (UILabel *)loadSpeedLabel
{
    if (_loadSpeedLabel == nil) {
        UILabel *loadSpeedLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:loadSpeedLabel];
        _loadSpeedLabel = loadSpeedLabel;
        loadSpeedLabel.font = [UIFont systemFontOfSize:12];
        loadSpeedLabel.textColor = [UIColor whiteColor];
        loadSpeedLabel.text = @"0.0KB/s";
        loadSpeedLabel.textAlignment = NSTextAlignmentCenter;
        loadSpeedLabel.hidden = YES;
    }
    return _loadSpeedLabel;
}

- (UIImageView *)topBar
{
    if (_topBar == nil) {
        UIImageView *topBar = [[UIImageView alloc] init];
        [self.controllView addSubview:topBar];
        topBar.image = [UIImage vp_imageWithName:@"vp_topBarBg"];
        _topBar = topBar;
        topBar.userInteractionEnabled = YES;
    }
    return _topBar;
}

- (UIImageView *)bottomBar
{
    if (_bottomBar == nil) {
        UIImageView *bottomBar = [[UIImageView alloc] init];
        [self.controllView addSubview:bottomBar];
        _bottomBar = bottomBar;
//        bottomBar.backgroundColor = kVP_Color(0, 0, 0, 0.3);
        bottomBar.image = [UIImage vp_imageWithName:@"vp_botBarBg"];
        bottomBar.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarPan:)];
        [bottomBar addGestureRecognizer:pan];
    }
    return _bottomBar;
}

- (UIButton *)cameraBtn
{
    if (_cameraBtn == nil) {
        UIButton *cameraBtn = [[UIButton alloc] init];
        [self.controllView addSubview:cameraBtn];
        _cameraBtn = cameraBtn;
        [cameraBtn setImage:[UIImage vp_imageWithName:@"vp_camera"] forState:UIControlStateNormal];
        [cameraBtn sizeToFit];
        [cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}

- (UIButton *)switchBtn
{
    if (_switchBtn == nil) {
        UIButton *switchBtn = [[UIButton alloc] init];
        [self.controllView addSubview:switchBtn];
        _switchBtn = switchBtn;
        //        [switchBtn setTitle:@"切换线路" forState:UIControlStateNormal];
        [switchBtn setImage:[UIImage vp_imageWithName:@"vp_switch"] forState:UIControlStateNormal];
        [switchBtn addTarget:self action:@selector(didClickSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (HCImageShareView *)imageShareView
{
    if (_imageShareView == nil) {
        HCImageShareView *imageShareView = [[HCImageShareView alloc] init];
        [self.controllView addSubview:imageShareView];
        _imageShareView = imageShareView;
        imageShareView.alpha = 0.0;
        imageShareView.layer.cornerRadius = 5;
        imageShareView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageShareViewClicked)];
        [imageShareView addGestureRecognizer:tap];
    }
    return _imageShareView;
}

- (UIView *)controllView
{
    if (_controllView == nil) {
        UIView *controllerView = [[UIView alloc] init];
        [self.controllContentView addSubview:controllerView];
        _controllView = controllerView;
        controllerView.alpha = 0.0;
        controllerView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerViewClicked)];
        [controllerView addGestureRecognizer:tap];
    }
    return _controllView;
}

- (UIView *)lockContentView
{
    if (_lockContentView == nil) {
        UIView *lockContentView = [[UIView alloc] init];
        [self.controllContentView addSubview:lockContentView];
        _lockContentView = lockContentView;
        lockContentView.alpha = 0.0;
        lockContentView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lockContentViewClicked)];
        [lockContentView addGestureRecognizer:tap];
    }
    return _lockContentView;
}

- (UIImageView *)lockTopBar
{
    if (_lockTopBar == nil) {
        UIImageView *lockTopBar = [[UIImageView alloc] init];
        [self.lockContentView addSubview:lockTopBar];
        lockTopBar.image = [UIImage vp_imageWithName:@"vp_topBarBg"];
        _lockTopBar = lockTopBar;
    }
    return _lockTopBar;
}

- (UIImageView *)lockBottomBar
{
    if (_lockBottomBar == nil) {
        UIImageView *lockBottomBar = [[UIImageView alloc] init];
        [self.lockContentView addSubview:lockBottomBar];
        lockBottomBar.image = [UIImage vp_imageWithName:@"vp_botBarBg"];
        _lockBottomBar = lockBottomBar;
    }
    return _lockBottomBar;
}

- (UIButton *)lockBtn
{
    if (_lockBtn == nil) {
        UIButton *lockBtn = [[UIButton alloc] init];
        [self.controllContentView addSubview:lockBtn];
        _lockBtn = lockBtn;
        [lockBtn setImage:[UIImage vp_imageWithName:@"vp_unlock"] forState:UIControlStateNormal];
        [lockBtn setImage:[UIImage vp_imageWithName:@"vp_locked"] forState:UIControlStateSelected];
        [lockBtn addTarget:self action:@selector(didClickLockBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockBtn;
}

- (UILabel *)progressLabel
{
    if (_progressLabel == nil) {
        UILabel *progressLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:progressLabel];
        _progressLabel = progressLabel;
        progressLabel.font = [UIFont systemFontOfSize:20];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.hidden = YES;
    }
    return _progressLabel;
}

- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        UILabel *messageLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:messageLabel];
        _messageLabel = messageLabel;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.backgroundColor = kVP_Color(0, 0, 0, 0.3);
        messageLabel.hidden = YES;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.layer.cornerRadius = 3;
        messageLabel.clipsToBounds = YES;
    }
    return _messageLabel;
}

- (UISlider *)volumeViewSlider
{
    if (_volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        volumeView.showsRouteButton = NO;
        //默认YES
        volumeView.showsVolumeSlider = NO;
        [self addSubview:volumeView];
        [volumeView userActivity];
        
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeViewSlider;
}

#pragma mark - 初始化
- (instancetype)initWithCurController:(UIViewController *)curController
{
    if (self = [super init]) {
        self.curController = curController;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.zoomInWhenVerticalScreen = YES;
        self.rootPresentVc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self setupNotification];
        [self setupBtnsShow];
        [self setupZoomInHiddenBtns];
        [self setBtnsZoomInHidden:YES];
        [self setupProperty];
        [self progressView];
        [self initSetAirPlay];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    if (self.url) {
        self.urlPlayer.frame = self.contentView.bounds;
    }
    
    [self setupControllContentViewFrame];
}

- (void)dealloc
{
    [self stop];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    VPLog(@"dealloc - HCVideoPlayer");
}

- (void)setupNotification
{
    //监听手动切换横竖屏状态
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 网速监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReceivedSpeed:) name:NotificationNetworkReceivedSpeed object:nil];
    
    // AirPlay 相关通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPVolumeViewWirelessRoutesAvailableDidChange) name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPVolumeViewWirelessRouteActiveDidChange) name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

}

- (void)setupProperty
{
    _autoZoom = YES;
    self.volume = 1.0;
    self.rate = 1.0;
    _showBackWhileZoomIn = YES;
    _orgStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _orgStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
}

- (void)setupControllContentViewFrame
{
    self.controllContentView.frame = self.bounds;
    
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    
    [self.loadErrorLabel sizeToFit];
    CGRect rect = self.loadErrorLabel.frame;
    rect.origin.x = (selfW - rect.size.width) * 0.5;
    rect.origin.y = (selfH - rect.size.height) * 0.5;
    self.loadErrorLabel.frame = rect;
    
    CGFloat totalHeight = self.activityIndicator.frame.size.height + 6 + self.loadSpeedLabel.font.lineHeight;
    rect = self.activityIndicator.frame;
    rect.origin.y = (selfH - totalHeight) * 0.5;
    rect.origin.x = (selfW - rect.size.width) * 0.5;
    self.activityIndicator.frame = rect;
    self.loadSpeedLabel.frame = CGRectMake(0, CGRectGetMaxY(self.activityIndicator.frame) + 6, self.controllContentView.frame.size.width, self.loadSpeedLabel.font.lineHeight);
    
    CGFloat width = 60;
    CGFloat height = 44;
    CGFloat x = 0;
    if (kVP_IS_IPHONE_X && _zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        x = 44;
    }
    CGFloat y = (selfH - height) * 0.5;
    self.lockBtn.frame = CGRectMake(x, y, width, height);
    
    [self setupControllViewFrame];
    
    [self setupLockContentViewFrame];
    
    [self setupTVControllViewFrame];
    
    [self.controllContentView bringSubviewToFront:self.lockBtn];
    
    [self.contentView bringSubviewToFront:self.controllContentView];
}

- (void)setupControllViewFrame
{
    // 1.顶部bar
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    if (kVP_IS_IPHONE_X && _zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        rect.origin.x = 44;
        rect.size.width = rect.size.width - 44 * 2;
    }
    self.controllView.frame = rect;
    CGFloat controllViewW = self.controllView.bounds.size.width;
    CGFloat controllViewH = self.controllView.bounds.size.height;
    
    CGFloat kTopBarMargin = 20;
    // 1.1 backBtn
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [self.topBar addSubview:self.backBtn];
        self.backBtn.frame = CGRectMake(0, kTopBarMargin, kHCVP_BtnWidth, 44);
    }
    else
    {
        self.backBtn.frame = CGRectZero;
        if (_showBackWhileZoomIn) {
            [self.controllContentView addSubview:self.backBtn];
            self.backBtn.frame = CGRectMake(0, kTopBarMargin, kHCVP_BtnWidth, 44);
        }
    }
    
    CGFloat imageW = self.moreBtn.imageView.image.size.width;
    // 1.2 moreBtn
    UIView *view = nil;
    CGFloat width = (self.moreBtn.alpha && !self.moreBtn.hidden) ? kHCVP_BtnWidth : 0;
    CGFloat height = 44;
    CGFloat x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    CGFloat y = kTopBarMargin;
    self.moreBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.moreBtn;
    }
    
    // 1.3 shareBtn
    imageW = self.shareBtn.imageView.image.size.width;
    width = (self.shareBtn.alpha && !self.shareBtn.hidden) ? kHCVP_BtnWidth : 0;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    x = (CGRectGetMinX(self.moreBtn.frame) == controllViewW) ? x : CGRectGetMinX(self.moreBtn.frame) - width;
    self.shareBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.shareBtn;
    }
    
    // 1.4 tvBtn
    imageW = self.tvBtn.imageView.image.size.width;
    width = (self.tvBtn.alpha && !self.tvBtn.hidden) ? kHCVP_BtnWidth : 0;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    x = (CGRectGetMinX(self.shareBtn.frame) == controllViewW) ? x : CGRectGetMinX(self.shareBtn.frame) - width;
    self.tvBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.tvBtn;
    }
    
    // 1.5 titleLabel
    if (view) {
        width = CGRectGetMinX(self.tvBtn.frame) - CGRectGetMaxX(self.backBtn.frame) + 5;
    }
    else {
        width = controllViewW - CGRectGetMaxX(self.backBtn.frame) - 10;
    }
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    height = size.height;
    x = CGRectGetMaxX(self.backBtn.frame) - 5;
    y = (self.backBtn.frame.size.height - height) * 0.5 + self.backBtn.frame.origin.y;
    self.titleLabel.frame = CGRectMake(x, y, width, height);
    
    // 1.6 topBar
    x = 0;
    y = 0;//_zoomStatus == HCVideoPlayerZoomStatusZoomOut ? 20 : 15;
    width = controllViewW;
    height = MAX(66, MAX(CGRectGetMaxY(self.titleLabel.frame), CGRectGetMaxY(self.backBtn.frame)));
    self.topBar.frame = CGRectMake(x, y, width, height);
    
    // 2.底部bar
    // 2.1 bottomBar
    CGFloat botBarHeight = kHCVP_BottomBarHeight + (_zoomStatus == HCVideoPlayerZoomStatusZoomOut ? kVP_iPhoneXSafeBottomHeight : 0);
    x = 0;
    width = controllViewW;
    height = botBarHeight;
    y = controllViewH - height;
    self.bottomBar.frame = CGRectMake(x, y, width, height);
    
    // 2.1
    
    // 2.2 playerBtn
    imageW = self.playerBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    x = 20 - (width - imageW) * 0.5;
    y = 0;
    height = botBarHeight;
    self.playerBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.3 nextBtn
    width = (self.nextBtn.alpha && !self.nextBtn.hidden) ? MAX(kHCVP_BtnWidth, self.nextBtn.bounds.size.width) : 0;
    height = botBarHeight;
    x = CGRectGetMaxX(self.playerBtn.frame);
    y = 0;
    self.nextBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.4 zoomBtn
    imageW = self.zoomBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    height = botBarHeight;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    y = 0;
    self.zoomBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.5 episodeBtn
    width = (self.episodeBtn.alpha && !self.episodeBtn.hidden) ? MAX(kHCVP_BtnWidth, self.episodeBtn.bounds.size.width) : 0;
    height = botBarHeight;
    x = CGRectGetMinX(self.zoomBtn.frame) - width;
    y = 0;
    self.episodeBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.6 progressView
    x = CGRectGetMaxX(self.nextBtn.frame);
    y = 0;
    height = botBarHeight;
    width = CGRectGetMinX(self.episodeBtn.frame) - CGRectGetMaxX(self.nextBtn.frame) - (self.episodeBtn.alpha ? 5 : 0);
    self.progressView.frame = CGRectMake(x, y, width, height);
    
    [self setupTimeLabelFrame];
    
    // 3.rightSlide
    CGFloat rightSlideBtnH = 44;
    NSInteger showBtnCount = 0;
    if (self.cameraBtn.alpha && !self.cameraBtn.hidden) {
        showBtnCount += 1;
    }
    if (self.switchBtn.alpha && !self.switchBtn.hidden) {
        showBtnCount += 1;
    }
    CGFloat padding = 20;
    CGFloat totalH = showBtnCount * rightSlideBtnH + (showBtnCount - 1) * padding;
    CGFloat fristY = (controllViewH - totalH) * 0.5;
    
    // 3.1 cameraBtn
    imageW = self.cameraBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    height = (self.cameraBtn.alpha && !self.cameraBtn.hidden) ? rightSlideBtnH : 0;
    x = controllViewW - width - 20 + (width - imageW) * 0.5;
    y = fristY;
    self.cameraBtn.frame = CGRectMake(x, y, width, height);
    
    width = 68;
    height = [self.imageShareView heightToFit];
    x = CGRectGetMinX(self.cameraBtn.frame) - width - 10;
    y = CGRectGetMinY(self.cameraBtn.frame) + (CGRectGetHeight(self.cameraBtn.frame) - height) * 0.5;
    self.imageShareView.frame = CGRectMake(x, y, width, height);
    
    // 3.2 switchBtn
    imageW = self.switchBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    height = (self.switchBtn.alpha && !self.switchBtn.hidden) ? rightSlideBtnH : 0;
    x = controllViewW - width - 20 + (width - imageW) * 0.5;;
    y = CGRectGetMaxY(self.cameraBtn.frame) + ((CGRectGetMaxY(self.cameraBtn.frame) == fristY) ? 0 : padding);
    self.switchBtn.frame = CGRectMake(x, y, width, height);
}

- (void)setupTimeLabelFrame
{
    CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = CGRectGetMaxX(self.progressView.frame) - size.width;
    CGFloat y = CGRectGetMaxY(self.progressView.frame) - self.progressView.frame.size.height * 0.5 + 5;
    CGFloat width = size.width;
    CGFloat height = size.height;
    self.timeLabel.frame = CGRectMake(x, y, width, height);
}

- (void)setupLockContentViewFrame
{
    // 1.顶部bar
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    if (kVP_IS_IPHONE_X && _zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        rect.origin.x = 44;
        rect.size.width = rect.size.width - 44 * 2;
    }
    self.lockContentView.frame = rect;
    CGFloat lockContentViewW = self.lockContentView.bounds.size.width;
    CGFloat lockContentViewH = self.lockContentView.bounds.size.height;
    
    // 1. lockTopBar
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = lockContentViewW;
    CGFloat height = 66;
    self.lockTopBar.frame = CGRectMake(x, y, width, height);
    
    // 2. lockBottomBar
    CGFloat botBarHeight = kHCVP_BottomBarHeight + (_zoomStatus == HCVideoPlayerZoomStatusZoomOut ? kVP_iPhoneXSafeBottomHeight : 0);
    x = 0;
    width = lockContentViewW;
    height = botBarHeight;
    y = lockContentViewH - height;
    self.lockBottomBar.frame = CGRectMake(x, y, width, height);
}

- (void)setupTVControllViewFrame
{
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    if (kVP_IS_IPHONE_X && _zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        rect.origin.x = 44;
        rect.size.width = rect.size.width - 44 * 2;
    }
}

- (void)setupBtnsShow
{
    self.showMoreBtn = YES;
    self.showShareBtn = YES;
    self.showTvBtn = YES;
    self.showCameraBtn = YES;
    self.showEpisodeBtn = YES;
    self.showNextBtn = YES;
    self.showSwitchBtn = YES;
}

- (void)setupZoomInHiddenBtns
{
    _zoomInHiddenMoreBtn = YES;
    _zoomInHiddenShareBtn = NO;
    _zoomInHiddenTvBtn = NO;
    _zoomInHiddenCameraBtn = YES;
    _zoomInHiddenNextBtn = NO;
    _zoomInHiddenEpisodeBtn = YES;
    _zoomInHiddenSwitchBtn = NO;
    _zoomInHiddenLockBtn = YES;
}

#pragma mark - 外部方法
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController;
{
    return [self showWithUrl:url curController:curController readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
        [videoPlayer play];
    }];
}

+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController readyComplete:(HCVideoPlayerReadyComplete)readyComplete;
{
    if (![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    HCVideoPlayer *videoPlayer = [[self alloc] initWithCurController:curController];
    [[UIApplication sharedApplication].keyWindow addSubview:videoPlayer];
    
    videoPlayer.zoomInWhenVerticalScreen = NO;
    videoPlayer.noZoomInShowModel = YES;
    
    // 放大显示一些按钮比如更多按钮
    [videoPlayer setBtnsZoomInHidden:NO];
    // 放大设置屏幕可转
    [AppDelegate setAllowRotation:YES forRootPresentVc:videoPlayer.rootPresentVc];
    
    videoPlayer.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
    [videoPlayer setupControllContentViewPanGesture];
    
    if (videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeLeft && videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeRight) {
        [AppDelegate setPortraitOrientation];
        videoPlayer.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    CGFloat angle = ((videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight) ? -M_PI_2 : M_PI_2);
    videoPlayer.transform = CGAffineTransformMakeRotation(angle);
    videoPlayer.frame = [UIScreen mainScreen].bounds;
    CGRect rect = videoPlayer.frame;
    rect.origin.x = -kVP_ScreenWidth;
    videoPlayer.frame = rect;
    videoPlayer.isOnRotaion = YES;
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        CGRect rect = videoPlayer.frame;
        rect.origin.x = 0;
        videoPlayer.frame = rect;
    } completion:^(BOOL finished) {
        [videoPlayer playWithUrl:url readyComplete:readyComplete];
        videoPlayer.zoomBtn.selected = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
        HCOrientController *orVC = [[HCOrientController alloc] init];
        videoPlayer.orVC = orVC;
        orVC.delegate = videoPlayer;
        orVC.orientation = (videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
        UITabBarController *tabVc = [[UITabBarController alloc] init];
        [tabVc addChildViewController:nvc];
        
        [videoPlayer.rootPresentVc presentViewController:tabVc animated:NO completion:^{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
            [AppDelegate setOrientation:orVC.orientation];// 设置一致方向
        }];
        
        videoPlayer.transform = CGAffineTransformIdentity;
        videoPlayer.frame = [UIScreen mainScreen].bounds;
        videoPlayer.isOnRotaion = NO;
    }];
    return videoPlayer;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self playWithUrl:url];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
}

- (void)playWithUrl:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [self playWithUrl:url readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
        [weakSelf play];
    }];
}

- (void)playWithUrl:(NSURL *)url readyComplete:(HCVideoPlayerReadyComplete)readyComplete
{
//    _tvControllView.hidden = ![HCAirplayCastTool isAirPlayOnCast];
//    self.loadErrorLabel.hidden = YES;
//    self.controllView.hidden = YES;
//    if (self.zoomBtn.selected == YES && !_noZoomInShowModel) { // 防止点放大点快了旋转时点到下面一层
//        [[UIApplication sharedApplication].keyWindow addSubview:self];
//        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
//        return;
//    }
    _url = url;
    if (!_url) {
        _url = [NSURL URLWithString:@""];
    }
    
    @autoreleasepool {
        [self stop];
        __weak typeof(self) weakSelf = self;
        [self layoutSubviews];
        if (_urlPlayer.playerState != HCPlayerViewStatePlay) {
            self.playerBtn.selected = NO;
            [self.contentView addSubview:self.urlPlayer];
            self.urlPlayer.volume = _volume;
            [self.urlPlayer readyWithUrl:_url complete:^(HCPlayerViewState status) {
                if (readyComplete) {
                    readyComplete(weakSelf, [weakSelf status]);
                }
            }];
            [self showLoading];
        }
        else
        {
            self.playerBtn.selected = YES;
            if (readyComplete) {
                readyComplete(weakSelf, [weakSelf status]);
            }
        }
        [self.contentView bringSubviewToFront:self.controllContentView];
    }
}

- (void)play
{
    if (_url)
    {
        [_urlPlayer play];
    }
}

- (void)pause
{
    if (_url)
    {
        [_urlPlayer pause];
    }
}

- (void)resume
{
    if (_url)
    {
        [_urlPlayer play];
    }
}

- (void)stop
{
    @autoreleasepool {
        [_urlPlayer stop];
        
        [[HCNetWorkSpeed shareNetworkSpeed] stopMonitoringNetworkSpeed];
        self.loadSpeedLabel.text = @"0.0KB/s";
        [self hiddenLoading];
        self.controllView.hidden = YES;
        self.progressView.playTime = 0;
        self.progressView.loadTime = 0;
        self.progressView.totalTime = 0;
        //        _urlPlayer.delegate = nil;
        //        [_urlPlayer removeFromSuperview];
        //        _urlPlayer = nil;
    }
}

- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay
{
    self.progressView.playTime = 0;
    [self.urlPlayer seekToTime:time autoPlay:autoPlay];
}

- (HCVideoPlayerStatus)status
{
    HCVideoPlayerStatus status = HCVideoPlayerStatusIdle;
    if (_url && _urlPlayer.playerState == HCPlayerViewStateReadying) {
        status = HCVideoPlayerStatusReadying;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateReadyed)
    {
        status = HCVideoPlayerStatusReadyed;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePlay)
    {
        status = HCVideoPlayerStatusPlay;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePause)
    {
        status = HCVideoPlayerStatusPause;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePlayback)
    {
        status = HCVideoPlayerStatusPlayback;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateStop)
    {
        status = HCVideoPlayerStatusStop;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateError)
    {
        status = HCVideoPlayerStatusError;
    }
    return status;
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    self.urlPlayer.volume = _volume;
}

- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    self.urlPlayer.rate = rate;
}

- (void)setShowMoreBtn:(BOOL)showMoreBtn
{
    _showMoreBtn = showMoreBtn;
    self.moreBtn.alpha = _showMoreBtn;
}

- (void)setShowShareBtn:(BOOL)showShareBtn
{
    _showShareBtn  = showShareBtn;
    self.shareBtn.alpha = _showShareBtn;
}

- (void)setShowTvBtn:(BOOL)showTvBtn
{
    _showTvBtn = showTvBtn;
    self.tvBtn.alpha = _showTvBtn;
}

- (void)setShowCameraBtn:(BOOL)showCameraBtn
{
    _showCameraBtn = showCameraBtn;
    self.cameraBtn.alpha = _showCameraBtn;
}

- (void)setShowNextBtn:(BOOL)showNextBtn
{
    _showNextBtn = showNextBtn;
    self.nextBtn.alpha = _showNextBtn;
}

- (void)setShowEpisodeBtn:(BOOL)showEpisodeBtn
{
    _showEpisodeBtn = showEpisodeBtn;
    self.episodeBtn.alpha = _showEpisodeBtn;
}

- (void)setShowSwitchBtn:(BOOL)showSwitchBtn
{
    _showSwitchBtn = showSwitchBtn;
    self.switchBtn.alpha = _showSwitchBtn;
}

- (void)setShowLockBtn:(BOOL)showLockBtn
{
    _showLockBtn = showLockBtn;
    self.lockBtn.alpha = _showLockBtn;
}

- (void)setZoomInHiddenMoreBtn:(BOOL)zoomInHiddenMoreBtn
{
    _zoomInHiddenMoreBtn = zoomInHiddenMoreBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenShareBtn:(BOOL)zoomInHiddenShareBtn
{
    _zoomInHiddenShareBtn = zoomInHiddenShareBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenTvBtn:(BOOL)zoomInHiddenTvBtn
{
    _zoomInHiddenTvBtn = zoomInHiddenTvBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenCameraBtn:(BOOL)zoomInHiddenCameraBtn
{
    _zoomInHiddenCameraBtn = zoomInHiddenCameraBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenNextBtn:(BOOL)zoomInHiddenNextBtn
{
    _zoomInHiddenNextBtn = zoomInHiddenNextBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenEpisodeBtn:(BOOL)zoomInHiddenEpisodeBtn
{
    _zoomInHiddenEpisodeBtn = zoomInHiddenEpisodeBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenSwitchBtn:(BOOL)zoomInHiddenSwitchBtn
{
    _zoomInHiddenSwitchBtn = zoomInHiddenSwitchBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenLockBtn:(BOOL)zoomInHiddenLockBtn
{
    _zoomInHiddenLockBtn = zoomInHiddenLockBtn;
    [self setBtnsZoomInHidden:(_zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete
{
    [_urlPlayer getCurrentTimeImageComplete:^(UIImage *image) {
        if (complete) {
            complete(image);
        }
    }];
}

- (void)setCurController:(UIViewController *)curController
{
    _curController = curController;
    if (_curController == nil) {
        _rootPresentVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    else
    {
        _rootPresentVc = [self getRootPresentVcWithCurVc:_curController];
    }
}

- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden
{
    if (![msg isKindOfClass:[NSString class]]) {
        msg = @"";
    }
    if (stopPlay) {
        [self stop];
    }
    
    CGSize selfSize = self.frame.size;
    self.messageLabel.text = msg;
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(selfSize.width - 30, CGFLOAT_MAX)];
    CGFloat width = size.width + 6;
    CGFloat height = size.height + 6;
    CGFloat y = CGRectEqualToRect(self.loadSpeedLabel.frame, CGRectZero) ? (selfSize.height - height) * 0.5 : CGRectGetMaxY(self.loadSpeedLabel.frame) + 10;
    CGFloat x = (selfSize.width - width) * 0.5;
    self.messageLabel.frame = CGRectMake(x, y, width, height);
    self.messageLabel.hidden = NO;
    self.messageLabel.alpha = 1.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (autoHidden) {
            [UIView animateWithDuration:kVP_AniDuration animations:^{
                self.messageLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.messageLabel.hidden = YES;
            }];
        }
    });
}

- (void)hiddenMsgAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.messageLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.messageLabel.hidden = YES;
        }];
    }
    else
    {
        self.messageLabel.hidden = YES;
    }
}

- (void)setIsLive:(BOOL)isLive
{
    _isLive = isLive;
    self.playerBtn.hidden = _isLive;
    self.nextBtn.hidden = _isLive;
    self.progressView.hidden = _isLive;
    self.episodeBtn.hidden = _isLive;
    self.timeLabel.hidden = _isLive;
    [self setupControllViewFrame];
}

- (void)stopAndExitFullScreen
{
    [self stop];
    
    [self removeFromSuperview];
    [_orVC dismissViewControllerAnimated:NO completion:^{
    }];
    [AppDelegate setPortraitOrientation];
    [AppDelegate setAllowRotation:NO forRootPresentVc:nil];
}

- (void)makeZoomIn
{
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [self zoomBtnClicked:self.zoomBtn];
    }
}

#pragma mark - HCPlayerViewDelegate
- (void)playerView:(HCPlayerView *)playerView vedioSize:(CGSize)vedioSize
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)playerView:(HCPlayerView *)playerView totalTime:(NSTimeInterval)totalTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.progressView.totalTime = totalTime;
            _totalTime = totalTime;
        }
        else
        {
            self.progressView.totalTime = 0;
            _totalTime = 0;
        }
    });
}

- (void)playerView:(HCPlayerView *)playerView loadTime:(NSTimeInterval)loadTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.progressView.loadTime = loadTime;
            [self showOrHiddenLoading];
        }
        else
        {
            self.progressView.loadTime = 0;
        }
    });
}

- (void)playerView:(HCPlayerView *)playerView playTime:(NSTimeInterval)playTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _lastPanContentViewTime = playTime;
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            
            if (fabs(playTime - self.progressView.playTime) <= 3 || self.progressView.playTime == 0) { // 避免手动改变进度进度条会返回的情况
                self.progressView.playTime = playTime;
            }
            [self showOrHiddenLoading];
            self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:playTime], [NSString vp_formateStringFromSec:self.progressView.totalTime]];
            
            self.progressLabel.hidden = YES;
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:playTime:)]) {
                [self.delegate videoPlayer:self playTime:playTime];
            }
        }
        else
        {
            self.progressView.playTime = 0;
            self.timeLabel.text = @"00:00 / 00:00";
        }
        [self setupTimeLabelFrame];
    });
}

- (void)didReadyForPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = NO;
        }
    });
}

- (void)didStartPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(didStartPlayForVideoPlayer:)]) {
            [self.delegate didStartPlayForVideoPlayer:self];
        }
    });
}

- (void)didContinuePlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(didContinuePlayForVideoPlayer:)]) {
            [self.delegate didContinuePlayForVideoPlayer:self];
        }
    });
}

- (void)didPausePlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = NO;
        }
    });
}

- (void)didStopPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = NO;
            self.progressView.loadProgress = 1.0;
        }
    });
}

- (void)didPlaybackForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        __weak typeof(self) weakSelf = self;
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
            self.playerBtn.selected = NO;
            self.progressView.playProgress = 0.0;
            if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut && !_isOnRotaion && !_noZoomInShowModel) {
                [self zoomBtnClicked:self.zoomBtn duration:kVP_rotaionAniDuration complete:^(HCVideoPlayerZoomStatus zoomStatus) {
                    [weakSelf setupControllContentViewPanGesture];
                    if ([weakSelf.delegate respondsToSelector:@selector(didPlaybackForVideoPlayer:)]) {
                        [weakSelf.delegate didPlaybackForVideoPlayer:weakSelf];
                    }
                }];
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(didPlaybackForVideoPlayer:)]) {
                    [self.delegate didPlaybackForVideoPlayer:self];
                }
            }
        }
    });
}

- (void)didLoadErrorForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self showLoadError];
    });
}

#pragma mark - HCProgressViewDelegate
- (void)progressView:(HCProgressView *)progressView didChangedSliderValue:(double)sliderValue time:(NSTimeInterval)time;
{
    @autoreleasepool {
        if (self.url)
        {
//            VPLog(@"seekTime == %f", seekTime);
            [_urlPlayer seekToTime:time autoPlay:NO];
//            self.progressView.loadTime = 0;
        }
    }
}

- (void)progressView:(HCProgressView *)progressView didSliderUpAtValue:(CGFloat)value time:(CGFloat)time
{
    @autoreleasepool {
        if (self.url)
        {
//            VPLog(@"seekTime == %f", time);
            [_urlPlayer seekToTime:time autoPlay:YES];
//            self.progressView.loadTime = 0;
        }
    }
}

#pragma mark - HCOrientControllerDelegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isOnRotaion = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isOnRotaion = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _isOnRotaion = NO;
}

#pragma mark - HCSharePanelDelegate
- (void)sharePanel:(HCSharePanel *)sharePanel didSelectItem:(HCShareItem *)item
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didSelectSharePanelItem:shareImage:)]) {
        [self.delegate videoPlayer:self didSelectSharePanelItem:item shareImage:([item.key isEqualToString:ShareListKeyImageShare] ? self.imageShareView.image : nil)];
    }
    [_sharePanel hiddenPanel];
}

- (void)didHiddenSharePanel
{
    self.controllView.hidden = NO;
}

#pragma mark - HCMorePanelDelegate
- (void)morePanel:(HCMorePanel *)morePanel didSelectRate:(CGFloat)rate
{
    self.rate = rate;
}

- (void)morePanel:(HCMorePanel *)morePanel didChangeColloctStatus:(BOOL)status
{
    _collectStatus = status;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeMorePanelColloctStatus:)]) {
        [self.delegate videoPlayer:self didChangeMorePanelColloctStatus:status];
    }
}

- (void)didHiddenMorePanel
{
    self.controllView.hidden = NO;
}

#pragma mark - 事件
- (void)backBtnClicked
{
    if (_noZoomInShowModel) {
        [self hiddenSelf];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBackBtnAtZoomStatus:)]) {
            [self.delegate videoPlayer:self didClickBackBtnAtZoomStatus:_zoomStatus];
        }
        if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
            [self zoomBtnClicked:self.zoomBtn];
        }
    }
}

- (void)zoomBtnClicked:(UIButton *)zoomBtn
{
    __weak typeof(self) weakSelf = self;
    if (_noZoomInShowModel) {
        [self hiddenSelf];
    }
    else
    {
        [self zoomBtnClicked:zoomBtn duration:kVP_rotaionAniDuration complete:^(HCVideoPlayerZoomStatus zoomStatus) {
            [weakSelf setupControllContentViewPanGesture];
        }];
    }
}

- (void)zoomBtnClicked:(UIButton *)zoomBtn duration:(NSTimeInterval)duration complete:(void (^)(HCVideoPlayerZoomStatus zoomStatus))complete
{
    if (!self.superview) {
        return;
    }
    @autoreleasepool {
        zoomBtn.selected = !zoomBtn.selected;
        _zoomStatus = HCVideoPlayerZoomStatusZoomIn;
        if (zoomBtn.selected) {
            _zoomStatus = HCVideoPlayerZoomStatusZoomOut;
        }
        
        __weak typeof(self) weakSelf = self;
        if (self.zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:self.orgRect]}];
            
            // 隐藏分享面板
            [_sharePanel hiddenPanel];
            [_morePanel hiddenPanel];
            
            self.isOnRotaion = YES;
            [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
                // 缩小隐藏一些按钮
                [weakSelf setBtnsZoomInHidden:YES];
                // 缩小屏幕不可旋转
                [AppDelegate setAllowRotation:NO forRootPresentVc:weakSelf.rootPresentVc];

                CGRect rect = weakSelf.orgRect;
                [UIView animateWithDuration:duration animations:^{
                    weakSelf.transform = CGAffineTransformIdentity;
                    weakSelf.frame = rect;
                } completion:^(BOOL finished) {
                    if (weakSelf.getPlayerSuperViewBlock) {
                        weakSelf.playSuperView = weakSelf.getPlayerSuperViewBlock(weakSelf);
                    }
                    if (weakSelf.getPlayerDelegateBlock) {
                        weakSelf.delegate = weakSelf.getPlayerDelegateBlock(weakSelf);
                    }
                    [weakSelf.playSuperView addSubview:weakSelf];
                    weakSelf.frame = weakSelf.playSuperView.bounds;

                    if (complete) {
                        complete(HCVideoPlayerZoomStatusZoomIn);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                        [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomIn];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];

                    weakSelf.isOnRotaion = NO;
                    [AppDelegate setPortraitOrientation];
                }];
            }];
            [UIApplication sharedApplication].statusBarStyle = self.orgStatusBarStyle;
            [UIApplication sharedApplication].statusBarHidden = self.orgStatusBarHidden;
            self.center = [UIApplication sharedApplication].keyWindow.center;
            self.transform = CGAffineTransformMakeRotation(self.deviceOrientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : -M_PI_2);
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)]}];
            
            // 放大显示一些按钮比如更多按钮
            [self setBtnsZoomInHidden:NO];
            // 放大设置屏幕可转
            [AppDelegate setAllowRotation:YES forRootPresentVc:self.rootPresentVc];
            
            self.playSuperView = self.superview;
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            self.orgRect = [self getOrgRect];
            self.frame = self.orgRect;
            self.isOnRotaion = YES;
            
            if (self.deviceOrientation != UIDeviceOrientationLandscapeLeft && self.deviceOrientation != UIDeviceOrientationLandscapeRight) {
                [AppDelegate setPortraitOrientation];
                self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
            [UIView animateWithDuration:duration animations:^{
                self.center = [UIApplication sharedApplication].keyWindow.center;
                CGFloat angle = ((self.deviceOrientation == UIDeviceOrientationLandscapeRight) ? -M_PI_2 : M_PI_2);
                self.transform = CGAffineTransformMakeRotation(angle);
                self.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarHidden = self.controllView.hidden;
                HCOrientController *orVC = [[HCOrientController alloc] init];
                self.orVC = orVC;
                orVC.delegate = self;
                orVC.orientation = (self.deviceOrientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
                UITabBarController *tabVc = [[UITabBarController alloc] init];
                [tabVc addChildViewController:nvc];
                
                [self.rootPresentVc presentViewController:tabVc animated:NO completion:^{
                    if (complete) {
                        complete(HCVideoPlayerZoomStatusZoomOut);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                        [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomOut];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    [UIApplication sharedApplication].statusBarHidden = weakSelf.controllView.hidden;
                    [AppDelegate setOrientation:orVC.orientation];// 设置一致方向
                }];
                
                self.transform = CGAffineTransformIdentity;
                self.frame = [UIScreen mainScreen].bounds;
                self.isOnRotaion = NO;
            }];
        }
    }
}

- (void)playerBtnClicked:(UIButton *)playerBtn
{
    @autoreleasepool {
        if (self.url)
        {
            if (self.urlPlayer.playerState == HCPlayerViewStateReadying) {
                return;
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStatePlay)
            {
                [self.urlPlayer pause];
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStatePlayback || self.urlPlayer.playerState == HCPlayerViewStateReadyed)
            {
                [self.urlPlayer play];
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStateStop || self.urlPlayer.playerState == HCPlayerViewStateIdle || self.urlPlayer.playerState == HCPlayerViewStateError)
            {
                [self showLoading];
                [self.urlPlayer readyWithUrl:self.url];
            }
        }
        self.messageLabel.hidden = YES;
    }
}

- (void)controllContentViewClicked
{
//    if ((!(self.urlPlayer.playerState == HCPlayerViewStateReadyed || self.urlPlayer.playerState == HCPlayerViewStatePlay|| self.urlPlayer.playerState == HCPlayerViewStatePause|| self.urlPlayer.playerState == HCPlayerViewStatePlayback)) && !_noZoomInShowModel) {
//        return;
//    }
    if (self.lockBtn.selected) {
        self.lockContentView.hidden = NO;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.lockContentView.alpha = 1.0;
        }];
    }
    else
    {
        self.controllView.hidden = NO;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.controllView.alpha = 1.0;
        }];
    }
    
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)controllContentViewPan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self.controllContentView];
    CGPoint translation = [pan translationInView:self.controllContentView];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _slideDirection = 0;
        _volumeLastY = 0;
        _brightLastY = 0;
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        if (_slideDirection == 0) { // 定这次滑动的方向
            _slideDirection = fabs(translation.y) > fabs(translation.x) ? -1 : 1;
        }
        
        if (_slideDirection == -1) { // 上下滑动
            // 调节系统音量
            if (location.x > self.controllContentView.frame.size.width * 0.5) {
                if (fabs(translation.y - _volumeLastY) > 5) {
                    Float32 systemVolume = _volumeViewSlider.value;
                    systemVolume = systemVolume + ((translation.y - _volumeLastY) > 0 ? -0.0667 : 0.0667);
                    if (systemVolume > 1.0) {
                        systemVolume = 1.0;
                    }
                    if (systemVolume < 0.0) {
                        systemVolume = 0.0;
                    }
                    // change system volume, the value is between 0.0f and 1.0f
                    [self.volumeViewSlider setValue:systemVolume animated:YES];
                    _volumeLastY = translation.y;
                }
            }
            // 调节系统屏幕亮度
            else
            {
                if (fabs(translation.y - _brightLastY) > 5) {
                    CGFloat systemBright = [UIScreen mainScreen].brightness;
                    systemBright = systemBright + ((translation.y - _brightLastY) > 0 ? -0.0667 : 0.0667);
                    if (systemBright > 1.0) {
                        systemBright = 1.0;
                    }
                    if (systemBright < 0.0) {
                        systemBright = 0.0;
                    }
                    // change system volume, the value is between 0.0f and 1.0f
                    //            [UIScreen mainScreen].brightness = systemBright;
                    [[UIScreen mainScreen] setBrightness:systemBright];
                    _brightLastY = translation.y;
                }
                VPLog(@"在左边滑动 %f", translation.y);
            }
        }
        else { // 左右滑动
            if (_isLive) { // 直播情况
                return;
            }
            if ((self.status == HCVideoPlayerStatusPlay || self.status == HCVideoPlayerStatusPause) && _zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
                [self pause];
                _currentPanContentViewTime = _lastPanContentViewTime + translation.x;
                if (_currentPanContentViewTime < 0) {
                    _currentPanContentViewTime = 0;
                }
                if (_currentPanContentViewTime > self.progressView.totalTime) {
                    _currentPanContentViewTime = self.progressView.totalTime;
                }
                self.progressView.playTime = _currentPanContentViewTime;
                self.progressLabel.hidden = NO;
                NSString *time = [NSString vp_formateStringFromSec:_currentPanContentViewTime];
                self.progressLabel.text = @"00:00";
                if (time.length > 5) {
                    self.progressLabel.text = @"00:00:00";
                }
                [self.progressLabel sizeToFit];
                self.progressLabel.text = time;
                
                CGFloat width = self.progressLabel.frame.size.width;
                CGFloat height = self.progressLabel.frame.size.height;
                CGFloat x = floor((kVP_ScreenWidth - width) * 0.5);
                CGFloat y = floor(CGRectGetMinY(self.activityIndicator.frame) - height - 10);
                self.progressLabel.frame = CGRectMake(x, y, width, height);
                
                self.controllView.hidden = NO;
                [UIView animateWithDuration:kVP_AniDuration animations:^{
                    self.controllView.alpha = 1.0;
                }];
            }
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        if (_slideDirection == 1 && !_isLive) { // 左右滑动
            [_urlPlayer seekToTime:self.progressView.playTime autoPlay:YES];
            self.progressLabel.hidden = YES;
            _lastPanContentViewTime = _currentPanContentViewTime;
        }
    }
}

- (void)controllerViewClicked
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.controllView.alpha = 0.0;
        self.imageShareView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.controllView.hidden = YES;
        CGRect rect = self.qualitySheet.frame;
        self.qualitySheet.hidden = YES;
        rect.size.height = 0;
        rect.origin.y = self.bottomBar.frame.origin.y;
        self.qualitySheet.frame = rect;
    }];
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)lockContentViewClicked
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.lockContentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.lockContentView.hidden = YES;
    }];
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)qualityBtnClicked:(UIButton *)qualityBtn
{
    CGRect rect = self.qualitySheet.frame;
    if (self.qualitySheet.hidden) {
        self.qualitySheet.hidden = NO;
        self.qualitySheet.alpha = 1.0;
        rect.size.height = 100;
        rect.origin.y = self.bottomBar.frame.origin.y - rect.size.height;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.qualitySheet.frame = rect;
        }];
    }
    else
    {
        rect.size.height = 0;
        rect.origin.y = self.bottomBar.frame.origin.y;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.qualitySheet.alpha = 0.0;
        }completion:^(BOOL finished) {
            self.qualitySheet.hidden = YES;
            self.qualitySheet.frame = rect;
        }];
    }
}

- (void)bottomBarPan:(UIPanGestureRecognizer *)recognizer
{
    if (_isLive) {  // 直播情况
        return;
    }
    CGPoint point =  [recognizer translationInView:self.progressView];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
        [self progressView:self.progressView didSliderUpAtValue:self.progressView.playProgress time:self.progressView.playTime];
        [self.urlPlayer play];
//        self.progressView.loadTime = 0;
        self.isPan = NO;
    }
    else {
        if (!self.isPan) {
            self.panStartProgress = self.progressView.playProgress;
        }
        self.isPan = YES;
        [self.urlPlayer pause];
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
    }
}

- (void)loadErrorLabelClicked
{
    if (_url) {
        [self playWithUrl:_url];
    }
}

- (void)moreBtnClicked:(UIButton *)btn
{
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickMoreBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickMoreBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    HCMorePanel *morePanel = [[HCMorePanel alloc] init];
    morePanel.rate = _rate;
    morePanel.delegate = self;
    morePanel.collectStatus = _collectStatus;
    [morePanel showPanelAtView:self.controllContentView];
    _morePanel = morePanel;
    self.controllView.hidden = YES;
}

- (void)shareBtnClicked:(UIButton *)btn
{
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickShareBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickShareBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    HCSharePanel *sharePanel = [[HCSharePanel alloc] init];
    [sharePanel showPanelAtView:self.controllContentView key:ShareListKeyLinkShare];
    sharePanel.delegate = self;
    _sharePanel = sharePanel;
    self.controllView.hidden = YES;
}

- (void)tvBtnClicked:(UIButton *)btn
{
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickTVBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickTVBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    if ((self.urlPlayer.playerState == HCPlayerViewStateReadyed || self.urlPlayer.playerState == HCPlayerViewStatePlay || self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStatePlayback) && !_isLive) {
        [self pause];
    }
    else
    {
        [self stop];
    }
}

- (void)nextBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickNextBtn:)]) {
        [self.delegate videoPlayer:self didClickNextBtn:btn];
    }
}

- (void)episodeBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickEpisodeBtn:)]) {
        [self.delegate videoPlayer:self didClickEpisodeBtn:btn];
    }
}

- (void)cameraBtnClicked:(UIButton *)btn
{
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickCameraBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickCameraBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.imageShareView.alpha == 0) {
        [self.urlPlayer getCurrentTimeImageComplete:^(UIImage *image) {
            weakSelf.imageShareView.image = image;
            [UIView animateWithDuration:kVP_AniDuration animations:^{
                weakSelf.imageShareView.alpha = 1 - weakSelf.imageShareView.alpha;;
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.imageShareView.alpha = 1 - self.imageShareView.alpha;;
        }];
    }
}

- (void)didClickSwitchBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickSwitchBtn:)]) {
        [self.delegate videoPlayer:self didClickSwitchBtn:btn];
    }
}

- (void)imageShareViewClicked
{
    HCSharePanel *sharePanel = [[HCSharePanel alloc] init];
    [sharePanel showPanelAtView:self.controllContentView key:ShareListKeyImageShare];
    sharePanel.delegate = self;
    
    _sharePanel = sharePanel;
    self.controllView.hidden = YES;
    self.imageShareView.alpha = 0.0;
}

- (void)didClickLockBtn
{
    self.lockBtn.selected = !self.lockBtn.selected;
    
    if (self.lockBtn.selected) {
        if ([self isControllContentViewShowContent]) {
            self.lockContentView.alpha = 1.0;
            self.lockContentView.hidden = NO;
        }
        self.controllView.hidden = YES;
        self.controllView.alpha = 0;
    }
    else
    {
        if ([self isControllContentViewShowContent]) {
            self.controllView.alpha = 1.0;
            self.controllView.hidden = NO;
        }
        self.lockContentView.hidden = YES;
        self.lockContentView.alpha = 0;
    }
}

#pragma mark - 通知事件
- (void)orientationDidChange:(id)change
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            if (_autoZoom && [self isInCurrentShowControllerForSelf] && _zoomStatus == HCVideoPlayerZoomStatusZoomIn && !_isOnRotaion && (_urlPlayer.playerState == HCPlayerViewStatePlay || _urlPlayer.playerState == HCPlayerViewStatePause || _urlPlayer.playerState == HCPlayerViewStateReadyed)) {
                [self zoomBtnClicked:self.zoomBtn];
            }
            VPLog(@"UIDeviceOrientationLandscapeLeft");
        }
        if (orientation == UIDeviceOrientationLandscapeRight) {
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            if (_autoZoom && [self isInCurrentShowControllerForSelf] && _zoomStatus == HCVideoPlayerZoomStatusZoomIn && !_isOnRotaion && (_urlPlayer.playerState == HCPlayerViewStatePlay || _urlPlayer.playerState == HCPlayerViewStatePause || _urlPlayer.playerState == HCPlayerViewStateReadyed)) {
                [self zoomBtnClicked:self.zoomBtn];
            }
            VPLog(@"UIDeviceOrientationLandscapeRight");
        }
        if (orientation == UIDeviceOrientationPortrait && !self.lockBtn.selected) {
            if (_zoomInWhenVerticalScreen) {
                if (_autoZoom && [self isInCurrentShowControllerForSelf] && _zoomStatus == HCVideoPlayerZoomStatusZoomOut && !_isOnRotaion) {
                    [self zoomBtnClicked:self.zoomBtn];
                }
            }
            VPLog(@"UIDeviceOrientationPortrait");
        }
        if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            VPLog(@"UIDeviceOrientationPortraitUpsideDown");
        }
    });
}

- (void)networkReceivedSpeed:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadSpeedLabel.text = notification.userInfo[@"received"];
    });
}

#pragma mark AirPlay 相关通知
- (void)MPVolumeViewWirelessRoutesAvailableDidChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
//    [self setupIsWirelessRouteActive];
    });
}

#pragma mark - 内部方法
- (void)showOrHiddenLoading
{
    if (((fabs(self.progressView.loadTime - _progressView.playTime) < 0.3) && _urlPlayer.playerState == HCPlayerViewStatePlay) || _urlPlayer.playerState == HCPlayerViewStateReadying) {
        [self showLoading];
    }
    else
    {
        [self hiddenLoading];
    }
}

- (void)showLoading
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    self.loadSpeedLabel.hidden = NO;
    [[HCNetWorkSpeed shareNetworkSpeed] startMonitoringNetworkSpeed];
}

- (void)hiddenLoading
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    self.loadSpeedLabel.hidden = YES;
    [[HCNetWorkSpeed shareNetworkSpeed] stopMonitoringNetworkSpeed];
}

- (void)showLoadError
{
    [self hiddenLoading];
    self.loadErrorLabel.hidden = NO;
}

- (UIViewController *)viewControllerForView:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGRect)getOrgRect
{
    CGRect rect = [self.playSuperView convertRect:self.playSuperView.bounds toView:[UIApplication sharedApplication].keyWindow];
    if ([self viewControllerForView:self.playSuperView].navigationController && [UIApplication sharedApplication].statusBarHidden) {
        rect.origin.y -= 20;
    }
    else if (![self viewControllerForView:self.playSuperView].navigationController &&  ![UIApplication sharedApplication].statusBarHidden)
    {
        rect.origin.y += 20;
    }
    return rect;
}

- (void)setBtnsZoomInHidden:(BOOL)hidden
{
    if (_zoomInHiddenTvBtn) {
        self.tvBtn.hidden = hidden;
    }
    if (_zoomInHiddenMoreBtn) {
        self.moreBtn.hidden = hidden;
    }
    if (_zoomInHiddenShareBtn) {
        self.shareBtn.hidden = hidden;
    }
    if (_zoomInHiddenNextBtn) {
        self.nextBtn.hidden = _isLive ? YES : hidden;
    }
    if (_zoomInHiddenEpisodeBtn) {
        self.episodeBtn.hidden = _isLive ? YES : hidden;
    }
    if (_zoomInHiddenCameraBtn) {
        self.cameraBtn.hidden = hidden;
    }
    if (_zoomInHiddenSwitchBtn) {
        self.switchBtn.hidden = hidden;
    }
    [self showOrHiddenLockBtnWhenCan];
    //
    self.imageShareView.alpha = 0.0;
}

- (void)setupControllContentViewPanGesture
{
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
        for (UIGestureRecognizer *gr in self.controllContentView.gestureRecognizers) {
            if ([gr isKindOfClass:[UIPanGestureRecognizer class]]) {
                [self.controllContentView removeGestureRecognizer:gr];
                break;
            }
        }
    }
    else
    {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(controllContentViewPan:)];
        [self.controllContentView addGestureRecognizer:pan];
    }
}



/** 配合+showWithUrl:类方法使用 */
- (void)hiddenSelf
{
    _isOnRotaion = YES;
    [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
        // 缩小屏幕不可旋转
        [AppDelegate setAllowRotation:NO forRootPresentVc:self.rootPresentVc];
        
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            CGRect rect = self.frame;
            rect.origin.y = kVP_ScreenHeight;
            self.frame = rect;
        } completion:^(BOOL finished) {
            _isOnRotaion = NO;
            [self removeFromSuperview];
        }];
        
        // 消除方向对键盘的影响
        [AppDelegate setPortraitOrientation];
    }];
    [UIApplication sharedApplication].statusBarStyle = _orgStatusBarStyle;
    [UIApplication sharedApplication].statusBarHidden = _orgStatusBarHidden;
    self.center = [UIApplication sharedApplication].keyWindow.center;
    self.transform = CGAffineTransformMakeRotation(_deviceOrientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : -M_PI_2);
}

- (UIViewController *)getRootPresentVcWithCurVc:(UIViewController *)curVc
{
    UIViewController *rootPresentVc = nil;
    if (curVc.parentViewController) {
        rootPresentVc = curVc.parentViewController;
        UIViewController *parentVc = [self getRootPresentVcWithCurVc:rootPresentVc];
        if (parentVc) {
            return parentVc;
        }
        else
        {
            return rootPresentVc;
        }
    }
    else
    {
        return curVc;
    }
}

- (void)showOrHiddenLockBtnWhenCan
{
    if (self.controllView.alpha != 0  || self.lockContentView.alpha != 0) {
        if (_zoomInHiddenLockBtn) {
            if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
                self.lockBtn.hidden = NO;
            }
            else {
                self.lockBtn.hidden = YES;
            }
        }
        else {
            self.lockBtn.hidden = NO;
        }
    }
    else {
        self.lockBtn.hidden = YES;
    }
}

- (BOOL)isControllContentViewShowContent
{
    return (!_controllView.hidden && _controllView.alpha == 1) || (!_lockContentView.hidden && _lockContentView.alpha == 1);
}

- (BOOL)isInCurrentShowControllerForSelf
{
    if ((self.vp_myController.isViewLoaded && self.vp_myController.view.window) || self.superview == [UIApplication sharedApplication].keyWindow) {
        return YES;
    }
    return NO;
}

#pragma mark AirPlay 投屏 内部方法
/// 初始化进行AirPlay投屏设置
- (void)initSetAirPlay
{
    [g_airPlayVideoPlayer stop];
    g_airPlayVideoPlayer = nil;
}

@end


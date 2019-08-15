//
//  MediaPlayer.m
//  SydneyToday
//
//  Created by Qson on 2018/10/30.
//  Copyright © 2018 Yu Wang. All rights reserved.
//

#import "MediaPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+QS.h"
//#import "ShortVideoView.h"

#pragma mark - ShortVideoSlider
@interface SSVSlider : UISlider
@property (nonatomic, assign) CGFloat sliderHeight;
@end

#pragma mark - SSVProgressView
@interface SSVProgressView : UIView
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) UIView *progressView;
@property (nonatomic, weak) UIView *bottomView;
@end

#pragma mark - ShortVideoSlider
@interface SSVSlider ()

@end

@implementation SSVSlider
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    if (_sliderHeight == 0) {
        _sliderHeight = 2;
    }
    return CGRectMake(0, (CGRectGetHeight(self.frame) - _sliderHeight) * 0.5, CGRectGetWidth(self.frame), _sliderHeight);
}
@end

@interface SSVProgressView ()

@end

@implementation SSVProgressView
#pragma mark - 懒加载
- (UIView *)bottomView
{
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        [self addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIView *)progressView
{
    if (_progressView == nil) {
        UIView *progressView = [[UIView alloc] init];
        [self addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self bottomView];
        [self progressView];
        _progressHeight = 1;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bottomView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _progressHeight) * 0.5, CGRectGetWidth(self.frame), _progressHeight);
    CGFloat width = self.progressView.frame.size.width;
    self.progressView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _progressHeight) * 0.5, width, _progressHeight);
    [self setProgress:_progress];
}

#pragma mark - 外部方法
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress > 1.0) {
        _progress = 1.0;
    }
    
    if (_progress < 0.0) {
        _progress = 0.0;
    }
    CGRect rect = self.progressView.frame;
    CGFloat width = CGRectGetWidth(self.frame) * _progress;
    if(!isnan(width)) {
        rect.size.width = width;
        self.progressView.frame = rect;
    }
}
@end

@interface  MediaPlayer ()
@property (nonatomic, weak) UIView          *customView;

@property (nonatomic, weak) UIView          *playerContentView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) UIImageView     *bgImageView;
@property (nonatomic, weak) UIView          *touchView;
@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, weak) UIButton        *playerBtn;

@property (nonatomic, assign) BOOL          toHiddToolStatus;
@property (nonatomic, assign) BOOL          isPlaying;
@property (nonatomic, assign) BOOL          isZoomStatus;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;

@property (nonatomic, weak) UILabel         *loadErrorLabel;


@property (nonatomic, assign) CGFloat       totaltimes;
// 保存滑动时slider的初始值
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) BOOL isPan;

// 底部
@property (nonatomic, weak) UIView *bottomBar;
@property (nonatomic, weak) UIButton *zoomBtn;
@property (nonatomic, weak) SSVSlider *slider;
@property (nonatomic, weak) SSVProgressView *progressView;
//@property (nonatomic, weak) UIButton *volumeBtn;
@property (nonatomic, weak) UILabel *leftTimeLabel;
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, strong) id playTimeObserver;
@end

@implementation MediaPlayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)dealloc
{
    CGLog(@"%s",__func__);
    [self releasePlayer];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupFrame];
}

- (void)setupView
{
    [self customView];
    [self loadErrorLabel];
    [self playerContentView];
    [self bgImageView];
}

- (void)setupFrame
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    w = ScreenWidth;
    h = ScreenHeight;
    self.customView.frame = CGRectMake(x, y, w, h);
    self.playerContentView.frame = self.customView.bounds;
    self.bgImageView.frame = self.customView.bounds;
    self.touchView.frame = self.bgImageView.bounds;
    w = self.playerBtn.width;
    h = self.playerBtn.height;
    x = (self.bgImageView.width - w) * 0.5;
    y = (self.bgImageView.height - h) * 0.5;
    self.playerBtn.frame = CGRectMake(x, y, w, h);
    
    self.activityIndicator.center = self.playerContentView.center;
    self.loadErrorLabel.frame = self.customView.bounds;
    
    _playerLayer.frame = self.bgImageView.bounds;
    
    h = 40;
    y = ScreenHeight - kiPhoneXSafeBottomHeight - h;
    x = 30;
    w = ScreenWidth - 2 * x;
    
    // 底部bar
    h = 40;
    y = ScreenHeight - kiPhoneXSafeBottomHeight - h;
    x = 0;
    w = ScreenWidth;
    self.bottomBar.frame = CGRectMake(x, y, w, h);
    
    CGFloat width = [@"00:00" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.leftTimeLabel.font} context:nil].size.width;
    self.leftTimeLabel.frame = CGRectMake(20, 0, width + 2 * 5, self.bottomBar.height);
    self.leftTimeLabel.text = self.leftTimeLabel.text.length ? self.leftTimeLabel.text : @"00:00";
    
    BOOL isFullScreen = self.zoomBtn.selected; //< 是否全屏
    
    CGFloat rightMargin = isFullScreen ? 20 : 20;
    self.timeLabel.frame = CGRectMake(self.bottomBar.width - (width + 2 * 5) - rightMargin, 0, width + 2 * 5, self.bottomBar.height);
    
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.leftTimeLabel.frame), 0, CGRectGetMinX(self.timeLabel.frame) - CGRectGetMaxX(self.leftTimeLabel.frame), self.bottomBar.height);
    
    self.progressView.frame = CGRectMake(self.slider.frame.origin.x, 0, self.slider.frame.size.width, self.bottomBar.height);
    
    [self.touchView bringSubviewToFront:self.bottomBar];
}

#pragma mark - 外部方法
- (void)readyWithUrl:(NSURL *)url autoPlay:(BOOL)autoPlay
{
    self.url = url;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    
    NSURL *videoUrl = url;
    if(videoUrl) {
        [UIImage imageFromDiskCacheForVideoKey:videoUrl.absoluteString complete:^(UIImage *image) {
            if(image)
                self.bgImageView.image = image;
        }];
        
        _player = [AVPlayer playerWithURL:videoUrl];
        _player.volume = 0.0;
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.frame = self.bounds;
        [self.bgImageView.layer addSublayer:_playerLayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem]; // 播放结束
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:UIApplicationWillResignActiveNotification object:nil]; // 进入后台
        //监听手动切换横竖屏状态
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

        // 观察status属性，
        [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        // 观察缓冲进度
        [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        [self monitoringPlayback:_player.currentItem];
    }
}

#pragma mark - 内部实现
- (void)releasePlayer
{
    [self releasePlayItem];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

- (void)showLoading
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.touchView.alpha = 0.0;
    self.touchView.tag = 0;// 表示加载状态；
    [self.customView bringSubviewToFront:self.activityIndicator];
}

- (void)hiddenLoading
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.touchView.alpha = 1.0;
    self.touchView.tag = 1;// 加载完状态，点击可以显示；
}

- (void)loadErrorLabelClicked
{
    [self releasePlayer];
    if (_url) {
        [self playWithUrl];
    }
}

- (void)playWithUrl
{
    self.url = _url;
    self.loadErrorLabel.hidden = YES;
    [self showLoading];
}

- (void)releasePlayItem
{
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [_player replaceCurrentItemWithPlayerItem:nil];
}

- (void)loadError
{
    [self hiddenLoading];
    
    self.playerContentView.hidden = YES;
    self.loadErrorLabel.hidden = NO;
    [self.customView bringSubviewToFront:self.loadErrorLabel];
}

- (void)readyToPlay
{
    [self hiddenLoading];
    
    self.touchView.userInteractionEnabled = YES;
    self.playerBtn.hidden = NO;
    [self.customView bringSubviewToFront:self.playerContentView];
    
    [self tapAction];
}

- (void)didDisplayControlView:(BOOL)isShowCtrView
{
    if([_delegate respondsToSelector:@selector(mediaPlayer:didDisplayControlView:)]) {
        [_delegate mediaPlayer:self didDisplayControlView:isShowCtrView];
    }
    
    if(isShowCtrView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomBar.y = ScreenHeight - kiPhoneXSafeBottomHeight - 40;
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomBar.y = ScreenHeight;
        }];
    }
}

//传入 秒  得到  xx:xx
-(NSString *)getMMSSFromSec:(CGFloat)sec {
    
    NSInteger seconds = floor(sec);
    
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
}

/**
 播放前AudioSession配置
 */
- (void)configAudioSessionStart {
    // 使用这个category的应用不会随着静音键和屏幕关闭而静音。可在后台播放声音
    // 终端后台音频的播放
    [[AVAudioSession sharedInstance] setActive:YES withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

/**
 播放完成AudioSession配置
 */
- (void)configAudioSessionEnd {
    // 通知后台程序可以 之前被打断的后台audio恢复播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions: AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}

#pragma mark - 事件
- (void)tapAction
{
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [self configAudioSessionStart];
        [_player play];
        [_playerBtn setImage:nil forState:UIControlStateNormal];
        _toHiddToolStatus = YES;
        _isPlaying = YES;
        [self didDisplayControlView:!_toHiddToolStatus];
    } else {
        [self configAudioSessionEnd];
        [_player pause];
        [_playerBtn setImage:[UIImage imageNamed:@"sv_pauseStatus"] forState:UIControlStateNormal];
        _toHiddToolStatus = NO;
        _isPlaying = NO;
        [self didDisplayControlView:!_toHiddToolStatus];
    }
}

- (void)videoVolumeWithOnOrOff:(BOOL)isOn
{
    _player.volume = isOn ? 1.0 : 0.0;

    CGLog(@"当前音量：%f",_player.volume);
}

- (void)pausePlayerAndShowNaviBar
{
    [self configAudioSessionEnd];
    [_player pause];
    [_playerBtn setImage:[UIImage imageNamed:@"sv_pauseStatus"] forState:UIControlStateNormal];
    _toHiddToolStatus = NO;
    _isPlaying = NO;
    [self didDisplayControlView:!_toHiddToolStatus];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view isKindOfClass:[UISlider class]])
        return NO;
    else
        return YES;
}

- (void)sliderValueChanged
{
    @autoreleasepool {
        if (self.url)
        {
            __weak typeof(self) weakSelf = self;
            NSTimeInterval seekTime = self.slider.value * _totaltimes;
            CMTime changedTime = CMTimeMakeWithSeconds(seekTime, 1.0);
            [self.player.currentItem seekToTime:changedTime toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
                if (weakSelf.isPlaying) {
                    [self configAudioSessionStart];
                    [weakSelf.player play];
                }
            }];
            
        }
        if (!self.isPan) {
            self.value = self.slider.value;
        }
    }
}

- (void)sliderUp
{
    @autoreleasepool {
        if (self.url)
        {
            NSTimeInterval seekTime = self.slider.value * _totaltimes;
            CMTime changedTime = CMTimeMakeWithSeconds(seekTime, 1.0);
            [self.player.currentItem seekToTime:changedTime toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
                //                if (autoPlay) {
                //                    [weakSelf play];
                //                }
            }];
        }
    }
}

- (void)bottomBarPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point =  [recognizer translationInView:self.slider];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.value * self.slider.bounds.size.width;
        self.slider.value = (point.x + x) / self.slider.bounds.size.width;
        [self sliderValueChanged];
        if(self.isPlaying) {
            [self configAudioSessionStart];
            [self.player play];
        }
        self.isPan = NO;
    }
    else {
        if (!self.isPan) {
            self.value = self.slider.value;
        }
        self.isPan = YES;
        [self configAudioSessionEnd];
        [self.player pause];
        CGFloat x = self.value * self.slider.bounds.size.width;
        self.slider.value = (point.x + x) / self.slider.bounds.size.width;
    }
}

- (void)zoomBtnClicked:(UIButton *)sender
{
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    @autoreleasepool {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
            if (status == AVPlayerStatusReadyToPlay) {
                CGLog(@"视频准备完成");
                [self readyToPlay];
                CMTime duration = playerItem.duration;

                if ([self respondsToSelector:@selector(playerView:totalTime:)]) {
                    [self playerView:self totalTime:CMTimeGetSeconds(duration)];
                }
            } else if (status == AVPlayerStatusFailed) {
                CGLog(@"视频加载失败");
                [self loadError];
            } else {
                [self readyToPlay];
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            if ([self respondsToSelector:@selector(playerView:loadTime:)]) {
                [self playerView:self loadTime:[self loadTimeWithPlayerItem:playerItem]];
            }
        }
    }
}

// 观察播放进度
- (void)monitoringPlayback:(AVPlayerItem *)item {
    
    __weak typeof(self)weakSelf = self;
    
    // 播放进度, 每秒执行10次， CMTime 为10分之一秒
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @autoreleasepool {
            // 当前播放秒
            NSTimeInterval currentPlayTime = (double)item.currentTime.value / item.currentTime.timescale;
            weakSelf.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
            if ([weakSelf respondsToSelector:@selector(playerView:playTime:)]) {
                [weakSelf playerView:weakSelf playTime:currentPlayTime];
            }
        }
    }];
}

// 已缓冲进度
- (NSTimeInterval)loadTimeWithPlayerItem:(AVPlayerItem *)playerItem {
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges]; // 获取item的缓冲数组
    // discussion Returns an NSArray of NSValues containing CMTimeRanges
    if (!loadedTimeRanges.count) {
        return 0;
    }
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}

- (void)playerView:(MediaPlayer *)playerView totalTime:(NSTimeInterval)totalTime
{
    if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
        _totaltimes = totalTime;
        
        self.timeLabel.text = [self getMMSSFromSec:_totaltimes];
        if(_totaltimes > CGFLOAT_MIN) {
            self.bottomBar.hidden = NO;
        }
    }
    else
    {
        _totaltimes = 0;
    }
}

- (void)playerView:(MediaPlayer *)playerView loadTime:(NSTimeInterval)loadTime
{
    if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
        if(_totaltimes > CGFLOAT_MIN) {
            self.progressView.progress = (loadTime / _totaltimes);
        }
    }
    else
    {
        self.progressView.progress = 0;
    }
}

- (void)playerView:(MediaPlayer *)playerView playTime:(NSTimeInterval)playTime
{
    if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString]) {
        if(playTime > CGFLOAT_MIN && _totaltimes > CGFLOAT_MIN) {
            self.slider.value = (playTime / _totaltimes);
            self.leftTimeLabel.text = [self getMMSSFromSec:playTime];
            self.timeLabel.text = [self getMMSSFromSec:_totaltimes];
        }
    }
    else
    {
        self.slider.value = 0;
        self.leftTimeLabel.text = @"00:00";
        self.timeLabel.text = @"00:00";
    }
}

#pragma mark - 懒加载
- (UIView *)customView
{
    if(_customView == nil) {
        UIView *customView = [[UIView alloc] init];
        customView.backgroundColor = [UIColor blackColor];
        [self addSubview:customView];
        _customView = customView;
    }
    return _customView;
}

-(UIButton *)playerBtn
{
    if(_playerBtn == nil) {
        UIImage *image = [UIImage imageNamed:@"sv_pauseStatus"];
        UIButton *playerBtn = [[UIButton alloc] init];
        [playerBtn setImage:image forState:UIControlStateNormal];
        playerBtn.userInteractionEnabled = NO;
        playerBtn.hidden = YES;
        [playerBtn sizeToFit];
        [self.touchView addSubview:playerBtn];
        _playerBtn = playerBtn;
    }
    return _playerBtn;
}

- (UIView *)playerContentView
{
    if (_playerContentView == nil) {
        UIView *playerContentView = [[UIView alloc] init];
        [self.customView addSubview:playerContentView];
        _playerContentView = playerContentView;
    }
    return _playerContentView;
}

- (UIImageView *)bgImageView
{
    if(_bgImageView == nil) {
        UIImageView *bgImageView = [[UIImageView alloc] init];
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.playerContentView addSubview:bgImageView];
        _bgImageView = bgImageView;
    }
    return _bgImageView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (_activityIndicator == nil) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.hidden = YES;
        [self.customView addSubview:activityIndicator];
        _activityIndicator = activityIndicator;
    }
    return _activityIndicator;
}

- (UIView *)touchView
{
    if (_touchView == nil) {
        UIView *touchView = [[UIView alloc] init];
        touchView.backgroundColor = [UIColor clearColor];
        touchView.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [touchView addGestureRecognizer:tap];
        [self.playerContentView addSubview:touchView];
        _touchView = touchView;
    }
    return _touchView;
}

//- (HCPlayerView *)playerView
//{
//    if (_playerView == nil) {
//        HCPlayerView *playerView = [[HCPlayerView alloc] init];
//        [self.bgImageView addSubview:playerView];
//        _playerView = playerView;
//        playerView.delegate = self;
//        playerView.displayMode = HCPlayerViewDisplayModeScaleAspectFit;
//        playerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//        playerView.backgroundColor = [UIColor clearColor];
//        playerView.volume = 0.0;
//    }
//    return _playerView;
//}

- (UILabel *)loadErrorLabel
{
    if (_loadErrorLabel == nil) {
        UILabel *loadErrorLabel = [[UILabel alloc] init];
        [self.customView addSubview:loadErrorLabel];
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

- (UIView *)bottomBar
{
    if (_bottomBar == nil) {
        UIView *bottomBar = [[UIView alloc] init];
        [self.touchView addSubview:bottomBar];
        bottomBar.hidden = YES;
        _bottomBar = bottomBar;
 
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarPan:)];
        [bottomBar addGestureRecognizer:pan];
    }
    return _bottomBar;
}

- (SSVSlider *)slider
{
    if (_slider == nil) {
        SSVSlider *slider = [[SSVSlider alloc] init];
        [self.bottomBar addSubview:slider];
        _slider = slider;
        slider.sliderHeight = 5.0;
        slider.maximumTrackTintColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"sv_dot"];
        [slider setThumbImage:image forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchCancel];
        slider.minimumTrackTintColor = [UIColor whiteColor];
    }
    return _slider;
}

- (SSVProgressView *)progressView
{
    if (_progressView == nil) {
        SSVProgressView *progressView = [[SSVProgressView alloc] init];
        [self.bottomBar addSubview:progressView];
        _progressView = progressView;
        progressView.progressHeight = 5.0;
        
        progressView.bottomView.backgroundColor = QSColor(255, 255, 255, 0.2);
        progressView.progressView.backgroundColor = QSColor(255, 255, 255, 0.5);
        
        progressView.bottomView.layer.cornerRadius = progressView.progressHeight * 0.5;
        progressView.progressView.clipsToBounds = YES;
        
        progressView.progressView.layer.cornerRadius = progressView.progressHeight * 0.5;
        progressView.progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (UIButton *)zoomBtn
{
    if (_zoomBtn == nil) {
        UIButton *zoomBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:zoomBtn];
        _zoomBtn = zoomBtn;
        [zoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage imageNamed:@"sv_fullScreen"] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage imageNamed:@"sv_unFullScreen"] forState:UIControlStateSelected];
        [zoomBtn addTarget:self action:@selector(zoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomBtn;
}

- (UILabel *)leftTimeLabel
{
    if (_leftTimeLabel == nil) {
        UILabel *leftTimeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:leftTimeLabel];
        _leftTimeLabel = leftTimeLabel;
        leftTimeLabel.font = [UIFont systemFontOfSize:kIPadSuitFloat(11)];
        leftTimeLabel.textColor = [UIColor whiteColor];
        leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _leftTimeLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:timeLabel];
        _timeLabel = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:kIPadSuitFloat(11)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

@end

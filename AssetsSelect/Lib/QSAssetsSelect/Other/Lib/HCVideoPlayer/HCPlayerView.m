//
//  HCPlayerView.m
//  HCVideoPlayer
//
//  Created by chc on 2017/6/6.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCPlayerView.h"
#import "HCVideoPlayerConst.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HCAirplayCastTool.h"

@interface HCPlayerView ()
{
    AVPlayerItemVideoOutput *_videoOutPut;
}
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, weak) AVPlayer *player;

@property (nonatomic, strong) void (^readyComplete)(HCPlayerViewState status);

@property (nonatomic, assign) CGSize vedioSize;
@property (nonatomic, strong) id playTimeObserver;

@property (nonatomic, weak) UIImageView *snapImageView; // 用于截屏
@property (nonatomic, strong) HCWeakTimer *timer;

@property (nonatomic, assign) BOOL hasHandleReadyCompleteBlock;
@end

@implementation HCPlayerView

#pragma mark - 懒加载
- (UIImageView *)snapImageView
{
    if (_snapImageView == nil) {
        UIImageView *snapImageView = [[UIImageView alloc] init];
        [self addSubview:snapImageView];
        _snapImageView = snapImageView;
        snapImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _snapImageView;
}

#pragma mark - 外部方法
- (void)readyWithUrl:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [self readyWithUrl:url complete:^(HCPlayerViewState status) {
        [weakSelf play];
    }];
}

- (void)readyWithUrl:(NSURL *)url complete:(void (^)(HCPlayerViewState status))complete
{
    _url = url;
    
    if (url == nil || !url.absoluteString.length) {
        _playerState = HCPlayerViewStateError;
        if ([self.delegate respondsToSelector:@selector(didLoadErrorForPlayerView:)]) {
            [self.delegate didLoadErrorForPlayerView:self];
        }
        if (self.readyComplete) {
            self.readyComplete(HCPlayerViewStateError);
        }
        return;
    }
    
    @autoreleasepool {
        
        self.readyComplete = complete;
        AVPlayerItem * playerItem = _player.currentItem;
        if (playerItem == nil) {
            [self stop];
            
//            playerItem = [AVPlayerItem playerItemWithURL:_url];
            NSURL *peerUrl = _url;
            if ([peerUrl.absoluteString containsString:@"http"] && ![HCAirplayCastTool isAirPlayOnCast]) {
//                peerUrl = [App_Delegate peerStreamURLForURL:_url];// p2p
            }
            AVAsset*liveAsset = [AVURLAsset URLAssetWithURL:peerUrl options:nil];
            
            playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
            // 观察status属性，
            [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            // 观察缓冲进度
            [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
            _player = [AVPlayer playerWithPlayerItem:playerItem];
        }
        
        _videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
        [playerItem addOutput:_videoOutPut];
        
        // 播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        //_player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
        _player.volume = _volume;
        _player.rate = _rate;
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.frame = self.bounds;
        [self.layer addSublayer:_playerLayer];
        
        _playerState = HCPlayerViewStateReadying;
        
        // 用于截屏
        [self sendSubviewToBack:self.snapImageView];
        self.snapImageView.image = nil;
        
        [_timer stop];
        _timer = nil;
        _hasHandleReadyCompleteBlock = NO;
    }
}

- (void)pause
{
    if (_playerState == HCPlayerViewStatePlay) {
        [_player pause];
        _playerState = HCPlayerViewStatePause;
        if ([self.delegate respondsToSelector:@selector(didPausePlayForPlayerView:)]) {
            [self.delegate didPausePlayForPlayerView:self];
        }
    }
    
    // 用于截屏
    [_timer stop];
    _timer = nil;
}

- (void)stop
{
    @autoreleasepool {
        if (_playerState != HCPlayerViewStateStop) {
            
            [_player.currentItem removeObserver:self forKeyPath:@"status"];
            [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [_player.currentItem removeObserver:self forKeyPath:@"presentationSize"];
            
            [_player.currentItem cancelPendingSeeks];
            [_player.currentItem.asset cancelLoading];
            [_player replaceCurrentItemWithPlayerItem:nil];
            
            _playerState = HCPlayerViewStateStop;
            if ([self.delegate respondsToSelector:@selector(didStopPlayForPlayerView:)]) {
                [self.delegate didStopPlayForPlayerView:self];
            }
            _snapImageView.image = nil;
            _playerLayer.player = nil;
            [_playerLayer removeFromSuperlayer];
        }
        
        // 用于截屏
        [self sendSubviewToBack:self.snapImageView];
        self.snapImageView.image = nil;
        
        [_timer stop];
        _timer = nil;
        _hasHandleReadyCompleteBlock = NO;
    }
}

- (void)play
{
    if (_playerState == HCPlayerViewStateReadyed || _playerState == HCPlayerViewStatePause || _playerState == HCPlayerViewStatePlayback || _playerState == HCPlayerViewStatePlay) {
        [self setupAVAudioSessionConfig];
        [_player play];
        if (_playerState == HCPlayerViewStateReadyed || _playerState == HCPlayerViewStatePlayback) {
            if ([self.delegate respondsToSelector:@selector(didStartPlayForPlayerView:)]) {
                [self.delegate didStartPlayForPlayerView:self];
            }
        }
        else if (_playerState == HCPlayerViewStatePause)
        {
            if ([self.delegate respondsToSelector:@selector(didContinuePlayForPlayerView:)]) {
                [self.delegate didContinuePlayForPlayerView:self];
            }
        }
        
        _playerState = HCPlayerViewStatePlay;
        [self monitoringPlayback:self.player.currentItem];
    }
    
    // 用于截屏
    [self sendSubviewToBack:self.snapImageView];
    self.snapImageView.image = nil;
    [_timer stop];
    _timer = nil;
}

- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay
{
    @autoreleasepool {
        CMTime changedTime = CMTimeMakeWithSeconds(time, 1.0);
        if (_playerState == HCPlayerViewStatePlay || _playerState == HCPlayerViewStatePause || _playerState == HCPlayerViewStateReadyed || _playerState ==  HCPlayerViewStatePlayback) {
            [self pause];
            __weak typeof(self) weakSelf = self;
//            [self.player.currentItem seekToTime:changedTime completionHandler:^(BOOL finished) {
//                if (autoPlay) {
//                    [weakSelf play];
//                }
//            }];
            [self.player.currentItem seekToTime:changedTime toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
                if (autoPlay) {
                    [weakSelf play];
                }
            }];
        }
    }
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    _player.volume = _volume;
}

- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    _player.rate = _rate;
}

- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CMTime itemTime = _player.currentItem.currentTime;
        CVPixelBufferRef pixelBuffer = [_videoOutPut copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CIContext *temporaryContext = [CIContext contextWithOptions:nil];
        CGImageRef imgRef = [temporaryContext
                                 createCGImage:ciImage
                                 fromRect:CGRectMake(0, 0,
                                                     CVPixelBufferGetWidth(pixelBuffer),
                                                     CVPixelBufferGetHeight(pixelBuffer))];
        
        //当前帧的画面
        UIImage *image = [UIImage imageWithCGImage:imgRef];
        CGImageRelease(imgRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(image);
            }
        });
    });
}

- (NSTimeInterval)currentTime
{
    if (_player.currentTime.timescale > 0) {
        return _player.currentItem.currentTime.value / _player.currentTime.timescale;
    }
    return 0;
}

#pragma mark - 内部方法
- (void)setPlayerLayerFrameWithSize:(CGSize)size
{
    if (CGSizeEqualToSize(CGSizeZero, size) || size.width == 0 || size.height == 0) {
        return;
    }
    
    if (_displayMode == HCPlayerViewDisplayModeScaleAspectFit) {
        _playerLayer.frame = self.bounds;
    }
    else if (_displayMode == HCPlayerViewDisplayModeScaleAspectFill)
    {
        CGFloat selfWidth = self.bounds.size.width;
        CGFloat selfHieht = self.bounds.size.height;
        CGFloat width = 0;
        CGFloat height = 0;
        if ((selfWidth / selfHieht) > (size.width / size.height)) {
            
            width = selfWidth;
            height = selfWidth * size.height / size.width;
            _playerLayer.frame = CGRectMake(0, -(height - selfHieht) * 0.5, width, height);
        }
        else
        {
            width = selfHieht * size.width / size.height;
            height = selfHieht;
            _playerLayer.frame = CGRectMake(-(width - selfWidth) * 0.5, 0, width, height);
        }
    }
    
    self.snapImageView.frame = _playerLayer.frame;
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

// 观察播放进度
- (void)monitoringPlayback:(AVPlayerItem *)item {
    
    __weak typeof(self)weakSelf = self;
    
    // 播放进度, 每秒执行10次， CMTime 为10分之一秒
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @autoreleasepool {
            // 当前播放秒
            NSTimeInterval currentPlayTime = (double)item.currentTime.value / item.currentTime.timescale;
            weakSelf.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
            if ([weakSelf.delegate respondsToSelector:@selector(playerView:playTime:)]) {
                [weakSelf.delegate playerView:weakSelf playTime:currentPlayTime];
            }
            
            // 用于截屏
//            if (!weakSelf.timer && weakSelf.playerState == HCPlayerViewStatePlay) {
//                weakSelf.timer = [HCWeakTimer scheduledTimerWithTimeInterval:3.0 target:weakSelf selector:@selector(timeEvent) userInfo:nil repeats:YES];
//            }
        }
    }];
}

#pragma mark - 通知
- (void)outputDeviceChanged:(NSNotification *)aNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_playerState == HCPlayerViewStatePlay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self play];
            });
        }
    });
}

- (void)playbackFinished:(NSNotification *)notification {
    
    AVPlayerItem *playerItem = [notification object];
    if (_player.currentItem != playerItem) {
        return;
    }
    
    @autoreleasepool {
        _playerState = HCPlayerViewStatePlayback;
        self.readyComplete = nil;
        if ([self.delegate respondsToSelector:@selector(didPlaybackForPlayerView:)]) {
            // 是否无限循环
            [playerItem seekToTime:kCMTimeZero]; // 跳转到初始
            //    [_player play]; // 是否无限循环
            [self.delegate didPlaybackForPlayerView:self];
        }
        else if ([self.delegate respondsToSelector:@selector(didPlayCompleteForPlayerView:)])
        {
            [self.delegate didPlayCompleteForPlayerView:self];
        }
        
        // 用于截屏
        [_timer stop];
        _timer = nil;
    }
}

#pragma mark - 事件
- (void)timeEvent
{
    self.snapImageView.backgroundColor = self.backgroundColor;
    self.snapImageView.contentMode = (self.displayMode == HCPlayerViewDisplayModeScaleAspectFit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill);
    __weak typeof(self) weakSelf = self;
    [self getCurrentTimeImageComplete:^(UIImage *image) {
        weakSelf.snapImageView.image =  image;
    }];
//    VPLog(@"timeEvent");
}

#pragma mark - 初始化

- (void)setupAVAudioSessionConfig {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (self.isFromLive) { // why
//        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowAirPlay error:nil];
    } else {
        /// 暂停其他 app 的视屏播放
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)backAVAudioSessionConfig {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    /// 暂停其他 app 的视屏播放
    [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [session setCategory:AVAudioSessionCategorySoloAmbient  error:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        self.displayMode = HCPlayerViewDisplayModeScaleAspectFit;
        self.volume = 1.0;
        self.rate = 1.0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setPlayerLayerFrameWithSize:_vedioSize];
}

- (void)dealloc
{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    VPLog(@"dealloc - HCPlayerView");
}

- (void)releasePlayer
{
    [self stop];
    [self backAVAudioSessionConfig];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    @autoreleasepool {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"presentationSize"]) {
            _vedioSize = playerItem.presentationSize;
            if ([self.delegate respondsToSelector:@selector(playerView:vedioSize:)]) {
                [self.delegate playerView:self vedioSize:_vedioSize];
            }
            [self setPlayerLayerFrameWithSize:_vedioSize];
        }
        else if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
            if (status == AVPlayerStatusReadyToPlay) {
                HCPlayerViewState playerState = _playerState;
                if (playerState != HCPlayerViewStatePlayback && playerState != HCPlayerViewStatePause && playerState != HCPlayerViewStatePlay) {
                    _playerState = HCPlayerViewStateReadyed;
                }
                // 获取视频长度
                CMTime duration = playerItem.duration;
                if ([self.delegate respondsToSelector:@selector(playerView:totalTime:)]) {
                    [self.delegate playerView:self totalTime:CMTimeGetSeconds(duration)];
                }
                
                if ([self.delegate respondsToSelector:@selector(didReadyForPlayForPlayerView:)] && !_hasHandleReadyCompleteBlock) {
                    [self.delegate didReadyForPlayForPlayerView:self];
                }
                
                if (_playerState == HCPlayerViewStatePlay) {
                    [self play];
                }
                
                // 准备完成block调用
                if (_readyComplete && (!_hasHandleReadyCompleteBlock || playerState == HCPlayerViewStatePlay)) {
                    self.readyComplete(_playerState);
                }
                _hasHandleReadyCompleteBlock = YES;
                
            } else if (status == AVPlayerStatusFailed) {
                _playerState = HCPlayerViewStateError;
                if ([self.delegate respondsToSelector:@selector(didLoadErrorForPlayerView:)]) {
                    [self.delegate didLoadErrorForPlayerView:self];
                }
                if (self.readyComplete) {
                    self.readyComplete(HCPlayerViewStateError);
                }
            } else {
                _playerState = HCPlayerViewStateError;
                if ([self.delegate respondsToSelector:@selector(didLoadErrorForPlayerView:)]) {
                    [self.delegate didLoadErrorForPlayerView:self];
                }
                if (self.readyComplete) {
                    self.readyComplete(HCPlayerViewStateError);
                }
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            if ([self.delegate respondsToSelector:@selector(playerView:loadTime:)]) {
                [self.delegate playerView:self loadTime:[self loadTimeWithPlayerItem:playerItem]];
            }
        }
    }
}
@end


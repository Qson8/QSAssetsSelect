//
//  HCVideoPlayer.h
//  HCVideoPlayer
//
//  Created by chc on 2017/6/3.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCVideoPlayerConst.h"

typedef enum {
    HCVideoPlayerZoomStatusZoomIn,
    HCVideoPlayerZoomStatusZoomOut
}HCVideoPlayerZoomStatus;

typedef enum {
    HCVideoPlayerStatusIdle,
    HCVideoPlayerStatusReadying,
    HCVideoPlayerStatusReadyed,
    HCVideoPlayerStatusPlay,
    HCVideoPlayerStatusPause,
    HCVideoPlayerStatusPlayback,
    HCVideoPlayerStatusStop,
    HCVideoPlayerStatusError
}HCVideoPlayerStatus;

@class HCVideoPlayer;
typedef void(^HCVideoPlayerReadyComplete)(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status);

#import <UIKit/UIKit.h>

@protocol HCVideoPlayerDelegate <NSObject>
@optional
// 播放相关
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer playTime:(NSTimeInterval)playTime;
- (void)didStartPlayForVideoPlayer:(HCVideoPlayer *)videoPlayer;
- (void)didReadyForPlayForVideoPlayer:(HCVideoPlayer *)videoPlayer;
- (void)didContinuePlayForVideoPlayer:(HCVideoPlayer *)videoPlayer;
- (void)didPlaybackForVideoPlayer:(HCVideoPlayer *)videoPlayer;

// 其他
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer changedZoomStatus:(HCVideoPlayerZoomStatus)zoomStatus;
// 返回NO则不执行内部处理
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didClickBackBtnAtZoomStatus:(HCVideoPlayerZoomStatus)zoomStatus;
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didClickMoreBtn:(UIButton *)moreBtn;
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didClickShareBtn:(UIButton *)shareBtn;
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didClickTVBtn:(UIButton *)tvBtn;
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didClickCameraBtn:(UIButton *)cameraBtn;
// 点击了切换按钮
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer didClickSwitchBtn:(UIButton *)switchBtn;
// 点击了下一个按钮
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer didClickNextBtn:(UIButton *)nextBtn;
// 点击了选集按钮
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer didClickEpisodeBtn:(UIButton *)episodeBtn;
// morePanel
// 点击了收藏按钮状态变化
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer didChangeMorePanelColloctStatus:(BOOL)status;
// sharePanel
// 点击了分享面板的Item，可通过Item里的key，来判断是分享链接，还是图片；
- (void)videoPlayer:(HCVideoPlayer *)videoPlayer didSelectSharePanelItem:(HCShareItem *)item shareImage:(UIImage *)shareImage;

@end

@protocol HCVideoPlayerShareDelegate <NSObject>
- (BOOL)videoPlayer:(HCVideoPlayer *)videoPlayer didSelectShareItem:(HCShareItem *)shareItem;
@end

@interface HCVideoPlayer : UIView
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign, readonly) HCVideoPlayerStatus status;
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, assign, readonly) HCVideoPlayerZoomStatus zoomStatus;
/** 音量（非系统音量） */
@property (nonatomic, assign) CGFloat volume;
/** 播放速度 */
@property (nonatomic, assign) CGFloat rate;
/** 收藏状态 */
@property (nonatomic, assign) BOOL collectStatus;
@property (nonatomic, weak) id <HCVideoPlayerDelegate> delegate;
@property (nonatomic, weak) id <HCVideoPlayerShareDelegate> shareDelegate;

@property (nonatomic, assign) BOOL showBackWhileZoomIn;

@property (nonatomic, copy) UIView *(^getPlayerSuperViewBlock)(HCVideoPlayer *videoPlayer);
@property (nonatomic, copy) id <HCVideoPlayerDelegate> (^getPlayerDelegateBlock)(HCVideoPlayer *videoPlayer);

/** 在全屏时，设备旋转到竖直时是否要取消全屏 */
@property (nonatomic, assign) BOOL zoomInWhenVerticalScreen;

/** 如果显示播放器的控制器是preset出来的，这项必填 */
@property (nonatomic, weak) UIViewController *curController;

/** 直接全屏显示在keyWindow上 */
- (instancetype)initWithCurController:(UIViewController *)curController;
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController;
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController readyComplete:(HCVideoPlayerReadyComplete)readyComplete;
- (void)playWithUrl:(NSURL *)url;
- (void)playWithUrl:(NSURL *)url readyComplete:(HCVideoPlayerReadyComplete)readyComplete;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay;

- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete;

- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden;

- (void)hiddenMsgAnimation:(BOOL)animation;

- (void)stopAndExitFullScreen;

- (void)makeZoomIn;

@property (nonatomic, assign) BOOL showMoreBtn;
@property (nonatomic, assign) BOOL showShareBtn;
@property (nonatomic, assign) BOOL showTvBtn;
@property (nonatomic, assign) BOOL showCameraBtn;
@property (nonatomic, assign) BOOL showNextBtn;
@property (nonatomic, assign) BOOL showEpisodeBtn;
@property (nonatomic, assign) BOOL showSwitchBtn;
@property (nonatomic, assign) BOOL showLockBtn;

@property (nonatomic, assign) BOOL zoomInHiddenMoreBtn;
@property (nonatomic, assign) BOOL zoomInHiddenShareBtn;
@property (nonatomic, assign) BOOL zoomInHiddenTvBtn;
@property (nonatomic, assign) BOOL zoomInHiddenCameraBtn;
@property (nonatomic, assign) BOOL zoomInHiddenNextBtn;
@property (nonatomic, assign) BOOL zoomInHiddenEpisodeBtn;
@property (nonatomic, assign) BOOL zoomInHiddenSwitchBtn;
@property (nonatomic, assign) BOOL zoomInHiddenLockBtn;

@property (nonatomic, assign) BOOL autoZoom;

@property (nonatomic, assign) BOOL isLive;

@property (nonatomic, assign) BOOL endEditWhenClickSelf;
@end


//
//  HCPlayerView.h
//  HCVideoPlayer
//
//  Created by chc on 2017/6/6.
//  Copyright © 2017年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    HCPlayerViewStateIdle,
    HCPlayerViewStateReadying,
    HCPlayerViewStateReadyed,
    HCPlayerViewStatePlay,
    HCPlayerViewStatePause,
    HCPlayerViewStatePlayback,
    HCPlayerViewStateStop,
    HCPlayerViewStateError
}HCPlayerViewState;

typedef enum {
    HCPlayerViewDisplayModeScaleAspectFit,
    HCPlayerViewDisplayModeScaleAspectFill
}HCPlayerViewDisplayMode;

@class HCPlayerView;
@protocol HCPlayerViewDelegate <NSObject>
@optional
- (void)playerView:(HCPlayerView *)playerView vedioSize:(CGSize)vedioSize;
- (void)playerView:(HCPlayerView *)playerView totalTime:(NSTimeInterval)totalTime;
- (void)playerView:(HCPlayerView *)playerView loadTime:(NSTimeInterval)loadTime;
- (void)playerView:(HCPlayerView *)playerView playTime:(NSTimeInterval)playTime;
- (void)didReadyForPlayForPlayerView:(HCPlayerView *)playerView;
- (void)didStartPlayForPlayerView:(HCPlayerView *)playerView;
- (void)didContinuePlayForPlayerView:(HCPlayerView *)playerView;
- (void)didPausePlayForPlayerView:(HCPlayerView *)playerView;
/** 停止播放（调用-(void)stop方法时调用） */
- (void)didStopPlayForPlayerView:(HCPlayerView *)playerView;
/** 播放完成并返回视频开头（和didPlayCompleteForPlayerView: 二选一调用，优先调用本方法） */
- (void)didPlaybackForPlayerView:(HCPlayerView *)playerView;
/** 播放完成不返回视频开头 */
- (void)didPlayCompleteForPlayerView:(HCPlayerView *)playerView;
- (void)didLoadErrorForPlayerView:(HCPlayerView *)playerView;
@end

@interface HCPlayerView : UIView

@property (nonatomic, assign) HCPlayerViewDisplayMode displayMode;

@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign) BOOL isFromLive; // 是否是直播页面

// 播放速度
@property (nonatomic, assign) CGFloat rate;

@property (nonatomic, assign, readonly) HCPlayerViewState playerState;

@property (nonatomic, weak) id <HCPlayerViewDelegate> delegate;

@property (nonatomic, copy, readonly) NSURL *url;

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

/** 准备视频，成功后会自动播放 */
- (void)readyWithUrl:(NSURL *)url;

/** 准备视频，成功后会调complete */
- (void)readyWithUrl:(NSURL *)url complete:(void (^)(HCPlayerViewState status))complete;

/** 播放视频，准备完成后有效 */
- (void)play;

/** 暂停播放，播放时有效 */
- (void)pause;

/** 停止播放 */
- (void)stop;

/** 跳到指定时间点，播放及暂停时有效 */
- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay;

- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete;

@end


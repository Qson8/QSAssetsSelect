//
//  MediaPlayer.h
//  SydneyToday
//
//  Created by Qson on 2018/10/30.
//  Copyright © 2018 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaPlayer;

@protocol MediaPlayerDelegate <NSObject>
@optional
- (void)mediaPlayer:(MediaPlayer *)mediaPlayer didDisplayControlView:(BOOL)isShowCtrView;
@end

@interface MediaPlayer : UIView <MediaPlayerDelegate>
@property (nonatomic, weak) id <MediaPlayerDelegate> delegate;
@property (nonatomic, copy, readonly) NSURL *url;

/** 准备视频，成功后根据需要看是否自动播放 */
- (void)readyWithUrl:(NSURL *)url autoPlay:(BOOL)autoPlay;
- (void)videoVolumeWithOnOrOff:(BOOL)isOn;
@end

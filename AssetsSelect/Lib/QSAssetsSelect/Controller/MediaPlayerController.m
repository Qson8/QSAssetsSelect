//
//  MediaPlayerController.m
//  SydneyToday
//
//  Created by Qson on 2017/12/14.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import "MediaPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "HCPlayerView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIImage+QS.h"
#import "MediaPlayer.h"

@interface MediaPlayerController () <MediaPlayerDelegate>

@property (nonatomic, weak) UIView          *topBar;
@property (nonatomic, weak) MediaPlayer     *mediaPlayer;
@end

@implementation MediaPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self setupNavBar];
}

- (void)dealloc
{
    CGLog(@"%s",__func__);
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self.view bringSubviewToFront:self.topBar];
}
#pragma mark - 初始化
- (void)setupUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self topBar];
}


- (void)setupNavBar
{
    self.fd_prefersNavigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - 外部方法
- (void)setItem:(MediaItem *)item
{
    _item = item;
    
    NSURL *url = item.fileUrl;
    if(!url && item.mediaUrl.length) url = [NSURL URLWithString:item.mediaUrl];

    self.videoUrl = url;
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
    
    [self.mediaPlayer readyWithUrl:videoUrl autoPlay:NO];
}

#pragma mark - 内部实现
// 是否隐藏状态栏
- (void)displayTopBar:(BOOL)isShowTopView
{
    if (isShowTopView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.topBar.y = 0;
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            self.topBar.y = - self.topBar.height;
        }];
    }
}

#pragma mark - 事件

- (void)barBackItemClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view isKindOfClass:[UISlider class]])
        return NO;
    else
        return YES;
    
}

- (void)openVoice:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.mediaPlayer videoVolumeWithOnOrOff:sender.selected];
}

#pragma mark - MediaPlayerDelegate
- (void)mediaPlayer:(MediaPlayer *)mediaPlayer didDisplayControlView:(BOOL)isShowCtrView
{
    [self displayTopBar:isShowCtrView];
}

#pragma mark - 懒加载

- (UIView *)topBar
{
    if(_topBar == nil) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = 0;
        CGFloat h = kNavigationBarHeight;
        
        UIView *topBar = [[UIView alloc] init];
        topBar.backgroundColor = [UIColor blackColor];
        topBar.frame = CGRectMake(x, y, ScreenWidth, h);
        [self.view addSubview:topBar];

        UIImage *backButtonImage = [UIImage imageNamed:@"back_navi"];
        backButtonImage = [backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIButton *backBtn = [[UIButton alloc] init];
        [backBtn setImage:backButtonImage forState:UIControlStateNormal];
        [backBtn setImage:backButtonImage forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(barBackItemClick) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:backBtn];
        x = 5;
        h = DefaultIconSize;
        w = DefaultIconSize + 10;
        y = kStatusBarHeight + (44 - h) * 0.5;
        backBtn.frame = CGRectMake(x, y, w, h);
        
        UIImage *image_off = [UIImage imageNamed:@"media_vedoff"];
        UIImage *image_on = [UIImage imageNamed:@"media_vedon"];
        UIButton *volBtn = [[UIButton alloc] init];
        [volBtn setImage:image_off forState:UIControlStateNormal];
        [volBtn setImage:image_on forState:UIControlStateSelected];
        [volBtn addTarget:self action:@selector(openVoice:) forControlEvents:UIControlEventTouchUpInside];
        [volBtn sizeToFit];
        [topBar addSubview:volBtn];
        w = volBtn.width + 10;
        h = volBtn.height;
        x = topBar.width - w - 15;
        y = kStatusBarHeight + (44 - h) * 0.5;
        volBtn.frame = CGRectMake(x, y, w, h);
        
        _topBar = topBar;
    }
    return _topBar;
}

- (MediaPlayer *)mediaPlayer
{
    if(_mediaPlayer == nil) {
        MediaPlayer *mediaPlayer = [[MediaPlayer alloc] init];
        mediaPlayer.delegate = self;
        mediaPlayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [self.view addSubview:mediaPlayer];
        _mediaPlayer = mediaPlayer;
        
        mediaPlayer.backgroundColor = [UIColor redColor];
    }
    return _mediaPlayer;
}

@end

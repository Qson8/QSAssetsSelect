//
//  HCProgressView.m
//  HCVideoPlayer
//
//  Created by chc on 2017/12/7.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCProgressView.h"
#import "HCSlider.h"
#import "UIImage+VP.h"
#import "HCVideoPlayerConst.h"

@interface HCProgressView ()
@property (nonatomic, weak) HCSlider *slider;
@property (nonatomic, weak) UIView *loadProgressView;
@property (nonatomic, weak) UIView *loadBottomView;
@end

@implementation HCProgressView
#pragma mark - 懒加载
- (UIView *)loadBottomView
{
    if (_loadBottomView == nil) {
        UIView *loadBottomView = [[UIView alloc] init];
        [self addSubview:loadBottomView];
        _loadBottomView = loadBottomView;
        loadBottomView.backgroundColor = [UIColor darkGrayColor];
    }
    return _loadBottomView;
}

- (UIView *)loadProgressView
{
    if (_loadProgressView == nil) {
        UIView *loadProgressView = [[UIView alloc] init];
        [self addSubview:loadProgressView];
        _loadProgressView = loadProgressView;
        loadProgressView.backgroundColor = kVP_Color(178 , 178, 178, 1.0);
    }
    return _loadProgressView;
}

- (HCSlider *)slider
{
    if (_slider == nil) {
        HCSlider *slider = [[HCSlider alloc] init];
        [self addSubview:slider];
        _slider = slider;
        slider.sliderHeight = 1.0;
        slider.maximumTrackTintColor = [UIColor clearColor];
        UIImage *image = [UIImage vp_imageWithName:@"vp_sliderPoint"];
        [slider setThumbImage:image forState:UIControlStateNormal];
        slider.minimumTrackTintColor = kVP_Color(226, 41, 30, 1.0);
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchCancel];
    }
    return _slider;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadBottomView];
        [self loadProgressView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTaped:)];
        [self addGestureRecognizer:tap];
        _progressHeight = 1;
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCProgressView");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.loadBottomView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _progressHeight) * 0.5, CGRectGetWidth(self.frame), _progressHeight);
    CGFloat width = self.loadProgressView.frame.size.width;
    self.loadProgressView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _progressHeight) * 0.5, width, _progressHeight);
    [self setLoadProgress:_loadProgress];
    
    self.slider.frame = self.bounds;
}

#pragma mark - 外部方法
- (void)setProgressHeight:(CGFloat)progressHeight
{
    _progressHeight = progressHeight;
    if (_progressHeight <= 0) {
        _progressHeight = 1;
    }
    self.slider.sliderHeight = _progressHeight;
}

- (void)setLoadProgress:(double)loadProgress
{
    _loadProgress = loadProgress;
    if (_loadProgress > 1.0) {
        _loadProgress = 1.0;
    }
    
    if (_loadProgress < 0.0) {
        _loadProgress = 0.0;
    }
    CGRect rect = self.loadProgressView.frame;
    rect.size.width = CGRectGetWidth(self.frame) * _loadProgress;
    self.loadProgressView.frame = rect;
    
    _loadTime = _loadProgress * _totalTime;
}

- (void)setPlayProgress:(double)playProgress
{
    _playProgress = playProgress;
    if (_playProgress > 1.0) {
        _playProgress = 1.0;
    }
    
    if (_playProgress < 0.0) {
        _playProgress = 0.0;
    }
    self.slider.value = _playProgress;
    _playTime = _playProgress * _totalTime;
}

- (void)setPlayTime:(double)playTime
{
    _lastPlayTime = _playTime;
    _playTime = playTime;
    if (_playTime > _totalTime) {
        _playTime = _totalTime;
    }
    if (_playTime < 0.0) {
        _playTime = 0.0;
    }
    if (_totalTime > 0) {
        self.playProgress = (_playTime / _totalTime);
    }
}

- (void)setLoadTime:(double)loadTime
{
    _loadTime = loadTime;
    if (_loadTime > _totalTime) {
        _loadTime = _totalTime;
    }
    if (_loadTime < 0.0) {
        _loadTime = 0.0;
    }
    if (_totalTime > 0) {
        self.loadProgress = (_loadTime / _totalTime);
    }
}

#pragma mark - 事件
- (void)sliderValueChanged
{
    self.playProgress = self.slider.value;
    if ([self.delegate respondsToSelector:@selector(progressView:didChangedSliderValue:time:)]) {
        [self.delegate progressView:self didChangedSliderValue:self.slider.value time:self.slider.value * _totalTime];
    }
}

- (void)sliderUp
{
    self.playProgress = self.slider.value;
    if ([self.delegate respondsToSelector:@selector(progressView:didSliderUpAtValue:time:)]) {
        [self.delegate progressView:self didSliderUpAtValue:self.slider.value time:(self.slider.value * _totalTime)];
    }
}

- (void)selfTaped:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    self.slider.value = point.x / self.bounds.size.width;
    VPLog(@"selfTaped %@", tap);
    self.playProgress = self.slider.value;
    if ([self.delegate respondsToSelector:@selector(progressView:didSliderUpAtValue:time:)]) {
        [self.delegate progressView:self didSliderUpAtValue:self.slider.value time:self.slider.value * _totalTime];
    }
}
@end

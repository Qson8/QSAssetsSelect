//
//  HCIconSlider.m
//  ShortVideo
//
//  Created by chc on 2018/1/16.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCIconSlider.h"
#import "HCVideoPlayerConst.h"
#import "HCSlider.h"

@interface HCIconSlider ()
@property (nonatomic, weak) HCSlider *slider;
@property (nonatomic, weak) UIImageView *leftImageView;
@property (nonatomic, weak) UIImageView *rightImageView;
@end

@implementation HCIconSlider

#pragma mark - 懒加载
- (HCSlider *)slider
{
    if (_slider == nil) {
        HCSlider *slider = [[HCSlider alloc] init];
        [self addSubview:slider];
        _slider = slider;
        slider.minimumTrackTintColor = [UIColor whiteColor];
        slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.6];
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchCancel];
    }
    return _slider;
}

- (UIImageView *)leftImageView
{
    if (_leftImageView == nil) {
        UIImageView *leftImageView = [[UIImageView alloc] init];
        [self addSubview:leftImageView];
        _leftImageView = leftImageView;
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView
{
    if (_rightImageView == nil) {
        UIImageView *rightImageView = [[UIImageView alloc] init];
        [self addSubview:rightImageView];
        _rightImageView = rightImageView;
    }
    return _rightImageView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.thumbImageName = @"vp_more_sliderPoint_16";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTaped:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

#pragma mark - 外部方法
- (void)setThumbImageName:(NSString *)thumbImageName
{
    _thumbImageName = thumbImageName;
    if (_thumbImageName == nil) {
        return;
    }
    [self.slider setThumbImage:[UIImage vp_imageWithName:_thumbImageName] forState:UIControlStateNormal];
    [self setupFrame];
}

- (void)setLeftImageName:(NSString *)leftImageName
{
    _leftImageName = leftImageName;
    if (_leftImageName == nil) {
        return;
    }
    self.leftImageView.image = [UIImage vp_imageWithName:_leftImageName];
    [self setupFrame];
}

- (void)setRightImageName:(NSString *)rightImageName
{
    _rightImageName = rightImageName;
    if (_rightImageName == nil) {
        return;
    }
    self.rightImageView.image = [UIImage vp_imageWithName:_rightImageName];
    [self setupFrame];
}

- (CGFloat)heightToFit
{
    CGFloat leftImageHeight = self.leftImageView.image.size.height;
    CGFloat rightImageHeight = self.rightImageView.image.size.height;
    CGFloat sliderHeight = self.slider.currentThumbImage.size.height;
    CGFloat height = MAX(leftImageHeight, MAX(rightImageHeight, sliderHeight));
    return height;
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    self.slider.value = value;
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat padding = 25;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat leftImageWidth = _leftImageWidth > 0 ? _leftImageWidth : self.leftImageView.image.size.width;
    CGFloat leftImageHeight = self.leftImageView.image.size.height;
    CGFloat rightImageWidth = _rightImageWidth > 0 ? _rightImageWidth : self.rightImageView.image.size.width;
    CGFloat rightImageHeight = self.rightImageView.image.size.height;
    
    CGFloat width = ceil(leftImageWidth);
    CGFloat height = ceil(leftImageHeight);
    CGFloat x = 0;
    CGFloat y = ceil((selfHeight - height) * 0.5);
    self.leftImageView.frame = CGRectMake(x, y, width, height);
    
    width = ceil(selfWidth - (leftImageWidth ? (leftImageWidth + padding) : 0) - (rightImageWidth ? (rightImageWidth + padding) : 0));
    height = ceil(selfHeight);
    x = ceil(leftImageWidth > 0 ? (leftImageWidth + padding) : 0);
    y = 0;
    self.slider.frame = CGRectMake(x, y, width, height);
    
    width = ceil(rightImageWidth);
    height = ceil(rightImageHeight);
    x = ceil((width > 0 ? padding : 0) + CGRectGetMaxX(self.slider.frame));
    y = ceil((selfHeight - height) * 0.5);
    self.rightImageView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - 事件
- (void)sliderValueChanged
{
    if ([self.delegate respondsToSelector:@selector(iconSlider:didChangedSliderValue:)]) {
        [self.delegate iconSlider:self didChangedSliderValue:self.slider.value];
    }
}

- (void)sliderUp
{
    if ([self.delegate respondsToSelector:@selector(iconSlider:didSliderUpAtValue:)]) {
        [self.delegate iconSlider:self didSliderUpAtValue:self.slider.value];
    }
}

- (void)selfTaped:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    self.slider.value = point.x / self.bounds.size.width;
    if ([self.delegate respondsToSelector:@selector(iconSlider:didSliderUpAtValue:)]) {
        [self.delegate iconSlider:self didSliderUpAtValue:self.slider.value];
    }
}
@end

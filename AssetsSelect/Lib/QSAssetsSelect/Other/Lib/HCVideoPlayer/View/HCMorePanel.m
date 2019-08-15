//
//  HCMorePanel.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/10.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCMorePanel.h"
#import "HCVideoPlayerConst.h"
#import "HCIconSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import<AVFoundation/AVFoundation.h>

@interface HCMorePanel ()<HCIconSliderDelegate>
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) HCVerButton *collectBtn;
@property (nonatomic, weak) UIView *playSpeedContentView;
@property (nonatomic, weak) UILabel *playSpeedTitleLabel;
@property (nonatomic, strong) NSArray *speedValues;
@property (nonatomic, strong) NSArray *speedTexts;
@property (nonatomic, strong) NSArray *playSpeedBtns;
@property (nonatomic, weak) HCIconSlider *voiceSlider;
@property (nonatomic, weak) HCIconSlider *brightSlider;
@property (nonatomic, strong) UISlider* volumeViewSlider;
@property (nonatomic, weak) UIButton *selSpeedBtn;
@end

@implementation HCMorePanel
#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (HCVerButton *)collectBtn
{
    if (_collectBtn == nil) {
        HCVerButton *collectBtn = [[HCVerButton alloc] init];
        [self.contentView addSubview:collectBtn];
        _collectBtn = collectBtn;
        [collectBtn setImage:[UIImage vp_imageWithName:@"vp_more_collect"] forState:UIControlStateNormal];
        [collectBtn setImage:[UIImage vp_imageWithName:@"vp_more_collect_h"] forState:UIControlStateSelected];
        [collectBtn setTitle:@"收藏该剧" forState:UIControlStateNormal];
        [collectBtn setTitle:@"取消收藏" forState:UIControlStateSelected];
        collectBtn.titleFont = [UIFont systemFontOfSize:13];
        collectBtn.padding = 10;
        collectBtn.titleLabel.textColor = [UIColor whiteColor];
    }
    return _collectBtn;
}

- (UIView *)playSpeedContentView
{
    if (_playSpeedContentView == nil) {
        UIView *playSpeedContentView = [[UIView alloc] init];
        [self.contentView addSubview:playSpeedContentView];
        _playSpeedContentView = playSpeedContentView;
    }
    return _playSpeedContentView;
}

- (UILabel *)playSpeedTitleLabel
{
    if (_playSpeedTitleLabel == nil) {
        UILabel *playSpeedTitleLabel = [[UILabel alloc] init];
        [self.playSpeedContentView addSubview:playSpeedTitleLabel];
        _playSpeedTitleLabel = playSpeedTitleLabel;
        playSpeedTitleLabel.text = @"多倍速播放";
        playSpeedTitleLabel.textColor = [UIColor whiteColor];
        playSpeedTitleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _playSpeedTitleLabel;
}

- (HCIconSlider *)voiceSlider
{
    if (_voiceSlider == nil) {
        HCIconSlider *voiceSlider = [[HCIconSlider alloc] init];
        [self.contentView addSubview:voiceSlider];
        _voiceSlider = voiceSlider;
        voiceSlider.delegate = self;
        voiceSlider.leftImageName = @"vp_more_unvoice";
        voiceSlider.rightImageName = @"vp_more_voice";
    }
    return _voiceSlider;
}

- (HCIconSlider *)brightSlider
{
    if (_brightSlider == nil) {
        HCIconSlider *brightSlider = [[HCIconSlider alloc] init];
        [self.contentView addSubview:brightSlider];
        _brightSlider = brightSlider;
        brightSlider.delegate = self;
        brightSlider.leftImageName = @"vp_more_unbright";
        brightSlider.rightImageName = @"vp_more_bright";
    }
    return _brightSlider;
}

- (UISlider *)volumeViewSlider
{
    if (_volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        volumeView.alpha = 0.0001f;
        volumeView.showsRouteButton = NO;
        //默认YES
        volumeView.showsVolumeSlider = YES;
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
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSelfGesture];
        [self collectBtn];
        [self setupPlaySpeedBtns];
        [self setupSliderImageWidth];
        [self volumeViewSlider];
        self.brightSlider.value = [UIScreen mainScreen].brightness;
        self.voiceSlider.value = [[AVAudioSession sharedInstance] outputVolume];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCMorePanel");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)setupSelfGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfPan)];
    [self addGestureRecognizer:pan];
}

#pragma mark - 外部方法
- (void)showPanelAtView:(UIView *)view
{
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    self.frame = view.bounds;
    [view addSubview:self];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.backgroundColor = kVP_Color(0, 0, 0, 0.5);
        }];
    });
}

- (void)hiddenPanel
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.backgroundColor = kVP_Color(0, 0, 0, 0.0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(didHiddenMorePanel)]) {
            [self.delegate didHiddenMorePanel];
        }
    }];
}

- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    for (int i = 0; i < _speedValues.count; i ++) {
        NSNumber *num = _speedValues[i];
        if (fabs(num.floatValue - _rate) < 0.1) {
            _selSpeedBtn.selected = NO;
            _selSpeedBtn = _playSpeedBtns[i];
            _selSpeedBtn.selected = YES;
        }
    }
}

- (void)setCollectStatus:(BOOL)collectStatus
{
    _collectStatus = collectStatus;
    self.collectBtn.selected = collectStatus;
    [self setupFrame];
}

#pragma mark - 事件
- (void)selfTap
{
    [self hiddenPanel];
}

- (void)selfPan
{
    
}

- (void)speedBtnClicked:(UIButton *)btn
{
    _selSpeedBtn.selected = NO;
    _selSpeedBtn = btn;
    _selSpeedBtn.selected = YES;
    
    NSNumber *num = _speedValues[btn.tag];
    if ([self.delegate respondsToSelector:@selector(morePanel:didSelectRate:)]) {
        [self.delegate morePanel:self didSelectRate:num.floatValue];
    }
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat width = ceil(self.collectBtn.imageView.image.size.width);
    CGFloat height = ceil([self.collectBtn heightToFitWidth:width]);
    CGFloat x = ceil([self.collectBtn btnXWithTitleX:0 btnWidth:width]);
    CGFloat y = 0;
    self.collectBtn.frame = CGRectMake(x, y, width, height);
    
    CGSize size = [self setupPlaySpeedContentViewSubViewsFrame];
    x = 0;
    y = ceil(CGRectGetMaxY(self.collectBtn.frame) + 52);
    self.playSpeedContentView.frame = CGRectMake(x, y, ceil(size.width), ceil(size.height));
    
    x = 0;
    y = ceil(CGRectGetMaxY(self.playSpeedContentView.frame) + 52);
    width = 300;
    height = ceil([self.voiceSlider heightToFit]);
    self.voiceSlider.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = ceil(CGRectGetMaxY(self.voiceSlider.frame) + 45);
    width = 300;
    height = ceil([self.brightSlider heightToFit]);
    self.brightSlider.frame = CGRectMake(x, y, width, height);
    
    width = ceil(MAX(self.playSpeedContentView.frame.size.width, self.brightSlider.frame.size.width));
    height = ceil(CGRectGetMaxY(self.brightSlider.frame));
    x = ceil((self.bounds.size.width - width) * 0.5);
    y = ceil((self.bounds.size.height - height) * 0.5);
    self.contentView.frame = CGRectMake(x, y, width, height);
}

- (void)setupPlaySpeedBtns
{
    _speedValues = @[@0.5,@0.75,@1.0,@1.25,@1.5,@2.0];
    _speedTexts = @[@"0.5X",@"0.75X",@"1.0X",@"1.25X",@"1.5X",@"2.0X"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < _speedTexts.count; i ++) {
        NSString *text = _speedTexts[i];
        UIButton *btn = [[UIButton alloc] init];
        [self.playSpeedContentView addSubview:btn];
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:kVP_Color(31, 147, 234, 1.0) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        btn.tag = i;
        [btn addTarget:self action:@selector(speedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [arrayM addObject:btn];
    }
    _playSpeedBtns = arrayM;
    [self setupPlaySpeedContentViewSubViewsFrame];
}

- (CGSize)setupPlaySpeedContentViewSubViewsFrame
{
    CGFloat maxHeight = ceil(MAX(self.playSpeedTitleLabel.font.lineHeight, ((UIButton *)self.playSpeedBtns.firstObject).titleLabel.font.lineHeight));
    CGSize size = [self.playSpeedTitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = 0;
    CGFloat y = 0;
    self.playSpeedTitleLabel.frame = CGRectMake(x, y, size.width, maxHeight);
    UIView *lastView = self.playSpeedTitleLabel;
    for (UIButton *btn in _playSpeedBtns) {
        CGSize size = [btn sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        x = ceil(CGRectGetMaxX(lastView.frame) + 36);
        y = 0;
        btn.frame =  CGRectMake(x, y, ceil(size.width), maxHeight);
        lastView = btn;
    }
    size = CGSizeMake(CGRectGetMaxX(lastView.frame), maxHeight);
    return size;
}

- (void)setupSliderImageWidth
{
    CGFloat leftImageWidth = MAX([UIImage vp_imageWithName:@"vp_more_unbright"].size.width, [UIImage vp_imageWithName:@"vp_more_unvoice"].size.width);
    CGFloat rightImageWidth = MAX([UIImage vp_imageWithName:@"vp_more_bright"].size.width, [UIImage vp_imageWithName:@"vp_more_voice"].size.width);
    self.voiceSlider.leftImageWidth = leftImageWidth;
    self.voiceSlider.rightImageWidth = rightImageWidth;
    self.brightSlider.leftImageWidth = leftImageWidth;
    self.brightSlider.rightImageWidth = rightImageWidth;
}

#pragma mark - HCIconSliderDelegate
- (void)iconSlider:(HCIconSlider *)iconSlider didChangedSliderValue:(double)sliderValue
{
    if (self.voiceSlider == iconSlider) {
        self.volumeViewSlider.value = sliderValue;
    }
    if (self.brightSlider == iconSlider) {
        [[UIScreen mainScreen] setBrightness:sliderValue];
    }
}

- (void)iconSlider:(HCIconSlider *)iconSlider didSliderUpAtValue:(CGFloat)value
{
    if (self.voiceSlider == iconSlider) {
        self.volumeViewSlider.value = value;
    }
    if (self.brightSlider == iconSlider) {
        [[UIScreen mainScreen] setBrightness:value];
    }
}
@end

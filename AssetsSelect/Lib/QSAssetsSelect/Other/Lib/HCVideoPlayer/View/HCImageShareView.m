//
//  HCImageShareView.m
//  ShortVideo
//
//  Created by chc on 2018/1/18.
//  Copyright © 2018年 chc. All rights reserved.
//
#define IS_IPHONE_4  (IS_IPHONE && SCREEN_MAX_LENGTH == 480.0)

#import "HCImageShareView.h"
#import "HCVideoPlayerConst.h"

@interface HCImageShareView ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;
@end

@implementation HCImageShareView
#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)label
{
    if (_label == nil) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        _label = label;
        label.text = @"点击分享";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 1;
    }
    return _label;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat scale = (kVP_isIphone4 ? (2.0f / 3.0f) : (9.0f / 16.0f));
    CGFloat selfWidth = self.bounds.size.width;
    
    CGFloat x = 5;
    CGFloat y = 5;
    CGFloat width = selfWidth - 10;
    CGFloat height = width *scale;
    self.imageView.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = CGRectGetMaxY(self.imageView.frame) + 10;
    width = selfWidth;
    height = self.label.font.lineHeight;
    self.label.frame = CGRectMake(x, y, width, height);
}

#pragma mark - 外部方法
- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (CGFloat)heightToFit
{
    return CGRectGetMaxY(self.label.frame) + 5;
}
@end

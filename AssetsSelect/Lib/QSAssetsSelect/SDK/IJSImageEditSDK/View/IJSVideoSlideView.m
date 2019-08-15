//
//  IJSVideoSlideView.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoSlideView.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>

@interface IJSVideoSlideView ()
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation IJSVideoSlideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame backImage:(UIImage *)backImage isLeft:(BOOL)isLeft
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.isLeft = isLeft;
        self.backImage = backImage;
    }
    return self;
}

- (void)setupFrame
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    w = _backImage.size.width;
    h = _backImage.size.height;
    y = (self.js_height - h) * 0.5;
    x = self.isLeft ? kIPadSuitFloat(4) : (self.js_width - kIPadSuitFloat(4) - w);
    self.imageView.frame = CGRectMake(x, y, w, h);
}
/*
- (void)drawRect:(CGRect)rect
{
    if (self.backImage != nil)
    {
        [self.backImage drawInRect:CGRectMake(0, 0, self.js_width, self.js_height)];
    }
    else
    {
        if (_isLeft)
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.js_width, self.js_height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
            [[IJSFColor colorWithR:170 G:170 B:170 alpha:1] set];
            [path fill];
            UIBezierPath *verticalLine = [UIBezierPath bezierPathWithRect:CGRectMake(self.js_width * 0.5, 10, 1, self.js_height - 20)];
            [[UIColor whiteColor] set];
            [verticalLine fill];
        }
        else
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.js_width, self.js_height) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
            [[IJSFColor colorWithR:170 G:170 B:170 alpha:1] set];
            [path fill];
            UIBezierPath *verticalLine = [UIBezierPath bezierPathWithRect:CGRectMake(self.js_width * 0.5, 10, 1, self.js_height - 20)];
            [[UIColor whiteColor] set];
            [verticalLine fill];
        }
    }
}
 */
#pragma mark set方法
- (void)setIsLeft:(BOOL)isLeft
{
    _isLeft = isLeft;
}
- (void)setBackImage:(UIImage *)backImage
{
    _backImage = backImage;
    
    self.imageView.image = backImage;
    [self setupFrame];
}

#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if(_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}
@end

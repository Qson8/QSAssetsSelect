//
//  HCVerButton.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCHorButton.h"

@implementation HCHorButton

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleFont = [UIFont systemFontOfSize:16];
        self.padding = 6;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGSize size = [self.currentTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : (_titleFont ? _titleFont : [UIFont systemFontOfSize:16])} context:nil].size;
    CGFloat width = size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    return CGRectMake(x, y, width, height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat width = self.currentImage.size.width;
    CGFloat height = self.currentImage.size.height;
    
    CGSize size = [self.currentTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : (_titleFont ? _titleFont : [UIFont systemFontOfSize:16])} context:nil].size;
    CGFloat x = size.width + _padding;
    CGFloat y = (self.bounds.size.height - height) * 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - 外部方法
- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
    [self setTitle:self.titleLabel.text forState:UIControlStateNormal];
}

- (CGFloat)fitWidth
{
    CGSize size = [self.currentTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : (_titleFont ? _titleFont : [UIFont systemFontOfSize:16])} context:nil].size;
    return size.width + _padding + self.currentImage.size.width;
}
@end

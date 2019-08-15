//
//  UIImage+PureColorImage.m
//  TodayCity
//
//  Created by liuyu on 15/5/20.
//  Copyright (c) 2015年 TodayCity. All rights reserved.
//

#import "UIImage+PureColorImage.h"

@implementation UIImage (PureColorImage)

+ (UIImage *)imageWithPureColor:(UIColor *)color size:(CGSize)size
{
    //开启绘图
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    
    //反悔绘制的结果
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageWithPureColor:(UIColor *)color
{
    return [self imageWithPureColor:color size:CGSizeMake(1, 1)];
}


@end

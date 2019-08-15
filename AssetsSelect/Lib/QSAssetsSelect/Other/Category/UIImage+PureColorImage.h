//
//  UIImage+PureColorImage.h
//  TodayCity
//
//  Created by liuyu on 15/5/20.
//  Copyright (c) 2015年 TodayCity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PureColorImage)

/**
 *  获取一个纯色图片
 */
+ (UIImage *)imageWithPureColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithPureColor:(UIColor *)color;
@end

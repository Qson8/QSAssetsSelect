//
//  UIImage+VP.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/5.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VP)
+ (instancetype)vp_imageWithName:(NSString *)name;

/**
 *  修改矢量图颜色
 *
 *  @param      maskColor 修改颜色
 *  @return     返回修改颜色后的image
 */
- (instancetype)vp_imageMaskWithColor:(UIColor *)maskColor;

/**
 *  修改矢量图颜色
 *
 *  @param      maskColor 修改颜色
 *  @param      outMaskColor 背景颜色
 *  @return     返回修改颜色后的image
 */
- (instancetype)vp_imageMaskWithColor:(UIColor *)maskColor outMaskColor:(UIColor *)outMaskColor;

/**
 * 颜色转image;
 */
+ (instancetype)vp_imageWithColor:(UIColor*)color;
@end

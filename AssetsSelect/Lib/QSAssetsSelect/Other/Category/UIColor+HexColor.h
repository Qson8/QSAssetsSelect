//
//  UIColor+HexColor.h
//  JRCS
//
//  Created by liuyu on 15/5/12.
//  Copyright (c) 2015年 liuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

/**
 *  16进制格式的颜色转化成类对象
 */
+ (UIColor *)colorWithHexValue:(NSInteger)hexValue alpha:(CGFloat)alpha;


/**
 *  16进制格式的颜色转化成类对象
 */
+ (UIColor *)colorWithHexValue:(NSInteger)hexValue;

/**
 *  获取16进制数字
 */
- (NSString *)hexValue;

/** 十六进制字符串 转成 颜色 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color;
@end

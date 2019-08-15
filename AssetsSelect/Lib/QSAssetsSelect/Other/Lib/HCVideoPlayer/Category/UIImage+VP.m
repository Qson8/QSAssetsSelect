//
//  UIImage+VP.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/5.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "UIImage+VP.h"

@implementation UIImage (VP)
+ (instancetype)vp_imageWithName:(NSString *)name
{
    NSString *dirPath = [[NSBundle mainBundle] pathForResource:@"HCVideoPlayer" ofType:@"bundle"];
    NSString *imagePath = [dirPath stringByAppendingPathComponent:name];
    UIImage *image = nil;
    if ([imagePath isKindOfClass:[NSString class]]) {
        image = [self imageNamed:imagePath];
    }
    return image;
}

- (instancetype)vp_imageMaskWithColor:(UIColor *)maskColor
{
    return [self vp_imageMaskWithColor:maskColor outMaskColor:nil];
}

- (instancetype)vp_imageMaskWithColor:(UIColor *)maskColor outMaskColor:(UIColor *)outMaskColor
{
    if (self == nil) {
        return nil;
    }
    UIImage *newImage = nil;
    CGRect imageRect = (CGRect){CGPointZero,self.size};
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (outMaskColor) {
        CGContextSetFillColorWithColor(context, outMaskColor.CGColor);
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextFillRect(context,rect);
    }
    if (maskColor) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));
        CGContextClipToMask(context, imageRect, self.CGImage);//选中选区 获取不透明区域路径
        CGContextSetFillColorWithColor(context, maskColor.CGColor);//设置颜色
        CGContextFillRect(context, imageRect);//绘制
    }
    else
    {
        [self drawInRect:imageRect];
    }
    newImage = UIGraphicsGetImageFromCurrentImageContext();//提取图片
    UIGraphicsEndImageContext();
    return newImage;
}

+ (instancetype)vp_imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end

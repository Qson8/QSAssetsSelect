//
//  UIImage+QS.m
//  AssetsSelect
//
//  Created by Qson on 2019/8/10.
//  Copyright © 2019 QSon. All rights reserved.
//

#import "UIImage+QS.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "SDImageCache.h"

@implementation UIImage (QS)
- (UIImage*)imageByScalingAndCroppingForWidth:(CGFloat)targetWidth
{
    UIImage *sourceImage = self;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width <= targetWidth) {
        return self;
    }
    
    UIImage *newImage = nil;
    CGFloat scaleFactor = targetWidth / width; // 压缩比例
    CGFloat targetHeight = height * scaleFactor;
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    //    UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, [UIScreen mainScreen].scale);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointMake(0.0, 0.0);
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    UIGraphicsEndImageContext();
    return newImage;
}

/* 获取视频第一帧缩略图 */
+ (UIImage *)getThumbailImageRequestWithUrlString:(NSString *)urlString
{
    //视频文件URL地址
    NSURL *url = [NSURL URLWithString:urlString];
    //创建媒体信息对象AVURLAsset
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    //创建视频缩略图生成器对象AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    //创建视频缩略图的时间，第一个参数是视频第几秒，第二个参数是每秒帧数
    CMTime time = CMTimeMake(0, 10);
    CMTime actualTime;//实际生成视频缩略图的时间
    NSError *error = nil;//错误信息
    //使用对象方法，生成视频缩略图，注意生成的是CGImageRef类型，如果要在UIImageView上显示，需要转为UIImage
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time
                                                actualTime:&actualTime
                                                     error:&error];
    if (error) {
        NSLog(@"截取视频缩略图发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    //CGImageRef转UIImage对象
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //记得释放CGImageRef
    CGImageRelease(cgImage);
    return image;
}

/* 取图片 缓存有就直接取，没有就缓存到磁盘 videoKey:可以是视频地址*/
+ (void)imageFromDiskCacheForVideoKey:(NSString *)videoUrl complete:(void(^)(UIImage *image))complete
{
    // 取图片
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromDiskCacheForKey:videoUrl];
    if(image) {
        if(complete) complete(image);
    }
    else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 处理耗时操作的代码块...
            UIImage *image = [self getThumbailImageRequestWithUrlString:videoUrl];
            if(image) {
                // 存图片
                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                [imageCache storeImage:image forKey:videoUrl toDisk:YES];
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(complete) complete(image);
                });
            }
        });
    }
}

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationDown:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            
            transform = CGAffineTransformRotate(transform, M_PI_2);
            
            break;
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
            break;
            
        case UIImageOrientationUp:
            
        case UIImageOrientationUpMirrored:
            
            break;
            
    }
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationUpMirrored:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
            
            
            
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
            
        case UIImageOrientationUp:
            
        case UIImageOrientationDown:
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationRight:
            
            break;
            
    }
    
    
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    
    // calculated above.
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             
                                             CGImageGetColorSpace(self.CGImage),
                                             
                                             CGImageGetBitmapInfo(self.CGImage));
    
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation) {
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            
            break;
        default:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}
@end

//
//  UIImage+QS.h
//  AssetsSelect
//
//  Created by Qson on 2019/8/10.
//  Copyright © 2019 QSon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QS)
- (UIImage*)imageByScalingAndCroppingForWidth:(CGFloat)targetWidth;

/* 获取视频第一帧缩略图 */
+ (UIImage *)getThumbailImageRequestWithUrlString:(NSString *)urlString;

/* 取图片 缓存有就直接取，没有就缓存到磁盘 videoKey:可以是视频地址*/
+ (void)imageFromDiskCacheForVideoKey:(NSString *)videoUrl complete:(void(^)(UIImage *image))complete;

- (UIImage *)fixOrientation;
@end

NS_ASSUME_NONNULL_END

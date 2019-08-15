//
//  MediaItem.m
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/7.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "MediaItem.h"
#import "UIImage+QS.h"

@implementation MediaItem

- (instancetype)initWithPhoto:(UIImage *)photo {
    if (self = [super init]) {
        self.mediaType = kMediaItemTypeImage;
        self.image = photo;
    }
    return self;
}

+ (instancetype)itemWithPhoto:(UIImage *)photo {
    return [[self alloc] initWithPhoto:photo];
}

+ (NSArray<MediaItem *> *)itemsWithPhotos:(NSArray<UIImage *> *)photos {
    NSMutableArray *arrM = [NSMutableArray array];
    for (UIImage *image in photos) {
        UIImage *zoomImage = [image imageByScalingAndCroppingForWidth:KPostImageWith];
        MediaItem *item = [[MediaItem alloc] initWithPhoto:zoomImage];
        [arrM addObject:item];
    }
    return arrM;
}
@end

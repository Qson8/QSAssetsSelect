//
//  MediaImageCell.h
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/8.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@class MediaImageCell;

@protocol MediaImageDelegate <NSObject>
- (void)mediaDidUploadedSuccesed:(MediaItem *)mediaItem;
@end

@interface MediaImageCell : UIView
@property (nonatomic, weak) id<MediaImageDelegate>delegate;
@property (nonatomic, weak) UIViewController *pushViewController;
@property (nonatomic, copy) NSString *catId;
@property (nonatomic, strong) MediaItem *item;
@end

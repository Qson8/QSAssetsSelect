//
//  MediaPlayerController.h
//  SydneyToday
//
//  Created by Qson on 2017/12/14.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"
@interface MediaPlayerController : UIViewController
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) MediaItem *item;
@end

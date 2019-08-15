//
//  HCOrientationsController.h
//  HCVideoPlayer
//
//  Created by chc on 2017/11/28.
//  Copyright © 2017年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayer.h"

@protocol HCOrientControllerDelegate <NSObject>
/** 屏幕将要旋转 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
/** 屏幕旋转中 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
/** 屏幕旋转完成 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
@end

@interface HCOrientController : UIViewController
/**
 屏幕旋转方向
 */
@property (assign, nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, copy) void (^destroyBlock)(void);
@property (nonatomic, weak) id <HCOrientControllerDelegate> delegate;
@end

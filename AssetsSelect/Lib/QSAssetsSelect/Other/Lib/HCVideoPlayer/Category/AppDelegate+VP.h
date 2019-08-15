//
//  AppDelegate+VP.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/3.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (VP)
+ (void)setPortraitOrientation;
+ (void)setOrientation:(UIInterfaceOrientation)orientation;
+ (void)setAllowRotation:(BOOL)allowRotation forRootPresentVc:(UIViewController *)rootPresentVc;
@end

//
//  HCOrientationsController.m
//  HCVideoPlayer
//
//  Created by chc on 2017/11/28.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCOrientController.h"
#import "HCVideoPlayerConst.h"

@interface HCOrientController ()
@end

@implementation HCOrientController

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        self.orientation = UIDeviceOrientationLandscapeLeft;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (HCVideoPlayer *player in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([player isKindOfClass:[HCVideoPlayer class]]) {
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:player];
            break;
        }
        if([player isKindOfClass:NSClassFromString(@"ShortVideoView")]) {
            CGLog(@"%@",player.superview);
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:player];
            break;
        }
    }
}

- (void)dealloc
{
    VPLog(@"dealloc - HCOrientController");
    if (self.destroyBlock) {
        self.destroyBlock();
    }
}

#pragma mark - UIViewControllerRotation
- (BOOL)shouldAutorotate
{
    VPLog(@"shouldAutorotate");
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
//    VPLog(@"UIInterfaceOrientationMaskLandscape");
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
//    VPLog(@"preferredInterfaceOrientationForPresentation %ld", self.orientation);
    return _orientation;
}

#pragma mark -
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.delegate respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) {
        [self.delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

//获取旋转中的状态
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.delegate respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) {
        [self.delegate willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
//屏幕旋转完成的状态
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(didRotateFromInterfaceOrientation:)]) {
        [self.delegate didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

@end

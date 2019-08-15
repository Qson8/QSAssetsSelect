//
//  AppDelegate+VP.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/3.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "AppDelegate+VP.h"
#import <objc/runtime.h>

BOOL g_allowRotation;
BOOL g_hasConfigRootVc;
@implementation AppDelegate (VP)

+ (void)initialize
{
    SEL method = @selector(application:supportedInterfaceOrientationsForWindow:);
    if (!class_addMethod([self class], method, (IMP)application_supportedInterfaceOrientationsForWindow, "I@:@c")) { // 创建失败则表示已存在该方法，则采用交换方法的方式
        Class class = objc_getClass([@"AppDelegate" UTF8String]);
        SEL method = @selector(application:supportedInterfaceOrientationsForWindow:);
        SEL newMethod = @selector(applicationNew:supportedInterfaceOrientationsForWindow:);
        Method originalMethod = class_getInstanceMethod(class, method);
        Method swizzledMethod = class_getInstanceMethod(class, newMethod);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (UIInterfaceOrientationMask)applicationNew:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (g_allowRotation) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return [self applicationNew:application supportedInterfaceOrientationsForWindow:window];
}

u_long application_supportedInterfaceOrientationsForWindow(id self, SEL cmd, UIApplication *application, UIWindow *window)
{
    if (g_allowRotation) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:window];
}

+ (void)setPortraitOrientation
{
    [self setOrientation:UIInterfaceOrientationPortrait];
}

+ (void)setOrientation:(UIInterfaceOrientation)orientation
{
    //    if(ScreenWidth > ScreenHeight) {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    // 从2开始是因为0 1 两个参数已经被selector和target占用
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
    //    }
}

#pragma mark - 配置根控制器旋转
+ (void)configRootVCOrientation
{
    if (g_hasConfigRootVc) {
        return;
    }
    Class class = [[UIApplication sharedApplication].keyWindow.rootViewController class];
    SEL method = @selector(preferredInterfaceOrientationForPresentation);
    if (!class_addMethod(class, method, (IMP)preferredInterfaceOrientationForPresentation, "I@:")) {
        SEL method = @selector(preferredInterfaceOrientationForPresentation);
        SEL newMethod = @selector(preferredInterfaceOrientationForPresentationNew);
        Method originalMethod = class_getInstanceMethod(class, method);
        Method swizzledMethod = class_getInstanceMethod(self, newMethod);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    g_hasConfigRootVc = YES;
}

+ (void)configOrientationForRootPresentVc:(UIViewController *)rootPresentVc
{
    if (rootPresentVc == nil) {
        return;
    }
    if (rootPresentVc == [UIApplication sharedApplication].keyWindow.rootViewController) {
        return;
    }
    Class class = [rootPresentVc class];
    SEL method = @selector(preferredInterfaceOrientationForPresentation);
    if (!class_addMethod(class, method, (IMP)preferredInterfaceOrientationForPresentation, "I@:")) {
        SEL method = @selector(preferredInterfaceOrientationForPresentation);
        SEL newMethod = @selector(preferredInterfaceOrientationForPresentationNew);
        Method originalMethod = class_getInstanceMethod(class, method);
        Method swizzledMethod = class_getInstanceMethod(self, newMethod);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentationNew {
    return UIInterfaceOrientationPortrait;
}

u_long preferredInterfaceOrientationForPresentation(id self, SEL cmd)
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 外部方法
+ (void)setAllowRotation:(BOOL)allowRotation forRootPresentVc:(UIViewController *)rootPresentVc
{
    g_allowRotation = allowRotation;
    
    if (allowRotation) {
        [self configRootVCOrientation];
        [self configOrientationForRootPresentVc:rootPresentVc];
    }
}
@end

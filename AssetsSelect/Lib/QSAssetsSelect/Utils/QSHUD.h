//
//  QSHUD.h
//  SydneyToday
//
//  Created by Qson on 16/7/28.
//  Copyright © 2016年 Yu Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

typedef enum : NSUInteger {
    QSAnimateTypeNone,
    QSAnimateTypeFade, // 淡入淡出
} QSAnimateType;

extern NSString * _Nullable const KAnonymousUsersConstant;
extern NSString * _Nullable const KNetworkErrorDataFromServer;
extern NSString * _Nullable const KNetworkFailure;
extern NSString * _Nullable const KEmailErrorConstant;
extern NSString * _Nonnull const KEmailEmptyConstant;

#define kNetworkError(code) ([NSString stringWithFormat:@"%@:%ld",KNetworkFailure,code])

// api推送监控调试
//#define kAPIRequestAlert(a) ([QSHUD showInfoWithStatus:[NSString stringWithFormat:a]])
#define kAPIRequestAlert(a)

@interface QSHUD : NSObject

/**
 *  实例化一个HUD弹窗(图片加载器)
 *
 *  @param targetView HUD加到哪个视图上
 *
 *  @return 返回一个已经实例过的HUD
 */
+ (void)showLoaderImage:(UIView *_Nullable)targetView;
+ (void)showLoaderBlackImage:(UIView *_Nonnull)targetView;
+ (void)showLiveLoaderImage:(UIView *_Nonnull)targetView;
/**
 *  显示hud加载文字
 *
 *  @param text       需要显示的文字
 *  @param targetView 要显示到哪里
 */
+ (void)showLoaderText:(NSString *_Nullable)text view:(UIView *_Nullable)targetView;

/**
 *  错误弹窗HUD
 *
 *  @param targetView 目标视图(HUD承载视图)
 *
 *  @return 返回实例化的HUD
 */
+ (void)showLoadingError:(UIView *_Nonnull)targetView;

/**
 *  显示指定文本的错误弹框HUD
 *
 *  @param targetView  目标视图(HUD承载视图)
 *  @param displayText 显示文本,显示的内容
 */
+ (void)showErrorHudWithText:(UIView *_Nullable)targetView withText:(NSString *_Nonnull)displayText;

/**
 *  显示指定内容的成功HUD
 *
 *  @param targetView  目标视图(HUD承载视图)
 *  @param displayText 显示文本,显示的内容
 */
+ (void)showSuccessHudWithText:(UIView *_Nonnull)targetView withText:(NSString *_Nullable)displayText;



/**
 *  隐藏某个视图上的HUD
 *
 *  @param view     目标视图
 *  @param animated 是否带动画
 */
+ (void)hiddenHUDForView:(UIView *_Nonnull)view animated:(BOOL)animated;

/**
 *  隐藏所有HUD
 *
 *  @param view     目标视图
 *  @param animated 是否带动画
 */
+ (void)hiddenAllHUDForView:(UIView *_Nonnull)view animated:(BOOL)animated;


+ (void)showInfoWithStatus:(NSString*_Nonnull)status;
+ (void)showWithStatus:(NSString*_Nullable)status;
+ (void)showErrorWithStatus:(NSString*_Nullable)status;
+ (void)showSuccessWithStatus:(NSString*_Nonnull)status;

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;

#pragma mark - 新HUD弹窗

/**
 *  Loading
 *
 *  @param text       需要显示的文字
 *  @param targetView 要显示到哪里
 */
+ (void)showLoadingMessage:(NSString *)msg view:(UIView *)targetView;

/**
 *  网络错误HUD
 *
 *  @param targetView 目标视图(HUD承载视图)
 *
 */
+ (void)showNetworkError:(UIView *_Nullable)targetView;

/**
 *  完成HUD
 *
 *  @param massage 文本消息
 *  @param targetView 目标视图(HUD承载视图) 如果为nil，则代表Window
 *
 */
+ (void)showCompleteMassage:(NSString *_Nullable)massage toView:(UIView *_Nullable)targetView;

/**
 *  异常HUD
 *
 *  @param massage 文本消息
 *  @param targetView 目标视图(HUD承载视图) 如果为nil，则代表Window
 *
 */
+ (void)showWarnMassage:(NSString *_Nullable)massage toView:(UIView *_Nullable)targetView;
@end

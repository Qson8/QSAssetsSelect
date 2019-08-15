//
//  QSHUD.m
//  SydneyToday
//
//  Created by Qson on 16/7/28.
//  Copyright © 2016年 Yu Wang. All rights reserved.
//

#import "QSHUD.h"

NSString *const KAnonymousUsersConstant = @"土澳居民";
NSString *const KNetworkErrorDataFromServer = @"服务器返回数据出错!";
NSString *const KNetworkFailure = @"网络请求失败,请稍后再试";
NSString *const KEmailErrorConstant = @"邮箱格式不正确";
NSString *const KEmailEmptyConstant = @"邮箱地址不能为空";

@implementation QSHUD

#pragma mark - show
/**
 *  显示(图片加载器)HUD弹窗
 *
 *  @param targetView HUD加到哪个视图上
 *
 *  @return 返回一个已经实例过的HUD
 */
+ (void)showLoaderImage:(UIView *)targetView {
    if (!targetView) return;
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:hud];
    hud.backgroundColor = [UIColor whiteColor];
    // 加载gif图片
    NSString *imageName = @"News_loading@2x";
    if (IS_IPHONE_6Plus || kIsIpad) {
       imageName = @"News_loading@3x";
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"gif"];
//    UIImage *loaderImage = [UIImage animatedImageWithAnimatedGIFURL:url];
    UIImage *loaderImage = nil;
    hud.customView = [[UIImageView alloc] initWithImage:loaderImage];
    CGRect newFrame = hud.customView.frame;
    newFrame.size = CGSizeMake(207, 75.0);
    hud.customView.frame = newFrame;
    hud.opacity=0;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}
+ (void)showLoaderBlackImage:(UIView *)targetView {
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:hud];
    hud.backgroundColor = [UIColor colorWithRed:0.174 green:0.174 blue:0.164 alpha:1.000];
    // 加载gif图片
    NSString *imageName = @"News_black_loading@2x";
    if (IS_IPHONE_6Plus || kIsIpad) {
        imageName = @"News_black_loading@3x";
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"gif"];
//    UIImage *loaderImage = [UIImage animatedImageWithAnimatedGIFURL:url];
    UIImage *loaderImage;
    //    loaderImage = [loaderImage imageMaskWithColor:[MainHelper getMainColor]];
    hud.customView = [[UIImageView alloc] initWithImage:loaderImage];
    CGRect newFrame = hud.customView.frame;
    newFrame.size = CGSizeMake(207, 75.0);
    hud.customView.frame = newFrame;
    hud.opacity=0;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}

+ (void)showLiveLoaderImage:(UIView *)targetView {
    if (!targetView) return;
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:hud];
    hud.backgroundColor = [UIColor whiteColor];
    // 加载gif图片
    NSString *imageName = @"live_loading@2x";
    if (IS_IPHONE_6Plus || kIsIpad || IS_IPHONE_X) {
        imageName = @"live_loading@3x";
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"gif"];
//    UIImage *loaderImage= [UIImage animatedImageWithAnimatedGIFURL:url];
    UIImage *loaderImage;
    hud.customView = [[UIImageView alloc] initWithImage:loaderImage];
    CGRect newFrame = hud.customView.frame;
    newFrame.size = CGSizeMake(207, 75.0);
    hud.customView.frame = newFrame;
    hud.opacity=0;
    hud.mode = MBProgressHUDModeCustomView;
    [hud show:YES];
}

/**
 *  显示hud加载文字
 *
 *  @param text       需要显示的文字
 *  @param targetView 要显示到哪里
 */
+ (void)showLoaderText:(NSString *)text view:(UIView *)targetView {

     if (!targetView) return;

    [self hiddenAllHUDForView:targetView animated:NO];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    hud.labelText = text;
    [targetView addSubview:hud];
    [hud show:YES];
}

/**
 *  显示错误弹窗HUD
 *
 *  @param targetView 目标视图(HUD承载视图)
 *
 *  @return 返回实例化的HUD
 */
+ (void)showLoadingError:(UIView *)targetView {
    [QSHUD showNetworkError:targetView];
//     if (!targetView) return;
//
//    [self hiddenAllHUDForView:targetView animated:NO];
//
//    MBProgressHUD *error_hud = [[MBProgressHUD alloc] initWithView:targetView];
//    [targetView addSubview:error_hud];
//
//    UIImageView *imageView = ({
//        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_error"]];
//        imageView.size = CGSizeMake(kIPadSuitFloat(40), kIPadSuitFloat(40));
//        imageView;
//    });
//    error_hud.customView = imageView;
//    error_hud.mode = MBProgressHUDModeCustomView;
//    error_hud.labelText = @"网络不给力，请稍后再试";
//    [error_hud show:YES];
//
//    // 2秒后隐藏HUD
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:targetView animated:YES];
//    });
}

/**
 *  显示指定文本的错误弹框HUD
 *
 *  @param targetView  目标视图(HUD承载视图)
 *  @param displayText 显示文本,显示的内容
 */
+ (void)showErrorHudWithText:(UIView *)targetView withText:(NSString *)displayText {
    [self showWarnMassage:displayText toView:targetView];
    
//    if (!targetView) return;
//    [self hiddenAllHUDForView:targetView animated:NO];
//
//    MBProgressHUD *error_hud = [[MBProgressHUD alloc] initWithView:targetView];
//    [targetView addSubview:error_hud];
//
//    UIImageView *imageView = ({
//        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_error"]];
//        imageView.size = CGSizeMake(kIPadSuitFloat(40), kIPadSuitFloat(40));
//        imageView;
//    });
//    error_hud.customView = imageView;
//    error_hud.mode = MBProgressHUDModeCustomView;
//    error_hud.detailsLabelText = displayText.safeString;
//    [error_hud show:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:targetView animated:YES];
//    });
}


/**
 *  显示指定内容的成功HUD
 *
 *  @param targetView  目标视图(HUD承载视图)
 *  @param displayText 显示文本,显示的内容
 */
+ (void)showSuccessHudWithText:(UIView *)targetView withText:(NSString *)displayText {
    
    [QSHUD showCompleteMassage:displayText toView:targetView];
    
//    if (!targetView) return;
//    [self hiddenAllHUDForView:targetView animated:NO];
//
//    MBProgressHUD *success_hud = [[MBProgressHUD alloc] initWithView:targetView];
//    [targetView addSubview:success_hud];
//
//    UIImageView *imageView = ({
//        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete"]];
//        imageView.size = CGSizeMake(kIPadSuitFloat(40), kIPadSuitFloat(40));
//        imageView;
//    });
//    success_hud.customView = imageView;
//    success_hud.mode = MBProgressHUDModeCustomView;
//    success_hud.detailsLabelText = displayText.safeString;
//    [success_hud show:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:targetView animated:YES];
//    });
}

+ (void)showInfoWithStatus:(NSString*)status
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [SVProgressHUD setInfoImage:nil];
#pragma clang diagnostic pop
    
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setBackgroundLayerColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    [SVProgressHUD showInfoWithStatus:status];
}

+ (void)showWithStatus:(NSString*)status
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setBackgroundLayerColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    [SVProgressHUD showWithStatus:status];
}

+ (void)showErrorWithStatus:(NSString*)status
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setBackgroundLayerColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    [SVProgressHUD showErrorWithStatus:status];
}

+ (void)showSuccessWithStatus:(NSString*)status
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setBackgroundLayerColor:QSColor(0, 0, 0, 0.8)];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion
{
    [SVProgressHUD dismissWithDelay:delay completion:completion];
}

#pragma mark - hidden
/**
 *  隐藏某个视图上的HUD
 *
 *  @param view     目标视图
 *  @param animated 是否带动画
 */
+ (void)hiddenHUDForView:(UIView *)view animated:(BOOL)animated {

    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    [MBProgressHUD hideAllHUDsForView:view animated:animated];
}

/**
 *  隐藏所有HUD
 *
 *  @param view     目标视图
 *  @param animated 是否带动画
 */
+ (void)hiddenAllHUDForView:(UIView *)view animated:(BOOL)animated {
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    [MBProgressHUD hideAllHUDsForView:view animated:animated];
}

+ (BOOL)isShowCommTip
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    NSLog(@"之前时间：%@", [userDefault objectForKey:@"nowDate"]);//之前存储的时间
    //    NSLog(@"现在时间%@",[NSDate date]);//现在的时间
    NSDate *now = [NSDate date];
    NSDate *agoDate = [userDefault objectForKey:@"nowDateForShowCommSuccessTips"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *ageDateString = [dateFormatter stringFromDate:agoDate];
    NSString *nowDateString = [dateFormatter stringFromDate:now];
    
    //    NSLog(@"日期比较：之前：%@ 现在：%@",ageDateString,nowDateString);
    
    if ( [ageDateString isEqualToString:nowDateString]) {
        return NO;
    }else
    {
        return YES;
    }
}

+ (void)probabilityShowTips
{
    
}


+ (NSArray *)arrayWithcommentGuideTips
{
    return @[@"元芳，你怎么看？",@"评论才是真英雄！",@"快来说说你的看法！",@"来，闷声发个帖！"];
}

+ (NSString *)stringWithcommentGuideTips
{
    NSArray *array = [self arrayWithcommentGuideTips];
    int randomNum = arc4random_uniform((int)array.count);
    NSString *string = array[randomNum];
    return string;
}

#pragma mark - 新HUD弹窗

/**
 *  Loading
 *
 *  @param text       需要显示的文字
 *  @param targetView 要显示到哪里
 */
+ (void)showLoadingMessage:(NSString *)msg view:(UIView *)targetView
{
    if (!targetView) {
        targetView = [UIApplication sharedApplication].keyWindow;
    }
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    hud.color = [UIColor clearColor];
    hud.userInteractionEnabled = NO;
    hud.labelText = msg;
    [targetView addSubview:hud];
    [hud show:YES];
}

/**
 *  网络错误HUD
 *
 *  @param targetView 目标视图(HUD承载视图) 如果为nil，则代表Window
 *
 */
+ (void)showNetworkError:(UIView *_Nullable)targetView {
    if (!targetView) {
        targetView = [UIApplication sharedApplication].keyWindow;
    }
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *error_hud = [[MBProgressHUD alloc] initWithView:targetView];
    error_hud.mode = MBProgressHUDModeCustomView;
    error_hud.color = [UIColor clearColor];
    [targetView addSubview:error_hud];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = QSColorFromRGB(0xFFFFFF);
    contentView.frame = CGRectMake((error_hud.width - kIPadSuitFloat(172)) * 0.5, (error_hud.height - kIPadSuitFloat(100)) * 0.5, kIPadSuitFloat(172), kIPadSuitFloat(100));
    contentView.backgroundColor = QSColorFromRGB(0xFFFFFF);
    contentView.layer.cornerRadius = kIPadSuitFloat(12);
    contentView.layer.shadowColor = QSColor(0, 0, 0, 0.5).CGColor;
    contentView.layer.shadowOffset = CGSizeMake(0, 0);
    contentView.layer.shadowRadius = 7.0f;
    contentView.layer.shadowOpacity = 0.5;
    
    UIImageView *imageView = ({
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"network_tip"]];
        CGFloat y = (contentView.height - (kIPadSuitFloat(50) + kIPadSuitFloat(9) + [UIFont systemFontOfSize:kIPadSuitFloat(14)].lineHeight)) * 0.5;
        imageView.frame = CGRectMake((contentView.width - kIPadSuitFloat(50)) * 0.5, y, kIPadSuitFloat(50), kIPadSuitFloat(50));
        imageView;
    });
    [contentView addSubview:imageView];
    
    UILabel *msgLabel = ({
        msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(kIPadSuitFloat(10),CGRectGetMaxY(imageView.frame) + kIPadSuitFloat(9), contentView.width - 2 * kIPadSuitFloat(10), [UIFont systemFontOfSize:kIPadSuitFloat(14)].lineHeight)];
        msgLabel.text = @"当前网络不给力";
        msgLabel.textColor = QSColorFromRGB(0x4A4A4A);
        msgLabel.font = [UIFont systemFontOfSize:kIPadSuitFloat(14)];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel;
    });
    [contentView addSubview:msgLabel];
    error_hud.customView = contentView;
    
    [error_hud show:YES];
    
    // 2秒后隐藏HUD
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:targetView animated:YES];
    });
}

/**
 *  完成HUD
 *
 *  @param massage 文本消息
 *  @param targetView 目标视图(HUD承载视图) 如果为nil，则代表Window
 *
 */
+ (void)showCompleteMassage:(NSString *_Nullable)massage toView:(UIView *_Nullable)targetView {
    if (!targetView) {
        targetView = [UIApplication sharedApplication].keyWindow;
    }
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *HUDView = [[MBProgressHUD alloc] initWithView:targetView];
    HUDView.mode = MBProgressHUDModeCustomView;
    HUDView.color = [UIColor clearColor];
    [targetView addSubview:HUDView];
    
    UIImage *image = [UIImage imageNamed:@"succed_tip"];
    UIView *contentView = [self contentViewAtHUD:HUDView.size image:image msg:massage];

    HUDView.customView = contentView;
    
    [HUDView show:YES];
    
    // 2秒后隐藏HUD
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:targetView animated:YES];
    });
}

/**
 *  异常HUD
 *
 *  @param massage 文本消息
 *  @param targetView 目标视图(HUD承载视图) 如果为nil，则代表Window
 *
 */
+ (void)showWarnMassage:(NSString *_Nullable)massage toView:(UIView *_Nullable)targetView {
    if (!targetView) {
        targetView = [UIApplication sharedApplication].keyWindow;
    }
    
    [self hiddenAllHUDForView:targetView animated:NO];
    
    MBProgressHUD *HUDView = [[MBProgressHUD alloc] initWithView:targetView];
    HUDView.mode = MBProgressHUDModeCustomView;
    HUDView.color = [UIColor clearColor];
    [targetView addSubview:HUDView];
    
    UIImage *image = [UIImage imageNamed:@"warning_tip"];
    UIView *contentView = [self contentViewAtHUD:HUDView.size image:image msg:massage];
    
    HUDView.customView = contentView;
    [HUDView show:YES];
    
    // 2秒后隐藏HUD
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:targetView animated:YES];
    });
}

/// 创建和布局弹窗内容视图
+ (UIView *)contentViewAtHUD:(CGSize)size image:(UIImage *)image msg:(NSString *)message
{
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = QSColorFromRGB(0xFFFFFF);
    contentView.frame = CGRectMake((size.width - kIPadSuitFloat(172)) * 0.5, (size.height - kIPadSuitFloat(100)) * 0.5, kIPadSuitFloat(172), kIPadSuitFloat(100));
    contentView.backgroundColor = QSColorFromRGB(0xFFFFFF);
    contentView.layer.cornerRadius = kIPadSuitFloat(12);
    contentView.layer.shadowColor = QSColor(0, 0, 0, 0.5).CGColor;
    contentView.layer.shadowOffset = CGSizeMake(0, 0);
    contentView.layer.shadowRadius = 7.0f;
    contentView.layer.shadowOpacity = 0.5;
    
    UIView *customView = [[UIView alloc] init];
    [contentView addSubview:customView];
    customView.x = kIPadSuitFloat(15);
    customView.width = contentView.width - 2 * customView.x;
    
    UIImageView *imageView;
    if(image) {
        imageView = ({
            imageView = [[UIImageView alloc] initWithImage:image];
            CGFloat y = kIPadSuitFloat(10);
            imageView.frame = CGRectMake((customView.width - kIPadSuitFloat(image.size.width)) * 0.5, y, kIPadSuitFloat(image.size.width), kIPadSuitFloat(image.size.height));
            imageView;
        });
        [customView addSubview:imageView];
    }
    
    UILabel *msgLabel = ({
        msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(imageView.frame) + kIPadSuitFloat(9), customView.width, [UIFont systemFontOfSize:kIPadSuitFloat(14)].lineHeight)];
        msgLabel.numberOfLines = 0;
        msgLabel.text = message;
        
        msgLabel.height = [msgLabel sizeThatFits:CGSizeMake(msgLabel.width, CGFLOAT_MAX)].height;
        msgLabel.textColor = QSColorFromRGB(0x4A4A4A);
        msgLabel.font = [UIFont systemFontOfSize:kIPadSuitFloat(14)];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel;
    });
    [customView addSubview:msgLabel];
    
    CGFloat x = customView.x;
    CGFloat w = customView.width;
    CGFloat h = CGRectGetMaxY(msgLabel.frame) + kIPadSuitFloat(10);
    CGFloat y = (contentView.height <= h) ? 0 : (contentView.height - h) * 0.5;
    customView.frame = CGRectMake(x, y, w, h);
    
    
    if(contentView.height <= customView.height) {
        contentView.height = customView.height;
        contentView.y = (size.height - contentView.height) * 0.5;
    }
    
    return contentView;
}
@end

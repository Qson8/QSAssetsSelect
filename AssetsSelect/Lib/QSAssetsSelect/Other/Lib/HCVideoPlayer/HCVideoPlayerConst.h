//
//  HCVideoPlayerConst.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCPlayerView.h"
#import "UIImage+VP.h"
#import "NSString+VP.h"
#import "HCWeakTimer.h"
#import "HCTVDeviceItem.h"
#import "HCShareItem.h"
#import "HCNetWorkSpeed.h"
#import "HCVerButton.h"


#ifdef DEBUG // 调试状态, 打开LOG功能
#define VPLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define VPLog(...)
#endif

UIKIT_EXTERN NSString *const NotificationVideoPlayerWillZoomOut;
UIKIT_EXTERN NSString *const NotificationVideoPlayerDidZoomOut;
UIKIT_EXTERN NSString *const NotificationVideoPlayerWillZoomIn;
UIKIT_EXTERN NSString *const NotificationVideoPlayerDidZoomIn;

UIKIT_EXTERN NSString *const ShareListKeyLinkShare;
UIKIT_EXTERN NSString *const ShareListKeyImageShare;


#define kVP_AniDuration 0.333333
#define kVP_rotaionAniDuration 0.333333

#define kVP_IS_IPHONE_X (fabs((double)MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) - (double)812)<DBL_EPSILON)

#define kVP_StatusBarHeight CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define kVP_iPhoneXSafeBottomHeight (kVP_IS_IPHONE_X ? 34 : 0)
#define kVP_iPhoneXSafeTopHeight (kVP_IS_IPHONE_X ? kVP_StatusBarHeight : 0)
#define kVP_NavigationBarHeight (kVP_StatusBarHeight + 44)

#define kVP_ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kVP_ScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define kVP_Color(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kVP_TextBlackColor kVP_Color(51, 51, 51, 1)
#define kVP_TextGrayColor kVP_Color(102, 102, 102, 1)
#define kVP_BgColor kVP_Color(248, 248, 248, 1);
#define kVP_LineColor kVP_Color(223, 223, 223, 1);

#define kVP_isIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kVP_isIphone4  (kVP_isIphone && kVP_ScreenHeight == 480.0)

#define kVP_IOS9 ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0)
#define kVP_IOS8 ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)



//
//  HCGoogleCastTool.m
//  HCVideoPlayer
//
//  Created by chc on 2018/6/7.
//  Copyright © 2018年 Yu Wang. All rights reserved.
//

#import "HCGoogleCastTool.h"
#import "HCVideoPlayerConst.h"

//static GCKUIMediaController *g_castMediaController;
//static NSString *g_castUrl;
//static NSString *g_castApplicationId;
//static __weak id <GCKLoggerDelegate> g_castDelegate;
//static __weak id <GCKSessionManagerListener> g_listener;
@implementation HCGoogleCastTool

#pragma mark - 外部方法
//+ (void)configApplicationID:(NSString *)applicationID delegate:(id <GCKLoggerDelegate>)delegate
//{
//    g_castApplicationId = applicationID;
//    g_castDelegate = delegate;
//}
//
//+ (void)initCast
//{
//    [self initCastWithApplicationID:g_castApplicationId delegate:g_castDelegate];
//}
//
//+ (GCKUIMediaController *)castMediaController
//{
//    return g_castMediaController;
//}
//
//+ (BOOL)isCastingWithUrl:(NSString *)url
//{
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return NO;
//    }
//
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return NO;
//    }
//
//    return ((g_castMediaController.lastKnownPlayerState != GCKMediaPlayerStateIdle && g_castMediaController.lastKnownPlayerState != GCKMediaPlayerStateUnknown) && [g_castUrl isEqualToString:url]);
//}
//
//+ (void)clearCastUrl
//{
//    g_castUrl = nil;
//}
//
//+ (void)addSessionManagerListener:(id <GCKSessionManagerListener>)listener
//{
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return ;
//    }
//
//    g_listener = listener;
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return;
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[GCKCastContext sharedInstance].sessionManager addListener:listener];
//    });
//}
//
//+ (void)startRemotePlaybackWithStreamType:(GCKMediaStreamType)streamType title:(NSString *)title description:(NSString *)description studio:(NSString *)studio photo:(NSString *)photo urlStr:(NSString *)urlStr {
//
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return ;
//    }
//
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return;
//    }
//
//    if (!urlStr.length) {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        GCKCastSession *currentCastSession = [GCKCastContext sharedInstance].sessionManager.currentCastSession;
//
//        GCKMediaQueueItemBuilder *builder = [[GCKMediaQueueItemBuilder alloc] init];
//        builder.mediaInformation = [self buildMediaInformationWithStreamType:streamType title:title description:description studio:studio photo:photo urlStr:urlStr];
//        builder.autoplay = YES;
//        builder.preloadTime = 60;
//        GCKMediaQueueItem *item = [builder build];
//        [currentCastSession.remoteMediaClient queueLoadItems:@[item]
//                                                  startIndex:0
//                                                playPosition:0
//                                                  repeatMode:GCKMediaRepeatModeOff
//                                                  customData:nil];
//        g_castUrl = urlStr;
//    });
//}
//
//+ (GCKMediaInformation *)buildMediaInformationWithStreamType:(GCKMediaStreamType)streamType title:(NSString *)title description:(NSString *)description studio:(NSString *)studio photo:(NSString *)photo urlStr:(NSString *)urlStr {
//
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return nil;
//    }
//
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return nil;
//    }
//
//    if (!urlStr.length) {
//        return nil;
//    }
//
//    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] initWithMetadataType:GCKMediaMetadataTypeMovie];
//    [metadata setString:(title ? title : @"") forKey:kGCKMetadataKeyTitle];
//    [metadata setString:(description ? description : @"") forKey:@"description"];
//    [metadata setString:(studio ? studio : @"") forKey:kGCKMetadataKeyStudio];
//
//    photo = (photo ? photo : @"");
//    NSURL *photoUrl = [NSURL URLWithString:photo];
//    [metadata addImage:[[GCKImage alloc] initWithURL:photoUrl
//                                               width:480
//                                              height:720]];
//    [metadata setString:photo forKey:@"posterUrl"];
//    [metadata addImage:[[GCKImage alloc] initWithURL:photoUrl
//                                               width:1200
//                                              height:780]];
//
//    GCKMediaInformation *mediaInfo = [[GCKMediaInformation alloc]
//                                      initWithContentID:(urlStr ? urlStr : @"")
//                                      streamType:streamType
//                                      contentType:@"application/vnd.apple.mpegURL"
//                                      metadata:metadata
//                                      streamDuration:333
//                                      mediaTracks:nil
//                                      textTrackStyle:nil
//                                      customData:nil];
//    return mediaInfo;
//}
//
//+ (void)playRemotelyWithStreamType:(GCKMediaStreamType)streamType title:(NSString *)title description:(NSString *)description studio:(NSString *)studio photo:(NSString *)photo urlStr:(NSString *)urlStr {
//
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return ;
//    }
//
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return ;
//    }
//
//    if (!urlStr.length) {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        GCKCastSession *castSession = [GCKCastContext sharedInstance].sessionManager.currentCastSession;
//        if (castSession) {
//            GCKMediaLoadOptions *loadOptions = [[GCKMediaLoadOptions alloc] init];
//            GCKMediaInformation *mediaInformation = [self buildMediaInformationWithStreamType:streamType title:title description:description studio:studio photo:photo urlStr:urlStr];
//            [castSession.remoteMediaClient loadMedia:mediaInformation withOptions:loadOptions];
//        }
//        [[GCKCastContext sharedInstance] presentDefaultExpandedMediaControls];
//    });
//}
//
//+ (GCKUICastContainerViewController *)createCastContainerControllerForViewController:(UIViewController *)viewController
//{
//    if (!kVP_IOS9) { // iOS9以上才兼容
//        return nil;
//    }
//
//    // 判断单例是否初始化
//    if (![GCKCastContext isSharedInstanceInitialized]) {
//        return nil;
//    }
//
//    GCKUICastContainerViewController *castContainerVC = [[GCKCastContext sharedInstance] createCastContainerControllerForViewController:viewController];
//    castContainerVC.miniMediaControlsItemEnabled = YES;
//    return castContainerVC;
//}
//
//#pragma mark - 内部方法
///**
// 初始化投屏
//
// @param applicationID 投屏的应用ID
// @param delegate 日志代理
// */
//+ (void)initCastWithApplicationID:(NSString *)applicationID delegate:(id <GCKLoggerDelegate>)delegate
//{
//    // ios9以下不兼容
//    if (!kVP_IOS9) {
//        return;
//    }
//
//    // 判断单例是否初始化，已初始化则不用再次初始化
//    if ([GCKCastContext isSharedInstanceInitialized]) {
//        return ;
//    }
//
//    if (!applicationID.length) {
//        VPLog(@"谷歌投屏初始化失败，没有配置应用ID");
//        return;
//    }
//
//    g_castApplicationId = applicationID;
//    g_castDelegate = delegate;
//
//    GCKDiscoveryCriteria *discoveryCriteria = [[GCKDiscoveryCriteria alloc] initWithApplicationID:applicationID];
//    GCKCastOptions *options = [[GCKCastOptions alloc] initWithDiscoveryCriteria:discoveryCriteria];
//    [GCKCastContext setSharedInstanceWithOptions:options];
//
//    //
//    g_castMediaController = [[GCKUIMediaController alloc] init];
//
//    // 设置初始化之前设置的监听者
//    if (g_listener) {
//        [self addSessionManagerListener:g_listener];
//    }
//
//    //
//    if (!delegate) {
//        return;
//    }
//
//    GCKLoggerFilter *logFilter = [[GCKLoggerFilter alloc] init];
//    [logFilter setLoggingLevel:GCKLoggerLevelVerbose
//                    forClasses:@[
//                                 @"GCKDeviceScanner",
//                                 @"GCKDeviceProvider",
//                                 @"GCKDiscoveryManager",
//                                 @"GCKCastChannel",
//                                 @"GCKMediaControlChannel",
//                                 @"GCKUICastButton",
//                                 @"GCKUIMediaController",
//                                 @"NSMutableDictionary"
//                                 ]];
//    [GCKLogger sharedInstance].filter = logFilter;
//    [[GCKLogger sharedInstance] setDelegate:delegate];
//}
@end

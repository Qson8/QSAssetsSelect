//
//  MediaItem.h
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/7.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 闪光灯 */
#define kCurrentStateOfFlashKey @"CurrentStateOfFlash"

/** 发布界面显示 */
#define kMargin12 kIPadSuitFloat(12)
#define kMargin20 kIPadSuitFloat(20)
#define kPadding10 (kIsIpad ? kIPadSuitFloat(20) : kIPadSuitFloat(10))
#define kPicsViewWidth (ScreenWidth - kMargin12 * 2)
#define kPicWidth ((kPicsViewWidth - 2 * kMargin20 - (kIsIpad ? 4 : 3) * kPadding10) / (kIsIpad ? 5.0 : 4.0))
#define kPicsViewHeight(picsCount) kIsIpad ? (2 * (kMargin20 + kPicWidth) + kPadding10) : (picsCount > 8 ? (2 * (kMargin20 + kPadding10) + 3 * kPicWidth) : (2 * (kMargin20 + kPicWidth) + kPadding10))
#define kIconFont [UIFont systemFontOfSize:kIPadSuitFloat(13)]

/** 相机 */
#define kMargin4    kIPadSuitFloat(4)
#define kMargin24   kIPadSuitFloat(24)
#define kMargin32   kIPadSuitFloat(32)
#define kMargin40   kIPadSuitFloat(40)
#define kMargin52   kIPadSuitFloat(52) // 内圈
#define kMargin60   kIPadSuitFloat(60) // 中圈
#define kMargin68   kIPadSuitFloat(68) // 外圈
#define kMargin167  kIPadSuitFloat(167)
#define kFont12 [UIFont systemFontOfSize:kIPadSuitFloat(12)]

typedef NS_ENUM(NSInteger, MediaItemType) {
    kMediaItemTypeImage,        // 0 图片
    kMediaItemTypeVideo,        // 1 视频
    kMediaItemTypeAddAsset,     // 2 添加按钮
};

typedef NS_ENUM(NSInteger, MediaUpdataState) {
    MediaUpdataStateNotUpdata,          // 0 未上传
    MediaUpdataStateUploading,          // 上传中...
    MediaUpdataStateUpdataSucced,       // 上传成功
    MediaUpdataStateUpdataFailure,      // 上传失败
    MediaUpdataStateNothing,            // 不需要上传
};

@interface MediaItem : NSObject
/** 数据层 */
@property (nonatomic, assign) MediaItemType mediaType;
@property (nonatomic, assign) MediaUpdataState UpdataState;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *mediaUrl;             // 网络地址
@property (nonatomic, strong) NSURL *fileUrl;               // 文件路径
@property (nonatomic, copy) NSString *placeholder;          // 占位图文件名

@property (nonatomic, copy) NSString *value;                // 结果
@property (nonatomic, copy) NSString *videopic;             // 视频封面

/** UI层 */
@property (nonatomic, assign) BOOL uploadOK;                // 上传成功
@property (nonatomic, strong) void(^removeItemBlock)(MediaItem *item);
@property (nonatomic, strong) void(^touchClickBlock)(MediaItem *item);

/** 类方法 */
+ (instancetype)itemWithPhoto:(UIImage *)photo;
+ (NSArray<MediaItem *> *)itemsWithPhotos:(NSArray<UIImage *> *)photos;
@end

//
//  MediaSelectCell.h
//  IJSPhotoSDKProject
//
//  Created by Qson on 2017/12/8.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+Extension.h"
#import "HCFormRowItem.h"
#import "IJSVideoManager.h"
#import "MediaImageCell.h"

@class MediaItem,MediaSelectCell;


@protocol MediaSelectDelegate <NSObject>
- (void)didSelectMediaCell:(MediaSelectCell *)cell;
@end


@interface MediaSelectCell : UITableViewCell
@property (nonatomic, weak) id <MediaSelectDelegate>delegate;
@property (nonatomic, copy) NSString *catId;
@property (nonatomic, assign) BOOL showAddBtn;
@property (nonatomic, assign) BOOL showBigAddBtn;
@property (nonatomic, assign) BOOL allowPickingVideo;
@property (nonatomic, assign) BOOL allowHybridAssets; // 支持图片和视频同时存在，No表示要不只能发视频，要么是能图片
@property (nonatomic, assign) NSInteger limitAssetCount;
@property (nonatomic, assign) NSInteger videoMaxTime; //< 允许上传视频最大时长 默认10s

@property (nonatomic, strong) HCFormRowItem *rowItem;
@property (nonatomic, weak) UIViewController *pushViewController;

/// 图片视图数组
@property (nonatomic, strong) NSArray *imageViews;
/// image数组
@property (nonatomic, strong, readonly) NSMutableArray *imageArray;

/** 添加按钮的frame */
@property (nonatomic, assign,readonly) CGPoint addCenterPoint;
+ (instancetype)cellWithTableView:(UITableView *)tabelView;
- (void)setOriginalVideo:(NSString *)videoUrl videoPic:(NSString *)videoPic;
- (void)getVideoComplete:(void(^)(NSString *videoStr,NSString *videopic,BOOL uploading,BOOL failure, BOOL NotUpdata))completeHandle;
- (void)getPhotosComplete:(void(^)(NSArray *origPhotos,NSArray *succePhotos,NSInteger numberOffailure,NSInteger numberOfuploading,NSInteger numberOfNotUpdata))completeHandle;

- (void)addPicIconClicked;
@end


#pragma mark - MediaSelectCell (Draft)
/*! @brief MediaSelectCell (Draft)
 *
 * 处理草稿相关逻辑
 */
@interface MediaSelectCell (Draft)
/** 设置草稿信息 */
- (void)setupDraftPhoto:(NSArray *)photos completeBack:(void(^)(void))completeBack;
- (void)saveStorageMedia:(MediaItem *)item;

/** 移除缓存视频相关信息 */
- (void)removeStorageVideo;
/** 移除图片文件夹 */
- (void)removeStorageAllPhoto;
/** 移除存储图片 */
- (void)removeStoragePhoto:(NSString *)photo;
@end


//
//  MediaCameraController.h
//  SydneyToday
//
//  Created by Qson on 2017/12/12.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MediaTakeOperationSureBlock)(id item);
@interface MediaCameraController : UIViewController

@property (copy, nonatomic) MediaTakeOperationSureBlock takeBlock;
@property (nonatomic, assign) CGFloat limitMaxSeconds;

/*默认为YES，如果设置为NO,用户将不能选择视频 */
@property (nonatomic, assign) BOOL allowPickingVideo;

/* 默认最大可选9张图片 */
@property (nonatomic, assign) NSInteger maxImagesCount;
/* 视频最大时长 */
@property (nonatomic, assign) CGFloat maxTime;
/** 拍照提示文本 默认：a.视频+照片下 "轻触拍照  按住摄影" b.照片下 "轻触拍照"*/
@property (nonatomic, copy) NSString *cameraTip;
@end

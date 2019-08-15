//
//  MediaUploadView.h
//  14.文件上传
//
//  Created by Qson on 2018/1/6.
//  Copyright © 2018年 康生 邱. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MediaType) {
    kMediaTypeImage,        // 0 图片
    kMediaTypeVideo,        // 1 视频
    kMediaTypeFile,     // 2 文件
};

@interface MediaUploadView : UIView
@property (nonatomic, strong) UIColor *rampColor;
/** 进度 */
@property (nonatomic, assign) CGFloat progress;
/** 文件类型 */
@property (nonatomic, assign) MediaType fileType;

- (void)startUpdating;
- (void)finishUpdating;
- (void)updataFailure;
@end

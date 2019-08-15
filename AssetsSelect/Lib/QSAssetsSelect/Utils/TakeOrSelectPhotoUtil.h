//
//  TakeOrSelectPhotoUtil.h
//  NetPhone
//
//  Created by common on 13-10-11.
//  Copyright (c) 2013年 青牛软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kImagePickerModePhoto = 0,
    kImagePickerModeVideo
}ImagePickerMode;

@protocol TakeOrSelectPhotoUtilDelegate <NSObject>

@optional
- (void)didFinishTakeOrSelectPhoto:(NSDictionary *)photoInfo;

@end

@interface TakeOrSelectPhotoUtil : NSObject <UINavigationControllerDelegate ,UIImagePickerControllerDelegate>

+ (TakeOrSelectPhotoUtil *)sharedInstanse;

+ (void)release;


/**
 *  拍照
 */
- (void)takePhotoFromViewController:(UIViewController *)viewController ImagePickerMode:(ImagePickerMode)mode AllowsEditing:(BOOL)allowsEditing viewDelegate:(UIView *)viewDelegate;

/**
 *  选择一张图片文件
 */
- (void)selectPhotoFromViewController:(UIViewController *)viewController AllowsEditing:(BOOL)allowsEditing viewDelegate:(UIView *)viewDelegate;

@end

//
//  TakeOrSelectPhotoUtil.m
//  NetPhone
//
//  Created by common on 13-10-11.
//  Copyright (c) 2013年 青牛软件. All rights reserved.
//

#define isIOS7  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)

#import "TakeOrSelectPhotoUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+PureColorImage.h"
#import "SVProgressHUD.h"

static TakeOrSelectPhotoUtil *_instanse;

@interface TakeOrSelectPhotoUtil ()

@property (nonatomic, weak) UIViewController *mViewController;
@property (nonatomic, weak) UIView *viewDelgate;
@end

@implementation TakeOrSelectPhotoUtil
@synthesize mViewController;

+ (TakeOrSelectPhotoUtil *)sharedInstanse
{
    if (!_instanse) {
        _instanse = [[TakeOrSelectPhotoUtil alloc] init];
    }
    return _instanse;
}

+ (void)release
{
    
}


/**
 *  拍照或者摄像
 */
- (void)takePhotoFromViewController:(UIViewController *)viewController ImagePickerMode:(ImagePickerMode)mode AllowsEditing:(BOOL)allowsEditing viewDelegate:(UIView *)viewDelegate;
{
    if(isIOS7)
    {
        //拍照仅仅涉及相机权限
        if (mode == kImagePickerModePhoto) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL videoGranted) {
                if (videoGranted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self commonTakePhotoFromViewController:viewController ImagePickerMode:mode AllowsEditing:allowsEditing viewDelegate:(UIView *)viewDelegate];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                    [AlertUtil showAlertWithText:@"可视没有访问相机的权限，无法进行拍照。请在设置->隐私->相机权限中开启访问权限。"];
                    [SVProgressHUD showInfoWithStatus:@"可视没有访问相机的权限，无法进行拍照。请在设置->隐私->相机权限中开启访问权限。"];
                        });
                }
            }];
        }
        //摄像涉及的权限
        else
        {
        //相机权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL videoGranted) {
            if (videoGranted) {
                //麦克风权限
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL audioGranted) {
                    if (audioGranted) {
                        //相片权限
                        ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc] init];
                         __block BOOL isStop=NO;
                        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                        if (!isStop) {
                                if (*stop) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [AlertUtil showAlertWithText:@"可视没有访问照片的权限，无法进行拍摄。请在设置->隐私->照片权限中开启访问权限。"];
                                         [SVProgressHUD showInfoWithStatus:@"可视没有访问照片的权限，无法进行拍摄。请在设置->隐私->照片权限中开启访问权限。"];
                                    });
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self commonTakePhotoFromViewController:viewController ImagePickerMode:mode AllowsEditing:allowsEditing viewDelegate:(UIView *)viewDelegate];
                                    });
                                    isStop=YES;
                                }
                            }
                        } failureBlock:^(NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [AlertUtil showAlertWithText:@"可视没有访问照片的权限，无法进行拍摄。请在设置->隐私->照片权限中开启访问权限。"];
                                [SVProgressHUD showInfoWithStatus:@"可视没有访问照片的权限，无法进行拍摄。请在设置->隐私->照片权限中开启访问权限。"];
                            });
                        }];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [AlertUtil showAlertWithText:@"可视没有访问麦克风的权限，无法进行拍摄。请在设置->隐私->麦克风权限中开启访问权限。"];
                            [SVProgressHUD showInfoWithStatus:@"可视没有访问麦克风的权限，无法进行拍摄。请在设置->隐私->麦克风权限中开启访问权限。"];
                        });
                    }
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[AlertUtil showAlertWithText:@"请在隐私设置中开启可视的拍照权限"];
//                    [AlertUtil showAlertWithText:@"可视没有访问相机的权限，无法进行拍照。请在设置->隐私->相机权限中开启访问权限。"];
                    [SVProgressHUD showInfoWithStatus:@"可视没有访问相机的权限，无法进行拍照。请在设置->隐私->相机权限中开启访问权限。"];
                });
            }
        }];
        }
    }
    else
    {
        //7以下拍摄涉及相片权限
        if (mode == kImagePickerModeVideo) {
            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc] init];
            __block BOOL isStop=NO;
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!isStop) {
                if (*stop) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                            [AlertUtil showAlertWithText:@"请在隐私设置中开启可视的照片权限"];
                        [SVProgressHUD showInfoWithStatus:@"请在隐私设置中开启可视的照片权限"];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"commonTakePhotoFromViewController ImagePickerMode ");
                        [self commonTakePhotoFromViewController:viewController ImagePickerMode:mode AllowsEditing:allowsEditing viewDelegate:(UIView *)viewDelegate];
                        });
                    isStop=YES;
                }
            }
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                [AlertUtil showAlertWithText:@"请在隐私设置中开启可视的照片权限"];
                    [SVProgressHUD showInfoWithStatus:@"请在隐私设置中开启可视的照片权限"];
                });
            }];
        }
        else
        {
            [self commonTakePhotoFromViewController:viewController ImagePickerMode:mode AllowsEditing:allowsEditing viewDelegate:(UIView *)viewDelegate];
        }
    }
}


- (void)commonTakePhotoFromViewController:(UIViewController *)viewController ImagePickerMode:(ImagePickerMode)mode AllowsEditing:(BOOL)allowsEditing viewDelegate:(UIView *)viewDelegate
{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.mViewController = viewController;
            self.viewDelgate = viewDelegate;
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.allowsEditing = allowsEditing;
            imagePickerController.delegate = self;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            imagePickerController.navigationBar.translucent = NO;
            
            NSString *requiredMediaType = (NSString *)kUTTypeImage;
            if (mode == kImagePickerModeVideo) {
                requiredMediaType = (NSString *)kUTTypeMovie;
                NSLog(@"你选择了拍摄视频");
                // 设置录制视频的质量
                [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeMedium];
                //设置最长摄像时间
                [imagePickerController setVideoMaximumDuration:30.f];
            }
            NSArray *arrMediaTypes = [NSArray arrayWithObjects:requiredMediaType, nil];
            [imagePickerController setMediaTypes:arrMediaTypes];
            
            imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            imagePickerController.showsCameraControls = YES;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
            
        } else {
//            [AlertUtil showAlertWithText:@"设备不支持拍照功能"];
            [SVProgressHUD showInfoWithStatus:@"设备不支持拍照功能"];
        }
}

/**
 *  选择一张图片文件
 */
- (void)selectPhotoFromViewController:(UIViewController *)viewController AllowsEditing:(BOOL)allowsEditing viewDelegate:(UIView *)viewDelegate
{
    self.mViewController = viewController;
    self.viewDelgate = viewDelegate;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = allowsEditing;
    imagePickerController.delegate = self;
    imagePickerController.navigationBar.translucent = NO;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [imagePickerController.navigationBar setTintColor:[UIColor whiteColor]];
    [imagePickerController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [imagePickerController.navigationBar setBackgroundImage:[UIImage imageWithPureColor:[UIColor redColor]] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.mViewController) {
        [self.mViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (self.viewDelgate && [self.viewDelgate respondsToSelector:@selector(didFinishTakeOrSelectPhoto:)]) {
        [self.viewDelgate performSelector:@selector(didFinishTakeOrSelectPhoto:) withObject:info];
    }
    else if (self.mViewController && [self.mViewController respondsToSelector:@selector(didFinishTakeOrSelectPhoto:)]) {
        [self.mViewController performSelector:@selector(didFinishTakeOrSelectPhoto:) withObject:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.mViewController) {
        
        [self.mViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)resetViewFrame
{
    if (isIOS7) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect frame = self.mViewController.navigationController.view.frame;
            NSLog(@"%f;%f;%f;%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            
            CGFloat statusBarHeight = [[UIApplication sharedApplication] isStatusBarHidden] ? 0.0f : 20.0f;
            UINavigationBar *navBar = self.mViewController.navigationController.navigationBar;
            [navBar setFrame:CGRectMake(0, 0, navBar.frame.size.width, navBar.frame.size.height + statusBarHeight)];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [self.mViewController.view setBounds:CGRectMake(0, statusBarHeight * -1, self.mViewController.view.bounds.size.width, self.mViewController.view.bounds.size.height)];
        }];
    }
}

#pragma mark - UINavigationControllerDelegate
/// 处理iOS11开始 PUPhotoPickerHostViewController 屏幕左边出现竖条（各设备宽度不一 参考:https://blog.csdn.net/gzgengzhen/article/details/80320518）
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 11)
    {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")])
    {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             // iOS 11之后，图片编辑界面最上层会出现一个宽度<42的view，会遮盖住左下方的cancel按钮，使cancel按钮很难被点击到，故改变该view的层级结构
             if (obj.frame.size.width < 42)
             {
                 [viewController.view sendSubviewToBack:obj];
                 *stop = YES;
             }
         }];
    }
}

@end

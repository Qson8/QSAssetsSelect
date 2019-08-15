//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  MLNavigationViewController.m
//  MLSelectPhoto
//
//  Created by 张磊 on 15/4/22.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
#define DefaultNavbarTintColor UIColorFromRGB(0x2f3535)
#define DefaultNavTintColor UIColorFromRGB(0xd5d5d5)
#define DefaultNavTitleColor UIColorFromRGB(0xd5d5d5)

#import "MLSelectPhotoNavigationViewController.h"
#import "MLSelectPhotoCommon.h"

@interface MLSelectPhotoNavigationViewController ()

@end

@implementation MLSelectPhotoNavigationViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    UINavigationController *rootVc = (UINavigationController *)[[UIApplication sharedApplication].keyWindow rootViewController];
    
    if ([rootVc isKindOfClass:[UINavigationController class]]) {
        [self.navigationBar setValue:[rootVc.navigationBar valueForKeyPath:@"barTintColor"] forKeyPath:@"barTintColor"];
        [self.navigationBar setTintColor:rootVc.navigationBar.tintColor];
        [self.navigationBar setTitleTextAttributes:rootVc.navigationBar.titleTextAttributes];
        
    }else{
        [self.navigationBar setValue:DefaultNavbarTintColor forKeyPath:@"barTintColor"];
        [self.navigationBar setTintColor:DefaultNavTintColor];
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:DefaultNavTitleColor}];
    }
}
@end

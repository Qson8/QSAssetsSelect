//
//  MediaPhotoBrowserController.m
//  SydneyToday
//
//  Created by Qson on 2018/11/2.
//  Copyright © 2018 Yu Wang. All rights reserved.
//

#import "MediaPhotoBrowserController.h"
#import "MWPhotoBrowser.h"

@interface MediaPhotoBrowserController ()
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, weak) UIButton *rightBtn;
@end

@implementation MediaPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.frame = [UIScreen mainScreen].bounds;
    
    [self closeBtn];
    [self rightBtn];
}

- (void)dealloc
{
    CGLog(@"%s",__func__);
}

#pragma mark - 事件
- (void)closeBtnDidClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBtnDidClick
{
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(photoBrowserRightButtonDidClick)]) {
            [self.delegate photoBrowserRightButtonDidClick];
        }
    }];
}

#pragma mark - 外部方法
- (void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    
    NSMutableArray *photosM = [NSMutableArray array];
    for (id image in imageArray) {
        if([image isKindOfClass:[UIImage class]]) {
            UIImage *tempImage = (UIImage *)image;
            MWPhoto *photo = [MWPhoto photoWithImage:tempImage];
            [photosM addObject:photo];
        }
        else if([image isKindOfClass:[NSString class]]) {
            NSURL *imgUrl = (NSURL *)image;
            MWPhoto *photo = [MWPhoto photoWithURL:imgUrl];
            [photosM addObject:photo];
        }
    }

    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photosM];
    browser.displayActionButton = NO;
    browser.alwaysShowControls = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.displayNavArrows = NO;
    browser.startOnGrid = NO;
    browser.enableGrid = YES;
    
    [self.view addSubview:browser.view];
    [self.view sendSubviewToBack:browser.view];
    [self addChildViewController:browser];
}

#pragma mark - 懒加载
- (UIButton *)closeBtn
{
    if(_closeBtn == nil) {
        UIButton *closeBtn = [[UIButton alloc] init];
        UIImage *image = [UIImage imageNamed:@"quxiao_icon_xuanzepingdao"];
        [closeBtn setImage:image forState:(UIControlStateNormal)];
        closeBtn.frame = CGRectMake(0, kStatusBarHeight,50, 44);
        [closeBtn addTarget:self action:@selector(closeBtnDidClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:closeBtn];
        _closeBtn = closeBtn;
    }
    return _closeBtn;
}

- (UIButton *)rightBtn
{
    if(_rightBtn == nil) {
        UIButton *rightBtn = [[UIButton alloc] init];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [rightBtn setTitle:@"重新选择" forState:UIControlStateNormal];
        [rightBtn setTitleColor:QSColorFromRGB(0xFFFFFF) forState:(UIControlStateNormal)];
        [rightBtn sizeToFit];
        rightBtn.frame = CGRectMake(ScreenWidth - 10 - (rightBtn.width + 20), kStatusBarHeight,rightBtn.width + 20, 44);
        [rightBtn addTarget:self action:@selector(rightBtnDidClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:rightBtn];
        _rightBtn = rightBtn;
    }
    return _rightBtn;
}

@end

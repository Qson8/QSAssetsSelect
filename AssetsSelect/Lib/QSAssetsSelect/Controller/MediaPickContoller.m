//
//  MediaPickContoller.m
//  SydneyToday
//
//  Created by Qson on 2017/12/13.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import "MediaPickContoller.h"

@interface MediaPickContoller ()

@end

@implementation MediaPickContoller

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - 初始化
- (void)setupUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
@end

//
//  ViewController.m
//  AssetsSelect
//
//  Created by Qson on 2019/8/10.
//  Copyright © 2019 QSon. All rights reserved.
//

#import "ViewController.h"
#import "MediaSelectCell.h"

@interface ViewController ()
@property (nonatomic, strong) MediaSelectCell *mediaCell;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // !!!: 上传视频
    HCFormRowItem *rowItem = [[HCFormRowItem alloc] init];
    MediaSelectCell *row = [MediaSelectCell cellWithTableView:nil];
    row.showAddBtn = YES;
    row.showBigAddBtn = YES;
    row.videoMaxTime = 15;
    row.rowItem = rowItem;
    row.allowPickingVideo = YES;
    row.pushViewController = self;
    row.width = ScreenWidth;
    row.height = 100;
    row.y = 180;
    _mediaCell = row;
    
    [self.view addSubview:row];
}


@end

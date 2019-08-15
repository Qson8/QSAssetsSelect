//
//  HCQualitySheet.h
//  HCVideoPlayer
//
//  Created by chc on 2017/12/7.
//  Copyright © 2017年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCQualitySheet : UIView
@property (nonatomic, strong) NSArray *allSupportQuality;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIButton *selectBtn;
@end

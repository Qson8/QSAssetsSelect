//
//  HCVerButton.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCShareItem.h"

@interface HCVerButton : UIButton
@property (nonatomic, strong) HCShareItem *shareItem;
@property (copy, nonatomic) void (^operation)(HCShareItem *shareItem);
/** 必须这样设置btn的字体 */
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) CGFloat padding;
- (CGFloat)heightToFitWidth:(CGFloat)width;
- (CGFloat)btnXWithTitleX:(CGFloat)titleX btnWidth:(CGFloat)btnWidth;
@end

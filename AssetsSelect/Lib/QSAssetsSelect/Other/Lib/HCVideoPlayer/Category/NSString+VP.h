//
//  NSString+VP.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (VP)
/** 传入 秒 得到 xx:xx:xx 或 xx:xx*/
+ (instancetype)vp_formateStringFromSec:(CGFloat)sec;

/** 传入 秒 得到 xx:xx:xx */
+ (instancetype)vp_getHHMMSSFromSec:(CGFloat)sec;

/** 传入 秒 得到  xx:xx */
+ (instancetype)vp_getMMSSFromSec:(CGFloat)sec;
@end

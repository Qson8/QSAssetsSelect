//
//  UIView+Tap.h
//  NeiHan
//
//  Created by Charles on 16/4/2.
//  Copyright © 2016年 Com.Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tap)
/**
 *  动态添加手势 
 */
- (void)setTapActionWithBlock:(void (^)(void))block ;
- (void)removeAllSubviews;
- (UIView*)subViewOfClassName:(NSString*)className;
- (UIViewController *)vp_myController;
@end

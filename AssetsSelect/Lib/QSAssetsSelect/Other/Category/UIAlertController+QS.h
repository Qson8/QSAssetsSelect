//
//  UIAlertController+QS.h
//  SydneyToday
//
//  Created by Qson on 16/12/15.
//  Copyright © 2016年 Yu Wang. All rights reserved.
//

@interface UIAlertController (QS)


+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)msg preferredStyle:(UIAlertControllerStyle)preferredStyle cancel:(NSString *)cancel done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))handler;


+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)msg preferredStyle:(UIAlertControllerStyle)preferredStyle cancel:(NSString *)cancel cancelHandler:(void (^)(UIAlertAction *action))cancelHandler done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))doneHandler;
@end

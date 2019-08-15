//
//  UIAlertController+QS.m
//  SydneyToday
//
//  Created by Qson on 16/12/15.
//  Copyright © 2016年 Yu Wang. All rights reserved.
//

#import "UIAlertController+QS.h"

@implementation UIAlertController (QS)

/**
 *  2个按钮(取消\完成)封装的UIAlertController
 *
 *  @param title          弹框标题
 *  @param msg            弹框消息
 *  @param preferredStyle 弹框样式
 *  @param cancel         取消按钮的标题
 *  @param done           完成按钮的标题
 *  @param handler        完成按钮的回调事件
 *
 *  @return 返回UIAlertController对象
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)msg preferredStyle:(UIAlertControllerStyle)preferredStyle cancel:(NSString *)cancel done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))handler {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:preferredStyle];
    if (cancel.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleDefault handler:nil];
        [alertVc addAction:cancelAction];
    }
    if (done.length) {
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:done style:UIAlertActionStyleDefault handler:handler];
        
        [alertVc addAction:doneAction];
        if(IOS9)
            [alertVc setPreferredAction:doneAction];
    }
    return alertVc;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)msg preferredStyle:(UIAlertControllerStyle)preferredStyle cancel:(NSString *)cancel cancelHandler:(void (^)(UIAlertAction *action))cancelHandler done:(NSString *)done doneHandler:(void (^)(UIAlertAction *action))doneHandler
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:preferredStyle];
    if (cancel.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleDefault handler:cancelHandler];
        [alertVc addAction:cancelAction];
    }
    if (done.length) {
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:done style:UIAlertActionStyleDefault handler:doneHandler];
        
        [alertVc addAction:doneAction];
        if(IOS9)
            [alertVc setPreferredAction:doneAction];
    }
    return alertVc;
}
@end

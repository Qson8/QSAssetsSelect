//
//  UIView+Tap.m
//  NeiHan
//
//  Created by Charles on 16/4/2.
//  Copyright © 2016年 Com.Charles. All rights reserved.
//

#import "UIView+Tap.h"
#import <objc/runtime.h>
/**
 *  动态添加手势
 */
static const char *ActionHandlerTapGestureKey;

@implementation UIView (Tap)

- (void)removeAllSubviews {
    //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

- (void)setTapActionWithBlock:(void (^)(void))block {
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
    
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized)  {
        void(^action)(void) = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (action)  {
            action();
        }
    }
}

- (UIView*)subViewOfClassName:(NSString*)className {
    for (UIView* subView in self.subviews) {
        if ([NSStringFromClass(subView.class) isEqualToString:className]) {
            return subView;
        }
        
        UIView* resultFound = [subView subViewOfClassName:className];
        if (resultFound) {
            return resultFound;
        }
    }
    return nil;
}

- (UIViewController *)vp_myController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
@end

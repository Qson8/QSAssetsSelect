

#import <UIKit/UIKit.h>

@interface UIView (Extension)

//可以轻松设置控件位置而不需要使用CGRectMake.....
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, weak, readonly) UIViewController *topViewController;

/** 快速返回一个Label */
+(UILabel *)getCommonLableWithName:(NSString *)name font:(NSInteger)font textColor:(UIColor *)clolor;

/** 快速返回一个Button */
+(UIButton *)getCommonButtonWithNormalName:(NSString *)name font:(NSInteger)font backGroundColor:(UIColor *)backGroundColor normalImage:(NSString *)normalImage
                                    target:(id)target action:(SEL)action;

- (UIViewController *)viewController;

- (void)removeAllSubviews;
    
@end

//
//  NSString+QS.h
//  AssetsSelect
//
//  Created by Qson on 2019/8/11.
//  Copyright © 2019 QSon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (QS)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font;
- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color;

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color LineSpacing:(CGFloat)lineSpacing;


- (void)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color LineSpacing:(CGFloat)lineSpacing complete:(void(^)(CGSize size,NSAttributedString *attributedString))complete;

@end

NS_ASSUME_NONNULL_END

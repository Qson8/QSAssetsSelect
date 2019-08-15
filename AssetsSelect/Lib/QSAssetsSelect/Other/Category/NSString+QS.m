//
//  NSString+QS.m
//  AssetsSelect
//
//  Created by Qson on 2019/8/11.
//  Copyright © 2019 QSon. All rights reserved.
//

#import "NSString+QS.h"

@implementation NSString (QS)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font
{
    NSDictionary *dict = @{NSFontAttributeName:font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
}

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color {
    return [self sizeWithMaxSize:maxSize font:font color:color LineSpacing:0];
}

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color LineSpacing:(CGFloat)lineSpacing {
    
    if(!self.length) return CGSizeZero;
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc]initWithString:self];
    
    [contentString setValue:font forKey:NSFontAttributeName];
    [contentString setValue:color forKey:NSForegroundColorAttributeName];
    
 // 断行方式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    paragraphStyle.hyphenationFactor = 0.9; // /hyphenationFactor 连字符属性，取值 0 到 1 之间，开启断词功能
    [contentString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self length])];
    CGSize size = [contentString boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return size;
}


/*! @brief  多行文本size和attributed 的处理
 *
 * @param   maxSize     最大尺寸
 * @param   font        字体
 * @param   color       颜色
 * @param   lineSpacing 行间距
 
 * @return block (size , attributedString)
 */
- (void)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font color:(UIColor *)color LineSpacing:(CGFloat)lineSpacing complete:(void(^)(CGSize size,NSAttributedString *attributedString))complete {
    
    if(!self.length) {
        !complete ?: complete(CGSizeZero,nil);
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    CGFloat oneHeight = [@"测试Test" boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
    
    CGFloat rowHeight = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
    CGFloat linespac = rowHeight > oneHeight ? lineSpacing : 0;
    
    [paragraphStyle setLineSpacing:linespac];
    paragraphStyle.hyphenationFactor = 0.9; // /hyphenationFactor 连字符属性，取值 0 到 1 之间，开启断词功能
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc]initWithString:self];
    
    NSMutableDictionary *attribDicts = [NSMutableDictionary dictionary];
    attribDicts[NSFontAttributeName] = font;
    attribDicts[NSForegroundColorAttributeName] = color;
    attribDicts[NSBaselineOffsetAttributeName] = @0;
    attribDicts[NSParagraphStyleAttributeName] = paragraphStyle;
    
    [contentString addAttributes:attribDicts range:NSMakeRange(0, [self length])];
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:attribDicts context:nil].size;
    
    if (complete) {
        complete(size,contentString);
    }
}
@end

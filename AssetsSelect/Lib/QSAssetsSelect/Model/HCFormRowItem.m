//
//  HCFormRowItem.m
//  SydneyToday
//
//  Created by chc on 2017/7/29.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import "HCFormRowItem.h"
//#import "FormManager.h"

NSString *const HCFormRowTypeText = @"text";
NSString *const HCFormRowTypeNumber = @"number";
NSString *const HCFormRowTypeDecimal = @"decimal";
NSString *const HCFormRowTypePassword = @"password";
NSString *const HCFormRowTypePhone = @"phone";
NSString *const HCFormRowTypeEmail = @"email";
NSString *const HCFormRowTypeSelectorAlert = @"Alert";
NSString *const HCFormRowTypeSelectorPush = @"selectorPush";// 显示第三方界面类型
NSString *const HCFormRowTypeMutiPickerPush = @"mutiPickerPush";
NSString *const HCFormRowTypeSinglePickerPush = @"singlePickerPush";
NSString *const HCFormRowTypeSinglePicker = @"taxonomy-dropdown";
NSString *const HCFormRowTypeDatePicker = @"datePicker";
NSString *const HCFormRowTypeYearPicker = @"taxonomy-slide"; // 年份选择
NSString *const HCFormRowTypeTimeToTimePicker = @"timeToTime";
NSString *const HCFormRowTypeTextView = @"long-text";
NSString *const HCFormRowTypeIconPicker = @"image";
NSString *const HCFormRowTypeSection = @"section";
/** 圆点单选 */
NSString *const HCFormRowTypeRadioChoice = @"taxonomy-single";
///** 方点多选 */
NSString *const HCFormRowTypeMultiChoice = @"taxonomy-checkbox-red";
/** 描述下面的方型标签 */
NSString *const HCFormRowTypeTagsLabel = @"taxonomy-label";

@implementation HCFormRowItem
- (void)setType:(NSString *)type
{
    _type = type;
    if (_placeHolder.length || [type isEqualToString:HCFormRowTypeSection]) {
        return;
    }
    if ([type isEqualToString:HCFormRowTypeText] || [type isEqualToString:HCFormRowTypeNumber] || [type isEqualToString:HCFormRowTypePhone] || [type isEqualToString:HCFormRowTypeEmail] || [type isEqualToString:HCFormRowTypeTextView]) {
        _placeHolder = @"请填写";
    }
    else
    {
        _placeHolder = @"请选择";
    }
}

- (void)setVid:(NSString *)vid
{
    _vid = vid;
    if (vid.integerValue) {
        _isTid = YES;
    }
}

- (void)setValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]]) {
        if (((NSArray *)value).count) {
            _value = value;
        }else {
            _value = nil;
        }
    } else {
        _value = value;
    }
}

- (void)setField:(NSString *)field
{
    _field = field;
    if ([field isEqualToString:@"global_placa"] || [field isEqualToString:@"service"] ) {
        _isTid = YES;
    }
    if ([field containsString:@"&"]) {
        NSArray *fields = [field componentsSeparatedByString:@"&"];
        _field1 = fields.firstObject;
        _field = fields.lastObject;
    }
}
//
//+ (NSMutableArray *)arraySectionForDictSection:(NSDictionary *)dictSection showSection:(BOOL)showSection sectionPosition:(NSInteger)sectionPosition sectionTitle:(NSString *)sectionTitle
//{
//    NSArray *values = dictSection.allValues;
//    NSMutableArray *valuesM = [NSMutableArray array];
//    for (NSDictionary *value in values) {
//        NSMutableDictionary *valueM = [NSMutableDictionary dictionaryWithDictionary:value];
//        NSInteger order = [valueM[@"order"] integerValue];
//        for (int i = 0; i < valuesM.count ; i++) {
//            if (order < [valuesM[i][@"order"] integerValue]) {
//                [valuesM insertObject:valueM atIndex:i];
//                break;
//            }
//        }
//        if (![valuesM containsObject:valueM]) {
//            [valuesM addObject:valueM];
//        }
//        valueM[@"type"] = [self rowTypeWithRowDict:valueM];
//    }
//    
//    if (showSection) {
//        NSMutableDictionary *sectionDictM = [NSMutableDictionary dictionary];
//        sectionDictM[@"type"] = HCFormRowTypeSection;
//        if (sectionTitle.length) {
//            sectionDictM[@"value"] = sectionTitle;
//        }
//        if (sectionPosition < valuesM.count) {
//            [valuesM insertObject:sectionDictM atIndex:sectionPosition];
//        }
//        else
//        {
//            [valuesM addObject:sectionDictM];
//        }
//    }
//    return valuesM;
//}
//
///// 处理联系方式包含中介的数据
//+ (NSMutableArray *)arraySectionForDictSection:(NSDictionary *)dictSection showSection:(BOOL)showSection sectionPosition:(NSInteger)sectionPosition sectionTitle:(NSString *)sectionTitle isIndividual:(BOOL)isIndividual
//{
//    NSArray *values = dictSection.allValues;
//    NSMutableArray *valuesM = [NSMutableArray array];
//    for (NSDictionary *value in values) {
//        NSMutableDictionary *valueM = [NSMutableDictionary dictionaryWithDictionary:value];
//        NSInteger order = [valueM[@"order"] integerValue];
//        for (int i = 0; i < valuesM.count ; i++) {
//            if (order < [valuesM[i][@"order"] integerValue]) {
//                [valuesM insertObject:valueM atIndex:i];
//                break;
//            }
//        }
//        if (![valuesM containsObject:valueM]) {
//            [valuesM addObject:valueM];
//        }
//        valueM[@"type"] = [self rowTypeWithRowDict:valueM];
//        valueM[@"identity"] = isIndividual ? @"1" : @"2";
//    }
//    
//    if (showSection) {
//        NSMutableDictionary *sectionDictM = [NSMutableDictionary dictionary];
//        sectionDictM[@"identity"] = isIndividual ? @"1" : @"2";
//        sectionDictM[@"type"] = HCFormRowTypeSection;
//        if(!isIndividual) {
//            sectionDictM[@"placeHolder"] = @"完善商户信息助你获得更多曝光";
//        }
//        else {
//            
//        }
//        if (sectionTitle.length) {
//            sectionDictM[@"value"] = sectionTitle;
//        }
//        if (sectionPosition < valuesM.count) {
//            [valuesM insertObject:sectionDictM atIndex:sectionPosition];
//        }
//        else
//        {
//            [valuesM addObject:sectionDictM];
//        }
//    }
//    return valuesM;
//}
//
//+ (NSString *)rowTypeWithRowDict:(NSDictionary *)rowDict
//{
//    NSString *type = rowDict[@"type"];
//    NSString *field = rowDict[@"field"];
//    NSString *keyboard = rowDict[@"keyboard"];
//    if ([field isEqualToString:@"global_placa"] || [field isEqualToString:@"address"] || [field isEqualToString:@"university"] || [field isEqualToString:@"group"] ) {
//        return HCFormRowTypeSelectorPush;
//    }
//    if ([type isEqualToString:@"taxonomy-radio"]){
//        return HCFormRowTypeSelectorAlert;
//    }
//    else if([type isEqualToString:@"taxonomy-dropdown"]){
//        return HCFormRowTypeSinglePicker;
//    }
//    else if([type isEqualToString:@"taxonomy-checkbox"]){
//        return HCFormRowTypeMutiPickerPush;
//    }
//    else if([type isEqualToString:@"text"]){
//        if ([keyboard isEqualToString:@"phone"]) {
//            return HCFormRowTypePhone;
//        }
//        else if ([keyboard isEqualToString:@"number"]) {
//            return HCFormRowTypeNumber;
//        }
//        else if ([keyboard isEqualToString:@"email"]) {
//            return HCFormRowTypeEmail;
//        }
//        else
//        {
//            return HCFormRowTypeText;
//        }
//    }
//    else if([type isEqualToString:@"long-text"]){
//        return HCFormRowTypeTextView;
//    }
//    else if([type isEqualToString:@"int"]){
//        return HCFormRowTypeNumber;
//    }
//    else if([type isEqualToString:@"password"]){
//        return HCFormRowTypePassword;
//    }
//    else if([type isEqualToString:@"string"]){
//        return HCFormRowTypeText;
//    }
//    else if([type isEqualToString:@"calendar"]){
//        return HCFormRowTypeDatePicker;
//    }
//    else
//    {
//        return type;
//    }
//}
//
//+ (NSArray *)rowItemsWithCatId:(NSString *)catId infoDict:(NSDictionary *)infoDict {
//    return [self rowItemsWithCatId:catId subCatId:nil infoDict:infoDict];
//}
//
///** 获取对应版块（子版块）发布模型数组 */
//+ (NSArray *)rowItemsWithCatId:(NSString *)catId subCatId:(NSString *)subCatId infoDict:(NSDictionary *)infoDict {
//    NSDictionary *thisCategoryFields = [self getThisCategoryFieldsWithCatId:catId subCatId:subCatId];
//    
//    // 获取显示别名(暂时用于黄页"资质认证"化名)
//    NSString *aliasString = nil;
//    NSString *certifiedcNum = nil;
////    if([PostTool isYellowPages:catId] || [catId isEqualToString:@"6370"]) {
////        NSDictionary *formDicts = [self getThisCategoryFieldsWithCatId:@"form"];
////        // 企业资质 重命名vs隐藏控制
////        NSDictionary *aliasDicts = [formDicts[@"zhengshu"] safeDict];
////        aliasString = aliasDicts[catId];
////        // 认证号 重命名vs隐藏控制
////        NSDictionary *cerIdDicts  = [formDicts[@"certID"] safeDict];
////        certifiedcNum = cerIdDicts[catId];
////    }
//
////    CGLog(@"thisCategoryFields == %@", thisCategoryFields);
////    NSArray *dictItems = nil;
////    if (thisCategoryFields) {
////        NSMutableArray *dictItemsM = [NSMutableArray array];
////        
////        if([catId isEqualToString:kLifeTextBook]) {
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:0 sectionTitle:nil]];
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:NO sectionPosition:0 sectionTitle:nil]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式"]];
////        }
////        else if([catId isEqualToString:kLifeNegocioSell]) { // 生意转让
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////            
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else if([catId isEqualToString:kLifeTradingMarket]) { // 交易市场
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////            
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"分类信息标题"]];
////            
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section5 = thisCategoryFields[@"section5"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section5 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else if([catId isEqualToString:kLifePetService]) { // 宠物交易
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////            
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else {
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:YES sectionPosition:hasPhoto?1:0 sectionTitle:@"分类信息标题"]];
////            
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"分类描述信息"]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式"]];
////        }
////        
////        dictItems = dictItemsM;
////    }
////    
//    NSMutableArray *rowItemsM = [NSMutableArray array];
////    for (NSDictionary *dictItem in dictItems) {
////        HCFormRowItem *rowItem = [HCFormRowItem mj_objectWithKeyValues:dictItem];
////        
////        if ([rowItem.field isEqualToString:@"minday"]) {
////            rowItem.placeHolder = @"周";
////        }
////        
////        if([PostTool isYellowPages:catId]) {
////            if([rowItem.field isEqualToString:@"zhengshu"]) {
////                if(aliasString.length) {
////                   rowItem.label = aliasString;
////                }
////                else continue;
////            }
////            if([rowItem.field isEqualToString:@"cretID"]) {
////                if(certifiedcNum.length) {
////                    rowItem.label = certifiedcNum;
////                }
////                else continue;
////            }
////        }
////        
////        for (NSString *key in infoDict.allKeys) {
////            if ([key isEqualToString:@"photo"]) {
////                
////            }
////            if ([key isEqualToString:rowItem.field]) {
////                id value = infoDict[key];
////                rowItem.value = value;
////            }
////            if ([key isEqualToString:rowItem.field1]) {
////                
////                id value = infoDict[key];
////                rowItem.value1 = value;
////            }
////        }
////        
////        if ([rowItem.field isEqualToString:@"title"]) {
////            rowItem.value = infoDict[@"uptitle"];
////        }
////        
////        [rowItemsM addObject:rowItem];
////    }
//    
//    return rowItemsM;
//}
//
///** 获取对应版块（子版块）发布字典数组 */
//+ (NSArray<NSDictionary *> *)rowsDictArrayWithCatId:(NSString *)catId subCatId:(NSString *)subCatId infoDict:(NSDictionary *)infoDict {
//    
//    NSDictionary *thisCategoryFields = [self getThisCategoryFieldsWithCatId:catId subCatId:subCatId];
//    
////    // 获取显示别名(暂时用于黄页"资质认证"化名)
////    NSString *aliasString = nil;
////    NSString *certifiedcNum = nil;
////    if([PostTool isYellowPages:catId] || [catId isEqualToString:@"6370"]) {
////        NSDictionary *formDicts = [self getThisCategoryFieldsWithCatId:@"form"];
////        // 企业资质 重命名vs隐藏控制
////        NSDictionary *aliasDicts = [formDicts[@"zhengshu"] safeDict];
////        aliasString = aliasDicts[catId];
////        // 认证号 重命名vs隐藏控制
////        NSDictionary *cerIdDicts  = [formDicts[@"certID"] safeDict];
////        certifiedcNum = cerIdDicts[catId];
////    }
//    
//    CGLog(@"thisCategoryFields == %@", thisCategoryFields);
//    NSArray *dictItems = nil;
////    if (thisCategoryFields) {
////        NSMutableArray *dictItemsM = [NSMutableArray array];
////
////        if([catId isEqualToString:kLifeTextBook]) {
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:0 sectionTitle:nil]];
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:NO sectionPosition:0 sectionTitle:nil]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式"]];
////        }
////        else if([catId isEqualToString:kLifeNegocioSell]) { // 生意转让
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else if([catId isEqualToString:kLifeTradingMarket]) { // 交易市场
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"分类信息标题"]];
////
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section5 = thisCategoryFields[@"section5"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section5 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else if([catId isEqualToString:kLifePetService]) { // 宠物交易
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:hasPhoto?1:0 sectionTitle:nil]];
////
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////        }
////        else if([catId isEqualToString:kLifeAutoBusiness]) { // 汽车买卖
////            if(subCatId.integerValue == 103) {
////                NSDictionary *section1 = thisCategoryFields[@"section1"];
////                [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:0 sectionTitle:@""]];
////
////                NSDictionary *section2 = thisCategoryFields[@"section2"];
////                [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"联系方式"]];
////            }
////            else if (subCatId.integerValue == 102){
////                NSDictionary *section1 = thisCategoryFields[@"section1"];
////                [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:NO sectionPosition:0 sectionTitle:@""]];
////
////                NSDictionary *section2 = thisCategoryFields[@"section2"];
////                [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:YES]];
////
////                NSDictionary *section3 = thisCategoryFields[@"section3"];
////                [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"联系方式" isIndividual:NO]];
////            }
////        }
////        else {
////            NSDictionary *section1 = thisCategoryFields[@"section1"];
////            BOOL hasPhoto = [section1.allKeys containsObject:@"field_photo"];
////
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section1 showSection:YES sectionPosition:hasPhoto?1:0 sectionTitle:@"分类信息标题"]];
////
////            NSDictionary *section2 = thisCategoryFields[@"section2"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section2 showSection:YES sectionPosition:0 sectionTitle:@"详细信息"]];
////            NSDictionary *section3 = thisCategoryFields[@"section3"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section3 showSection:YES sectionPosition:0 sectionTitle:@"分类描述信息"]];
////            NSDictionary *section4 = thisCategoryFields[@"section4"];
////            [dictItemsM addObjectsFromArray:[HCFormRowItem arraySectionForDictSection:section4 showSection:YES sectionPosition:0 sectionTitle:@"联系方式"]];
////        }
////
////        dictItems = dictItemsM;
////    }
////
//    NSMutableArray *rowItemsM = [NSMutableArray array];
////    for (NSDictionary *dictItem in dictItems) {
////
////        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictItem];
////
////        NSString *label = tempDict[@"label"];
////        NSString *field = tempDict[@"field"];
////        NSString *field1 = tempDict[@"field1"];
////        NSString *placeHolder = tempDict[@"placeHolder"];
////        NSString *body = tempDict[@"value"];
////        NSString *body1 = tempDict[@"value1"];
////
////        if ([field isEqualToString:@"minday"]) {
////            placeHolder = @"周";
////        }
////
////        if([PostTool isYellowPages:catId]) {
////            if([field isEqualToString:@"zhengshu"]) {
////                if(aliasString.length) {
////                    label = aliasString;
////                }
////                else continue;
////            }
////            if([field isEqualToString:@"cretID"]) {
////                if(certifiedcNum.length) {
////                    label = certifiedcNum;
////                }
////                else continue;
////            }
////        }
////
////        for (NSString *key in infoDict.allKeys) {
////            if ([key isEqualToString:@"photo"]) {
////
////            }
////            if ([key isEqualToString:field]) {
////                id value = infoDict[key];
////                body = value;
////            }
////            if ([key isEqualToString:field1]) {
////
////                id value = infoDict[key];
////                body1 = value;
////            }
////        }
////
////        if ([field isEqualToString:@"title"]) {
////            body = infoDict[@"uptitle"];
////        }
////
////        [rowItemsM addObject:tempDict];
////    }
//    
//    return rowItemsM;
//}
//
//
//+ (NSDictionary *)getThisCategoryFieldsWithCatId:(NSString *)catId {
////    // 获取当前版块的字段表
////    NSString *catIdString;
////    if ([PostTool isYellowPages:catId]) {
//////        catIdString = @"6370";
////        catIdString = @"yellowpage";
////    }else {
////        catIdString = catId;
////    }
////    if([catId isEqualToString:kLifeTextBook]) {
////        catIdString = @"book";
////    }
////    if([catId isEqualToString:kLifeNegocioSell]) {
////        catIdString = @"business";
////    }
////    if([catId isEqualToString:kLifeTradingMarket]) {
////        catIdString = @"market";
////    }
//    NSDictionary *thisCategoryFields = [MainHelper allCategoriesFieldsWithCatID:catIdString];
//    return thisCategoryFields;
//}
//
///** 通过catID和子id来获取发布字段表 */
//+ (NSDictionary *)getThisCategoryFieldsWithCatId:(NSString *)catId subCatId:(NSString *)subCatId {
//    // 获取当前版块的字段表
////    NSString *catIdString;
////    if ([PostTool isYellowPages:catId]) {
////        //        catIdString = @"6370";
////        catIdString = @"yellowpage";
////    }else {
////        catIdString = catId;
////    }
////    if([catId isEqualToString:kLifeTextBook]) {
////        catIdString = @"book";
////    }
////    if([catId isEqualToString:kLifeNegocioSell]) {
////        catIdString = @"business";
////    }
////    if([catId isEqualToString:kLifeTradingMarket]) {
////        catIdString = @"market";
////    }
////    if([catId isEqualToString:kLifeAutoBusiness]) {
////        catIdString = [NSString stringWithFormat:@"%@_%@",catId,subCatId];
////    }
////    if([catId isEqualToString:kLifePetService]) {
////        if([subCatId  isEqualToString:@"1550482512"]) { // 宠物猫
////            catIdString = @"pet_cat";
////        }
////        if([subCatId  isEqualToString:@"1550482522"]) { // 宠物狗
////            catIdString = @"pet_dog";
////        }
////        if([subCatId  isEqualToString:@"1550482532"]) { // 花鸟鱼虫
////            catIdString = @"animal_plant";
////        }
////        if([subCatId  isEqualToString:@"1550482542"]) { // 宠物用品
////            catIdString = @"pet_products";
////        }
////    }
////    NSDictionary *thisCategoryFields = [MainHelper allCategoriesFieldsWithCatID:catIdString];
//    return nil;
//}
//
//+ (NSDictionary *)sectionFieldsInfoForSection:(NSDictionary *)section infoDict:(NSDictionary *)infoDict
//{
//    NSMutableDictionary *sectionFields = [NSMutableDictionary dictionary];
//    NSMutableDictionary *sectionFieldsLabel = [NSMutableDictionary dictionary] ;
//    NSMutableArray *sectionFieldsIndex = [NSMutableArray array];
//    
//    for (NSString *key in section) {
//        NSString *fieldValue = [self fieldValueForSection:section key:key data:infoDict];
//        if (fieldValue.length) {
//            sectionFields[key] = fieldValue;
//            
//            NSDictionary *value = section[key];
//            NSString *label = value[@"label"];
//            sectionFieldsLabel[key] = label; // 存储 key 和 field 字段名
//            [sectionFieldsIndex addObject:key];// 按顺序 存Key
//        }
//    }
//    return @{@"sectionFieldsIndex" : sectionFieldsIndex , @"sectionFieldsLabel" : sectionFieldsLabel, @"sectionFields" : sectionFields};
//}
//
//// 给表单行数据传值
//+ (NSString *)fieldValueForSection:(NSDictionary *)FieldInSection key:(NSString *)key data:(NSDictionary *)data
//{
//    NSDictionary *value = [FieldInSection objectForKey:key];
//    NSString *type = [value objectForKey:@"type"];
//    NSString *vid = [NSString stringWithFormat:@"%@",[value objectForKey:@"vid"]];
//    //    NSString *label = [value objectForKey:@"label"];
//    NSString *field = [value objectForKey:@"field"]; // 数据字段
//    
//    NSString *fieldValue = [self getDataValueByType:type key:field vid:[vid integerValue] infoDict:data];
//    
//    if (fieldValue == nil) {
//        return nil;
//    }
//    
//    if (![fieldValue isKindOfClass:[NSString class]]) {  // 排除类型非字符串时，下面调用Length崩溃的bug
//        fieldValue = [NSString stringWithFormat:@"%@",fieldValue];
//    }
//    if ([fieldValue length] != 0) {
//        fieldValue = [fieldValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
//        return fieldValue;
//    }
//    return nil;
//}
//
//// 从服务器数据中取值,infoDict是服务器返回的数据
//+ (id)getDataValueByType:(NSString *)type key:(NSString *)key vid:(NSInteger)vid infoDict:(NSDictionary *)infoDict
//{
//    // 字符串
//    if ([type isEqualToString:@"string"]) {
//        NSString *value = [infoDict valueForKey:key];
//        if (![value isKindOfClass:[NSNull class]]) {
//            return value;
//        }
//    }
//    
//    // 文本
//    if ([type isEqualToString:@"text"]) {
//        NSString *value = [infoDict valueForKey:key];
//        if (![value isKindOfClass:[NSNull class]]) {
//            return value;
//        }
//    }
//    
//    // 整型
//    if ([type isEqualToString:@"int"]) {
//        NSString *value = [infoDict valueForKey:key];
//        if (![value isKindOfClass:[NSNull class]]) {
//            return [NSString stringWithFormat:@"%@",value];
//        }
//    }
//    
//    // 下拉框 (区域 户型)
//    if ([type isEqualToString:@"taxonomy-dropdown"]) {
//        NSString *tiD = [infoDict valueForKey:key];
//        if (![tiD isKindOfClass:[NSString class]]) { // 服务器给的数据类型非字符串则转成字符串，防止崩溃
//            tiD = [NSString stringWithFormat:@"%@",tiD];
//        }
//        NSString *value;
//        // 区域特殊处理
//        if ([key isEqualToString:@"global_placa"]) {
//            value = [MainHelper getAreaNameForTid:[tiD integerValue]];
//        } else {
//
//            FormOptionItem *item = [[FormManager sharedInstance] optionItemOfTid:tiD optionGroupVid:[NSString stringWithFormat:@"%ld",vid]];
//            value = item.name;
////            value = [[MainHelper getVidNamesForVid:[NSString stringWithFormat:@"%ld",vid]] valueForKey:tiD];
//        }
//        if (![value isKindOfClass:[NSNull class]]) {
//            return value;
//        }
//    }
//    
//    // radioc 单选 (房屋来源,行业,交易性质,房产状态,房产授权,房产类型,性别,学历,经验要求.学校,交易方式,书籍类型,变速箱,价格区间,是否送货,产品类型)
//    if ([type isEqualToString:@"taxonomy-radio"]) {
//        NSString *tiD = [infoDict valueForKey:key];
//        if (![tiD isKindOfClass:[NSString class]]) { // 服务器给的数据类型非字符串则转成字符串，防止崩溃
//            tiD = [NSString stringWithFormat:@"%@",tiD];
//        }
////        NSString *value = [[MainHelper getVidNamesForVid:[NSString stringWithFormat:@"%ld",vid]] valueForKey:tiD];
//        FormOptionItem *item = [[FormManager sharedInstance] optionItemOfTid:tiD optionGroupVid:[NSString stringWithFormat:@"%ld",vid]];
//        NSString *value = item.name;
//        return value;
//    }
//    
//    // 复选框 (附近设施,出租方式,房屋配置,求租方式,省份,工作性质,品牌)
//    if ([type isEqualToString:@"taxonomy-checkbox"]) {
//        NSString *valueTidsString = [infoDict valueForKey:key];
//        NSArray *valueTids = [valueTidsString componentsSeparatedByString:@","];
//        if (![valueTids isKindOfClass:[NSNull class]] && valueTids.count) {
//            NSString *valueNames = @"";
//            for (NSString *tmpTid in valueTids) {
////                NSString *value = [[MainHelper getVidNamesForVid:[NSString stringWithFormat:@"%ld",vid]] valueForKey:tmpTid];
//                FormOptionItem *item = [[FormManager sharedInstance] optionItemOfTid:tmpTid optionGroupVid:[NSString stringWithFormat:@"%ld",vid]];
//                NSString *value = item.name;
//                if ([tmpTid isEqualToString:valueTids.firstObject]) {
//                    valueNames = value;
//                    continue;
//                }
//                valueNames = [NSString stringWithFormat:@"%@ %@",valueNames,value];
//            }
//            return valueNames;
//        }
//    }
//    
//    // 长篇文本
//    if ([type isEqualToString:@"long-text"]) {
//        NSString *value = [infoDict valueForKey:key];
//        if (![value isKindOfClass:[NSNull class]]) {
//            return value;
//        }
//    }
//    
//    // 日历类型
//    if ([type isEqualToString:@"calendar"]) {
//        NSString *value = [infoDict valueForKey:key];
//        if (![value isKindOfClass:[NSNull class]]) {
//            return value;
//        }
//    }
//    return nil;
//}

@end

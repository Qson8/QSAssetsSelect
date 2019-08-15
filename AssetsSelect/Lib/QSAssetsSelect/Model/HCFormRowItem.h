//
//  HCFormRowItem.h
//  SydneyToday
//
//  Created by chc on 2017/7/29.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const HCFormRowTypeText;
extern NSString *const HCFormRowTypeNumber;
extern NSString *const HCFormRowTypeDecimal;
extern NSString *const HCFormRowTypePassword;
extern NSString *const HCFormRowTypePhone;
extern NSString *const HCFormRowTypeEmail;
extern NSString *const HCFormRowTypeSelectorAlert;
extern NSString *const HCFormRowTypeSelectorPush;
extern NSString *const HCFormRowTypeMutiPickerPush;
extern NSString *const HCFormRowTypeSinglePickerPush;
extern NSString *const HCFormRowTypeSinglePicker;
extern NSString *const HCFormRowTypeDatePicker;
extern NSString *const HCFormRowTypeYearPicker;
extern NSString *const HCFormRowTypeTimeToTimePicker;
extern NSString *const HCFormRowTypeTextView;
extern NSString *const HCFormRowTypeIconPicker;
extern NSString *const HCFormRowTypeSection;
/** 圆点单选 */
extern NSString *const HCFormRowTypeRadioChoice;
///** 方点多选 */
extern NSString *const HCFormRowTypeMultiChoice;
extern NSString *const HCFormRowTypeTagsLabel;


@interface HCFormRowItem : NSObject
/** 标题 */
@property (nonatomic, copy) NSString *label;
/** 字段 */
@property (nonatomic, copy) NSString *field;
/** 值 */
@property (nonatomic, copy) id value;
/** 字段1 */
@property (nonatomic, copy) NSString *field1;
/** 值1 */
@property (nonatomic, copy) id value1;
/** 头像 */
@property (nonatomic, strong) id image;
/** 输入类型 */
@property (nonatomic, copy) NSString *type;
/** 占位字符 */
@property (nonatomic, copy) NSString *placeHolder;
/** 必填 */
@property (nonatomic, copy) NSString *require;
@property (nonatomic, copy) NSString *keyboard;
/** value装的否是tid */
@property (nonatomic, assign) BOOL isTid;

/** row内显示的字符串 （拼接标题用） */
@property (nonatomic, weak) NSString *showString;
/// 文本前缀
@property (nonatomic, copy) NSString *bodyPrefix;
@property (nonatomic, strong) void(^valueCompletedBlock)(NSString *value);

/// 是否商家、中介 1:个人 2:商家或中介
@property (nonatomic, assign) NSInteger identity;
/**
 * 圆点单选操作记录 type = taxonomy-single下使用
 * 是否(操作)选择过
 */
@property (nonatomic, assign) BOOL isOpt;

@property (nonatomic, copy) NSString *postDomainId;

@property (nonatomic, assign) CGFloat cellHeight;

/** pushVc */
//@property (nonatomic, copy) UIViewController *pushVc;
@property (nonatomic, copy) NSString *vid;

/** 三方界面 */
@property (nonatomic, copy) Class destinClass;
@property (nonatomic, assign) BOOL isMutiSelect;
@property (nonatomic, assign) NSInteger maxSelectCount;

//+ (NSMutableArray *)arraySectionForDictSection:(NSDictionary *)dictSection showSection:(BOOL)showSection sectionPosition:(NSInteger)sectionPosition sectionTitle:(NSString *)sectionTitle;
//+ (NSArray *)rowItemsWithCatId:(NSString *)catId infoDict:(NSDictionary *)infoDict;
///** 获取对应版块（子版块）发布模型数组 */
//+ (NSArray *)rowItemsWithCatId:(NSString *)catId subCatId:(NSString *)subCatId infoDict:(NSDictionary *)infoDict;
///** 获取对应版块（子版块）发布字典数组 */
//+ (NSArray<NSDictionary *> *)rowsDictArrayWithCatId:(NSString *)catId subCatId:(NSString *)subCatId infoDict:(NSDictionary *)infoDict;
//+ (NSDictionary *)getThisCategoryFieldsWithCatId:(NSString *)catId;
//+ (NSDictionary *)sectionFieldsInfoForSection:(NSDictionary *)section infoDict:(NSDictionary *)infoDict;
@end

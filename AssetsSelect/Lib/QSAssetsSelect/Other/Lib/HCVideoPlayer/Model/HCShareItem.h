//
//  HCShareItem.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCShareItem : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *norImage;
@property (copy, nonatomic) NSString *higImage;
@property (copy, nonatomic) NSString *platform;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *key;

+ (instancetype)shareModelWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

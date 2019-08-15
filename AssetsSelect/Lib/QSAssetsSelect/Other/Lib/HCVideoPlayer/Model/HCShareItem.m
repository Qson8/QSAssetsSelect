//
//  HCShareItem.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCShareItem.h"

@implementation HCShareItem
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)shareModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

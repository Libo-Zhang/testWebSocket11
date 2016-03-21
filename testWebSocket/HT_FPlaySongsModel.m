//
//  HT_FPlaySongsModel.m
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_FPlaySongsModel.h"

@implementation HT_FPlaySongsModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        _id = [value integerValue];
    }
}
@end

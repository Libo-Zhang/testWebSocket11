//
//  HT_FPlayDevice.m
//  testWebSocket
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_FPlayDevice.h"

@implementation HT_FPlayDevice

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        _DID = [value integerValue];
    }
}
//-(id)initWithProperty:(long)did uidval:(long)uid dtypeval:(int)dtype dnamestr:(NSString*)dname devidstr:(NSString*)devid
//{
//    if (self = [super init]){
//        _uid = uid ;
//        _did = did ;
//        _dtype = dtype ;
//        _dname = dname ;
//        _devid = devid ;
//    }
//    return self;
//}
@end

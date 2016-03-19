//
//  HT_FPlayManager.h
//  testarray
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 huaishan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "HT_FPlayNearConnect.h"
#import "HT_FPlayDevice.h"
@interface HT_FPlayManager : NSObject
+(instancetype)getInsnstance;
//设备列表
@property (nonatomic, strong) NSMutableArray *mDeviceList;
@property (nonatomic, strong) NSMutableArray *remoteDeviceList;
-(void)getNeardevicegetWithSuccess:(void (^)(NSArray *nearDeviceArr))success WithFailer:(void (^)(id response))failer WithError:(void (^)(NSError *error))somethingError;
-(void)getUserdevicegetWithSuccess:(void (^)(NSArray *remoteDeviceArr))success WithFailer:(void (^)(id response))failer WithError:(void (^)(NSError *error))somethingError;
@property (nonatomic, strong) HT_FPlayDevice *currentDevice;

@property (nonatomic, strong) NSMutableArray *nearSongList;
@end

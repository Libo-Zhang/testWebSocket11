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
-(void)createNearUdpSocket;
-(void)getUserdeviceget;

@property (nonatomic, strong) HT_FPlayDevice *currentDevice;

@end

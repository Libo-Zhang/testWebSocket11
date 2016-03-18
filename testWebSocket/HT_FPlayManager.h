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
@interface HT_FPlayManager : NSObject
+(instancetype)getInsnstance;
//设备列表
@property (nonatomic, strong) NSMutableArray *mDeviceList;

-(void)createNearUdpSocket;
@end

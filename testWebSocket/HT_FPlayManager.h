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
//#import "AFNetworking.h"
@interface HT_FPlayManager : NSObject
+(instancetype)getInsnstance;
//得到附近的设备列表
-(void)getNeardevicegetWithSuccess:(void (^)(NSArray *nearDeviceArr))success WithFailer:(void (^)(id response))failer WithError:(void (^)(NSError *error))somethingError;
//得到用户的设备列表  api接口调用
-(void)getUserdevicegetWithSuccess:(void (^)(NSArray *remoteDeviceArr))success WithFailer:(void (^)(id response))failer WithError:(void (^)(NSError *error))somethingError;



//设备列表 near
@property (nonatomic, strong) NSMutableArray *mDeviceList;
//设备列表remoteDeviceList
@property (nonatomic, strong) NSMutableArray *remoteDeviceList;
//在线设备
@property (nonatomic, strong) NSMutableArray *onlineDevice;


//选择的设备
@property (nonatomic, strong) HT_FPlayDevice *currentDevice;
//播放列表
@property (nonatomic, strong) NSMutableArray *nearSongList;
//SD卡列表
@property (nonatomic, strong) NSMutableArray *SDSongList;
//歌曲的index
@property (nonatomic, assign) NSInteger songListIndex;



@end

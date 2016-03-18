//
//  HT_FPlayDevice.h
//  testWebSocket
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 uniview. All rights reserved.
//
/*
 {
 id: 35,
 dname: "HT100-41124",
 devid: "12:12:12:12:12:12",
 onlinetime: null,
 type: {
 tid: 1,
 tname: "HT100",
 clsname: "智能音箱",
 clsimg: "/images/default/config/soundbox.png",
 cname: "杭州展视网络科技有限公司"
 },
 configs: {
 songlist: "0",
 devicemode: "0",
 soundquality: "2",
 dname: "HT100-41124",
 onbootplay: "1",
 volume: "40",
 relation: "0",
 hversion: "00100010",
 sversion: "10010011",
 channel: "3"
 },
 status: 2,
 lasttime: "2016-3-16 8:16:34",
 bindtime: null
 }
 
 */
#import <Foundation/Foundation.h>

#import "HT_FPlayNearConnect.h"
#import "HT_FPlayRemoteConnect.h"
@interface HT_FPlayDevice : NSObject
//--设备属性
@property (nonatomic, assign) NSInteger DID;       //音响设备did(to)
@property (nonatomic, strong) NSString *dname;
@property (nonatomic, strong) NSString *devid;//音响设备的mac地址 id
@property (nonatomic, strong) NSString *onlinetime;
@property (nonatomic, strong) NSDictionary *type;//类型 还需要转换
@property (nonatomic, strong) NSDictionary *configs;//配置
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *lasttime;
@property (nonatomic, strong) NSString *bindtime;


@property (nonatomic, strong) HT_FPlayRemoteConnect *connect_remote; //设备的连接 － 互联网
@property (nonatomic, strong) HT_FPlayNearConnect *connect_near;
@property (nonatomic, assign) NSInteger UID;       //手机uid(from)

@property (nonatomic, strong) NSString *ipAddress;

@end

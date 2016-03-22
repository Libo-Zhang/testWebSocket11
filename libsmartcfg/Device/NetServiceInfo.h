//
//  NetServiceInfo.h
//  OMNIConfig
//
//  Created by YUAN HSIANG TSAI on 2015/6/9.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  用來註冊消息模式的Key，在Bonjour掃到一個Device時
 *  而且是透過WiFi設定後，才加入的
 *  會發出這個消息
 *
 *  [sender object] is NetServiceInfo
 */
extern NSString * const kGetWifiSettingDevice;

extern NSString * const kPingDeviceOK;
extern NSString * const kPingDeviceFailed;

/*!
 *  Class to keep information of scanned devices from bonjour.
 */
@interface NetServiceInfo : NSObject
/*!
 *  device name from bonjour
 *  (e.g., OMNICFG@003344556601)
 */
@property (nonatomic, copy) NSString * name;
/*!
 *  device type from bonjour
 *  (e.g., _omnicfg._tcp.local)
 */
@property (nonatomic, copy) NSString * type;
/*!
 *  device domain from bonjour
 *  (e.g., router-2.local.:80)
 */
@property (nonatomic, copy) NSString * domain;
/*!
 *  IP address of this device
 */
@property (nonatomic, copy) NSString * address;
/*!
 *  LAN IP address
 *  It will be different from address if user finish setting it
 */
@property (nonatomic, copy) NSString * lanIP;
/*!
 *  IPCam, AudioBox, TV, etc.
 *  It decided by product id and vendor id
 */
@property (nonatomic, copy) NSString * typeName;
/*!
 *  MAC address
 *  It parsers from name.
 */
@property (nonatomic, copy) NSString * macAddress;
/*!
 *  vendor id
 */
@property (nonatomic, copy) NSString * vid;
/*!
 *  product id
 */
@property (nonatomic, copy) NSString * pid;
/*!
 *  bonjour service version to prevent cache on bonjour
 */
@property (nonatomic, copy) NSString * sVersion;
/*!
 *  use for direct mode to check if apply successfully
 */
@property (nonatomic, copy) NSString * omniResult;
/*!
 *  用來確認是不是透過Smart config配置成功的
 */
@property (assign) BOOL isNewAdd;

- (void)startPing;
- (void)checkIfRestoredPreviousMode;

+ (instancetype)createRandomOne;
@end

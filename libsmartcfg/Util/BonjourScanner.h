//
//  BonjourScanner.h
//  OMNIConfig
//
//  Created by Edden on 7/23/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  用來註冊消息模式的Key，在Bonjour掃到一個被移除的Device時
 *  會發出這個消息
 *
 *  [sender object] is NetServiceInfo
 */
extern NSString * const kRemoveDeviceNotification;

/*!
 *  用來註冊消息模式的Key，在Bonjour掃到一個可加入的Device時
 *  會發出這個消息
 *
 *  [sender object] is NetServiceInfo
 */
extern NSString * const kScanDeviceGotNotification;

/*!
 *  key to register Observing getting omi_result = 2
 *  [sender object] is NetServiceInfo
 */
extern NSString * const kGetOmniResultNotification;

@interface BonjourScanner : NSObject

- (void)resetScanner;
- (void)startScan;
- (void)stopScan;

- (void)scanForQueryOmniResult;

// for test tableView
- (void)createFakeDevices;

@end

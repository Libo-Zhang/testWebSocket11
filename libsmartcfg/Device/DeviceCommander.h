//
//  DeviceCommander.h
//  OMNIConfig
//
//  Created by Edden on 10/19/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestTag) {
    RequestTagLogin,
    RequestTagWiFiSetting,
    RequestTagQueryApplyResult,
    RequestTagChangePassword,
    RequestTagRestartAP
};

typedef NS_ENUM(NSInteger, FailedCode) {
    FailedCodeServerReturnErr = -1,
};

@class DeviceAuthentication;
@protocol DeviceCommanderDelegate <NSObject>
- (void)onSuccessWithCommandType:(NSInteger)type;
- (void)onFailedWithErrCode:(NSInteger)code withCommandType:(NSInteger)type;
@end

@interface DeviceCommander : NSObject

- (instancetype)initWithIP:(NSString*)sIP withDelegate:(id<DeviceCommanderDelegate>)delegate;
- (void)doAuthWithUser:(NSString*)user Password:(NSString*)pw;
- (void)doWiFiSettingToSSID:(NSString*)ssid
               WiFiPassword:(NSString*)wifiPW;
- (void)queryResultForSettingWiFi;
- (void)stopAction;
- (void)restartCheetah;

@property (nonatomic, copy) NSString * targetSSID;

@end

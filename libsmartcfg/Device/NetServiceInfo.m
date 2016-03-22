//
//  NetServiceInfo.m
//  OMNIConfig
//
//  Created by YUAN HSIANG TSAI on 2015/6/9.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import "NetServiceInfo.h"
#import "SimplePing.h"
#import "BonjourScanner.h"
#import "HttpRequest.h"
#import "DebugMessage.h"

NSString * const kGetWifiSettingDevice      = @"bonjourScannedWifiSettingDevice";
NSString * const kPingDeviceOK              = @"pingDeviceOK";
NSString * const kPingDeviceFailed          = @"pingDeviceFailed";

typedef enum : NSUInteger {
    HttpTagGetIfRestored,
} HttpTag;

@interface NetServiceInfo() <SimplePingDelegate, HttpResultDelegate>
@property (nonatomic, strong) SimplePing    *ping;
@property (nonatomic, strong) NSTimer       *timerToPing;
@property (nonatomic, strong) PingFirstHttpRequest * request;
@end

@implementation NetServiceInfo {
    int counter;
    bool bGetPong;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self.request stopRequest];
    self.request = nil;
    NSLog(@"dealloc");
}

- (void)startPing {
    counter = 0;
    bGetPong = NO;
    self.isNewAdd = NO;
    self.ping = [SimplePing simplePingWithHostName:self.address];
    _ping.delegate = self;
    [_ping start];
}

- (void)sendPing {
    if (counter > 4 || _ping == nil || bGetPong) {
        if (_timerToPing) {
            [_timerToPing invalidate];
            self.timerToPing = nil;
        }
        
        if (!bGetPong) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPingDeviceFailed object:self];
        }
        
        return;
    }
    counter++;
    [_ping sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"start pinging %@", _address]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    self.timerToPing = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"didReceivePingResponsePacket %@", _address]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    if (bGetPong) {
        counter = 5;
        return;
    }
    bGetPong = YES;
    [_timerToPing invalidate];
    self.timerToPing = nil;
    [self performSelectorOnMainThread:@selector(postPingOKNotification) withObject:nil waitUntilDone:YES];
}

- (void)checkIfRestoredPreviousMode {
    self.request = [[PingFirstHttpRequest alloc] initWithIP:_address
                                               relativePath:@"omnicfg.cgi"
                                                       user:@"admin"
                                                   password:@"admin"
                                                        tag:HttpTagGetIfRestored];
    _request.resultDelegate = self;
    _request.bRetry = NO;
    [_request startRequest];
}

- (void)postPingOKNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPingDeviceOK object:self];
}

- (NSString *)description {
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_name forKey:@"name"];
    [dic setObject:_macAddress forKey:@"mac"];
    [dic setObject:_address forKey:@"ip"];
    [dic setObject:_lanIP forKey:@"LanIP"];
    [dic setObject:_vid forKey:@"vid"];
    [dic setObject:_pid forKey:@"pid"];
    [dic setObject:_typeName forKey:@"typeName"];
    [dic setObject:_sVersion forKey:@"version"];
    [dic setObject:_omniResult forKey:@"omniResult"];
    return [dic description];
}

- (void)postGetRestoreNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetWifiSettingDevice object:self];
}

- (void)onSuccess:(NSData *)result withTag:(NSInteger)tag {
    self.request = nil;
    NSError * error = nil;
    NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil) {
        self.isNewAdd = YES;
        [self performSelectorOnMainThread:@selector(postGetRestoreNotification) withObject:nil waitUntilDone:YES];
        return;
    }
    NSString * sResult = [jsonObject objectForKey:@"omi_restore_apply"];
    if (sResult == nil) {
        self.isNewAdd = YES;
        [self performSelectorOnMainThread:@selector(postGetRestoreNotification) withObject:nil waitUntilDone:YES];
        return;
    }
    
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"ret %@", sResult]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    self.isNewAdd = ([sResult intValue] == 0);
    [self performSelectorOnMainThread:@selector(postGetRestoreNotification) withObject:nil waitUntilDone:YES];
}

- (void)onFailed:(NSInteger)statusCode withTag:(NSInteger)tag {
    
}

+ (instancetype)createRandomOne {
    NetServiceInfo * one = [[NetServiceInfo alloc] init];
    int mac[6] = {0};
    for (int i = 0; i < 6; ++i) {
        mac[i] = arc4random() % 256;
    }
    one.name = [NSString stringWithFormat:@"OMNICFG@%02X%02X%02X%02X%02X%02X", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]];
    one.macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]];
    one.address = @"192.168.0.1";
    one.lanIP = (arc4random() % 2 == 1) ? @"192.168.0.1" : @"";
    int randomNum = arc4random() % 2;
    one.vid = (randomNum == 1) ? @"0001" : @"ffff";
    one.pid = (randomNum == 1) ? @"0001" : @"ffff";
    one.typeName = (randomNum == 1) ? @"Television" : @"IP Camera";
    return one;
}

@end

//
//  BonjourScanner.m
//  OMNIConfig
//
//  Created by Edden on 7/23/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#include <arpa/inet.h>

#import "BonjourScanner.h"
#import "DebugMessage.h"
#import "NetServiceInfo.h"
#import "libsmartcfg_constant.h"

NSString * const kRemoveDeviceNotification  = @"bonjourRemoveDevice";
NSString * const kScanDeviceGotNotification = @"bonjourScannedADevice";

NSString * const kGetOmniResultNotification = @"bonjourGetOmniResult";

#define kServiceType    @"_omnicfg._tcp"
#define kInitialDomain  @"local"

#define kLanIP          @"lan_ip"
#define kVendorID       @"sw_vid"
#define kProductID      @"sw_pid"
#define kVersion        @"version"
#define kOmniResult     @"omi_result"

@interface BonjourScanner() <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, strong) NSNetServiceBrowser       * serviceBrowser;
@property (nonatomic, strong) NSMutableArray            * serviceScannedArray;
@property (nonatomic, strong) NSMutableArray            * serviceResolvedArray;
@end

typedef enum : NSUInteger {
    DuplicatedNone,
    DuplicatedMAC,
    DuplicatedMACButNewVersion,
} DeplicatedState;

@implementation BonjourScanner {
    BOOL isForOmniResult;
    BOOL isContinue;
}

- (instancetype)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetValid:) name:kPingDeviceOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetInvalid:) name:kPingDeviceFailed object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPingDeviceOK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPingDeviceFailed object:nil];
}

- (void)createFakeDevices {
    for (int i = 0; i < 5; ++i) {
        NetServiceInfo * aDevice = [NetServiceInfo createRandomOne];
        [[NSNotificationCenter defaultCenter] postNotificationName:kScanDeviceGotNotification object:aDevice];
    }
}

- (void)resetScanner {
    if (self.serviceScannedArray == nil)
        self.serviceScannedArray = [[NSMutableArray alloc] init];

    if (self.serviceResolvedArray == nil)
        self.serviceResolvedArray = [[NSMutableArray alloc] init];
    
    [self.serviceScannedArray removeAllObjects];
    [self.serviceResolvedArray removeAllObjects];
}

- (void)startScan {
    [[DebugMessage sharedInstance] writeDebugMessage:@"Start Scan..."
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];

    isContinue = YES;
    isForOmniResult = NO;

    [self.serviceScannedArray removeAllObjects];
    
    NSNetServiceBrowser * serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.serviceBrowser = serviceBrowser;
    
    serviceBrowser.delegate = self;
    [serviceBrowser searchForServicesOfType:kServiceType inDomain:kInitialDomain];
}

- (void)scanForQueryOmniResult {
    [[DebugMessage sharedInstance] writeDebugMessage:@"Start Scan..."
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    isForOmniResult = YES;
    isContinue      = YES;
    
    [self.serviceScannedArray removeAllObjects];
    
    NSNetServiceBrowser * serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.serviceBrowser = serviceBrowser;
    
    serviceBrowser.delegate = self;
    [serviceBrowser searchForServicesOfType:kServiceType inDomain:kInitialDomain];
}

- (void)stopScan {
    if (!isContinue) {
        return;
    }
    
    isContinue = NO;
    [_serviceBrowser stop];
}


#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Find a service [%@] to resolve.", aNetService.name]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    [_serviceScannedArray addObject:aNetService];
    
    [aNetService setDelegate:self];
    // Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
    // choose to cancel the resolve by selecting another service in the table view.
    NSTimeInterval timeout = TIMEOUT_SCAN_DEVICE;
    [aNetService resolveWithTimeout:timeout];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [[DebugMessage sharedInstance] writeDebugMessage:@"Remove a found service."
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    [aNetService stop];
    [_serviceScannedArray removeObject:aNetService];
}

#pragma mark - implement NSNetServiceDelegate
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Resolve a service err %@", [errorDict description]]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    [sender stop];
    if (isContinue) {
        [sender setDelegate:self];
        NSTimeInterval timeout = TIMEOUT_SCAN_DEVICE;
        [sender resolveWithTimeout:timeout];
    } else {
        [_serviceScannedArray removeObject:sender];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    if (isContinue == NO) {
        return;
    }
    
    @try {
        
        if (isForOmniResult) {
            [self dealWithOmniResult:sender];
            return;
        }
        
        NetServiceInfo * newInfo = [[NetServiceInfo alloc] init];
        newInfo.name = [sender name];
        newInfo.type = [NSString stringWithFormat:@"%@%@", sender.type, sender.domain];
        newInfo.domain = [NSString stringWithFormat:@"%@:%d", sender.hostName, (int)sender.port];
        
        NSArray * splitName = [[sender name] componentsSeparatedByString:@"@"];
        NSString * sMAC = [splitName objectAtIndex:1];
        newInfo.macAddress = [self convertStringToMACAddress:sMAC];
        
        NSData * address = [sender.addresses objectAtIndex:0];
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        NSString * sAddress = [NSString stringWithFormat:@"%s", inet_ntoa(socketAddress->sin_addr)];
        newInfo.address = sAddress;
        
        NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]];
        
        NSString * sVersion = [[NSString alloc] initWithData:[dict valueForKey:kVersion] encoding:NSUTF8StringEncoding];
        newInfo.sVersion = sVersion;
        
        NSInteger check = [self checkIfDuplicated:newInfo];
        if (check == DuplicatedMAC) {
            [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Get depulicated service mac=%@", sMAC]
                                                    function:[NSString stringWithFormat:@"%s", __func__]
                                                        line:[NSString stringWithFormat:@"%d", __LINE__]
                                                        mode:DebugMessageBonjour];
            return;
        }
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * filterVid = [defaults objectForKey:KEY_VENDOR_ID];
        NSString * sVenderID = [[NSString alloc] initWithData:[dict valueForKey:kVendorID] encoding:NSUTF8StringEncoding];
        if (filterVid != nil && [filterVid length] > 0 && ![sVenderID isEqual:filterVid]) {
            return;
        }
        newInfo.vid = sVenderID;
        
        NSString * filterPid = [defaults objectForKey:KEY_PRODUCT_ID];
        NSString * sProductID = [[NSString alloc] initWithData:[dict valueForKey:kProductID] encoding:NSUTF8StringEncoding];
        if (filterPid != nil && [filterPid length] > 0 && ![sProductID isEqual:filterPid]) {
            return;
        }
        newInfo.pid = sProductID;
        
        // FIX: check device type name by Case?
        if ([sVenderID isEqualToString:@"0001"] && [sProductID isEqualToString:@"0001"]) {
            newInfo.typeName = @"Television";
        } else if ([sVenderID isEqualToString:@"ffff"] && [sProductID isEqualToString:@"ffff"]) {
            newInfo.typeName = @"IP Camera";
        } else {
            newInfo.typeName = @"AudioBox";
        }
        
        NSString * sLanIP = [[NSString alloc] initWithData:[dict valueForKey:kLanIP] encoding:NSUTF8StringEncoding];
        newInfo.lanIP = sLanIP;
        NSString * sOmniResult = [[NSString alloc] initWithData:[dict valueForKey:kOmniResult] encoding:NSUTF8StringEncoding];
        newInfo.omniResult = sOmniResult;
        
        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Get one -> %@", [newInfo description]]
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageBonjour];


        if (check == DuplicatedNone) {
            [_serviceResolvedArray addObject:newInfo];
        }
        [newInfo startPing];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (NSString*)convertStringToMACAddress:(NSString*)input {
    NSMutableString * output = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < [input length]; ++i) {
        if (i != 0 && i % 2 == 0) {
            [output appendString:@":"];
        }
        [output appendFormat:@"%c", [input characterAtIndex:i]];
    }
    return output;
}

- (NSInteger)checkIfDuplicated:(NetServiceInfo*)device {
    for (NSUInteger i = 0; i < [_serviceResolvedArray count]; ++i) {
        NetServiceInfo * anInfo = [_serviceResolvedArray objectAtIndex:i];
        if ([device.macAddress isEqualToString:anInfo.macAddress]) {
            if (![device.sVersion isEqualToString:anInfo.sVersion] && !isForOmniResult) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveDeviceNotification object:anInfo];
                [_serviceResolvedArray replaceObjectAtIndex:i withObject:device];
                return DuplicatedMACButNewVersion;
            } else {
                return DuplicatedMAC;
            }
        }
    }
    return DuplicatedNone;
}

- (void)onGetValid:(NSNotification*)sender {
    if (isForOmniResult) {
        return;
    }
    if ([self.serviceResolvedArray indexOfObject:[sender object]] != NSNotFound && isContinue) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kScanDeviceGotNotification object:[sender object]];
    }
}

- (void)onGetInvalid:(NSNotification*)sender {
    [self.serviceResolvedArray removeObject:[sender object]];
}

- (void)dealWithOmniResult:(NSNetService *)sender {
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]];
    if ([_serviceResolvedArray count] == 0) {
        return;
    }
    
    // If in AP mode, we should only have one NetServiceInfo
    NetServiceInfo * anInfo = [_serviceResolvedArray objectAtIndex:0];
    if (![anInfo.name isEqualToString:[sender name]]) {
        return;
    }
    
    NSString * sOmniResult = [[NSString alloc] initWithData:[dict valueForKey:kOmniResult] encoding:NSUTF8StringEncoding];
    if ([sOmniResult integerValue] == OmniStateConnectSuccess) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetOmniResultNotification object:anInfo];
    }
}

@end

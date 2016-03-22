//
//  DeviceCommander.m
//  OMNIConfig
//
//  Created by Edden on 10/19/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import "DeviceCommander.h"
#import "HttpRequest.h"
#import "BonjourScanner.h"
#import "DebugMessage.h"
#import "libsmartcfg_constant.h"
#import "NetServiceInfo.h"

static NSString * const CLI_PATH = @"cli.cgi";

@interface DeviceCommander() <HttpResultDelegate>
@property (nonatomic, strong) PingFirstHttpRequest * requestor;
@property (nonatomic, copy) NSString * ip;
@property (nonatomic, copy) NSString * user;
@property (nonatomic, copy) NSString * pw;
@property (nonatomic, strong) BonjourScanner * bonjourScanner;
@end

@implementation DeviceCommander {
    id<DeviceCommanderDelegate> _delegate;
    NSTimeInterval lastQueryTime;
    BOOL isGetQueryResult;
}
- (instancetype)initWithIP:(NSString*)sIP withDelegate:(id<DeviceCommanderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.ip = sIP;
        _delegate = delegate;
        lastQueryTime = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetCommitResult:) name:kGetOmniResultNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetOmniResultNotification object:nil];
    [self stopAction];
}

- (void)doAuthWithUser:(NSString*)user Password:(NSString*)pw {
    self.user = user;
    self.pw = pw;
    self.requestor = [[PingFirstHttpRequest alloc] initWithIP:_ip
                                                 relativePath:nil
                                                         user:user
                                                     password:pw
                                                          tag:RequestTagLogin];
    _requestor.resultDelegate = self;
    _requestor.bRetry = YES;
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Auth device u[%@]:pw[%@]", user, pw]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    [_requestor startRequest];
}

- (void)doWiFiSettingToSSID:(NSString*)ssid
               WiFiPassword:(NSString*)wifiPW {
    
    self.targetSSID = ssid;
    //NSString * vendorPhase = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_VENDOR_PHASE];
    NSString * vendorPhase = @"MONTAGE";
    NSString * applyStr = [[NSString alloc] initWithFormat:@"ssid=%@\npass=%@\nphase=%@",
                           ssid,
                           wifiPW,
                           vendorPhase];
    NSString * sBase64Apply = [[applyStr dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString * sPost = [NSString stringWithFormat:@"cmd=omnicfg_apply base64 %@ %@", mode_station, sBase64Apply];
    
    [[DebugMessage sharedInstance] writeDebugMessage:sPost
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    
    self.requestor = [[PingFirstHttpRequest alloc] initWithIP:_ip
                                                     relativePath:CLI_PATH
                                                             user:_user
                                                         password:_pw
                                                              tag:RequestTagWiFiSetting];
    _requestor.resultDelegate = self;
    _requestor.bRetry = YES;
    
    _requestor.strPostData = sPost;
    [_requestor startRequest];
}

- (void)doSendQuery {
    if (isGetQueryResult == YES)
        return;
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (currentTime - lastQueryTime < 1) {
        [self performSelector:@selector(doSendQuery) withObject:nil afterDelay:1];
        return;
    }
    
    self.requestor = [[PingFirstHttpRequest alloc] initWithIP:_ip
                                                 relativePath:CLI_PATH
                                                         user:_user
                                                     password:_pw
                                                          tag:RequestTagQueryApplyResult];
    _requestor.resultDelegate = self;
    _requestor.bRetry = YES;
    _requestor.strPostData = [NSString stringWithFormat:@"cmd=$omi_result"];
    [_requestor startRequest];
    lastQueryTime = currentTime;
}

- (void)queryResultForSettingWiFi {
    lastQueryTime = 0;
    isGetQueryResult = NO;
    self.bonjourScanner = [[BonjourScanner alloc] init];
    [_bonjourScanner scanForQueryOmniResult];
    [[DebugMessage sharedInstance] writeDebugMessage:@"Start Query omi_result"
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    
    [self performSelectorOnMainThread:@selector(doSendQuery) withObject:nil waitUntilDone:YES];
}

- (void)restartCheetah {
    self.requestor = [[PingFirstHttpRequest alloc] initWithIP:_ip
                                                 relativePath:CLI_PATH
                                                         user:_user
                                                     password:_pw
                                                          tag:RequestTagRestartAP];
    
    _requestor.resultDelegate = self;
    _requestor.bRetry = NO;
    _requestor.strPostData = @"cmd=omnicfg zero_counter";
    [[DebugMessage sharedInstance] writeDebugMessage:_requestor.strPostData
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    [_requestor startRequest];
}

- (void)onSuccess:(NSData *)result withTag:(NSInteger)tag {
    self.requestor = nil;
    if (_delegate == nil || RequestTagRestartAP == tag) {
        return;
    }
    
    NSString * string = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    if ([string rangeOfString:@"ERR"].location != NSNotFound) {
        if (tag != RequestTagQueryApplyResult)
            [_delegate onFailedWithErrCode:FailedCodeServerReturnErr withCommandType:tag];
        else
            [self performSelectorOnMainThread:@selector(doSendQuery) withObject:nil waitUntilDone:YES];
        return;
    }
    
    if (tag != RequestTagQueryApplyResult) {
        [_delegate onSuccessWithCommandType:tag];
        return;
    }
    
    [self dealWithQueryResult:[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]];
}

- (void)onFailed:(NSInteger)statusCode withTag:(NSInteger)tag {
    self.requestor = nil;
    if (_delegate == nil || RequestTagRestartAP == tag) {
        return;
    }
    if (tag != RequestTagQueryApplyResult) {
        [_delegate onFailedWithErrCode:statusCode withCommandType:tag];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(doSendQuery) withObject:nil waitUntilDone:YES];
}

- (void)onGetCommitResult:(NSNotification *)sender {
    if (isGetQueryResult == YES) {
        return;
    }
    
    isGetQueryResult = YES;
    NetServiceInfo * info = [sender object];
    if ([info.address isEqualToString:_ip]) {
        [_delegate onSuccessWithCommandType:RequestTagQueryApplyResult];
    }
    [_bonjourScanner stopScan];
    self.bonjourScanner = nil;
}

- (void)dealWithQueryResult:(NSString*)result {
    if (isGetQueryResult == YES) {
        return;
    }
    
    int mode = [result intValue];
    if (mode == OmniStateConnecting || mode == OmniStateNone) {
        [self performSelectorOnMainThread:@selector(doSendQuery) withObject:nil waitUntilDone:YES];
        return;
    }
    
    isGetQueryResult = YES;
    if (mode == OmniStateConnectSuccess) {
        [_delegate onSuccessWithCommandType:RequestTagQueryApplyResult];
    } else {
        [_delegate onFailedWithErrCode:mode withCommandType:RequestTagQueryApplyResult];
    }
    
    [_bonjourScanner stopScan];
    self.bonjourScanner = nil;
}

- (void)stopAction {
    if (_bonjourScanner) {
        [_bonjourScanner stopScan];
    }
    self.bonjourScanner = nil;
    
    if (_requestor) {
        [_requestor stopRequest];
    }
    self.requestor = nil;
}

@end

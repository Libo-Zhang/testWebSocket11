//
//  MIMOSender.m
//  libsmartcfg
//
//  Created by Edden on 10/26/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import "MIMOSender.h"
#import "libsmartcfg_constant.h"
#import "DebugMessage.h"

#include "channel_lock.h"
#include "coder.h"


@interface MIMOSender()
@property (nonatomic, strong) NSString * targetIP;
@property (nonatomic, strong) NSString * ssid;
@property (nonatomic, strong) NSString * pw;
@property (nonatomic, strong) PacketLengthSender * lockPhaseSender;
@property (nonatomic, strong) PacketLengthSender * contentSender;
@end

@implementation MIMOSender {
    NSTimeInterval sleepTime;
    BOOL isContinue;
    unsigned int lockStream[4];
    Byte * pData;
    int totalLen;
    int dataLen;
    BOOL bStopLockPhase;
    BOOL bStopContent;
}

- (instancetype)initWithTargetIP:(NSString*)ip {
    self = [super init];
    if (self) {
        self.targetIP = ip;
        sleepTime = 20000;  // 20ms
        self.lockPhaseSender    = [[PacketLengthSender alloc] initWithAddress:atoi([ip UTF8String]) withToS:IPTOS_TID_1];
        self.contentSender      = [[PacketLengthSender alloc] initWithAddress:atoi([ip UTF8String]) withToS:IPTOS_TID_5];
        pData = NULL;
    }
    return self;
}

- (void)setSSID:(NSString*)ssid Password:(NSString*)pw Mode:(int)mode {
    self.ssid = ssid;
    self.pw   = pw;
    lock_stream_gen(lockStream, SC_LOCK_LENGTH_BASE, SC_LOCK_SPEC_CHAR, SC_LOCK_INTERVAL_LEN);
    [_lockPhaseSender setFixLength:1200];
    [_contentSender setFixLength:1200];
    char ssidLength = ([ssid lengthOfBytesUsingEncoding:NSUTF8StringEncoding] & 0xFF);
    char pwLength   = ([pw lengthOfBytesUsingEncoding:NSUTF8StringEncoding] & 0xFF);
    dataLen = ssidLength + pwLength + 4;
    totalLen = ((dataLen + 8) >> 3) << 3;   // multiple of 8
    if (pData != NULL) {
        free(pData);
    }
    pData = malloc(totalLen);
    memset(pData, 0, totalLen);
    
    int index = 0;
    pData[index++] = (dataLen - 1) & 0xFF;
    pData[index++] = mode & 0xFF;
    pData[index++] = ssidLength & 0xFF;
    const char * pSrc = [ssid UTF8String];
    for (int i = 0; i < ssidLength; ++i) {
        pData[index++] = pSrc[i];
    }
    pData[index++] = pwLength & 0xFF;
    pSrc = [pw UTF8String];
    for (int i = 0; i < ssidLength; ++i) {
        pData[index++] = pSrc[i];
    }
}

- (void)start {
    isContinue = YES;
    bStopContent = NO;
    bStopLockPhase = NO;
    [self performSelectorInBackground:@selector(startSendLockPhase) withObject:nil];
    [self performSelectorInBackground:@selector(startSendContent) withObject:nil];
}

- (void)stop {
    
}

- (void)startSendLockPhase {
    size_t sizeLockPhase = sizeof(lockStream);
    Byte * pLockPhase = (Byte*)&lockStream[0];
    while (isContinue) {
        for (size_t i = 0; i < sizeLockPhase; ++i) {
            [_lockPhaseSender sendSpecifiedDataLength:pLockPhase[i]];
            usleep(sleepTime);
        }
    }
    bStopLockPhase = YES;
}

- (void)startSendContent {
    unsigned int * encoded_stream = sc_encoder(pData, totalLen);
    if (encoded_stream == NULL) {
        [[DebugMessage sharedInstance] writeDebugMessage:@"Encode stream is null"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageSmartconfig];
        isContinue = NO;
        bStopContent = YES;
        return;
    }
    while (isContinue) {
        for (int i = 0; i < totalLen; ++i) {
            
        }
    }
}

@end

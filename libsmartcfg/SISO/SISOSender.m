//
//  MontageConfigSender.m
//  TestApp
//
//  Created by Edden on 10/2/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import "SISOSender.h"
#import "DebugMessage.h"
#import "libsmartcfg_constant.h"

#define shift_for_avoid_2x2 900

@interface SISOSender()
@property (nonatomic, strong) NSMutableArray * contentSenders;
@property (nonatomic, strong) PacketLengthSender * baseLengthSender1;
@property (nonatomic, strong) PacketLengthSender * baseLengthSender2;
@end

@implementation SISOSender {
    BOOL bStopSendBaseLength;
    BOOL bStopSendData;
    BOOL bContinue;
    BOOL bEnterbackground;
    int  totalCount;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentSenders = [[NSMutableArray alloc] init];
        
        self.baseLengthSender1 = [[PacketLengthSender alloc] initWithAddress:mcAddrBaseLength1 withToS:IPTOS_TID_0];
        self.baseLengthSender2 = [[PacketLengthSender alloc] initWithAddress:mcAddrBaseLength2 withToS:IPTOS_TID_0];

        bStopSendBaseLength = YES;
        bStopSendData = YES;
        bContinue = NO;
        bEnterbackground = NO;
        _sleepForBaseLength = 10000;    // 30ms
        _sleepForChars      = 20000;    // 20ms
        _sleepForResend     = 20000;    // 50ms
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterbackground) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReactive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [self.contentSenders removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)start {
    bContinue = YES;
    if (bStopSendBaseLength == NO || bStopSendData == NO) {
        return;
    }
    
    bStopSendBaseLength = NO;
    bStopSendData = NO;
    [self setSenders];
    [self performSelectorInBackground:@selector(startSendBaseLength) withObject:nil];
    [self performSelectorInBackground:@selector(startSend) withObject:nil];
}

- (void)stop {
    bContinue = NO;
}

- (void)setSenders {
    [self.baseLengthSender1 setDataLength:_baseLength + shift_for_avoid_2x2];
    [self.baseLengthSender2 setDataLength:_baseLength + shift_for_avoid_2x2];
    
    int ssidLength = (int)[_ssid lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    int pwLength   = (int)[_password lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    int totalLength = ssidLength + pwLength + 3;

    uint32_t arrayIndexStart = 0;
    
    PacketLengthSender * totalLengthSender = [self getSenderFromIndex:arrayIndexStart++];
    [totalLengthSender setDataLength:totalLength + shift_for_avoid_2x2];
    
    PacketLengthSender * modeSender = [self getSenderFromIndex:arrayIndexStart++];
    [modeSender setDataLength:_mode + shift_for_avoid_2x2];
    
    PacketLengthSender * ssidLengthSender = [self getSenderFromIndex:arrayIndexStart++];
    [ssidLengthSender setDataLength:ssidLength + shift_for_avoid_2x2];
    
    
    const char * ssid = [_ssid UTF8String];
    for (NSUInteger i = 0; i < ssidLength; ++i) {
        unsigned char c = ssid[i];
        PacketLengthSender * ssidSender = [self getSenderFromIndex:arrayIndexStart++];
        [ssidSender setDataLength:c + shift_for_avoid_2x2];
    }

    PacketLengthSender * passLengthSender = [self getSenderFromIndex:arrayIndexStart++];
    [passLengthSender setDataLength:pwLength + shift_for_avoid_2x2];
    
    const char * password = [_password UTF8String];
    for (NSUInteger i = 0; i < pwLength; ++i) {
        unsigned char c = password[i];
        PacketLengthSender * pwSender = [self getSenderFromIndex:arrayIndexStart++];
        [pwSender setDataLength:c + shift_for_avoid_2x2];
    }
    
    totalCount = totalLength + 1;
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"total count %d", totalCount]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageSmartconfig];
}

- (PacketLengthSender*)getSenderFromIndex:(uint32_t)index {
    PacketLengthSender * ret = nil;
    if (index < [_contentSenders count]) {
        ret = [_contentSenders objectAtIndex:index];
    } else {
        uint32_t addr = (mcAddrContentStart + ((int)index<<24));
        ret = [[PacketLengthSender alloc] initWithAddress:addr withToS:IPTOS_TID_0];
        [_contentSenders addObject:ret];
    }
    return ret;
}

- (void)checkStopAll {
    if (bStopSendData && bStopSendBaseLength && !bEnterbackground) {
        [[DebugMessage sharedInstance] writeDebugMessage:@"checkStopAll"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageSmartconfig];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSISOSenderStopped object:nil];
    }
    bEnterbackground = NO;
}

- (void)startSendBaseLength {
    while (bContinue){
        [_baseLengthSender1 send];
        [_baseLengthSender2 send];
        usleep(_sleepForBaseLength);
    }
    bStopSendBaseLength = YES;
    
    [self checkStopAll];
}

- (void)startSend {
    
    while (bContinue){
        for (NSUInteger i = 0; i < totalCount; ++i) {
            PacketLengthSender * sender = [_contentSenders objectAtIndex:i];
            [sender send];
            usleep(_sleepForChars);
        }
        usleep(_sleepForResend);
    };
    bStopSendData = YES;
    
    [self checkStopAll];
}

- (void)handleEnterbackground {
    bContinue = NO;
    bEnterbackground = YES;
}

- (void)handleReactive {
    bEnterbackground = NO;
}

@end

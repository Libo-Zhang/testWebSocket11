//
//  BroadcastSender.h
//  TestApp
//
//  Created by Edden on 9/30/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>

#define kMIMOSenderFailed  (@"MIMOSenderFailed")
#define kMIMOSenderStopped (@"MIMOSenderStopped")
#define kSISOSenderFailed  (@"SISOSenderFailed")
#define kSISOSenderStopped (@"SISOSenderStopped")

#define mcAddrBaseLength1   0x6E6863E0
#define mcAddrBaseLength2   0x6C656EE0
#define mcAddrContentStart  0x006973E0

#define	IPTOS_TID_6     0xc0    // 6
#define	IPTOS_TID_5		0xa0    // 5
#define	IPTOS_TID_1		0x20    // 1
#define	IPTOS_TID_0		0x00    // 0

typedef enum : NSUInteger {
    StartResultsuccess = 0,
    StartResultsocketCreateFailed,
    StartResultsendFailed,
} StartResult;

@interface PacketLengthSender : NSObject

- (instancetype)initWithAddress:(in_addr_t)address withToS:(int)tos;

// for SISO
- (void)setDataLength:(int)length;
- (int)send;

// for MIMO
- (void)setFixLength:(int)length;
- (int)sendSpecifiedDataLength:(int)length;

@end

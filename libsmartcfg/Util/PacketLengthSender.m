//
//  BroadcastSender.m
//  TestApp
//
//  Created by Edden on 9/30/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import "PacketLengthSender.h"
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "DebugMessage.h"
#import "libsmartcfg_constant.h"

#define dest_port 9  // discard port (see wiki)

@interface PacketLengthSender()
@end

@implementation PacketLengthSender {
    char * sendData;
    int maxLength;
    int fd;
    in_addr_t addr;
    struct sockaddr_in destAddress;
    int typeOfService;
}

- (instancetype)initWithAddress:(in_addr_t)address withToS:(int)tos {
    self = [super init];
    
    if (self) {
        addr    = address;
        fd      = -1;
        sendData    = NULL;
        maxLength   = 0;
        typeOfService = tos;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterbackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    free(sendData);
    close(fd);
    fd          = -1;
    sendData    = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)setFixLength:(int)length {
    if (maxLength > length) {
        return;
    }
    
    if (sendData != NULL) {
        free(sendData);
    }
    maxLength = length;
    sendData = malloc(maxLength);
    memset(sendData, 1, maxLength);
}

- (void)setDataLength:(int)length {
    if (maxLength == length) {
        return;
    }

    if (sendData != NULL) {
        free(sendData);
    }
    maxLength = length;
    sendData = malloc(maxLength);
    memset(sendData, 1, maxLength);
}

- (BOOL)createSocket {
    fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd == -1) {
        [[DebugMessage sharedInstance] writeDebugMessage:@"Err to create socket"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageSmartconfig];
        return NO;
    }
    memset(&destAddress, 0, sizeof(destAddress));
    destAddress.sin_family      = AF_INET;
    destAddress.sin_addr.s_addr = addr;
    destAddress.sin_port        = htons(dest_port);
    
    if (setsockopt(fd, IPPROTO_IP, IP_TOS, &typeOfService, sizeof(typeOfService)) == -1) {
        NSLog(@"Err to setsockopt");
        return NO;
    }
    
    return YES;
}

- (int)send {
    return [self sendSpecifiedDataLength:maxLength];
}

- (int)sendSpecifiedDataLength:(int)length {
    if (fd == -1) {
        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"%08X : %d", addr, length]
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageHttpRequest];
        if ([self createSocket] == NO) {
            return StartResultsocketCreateFailed;
        }
    }

    int addrlen = (int)sizeof(destAddress);
    ssize_t cnt = 0;
    @synchronized(self) {
        cnt = sendto(fd, sendData, length, 0, (struct sockaddr *)&destAddress, addrlen);
    }
    if (cnt < 0) {
        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"failed to send %d to %08X", (int)cnt, addr]
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageHttpRequest];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSISOSenderFailed object:nil];
        return StartResultsendFailed;
    }
    
    return StartResultsuccess;
}

- (void)handleEnterbackground {
    @synchronized(self) {
        close(fd);
        fd = -1;
    }
}


@end

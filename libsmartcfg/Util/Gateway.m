//
//  GatewayChecker.m
//  SmartConfig
//
//  Created by Edden on 10/15/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#include <stdio.h>
#include <ctype.h>
#include <netinet/in.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <stdlib.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "HttpRequest.h"
#import "DebugMessage.h"
#import "libsmartcfg_constant.h"

#include "Gateway.h"
#include "route.h" /*the very same from google-code*/
//#import <net/route.h> // simulator

#define CTL_NET         4               /* network, see socket.h */

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@interface GatewayChecker() <HttpResultDelegate>
@property (nonatomic, strong) NSString * ip;
@property (nonatomic, strong) PingFirstHttpRequest * reqeust;
@end

@implementation GatewayChecker {
    BOOL isSupportedTimeout;
    int  previousWorkMode;
}

- (void)dealloc {
    [self.reqeust stopRequest];
    self.reqeust = nil;
}

- (NSString*)getGatewayIPFromInAddr:(in_addr_t) addr {
    NSString * result = nil;
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    if(sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        return nil;
    }
    if(l > 0) {
        buf = malloc(l);
        if(sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            return nil;
        }
        
        for(p = buf; p < (buf + l); p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                unsigned char octet[4]  = {0,0,0,0};
                for (int i=0; i<4; i++){
                    octet[i] = ( ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (i*8) ) & 0xFF;
                }
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    if (octet[0] == (addr & 0xFF) &&
                        octet[1] == ((addr >> 8) & 0xFF)) {
                        result = [NSString stringWithFormat:@"%d.%d.%d.%d", octet[0],octet[1],octet[2],octet[3]];
                        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"gateway ip is %@", result]
                                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                                    mode:DebugMessageOther];
                    }
                }
            }
        }
        free(buf);
    }
    return result;
}

- (void)lookupGatewayIP {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    in_addr_t i = inet_addr(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr));
                    self.ip = [self getGatewayIPFromInAddr:i];
                    break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
}

- (NSString*)getGatewayIP {
    return _ip;
}

- (void)checkGatewayMode {
    if (_ip == nil) {
        return;
    }
    self.reqeust = [[PingFirstHttpRequest alloc] initWithIP:_ip
                                                    relativePath:@"omnicfg.cgi"
                                                            user:@"admin"
                                                        password:@"admin"
                                                             tag:0];
    _reqeust.bRetry = NO;
    _reqeust.resultDelegate = self;
    _reqeust.timeout = TIMEOUT_DETECT_GATEWAY;
    [_reqeust startRequest];
}

- (void)stopCheck {
    if (self.reqeust == nil) {
        return;
    }
    [self.reqeust stopRequest];
    self.reqeust = nil;
}

- (void)onSuccess:(NSData *)result withTag:(NSInteger)tag {
    NSError * error = nil;
    NSDictionary * jsonObject = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil) {
        if (_delegate) {
            [_delegate onSmartConfigMode];
        }
        return;
    }
    int workMode  = [[jsonObject objectForKey:@"op_work_mode"] intValue];
    int remainTime = [[jsonObject objectForKey:@"RemainTime"] intValue];
    previousWorkMode = [[jsonObject objectForKey:@"omi_work_mode"] intValue];
    
    NSString * strValue = [jsonObject objectForKey:@"SupportTimeout"];
    isSupportedTimeout = [strValue isEqualToString:@"enable"];
    
    if (workMode != 1 || (isSupportedTimeout && remainTime == 0)) {
        // cannot config
        if (_delegate) {
            [_delegate onDirectModeButNotSettable];
        }
        return;
    }
    
    if (_delegate) {
        if (isSupportedTimeout == NO) {
            remainTime = -1;
        }
        [_delegate onDirectMode:remainTime];
    }
}

- (void)onFailed:(NSInteger)statusCode withTag:(NSInteger)tag {
    if (_delegate) {
        [_delegate onSmartConfigMode];
    }
}

- (BOOL)isSupportTimeout {
    return isSupportedTimeout;
}

- (BOOL)isPreviousStation {
    return previousWorkMode == mode_station_int;
}

@end
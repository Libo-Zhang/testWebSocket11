//
//  MIMOSender.h
//  libsmartcfg
//
//  Created by Edden on 10/26/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketLengthSender.h"

@interface MIMOSender : NSObject

- (instancetype)initWithTargetIP:(NSString*)ip;
- (void)setSSID:(NSString*)ssid Password:(NSString*)pw Mode:(int)mode;

- (void)start;
- (void)stop;

@end

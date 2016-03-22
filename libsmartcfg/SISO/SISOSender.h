//
//  MontageConfigSender.h
//  SmartConfig
//
//  Created by Edden on 10/2/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PacketLengthSender.h"

@interface SISOSender : NSObject

@property (nonatomic, copy) NSString * ssid;
@property (nonatomic, copy) NSString * password;

@property (assign) int baseLength;
@property (assign) int mode;

@property (assign) int sleepForBaseLength;
@property (assign) int sleepForChars;
@property (assign) int sleepForResend;

- (void)start;
- (void)stop;

@end

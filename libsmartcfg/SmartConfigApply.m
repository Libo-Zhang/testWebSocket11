//
//  SmartConfigApply.m
//  libsmartcfg
//
//  Created by Edden on 10/27/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import "SmartConfigApply.h"
#import "MIMOSender.h"
#import "SISOSender.h"
#import "libsmartcfg_constant.h"

#define basic_length        200

@interface SmartConfigApply()
@property (nonatomic, retain) SISOSender * sisoSender;
@end

@implementation SmartConfigApply {
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.sisoSender = [[SISOSender alloc] init];
        _sisoSender.baseLength = basic_length;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sisoStopped) name:kSISOSenderStopped object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSISOSenderStopped object:nil];
}

- (void)setSSID:(NSString*)ssid Password:(NSString *)pw Mode:(int)mode {
    _sisoSender.ssid = ssid;
    _sisoSender.password = pw;
    _sisoSender.mode = mode;
}

- (void)apply {
    [_sisoSender start];
}

- (void)stop {
    [_sisoSender stop];
}

- (void)sisoStopped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kConfigSenderStopped object:nil];
}

@end

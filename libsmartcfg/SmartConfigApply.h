//
//  SmartConfigApply.h
//  libsmartcfg
//
//  Created by Edden on 10/27/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartConfigApply : NSObject

- (void)setSSID:(NSString*)ssid Password:(NSString *)pw Mode:(int)mode;
- (void)apply;
- (void)stop;

@end

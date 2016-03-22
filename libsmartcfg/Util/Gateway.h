//
//  GatewayChecker.h
//  SmartConfig
//
//  Created by Edden on 10/15/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GatewayCheckDelegate <NSObject>
- (void)onDirectMode:(NSInteger)remainingTime;
- (void)onDirectModeButNotSettable;
- (void)onSmartConfigMode;
@end

@interface GatewayChecker : NSObject
- (void)lookupGatewayIP;
- (void)checkGatewayMode;
- (void)stopCheck;

@property (nonatomic, getter=getGatewayIP) NSString * getewayIP;
@property (nonatomic, assign) id<GatewayCheckDelegate> delegate;

@property (nonatomic, getter=isSupportTimeout)  BOOL isSupportTimeout;
@property (nonatomic, getter=isPreviousStation) BOOL isPreviousStation;
@end
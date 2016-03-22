//
//  AppDelegate.m
//  testWebSocket
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "libsmartcfg.h"
@import SystemConfiguration.CaptiveNetwork;

@interface AppDelegate ()
@property (nonatomic, strong) Reachability * reachability;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}
#pragma mark - About network reachability detect
- (void)onReachabilityChanged:(NSNotification *)sender {
    Reachability * reach = [sender object];
    NetworkStatus status = reach.currentReachabilityStatus;
    
    if (status == NotReachable) {
        [[DebugMessage sharedInstance] writeDebugMessage:@"WIFI Not Reachable"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageOther];
    } else {
        [[DebugMessage sharedInstance] writeDebugMessage:@"WIFI Reachable"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageOther];
    }
    [self fetchSSIDInfo];
}

#pragma mark - about SSID
- (NSDictionary *)fetchSSIDInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"%@ => %@", interfaceName, SSIDInfo]
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageOther];
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    if (SSIDInfo) {
        NSString * newSSID = [SSIDInfo valueForKey:@"SSID"];
        NSLog(@"%@", SSIDInfo);
        if (![self.currentSSID isEqualToString:newSSID]) {
            [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"SSID change from %@ to %@", _currentSSID, newSSID]
                                                    function:[NSString stringWithFormat:@"%s", __func__]
                                                        line:[NSString stringWithFormat:@"%d", __LINE__]
                                                        mode:DebugMessageOther];
            self.currentSSID = newSSID;
            //[[NSNotificationCenter defaultCenter] postNotificationName:kSSIDChangedNotification object:newSSID];
        }
    } else {
        self.currentSSID = nil;
        //[[NSNotificationCenter defaultCenter] postNotificationName:kSSIDChangedNotification object:@""];
    }
    
    return SSIDInfo;
}


@end

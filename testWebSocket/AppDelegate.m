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


@end

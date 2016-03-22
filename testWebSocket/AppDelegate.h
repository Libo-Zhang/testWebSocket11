//
//  AppDelegate.h
//  testWebSocket
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/*!
 *  Current detected ssid
 */
@property (nonatomic, copy) NSString * currentSSID;

@end


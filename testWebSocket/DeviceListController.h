//
//  DeviceListController.h
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListController : UITableViewController


- (void)scanByWifiSetting;
- (void)refreshList;
- (void)stopScan;
- (void)cleanList;

- (void)setClickTarget:(id)target action:(SEL)action;

@property (nonatomic, getter=getDeviceCount) NSUInteger numOfDevices;



@end

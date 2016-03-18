//
//  PlayVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "PlayVC.h"
#import "AFNetworking.h"
#import "HT_FPlayDevice.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayNearConnect.h"
@interface PlayVC ()

@end

@implementation PlayVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [[HT_FPlayManager getInsnstance]getUserdevicegetWithSuccess:^(id response) {
        
        HT_FPlayDevice *device = [HT_FPlayManager getInsnstance].currentDevice;
        device.connect_near = [HT_FPlayNearConnect new];
        [device.connect_near connectToDevice:device.ipAddress onPort:19211];
        
    } WithFailer:^(id response) {
        NSLog(@"失败");
        
    } WithError:^(NSError *error) {
        NSLog(@"出错");
    }];
}
//http://www.mydomain.com/api/userdeviceget
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)click:(id)sender {
    
    NSLog(@"%@",[HT_FPlayManager getInsnstance].currentDevice);
    
    //[device.connect_near sendMessage:1 WithotherParams:nil WithSongList:nil];
}
- (IBAction)playjimian:(id)sender {
    //需要传入播放列表
    NSJSONSerialization
    
}
- (IBAction)sdManager:(id)sender {
    //sd卡管理
    
    
}

@end

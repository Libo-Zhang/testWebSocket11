//
//  HT_ChooseDeviceVC.m
//  testWebSocket
//
//  Created by LB_Zhang on 16/3/21.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_ChooseDeviceVC.h"
#import "HT_FPlayManager.h"

@interface HT_ChooseDeviceVC ()

@end

@implementation HT_ChooseDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //先配置网络
    [self setUPNetWork];
    [self getOnlineDevice];
    
}
-(void)setUPNetWork{
    
}
-(void)getOnlineDevice{
    [[HT_FPlayManager getInsnstance]getUserdevicegetWithSuccess:^(NSArray *remoteDeviceArr) {//先得到userDevice
        [[HT_FPlayManager getInsnstance]getNeardevicegetWithSuccess:^(NSArray *nearDeviceArr) {//再得到nearDevice  进行比较而已
            for (HT_FPlayDevice *device in nearDeviceArr) {
                for (HT_FPlayDevice *remoteDevice in remoteDeviceArr) {
                    if ([remoteDevice.devid isEqualToString:device.devid]) {
                        NSLog(@" mac 地址相同 设备在线 保存下来");
                        [[HT_FPlayManager getInsnstance].onlineDevice addObject:device];
                    }
                }
                
            }
            
        } WithFailer:^(id response) {
            
        } WithError:^(NSError *error) {
            
        }];
        
    } WithFailer:^(id response) {
    } WithError:^(NSError *error) {
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end

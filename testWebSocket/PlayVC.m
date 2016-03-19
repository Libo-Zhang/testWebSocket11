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
#import "HT_SDcardVC.h"
#import "HT_PlayVC.h"
@interface PlayVC ()

@end

@implementation PlayVC
//比较列表中和附近的设备
-(void)remoteDevice:(NSArray *)remoteArr CompareNear:(NSArray *)nearArr{
    for (HT_FPlayDevice *remoteDevice in remoteArr) {
        for (HT_FPlayDevice *nearDevice in nearArr) {
            if ([remoteDevice.devid isEqualToString:nearDevice.devid]) {
                NSLog(@"列表中和附近的相匹配 放入 current中");
                //获得的是nearDevice  只有这个中才有ipAddress 可供使用
                [HT_FPlayManager getInsnstance].currentDevice = nearDevice;
                NSLog(@"%@",nearDevice.devid);
                break;
            }
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //getUser 放在remoteArr中
   // MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HT_FPlayDevice *device = [HT_FPlayDevice new];

    device.connect_near = [HT_FPlayNearConnect new];
    //NSLog(@"%@",device.ipAddress);
    [device.connect_near connectToDevice:@"192.168.0.106" onPort:19211];
    [HT_FPlayManager getInsnstance].currentDevice = device;
    //            hud.label.text = @"连接";
   
    
    
//    hud.contentColor = [UIColor blackColor];
//    //hud.mode = MBProgressHUDModeDeterminate;
//    [[HT_FPlayManager getInsnstance]getUserdevicegetWithSuccess:^(NSArray *remoteDeviceArr) {
//        [[HT_FPlayManager getInsnstance]getNeardevicegetWithSuccess:^(NSArray *nearDeviceArr) {
//
//            [self remoteDevice:remoteDeviceArr CompareNear:nearDeviceArr];
//            HT_FPlayDevice *device = [HT_FPlayManager getInsnstance].currentDevice;
//            device.connect_near = [HT_FPlayNearConnect new];
//            NSLog(@"%@",device.ipAddress);
//            [device.connect_near connectToDevice:device.ipAddress onPort:19211];
////            hud.label.text = @"连接";
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [hud hideAnimated:YES ];
//            });
//            
//        } WithFailer:^(id response) {
//            
//        } WithError:^(NSError *error) {
//            
//        }];
//    } WithFailer:^(id response) {
//        
//    } WithError:^(NSError *error) {
//        
//    }];

}
//http://www.mydomain.com/api/userdeviceget
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)click:(id)sender {
    HT_FPlayDevice *device = [HT_FPlayManager getInsnstance].currentDevice;
    //NSLog(@"%@",[HT_FPlayManager getInsnstance].currentDevice);
    
    [device.connect_near sendMessage:401 WithotherParams:nil WithSongList:nil];
}
- (IBAction)playjimian:(id)sender {
    //需要传入播放列表
    //NSJSONSerialization
    HT_PlayVC *playVC = [HT_PlayVC new];
    [self.navigationController pushViewController:playVC animated:YES];
    
}
- (IBAction)sdManager:(id)sender {
    //sd卡管理
    HT_SDcardVC *sdcard = [HT_SDcardVC new];
    
    [self.navigationController pushViewController:sdcard animated:YES];
    
}

@end

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
@interface PlayVC ()

@end

@implementation PlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[HT_FPlayManager getInsnstance]getUserdeviceget];
    
}
//http://www.mydomain.com/api/userdeviceget
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (IBAction)click:(id)sender {
    NSLog(@"%@",[HT_FPlayManager getInsnstance].currentDevice);
    
    
}

@end

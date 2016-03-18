//
//  HT_remoteControlVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_remoteControlVC.h"

@interface HT_remoteControlVC ()

@end

@implementation HT_remoteControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device.connect_remote = [HT_FPlayRemoteConnect new];
    //http://www.blue-zero.com/WebSocket/
    //ws://192.168.1.200:9001/mpp/command.cmd
    //ws://115.29.193.48:8088
    [self.device.connect_remote startWithWSAddress:@"ws://www.itinga.cn:9001/mpp/command.cmd"];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor greenColor];
    btn.frame = CGRectMake(100, 100, 50, 50);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)btnclick{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:@(103) forKey:@"action"];
         //[dictionary setValue:@(3) forKey:@"2222"];
        [dictionary setValue:[NSString stringWithFormat:@"UID:%ld",self.device.UID] forKey:@"from"];
        [dictionary setValue:[NSString stringWithFormat:@"DID:%ld",self.device.DID] forKey:@"to"];
        //[dictionary setValue:@[] forKey:@"songs"];

        NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    
        //NSString *sendMessage = [NSString stringWithFormat:@"%ld#%@",data.length,dataMessage];
        //NSData *sendData = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"~~~~~~~~~%@~~~~~~~~~~~~",dataMessage);
       [self.device.connect_remote sendMessage:dataMessage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

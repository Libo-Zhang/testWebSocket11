//
//  HT_FPlayRemoteConnect.m
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_FPlayRemoteConnect.h"
#import "SRWebSocket.h"
@interface HT_FPlayRemoteConnect () <SRWebSocketDelegate>
{
    SRWebSocket *webSocket;
    
}

@end

@implementation HT_FPlayRemoteConnect

-(void)start{
    webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://www.itinga.cn:9001/mpp/command.cmd"]]];
    //ws://192.168.1.200:9001/mpp/command.cmd
    //
    //ws://115.29.193.48:8088
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"MyProjectCookie"]];
    //不设置cookie 就会直接close的
    [webSocket setRequestCookies:cookies];
    webSocket.delegate = self;
    [webSocket open];
}

@end

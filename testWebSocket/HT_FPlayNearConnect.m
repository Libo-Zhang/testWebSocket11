//
//  HT_FPlayNearConnect.m
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_FPlayNearConnect.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayDevice.h"
@interface HT_FPlayNearConnect ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpServerSocket;
    //socket 对象
    GCDAsyncSocket *clientSocket;
    NSInteger stopRefresh;
}
@end
@implementation HT_FPlayNearConnect
-(void)createUdpSocket{
    stopRefresh = 0;
//    NSString *str = [NSString stringWithFormat:@"%@%d",@"My socket queue",arc4random() %1000];
//    const char * a =[str UTF8String];
    dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL);
    udpServerSocket = [[GCDAsyncUdpSocket alloc ] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [udpServerSocket bindToPort:19210 error:nil];
    //接受一次消息 只接受一次
    //[udpServerSocket receiveOnce:nil];
    //接受多次
    [udpServerSocket beginReceiving:nil];
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    //uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
//    NSLog(@"%@:%u",ip,port);
//     NSLog(@"%@",message);
    [self praseReciveMessage:message fromAddress:address];
}
-(void)praseReciveMessage:(NSString *)message fromAddress:(NSData *)address{
   
//  hitinga$00:32:10:00:a2:01$19211$HT100-89029$18$111
    if (stopRefresh == 5) {
        NSLog(@"停止寻找设备");
        [udpServerSocket close];
        //udpServerSocket.delegate = nil;
        //udpServerSocket = nil;
        //刷新界面
        //self.nearUpdateDeviceBlock(@"刷新了设备");
        return;
    }
    NSArray *array = [message componentsSeparatedByString:@"$"];
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"%@:%u",ip,port);
    NSLog(@"%@",message);
    if ([array.firstObject isEqualToString: @"hitinga"]) {
        NSLog(@"比较mac 地址:%@",array[1]);
        if ([self isNewDevice:array[1]]) {
            NSLog(@"~~~~~~~~~~~~~~~为新的mac地址");
            HT_FPlayDevice *newDevice = [HT_FPlayDevice new];
            newDevice.devid = array[1];
            newDevice.ipAddress = ip;
            newDevice.connect_near = self;
            //加入一个新的设备
            [[HT_FPlayManager getInsnstance].mDeviceList addObject:newDevice];
        }
    }
    //return NO;
}
-(BOOL)isNewDevice:(NSString *)macAdd{
    if ([macAdd isEqualToString:@""] || macAdd ==nil) {
        return NO;
    }
    for (HT_FPlayDevice *device in [HT_FPlayManager getInsnstance].mDeviceList) {
        if ([device.devid isEqualToString:macAdd]) {
            NSLog(@"这个mac地址已经有了");
            stopRefresh ++;
            return NO;
        }
    }
    
    return YES;
    
}
//监听和服务器的连接成功(socket 洞打通)
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功,可以发送消息");
    //[sendmsg 801];
    //执行接收数据(等待接收服务器的数据)
    [clientSocket readDataWithTimeout:-1 tag:10];
}
//监听是否发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"客户端发送成功");
}
//监听有服务区端发送来的消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //data.bytes
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _nearReturnMessageBlock(message);
    // self.showTextView.text = [NSString stringWithFormat:@"%@%@\n",self.showTextView.text,message];
   // NSLog(@"%@ tag:%ld",message,tag);
    //   [clientSocket writeData:data withTimeout:-1 tag:0];
    [clientSocket readDataWithTimeout:-1 tag:10];
//    [clientSocket readDataToLength:5 withTimeout:1 tag:0];
}
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
//    NSLog(@"~~~~~!!!!%ld",partialLength);
//}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"!~~~~~~~error%@",err);
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"Received bytes: %zd",partialLength);
}

- (void)connectToDevice:(NSString *)address onPort:(NSInteger)port {
    //创建clientSocket 对象
    clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //连接主机(IP 地址+端口)
    //uint16_t port = 19211;
    NSError *error = nil;
    // [self.clientSocket connectToUrl:[NSURL URLWithString:@"http://localhost:80"] withTimeout:.5 error:nil]
    //    NSData *data = [@"http://localhost:80" dataUsingEncoding:NSUTF8StringEncoding];
    //@"192.168.0.109"
    if(![clientSocket connectToHost:address onPort:port error:nil]){
        //返回是否连接成
        NSLog(@"客户端连接失败:%@",error);
    }else{
        NSLog(@"正在连接");
    }
}


- (void)sendMessage:(NSInteger )action WithotherParams:(NSArray *)params WithSongList:(NSArray *)songsList{
    //NSDictionary *dictionary = @{@"action" : @(action)};
    NSMutableDictionary *mudictioanry = [NSMutableDictionary dictionary];;
    [mudictioanry setObject:@(action) forKey:@"action"];
    
    switch (action) {
        case 0://点歌 需要用到
            
            break;
        case 6:
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"volume"];

            break;
        case 7:
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"position"];
            
            break;
        case 8:
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"playmode"];
            
            break;
        case 9:
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"idx"];
            
            break;
        default:
            break;
    }
    
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:mudictioanry options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //前提是连接成功
    //发送消息到服务器端
    //NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    //NSInteger action = [self.textField.text integerValue];
//    NSDictionary *dictionary = @{@"action" : @(action)};
//    //    [dictionary setValue:@(803) forKey:@"action"];
//    //    //[dictionary setValue:@(3) forKey:@"2222"];
//    //    [dictionary setValue:[NSString stringWithFormat:@"UID:%ld",device.UID] forKey:@"from"];
//    //    [dictionary setValue:[NSString stringWithFormat:@"DID:%ld",device.DID] forKey:@"to"];
//    //    //[dictionary setValue:@[] forKey:@"songs"];
//    //    { "to" : "DID:33", "action" : 1, "from" : "UID:83" }
//    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *dataMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *sendMessage = [NSString stringWithFormat:@"%ld#%@",data.length,dataMessage];
    NSData *sendData = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",sendMessage);
    
    //    NSData *ssss = [@{
    //                    "action" : 0
    //                    } dataUsingEncoding:NSUTF8StringEncoding];
    //经过5秒没发送  就把消息扔了   -1 没有限制  一般会在服务器端限定
    [clientSocket writeData:sendData withTimeout:5 tag:100];
    
}




@end

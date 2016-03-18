//
//  HT_GetUDPVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/16.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_GetUDPVC.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
@interface HT_GetUDPVC ()<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
{
    GCDAsyncUdpSocket *udpServerSocket;
    //socket 对象
    GCDAsyncSocket *clientSocket;
}
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation HT_GetUDPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUdpSocket];
    
}
-(void)createUdpSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL);
    udpServerSocket = [[GCDAsyncUdpSocket alloc ] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [udpServerSocket bindToPort:19210 error:nil];
    //接受一次消息 只接受一次
[udpServerSocket receiveOnce:nil];
    //[udpServerSocket beginReceiving:nil];
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"%@:%u",ip,port);
    NSLog(@"%@",message);
//    NearConnect * connctt [];
}
- (IBAction)btnclick:(id)sender {
    //创建clientSocket 对象
    clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //连接主机(IP 地址+端口)
    uint16_t port = 19211;
    NSError *error = nil;
    
    // [self.clientSocket connectToUrl:[NSURL URLWithString:@"http://localhost:80"] withTimeout:.5 error:nil]
    //    NSData *data = [@"http://localhost:80" dataUsingEncoding:NSUTF8StringEncoding];
    
    if(![clientSocket connectToHost:@"192.168.0.107" onPort:port error:nil]){
        //返回是否连接成
        NSLog(@"客户端连接失败:%@",error);
    }else{
        NSLog(@"正在连接");
    }
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
   // self.showTextView.text = [NSString stringWithFormat:@"%@%@\n",self.showTextView.text,message];
    NSLog(@"%@ tag:%ld",message,tag);
//   [clientSocket writeData:data withTimeout:-1 tag:0];
    [clientSocket readDataWithTimeout:-1 tag:10];
}
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
//    NSLog(@"~~~~~!!!!%ld",partialLength);
//}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"!~~~~~~~error%@",err);
}
- (IBAction)sendMessage:(id)sender {
    //前提是连接成功
    //发送消息到服务器端
    //NSData *data = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger action = [self.textField.text integerValue];
    NSDictionary *dictionary = @{@"action" : @(action)};
//    [dictionary setValue:@(803) forKey:@"action"];
//    //[dictionary setValue:@(3) forKey:@"2222"];
//    [dictionary setValue:[NSString stringWithFormat:@"UID:%ld",device.UID] forKey:@"from"];
//    [dictionary setValue:[NSString stringWithFormat:@"DID:%ld",device.DID] forKey:@"to"];
//    //[dictionary setValue:@[] forKey:@"songs"];
//    { "to" : "DID:33", "action" : 1, "from" : "UID:83" }
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *sendMessage = [NSString stringWithFormat:@"%ld#%@",dataMessage.length,dataMessage];
    NSData *sendData = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",sendMessage);
    
//    NSData *ssss = [@{
//                    "action" : 0
//                    } dataUsingEncoding:NSUTF8StringEncoding];
    //经过5秒没发送  就把消息扔了   -1 没有限制  一般会在服务器端限定
    [clientSocket writeData:sendData withTimeout:5 tag:100];
    
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"Received bytes: %zd",partialLength);
}

@end

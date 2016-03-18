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

-(void)startWithWSAddress:(NSString *)wsAddress{
    webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wsAddress]]];
    //ws://192.168.1.200:9001/mpp/command.cmd
    //ws://www.itinga.cn:9001/mpp/command.cmd
    //ws://115.29.193.48:8088
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"MyProjectCookie"]];
    //不设置cookie 就会直接close的
    [webSocket setRequestCookies:cookies];
    webSocket.delegate = self;
    [webSocket open];
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"receiveMessage%@",message);
//    if([message isEqualToString:@"服务器收到了你的消息：C"]){
//        NSLog(@"update userInfo");
//        [self getUserdeviceget];
//    }
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"Open it~!!!!!");
}
- (void)sendMessage:(NSString * )message{
    //[webSocket sendPing:[@"wowowo" dataUsingEncoding:NSUTF8StringEncoding]];
    [webSocket send:message];
}
// 获取当前用户下的所有设备
//-(void)getUserdeviceget{
//
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//
//    NSString *url = [NSString stringWithFormat:@"%@/api/userdeviceget",Address2];
//    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        userDeviceNum = responseObject[@"cnt"];
//        //从哪个设备发送消息
//        fromDeVidString = [responseObject[@"userinfo"] objectForKey:@"id"];
//        if ([responseObject[@"ret"] integerValue]== 0) {
//            self.mDeviceList =  [self praseDevice: responseObject[@"devices"]];
//            //获得新的列表   通过block返回
//            self.devideUpdateblocks(self.mDeviceList);
//        }
//       // NSLog(@"\n%ld \n devideID%@",device.ID,device.devid);
//       // NSLog(@"\nuserDeviceNum:%@ \nfromDeVidString:%@ \nDeviceList:%@",userDeviceNum,fromDeVidString,self.mDeviceList);
//    }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error){
//              NSLog(@"Error: %@", error);
//          }];
//}
//解析数据
//-(NSMutableArray *)praseDevice:(NSArray *)array{
//    NSMutableArray *mutableArr = [NSMutableArray array];
//    for (NSDictionary *dic in array) {
//           HT_FPlayDevice *device = [HT_FPlayDevice new];
//        [device setValuesForKeysWithDictionary:dic];
//        device.connect_remote = self.webSocket;
//        device.UID = [fromDeVidString integerValue];
//        [mutableArr addObject:device];
//    }
//    return mutableArr;
//}
- (void)sendMessage:(NSInteger )action WithotherParams:(NSArray *)params WithUid:(NSInteger)uid WithDid:(NSInteger)did WithSongList:(NSArray *)songsList{
    
}
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"关闭了webSocke 如果不是手动关闭 就代表传参数或者cookie出现错误,\\didcloseWithCOde,%ld\n reason:%@\nwasclean:%d",code,reason,wasClean);

}
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    //NSString *str = [NSString stringEncodingForData:pongPayload encodingOptions:NSUTF8StringEncoding convertedString:nil usedLossyConversion:YES];
    NSLog(@"receivePong Data");
}

@end

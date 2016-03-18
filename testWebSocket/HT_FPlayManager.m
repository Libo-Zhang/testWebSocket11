//
//  HT_FPlayManager.m
//  testarray
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 huaishan. All rights reserved.
//

#import "HT_FPlayManager.h"
#import "AFNetworking.h"
#import "HT_FPlayDevice.h"
//#define Address @"http://192.168.1.200:9001/mpp"
//http://www.hitinga.com
#define Address2 @"http://www.hitinga.com"
@interface HT_FPlayManager ()<SRWebSocketDelegate>
{
    NSString *toDevidString;   //发消息到哪个设备
    NSString *fromDeVidString; // 从哪个设备发消息
    NSNumber *userDeviceNum; //当前用户下设备的个数
}

//@property (nonatomic, strong) NSMutableArray *mDeviceList; //设备列表
@property (nonatomic, assign) int count; //设备数量
@property (nonatomic, assign) int current; //当前使用设备
//@property (nonatomic, strong) SRWebSocket *webSocket; //websocket remote
@property (nonatomic, strong) HT_FPlayNearConnect *nearConnect;

@end
@implementation HT_FPlayManager
static HT_FPlayManager *instance;
+(instancetype)getInsnstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HT_FPlayManager new];
        //打开webSocket
         //[instance start];
          instance.mDeviceList = [NSMutableArray array];
        instance.remoteDeviceList = [NSMutableArray array];
         //[instance getUserdeviceget];
    });
    return instance;
}
-(void)createNearUdpSocket{
    self.nearConnect = [HT_FPlayNearConnect new];
    [self.nearConnect createUdpSocket];

}

- (void)connectToNearDevice:(NSString *)address onPort:(NSInteger)port{
    self.nearConnect = [HT_FPlayNearConnect new];
    [self.nearConnect connectToDevice:address onPort:port];
}


//-(void)start{
//     self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://www.itinga.cn:9001/mpp/command.cmd"]]];
//    //ws://192.168.1.200:9001/mpp/command.cmd
//    //ws://www.itinga.cn:9001/mpp/command.cmd
//    //ws://115.29.193.48:8088
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    //对取出的cookie进行反归档处理
//        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"MyProjectCookie"]];
//    //不设置cookie 就会直接close的
//        [self.webSocket setRequestCookies:cookies];
//        self.webSocket.delegate = self;
//        [self.webSocket open];
//}
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
//    NSLog(@"receiveMessage%@",message);
////    if([message isEqualToString:@"服务器收到了你的消息：C"]){
////        NSLog(@"update userInfo");
////        [self getUserdeviceget];
////    }
//}
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
//    NSLog(@"Open it~!!!!!");
//}
//// 获取当前用户下的所有设备
-(void)getUserdeviceget{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/userdeviceget",Address2];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        userDeviceNum = responseObject[@"cnt"];
        //从哪个设备发送消息
        fromDeVidString = [responseObject[@"userinfo"] objectForKey:@"id"];
        if ([responseObject[@"ret"] integerValue]== 0) {
           
            self.remoteDeviceList =  [self praseDevice: responseObject[@"devices"]];
             NSLog(@"获得成功 %ld",self.remoteDeviceList.count);
            //获得新的列表   通过block返回
           // self.devideUpdateblocks(self.mDeviceList);
        }
       // NSLog(@"\n%ld \n devideID%@",device.ID,device.devid);
       // NSLog(@"\nuserDeviceNum:%@ \nfromDeVidString:%@ \nDeviceList:%@",userDeviceNum,fromDeVidString,self.mDeviceList);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"Error: %@", error);
          }];
}
////解析数据
-(NSMutableArray *)praseDevice:(NSArray *)array{
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (NSDictionary *dic in array) {
           HT_FPlayDevice *device = [HT_FPlayDevice new];
        [device setValuesForKeysWithDictionary:dic];
        //device.connect_remote = self;
        device.UID = [fromDeVidString integerValue];
        [mutableArr addObject:device];
    }
    return mutableArr;
}
@end

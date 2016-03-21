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


#import <objc/runtime.h>
@interface HT_FPlayNearConnect ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpServerSocket;
    //socket 对象
    GCDAsyncSocket *clientSocket;
    NSInteger stopRefresh;
    NSInteger flag;
}
@end
@implementation HT_FPlayNearConnect
#pragma mark udpServerSocket
-(void)createUdpSocket{
    stopRefresh = 0;
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
     // NSLog(@"%@",message);
    [self praseReciveMessage:message fromAddress:address];
}
-(void)praseReciveMessage:(NSString *)message fromAddress:(NSData *)address{
   
//hitinga$00:32:10:00:a2:01$19211$HT100-89029$18$111
    if (stopRefresh == 8) {
        NSLog(@"停止寻找设备");
        [udpServerSocket close];
        self.getNearDeviceBlock([HT_FPlayManager getInsnstance].mDeviceList);
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
-(void)getNeardeviceget{
    [self createUdpSocket];
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
#pragma mark - GCDAsyncSocket;
//监听和服务器的连接成功(socket 洞打通)
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功,可以发送消息");
    
    //执行接收数据(等待接收服务器的数据)
    //[clientSocket readDataWithTimeout:-1 tag:10];
 
     [clientSocket readDataToLength:1 withTimeout:-1 tag:0];
}
//监听是否发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
   
    NSLog(@"客户端发送成功");
}
//监听有服务区端发送来的消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
     @synchronized(self){//只能加一把锁
         //data.bytes
         NSMutableString *message = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSLog(@"~~~~!!!!!!%@",message);
         //     [clientSocket readDataWithTimeout:-1 tag:10];
         //    //返回不以#开头的
         //    if (![message hasSuffix:@"#"]) {
         //         _nearReturnMessageBlock(message);
         //    }
         
         if (flag == 0) {
             if ([message isEqualToString:@"#"]) {
                 flag = 1;
                 [clientSocket readDataToData:[@"#" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
             }else{
                 NSLog(@"在这些情况之外 flag 的值为");
                // [clientSocket readDataWithTimeout:-1 tag:0];
                 //flag = 0;
             }
             //[clientSocket readDataToLength:1 withTimeout:-1 tag:0];
         }else  if (flag == 1) {
             NSString *str = [message substringToIndex:message.length - 1];
             //NSLog(@"%@",str);
             [clientSocket readDataToLength:[str integerValue]  withTimeout:-1 tag:0];
             flag = 2;
         }else if(flag == 2){
             _nearReturnMessageBlock(message);
             [clientSocket readDataToLength:1 withTimeout:-1 tag:0];
             flag = 0;
         }else{// 有时候发送  没有返回  感觉是这里还需要改 测试
             NSLog(@"在这些情况之外 flag 的值为:%ld",flag);
              //[clientSocket readDataWithTimeout:-1 tag:0];
         }

     }    
}
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"~~~~~!!!!%ld",partialLength);
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"!~~~~~~~error%@",err);
    NSLog(@"重新连接");
     //[self connectToDevice:@"192.168.0.111" onPort:19211];
    
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
    
    
    //flag = 0;
    //NSDictionary *dictionary = @{@"action" : @(action)};
    NSMutableDictionary *mudictioanry = [NSMutableDictionary dictionary];;
    [mudictioanry setObject:@(action) forKey:@"action"];
    
    switch (action) {
        case 0://点歌 需要用到
            [mudictioanry setObject:songsList forKey:@"songs"];
            break;
        case 6://音量
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"volume"];

            break;
        case 7://seek
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"position"];
            
            break;
        case 8://设置播放模式
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"playmode"];
            
            break;
        case 9://播放当前列表中的某一个媒体
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"idx"];
            break;
        case 401://播放当前列表中的某一个媒体
            [mudictioanry setObject:@([params.firstObject integerValue]) forKey:@"offset"];
            
            break;
        case 203:
            [mudictioanry setObject:songsList forKey:@"songs"];
            break;
        case 403:
            [mudictioanry setObject:params.firstObject forKey:@"fileid"];
            break;
        default:
            break;
    }
    NSLog(@"~~~~%@",mudictioanry);
   // NSDictionary *dic = @{@"pubtime":@"0000-00-00"};
   //NSString *dicstr = @"{pubtime: "0000-00-00",id: 3390, res: [{duration: 197,filesize: 4720318,fmt: "mp3",quality: 0,lrc: "http://musicdata.baidu.com/data2/lrc/65644956/01%2E%E9%BB%84%E9%87%91%E7%94%B2%28%E7%BD%91%E7%BB%9C%E7%89%88%29.lrc",bitrate: 192,url: "http://www.hitinga.com/get/playUrl?ws=3&so=3390&rid=28403"}],name: "01.黄金甲(网络版)",compose: "",singer: "周杰伦",language: "",posters: "http://a.hiphotos.baidu.com/ting/pic/item/024f78f0f736afc320f09770b119ebc4b7451222.jpg"}"
    //NSData *data = [mudictioanry d]
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
    [clientSocket writeData:sendData withTimeout:-1 tag:100];
    
}

//- (NSDictionary *)dictionaryFromModel
//{
//    unsigned int count = 0;
//    
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
//    
//    for (int i = 0; i < count; i++) {
//        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        id value = [self valueForKey:key];
//        
//        //only add it to dictionary if it is not nil
//        if (key && value) {
//            if ([value isKindOfClass:[NSString class]]
//                || [value isKindOfClass:[NSNumber class]]) {
//                // 普通类型的直接变成字典的值
//                [dict setObject:value forKey:key];
//            }
//            else if ([value isKindOfClass:[NSArray class]]
//                     || [value isKindOfClass:[NSDictionary class]]) {
//                // 数组类型或字典类型
//                [dict setObject:[self idFromObject:value] forKey:key];
//            }
//            else {
//                // 如果model里有其他自定义模型，则递归将其转换为字典
//                [dict setObject:[value dictionaryFromModel] forKey:key];
//            }
//        } else if (key && value == nil) {
//            // 如果当前对象该值为空，设为nil。在字典中直接加nil会抛异常，需要加NSNull对象
//            [dict setObject:[NSNull null] forKey:key];
//        }
//    }
//    
//    free(properties);
//    return dict;
//}
//
//- (id)idFromObject:(nonnull id)object
//{
//    if ([object isKindOfClass:[NSArray class]]) {
//        if (object != nil && [object count] > 0) {
//            NSMutableArray *array = [NSMutableArray array];
//            for (id obj in object) {
//                // 基本类型直接添加
//                if ([obj isKindOfClass:[NSString class]]
//                    || [obj isKindOfClass:[NSNumber class]]) {
//                    [array addObject:obj];
//                }
//                // 字典或数组需递归处理
//                else if ([obj isKindOfClass:[NSDictionary class]]
//                         || [obj isKindOfClass:[NSArray class]]) {
//                    [array addObject:[self idFromObject:obj]];
//                }
//                // model转化为字典
//                else {
//                    [array addObject:[obj dictionaryFromModel]];
//                }
//            }
//            return array;
//        }
//        else {
//            return object ? : [NSNull null];
//        }
//    }
//    else if ([object isKindOfClass:[NSDictionary class]]) {
//        if (object && [[object allKeys] count] > 0) {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            for (NSString *key in [object allKeys]) {
//                // 基本类型直接添加
//                if ([object[key] isKindOfClass:[NSNumber class]]
//                    || [object[key] isKindOfClass:[NSString class]]) {
//                    [dic setObject:object[key] forKey:key];
//                }
//                // 字典或数组需递归处理
//                else if ([object[key] isKindOfClass:[NSArray class]]
//                         || [object[key] isKindOfClass:[NSDictionary class]]) {
//                    [dic setObject:[self idFromObject:object[key]] forKey:key];
//                }
//                // model转化为字典
//                else {
//                    [dic setObject:[object[key] dictionaryFromModel] forKey:key];
//                }
//            }
//            return dic;
//        }
//        else {
//            return object ? : [NSNull null];
//        }
//    }
//    
//    return [NSNull null];
//}

@end

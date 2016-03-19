//
//  HT_FPlayNearConnect.h
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HT_FPlayNearConnect : NSObject

@property (nonatomic, strong) void (^nearReturnMessageBlock) (id response);
-(void)createUdpSocket;
- (void)connectToDevice:(NSString *)address onPort:(NSInteger)port;
//发送消息
- (void)sendMessage:(NSInteger )action WithotherParams:(NSArray *)params WithSongList:(NSArray *)songsList;




//获得near 设备列表
-(void)getNeardeviceget;
@property (nonatomic, strong) void(^getNearDeviceBlock) (NSArray *array);
@end

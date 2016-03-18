//
//  HT_FPlayRemoteConnect.h
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HT_FPlayRemoteConnect : NSObject
@property (nonatomic, strong) void (^nearReturnMessageBlock) (id response);
-(void)startWithWSAddress:(NSString *)wsAddress;
//发送消息
- (void)sendMessage:(NSInteger )action WithotherParams:(NSArray *)params WithUid:(NSInteger)uid WithDid:(NSInteger)did WithSongList:(NSArray *)songsList;
- (void)sendMessage:(NSString * )action;



@end

//
//  HT_PlayStatusModel.h
//  testWebSocket
//
//  Created by uniview on 16/3/19.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 e{"action":104,"status":"paused","mute":false,"volume":"50","playmode":"2","song":"Coffee, Tea Or Me 我爱你(网络版)","songid":10,"position":34,"duration":196,"total":12,"idx":10}
 */
@interface HT_PlayStatusModel : NSObject
@property (nonatomic, assign) NSInteger action;

@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger idx;

//以下是暂停时的
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *mute;
@property (nonatomic, strong) NSString *volume;
@property (nonatomic, strong) NSString *playmode;
@property (nonatomic, strong) NSString *song;
@property (nonatomic, strong) NSString *songid;

@end

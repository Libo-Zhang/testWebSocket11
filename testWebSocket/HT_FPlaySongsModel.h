//
//  HT_FPlaySongsModel.h
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HT_FPlaySongsModel : NSObject
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *singer;
@property (nonatomic, strong) NSString  *compose;
@property (nonatomic, strong) NSString  *language;
@property (nonatomic, strong) NSString  *posters;
@property (nonatomic, strong) NSString  *pubtime;
@property (nonatomic, strong) NSArray   *res;
@end

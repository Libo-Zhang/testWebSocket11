//
//  HT_FPlayResModel.h
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HT_FPlayResModel : NSObject

@property (nonatomic, assign) NSInteger  duration;
@property (nonatomic, assign) NSUInteger filesize;
@property (nonatomic, strong) NSString   *fmt;
@property (nonatomic, assign) NSInteger  quality;
@property (nonatomic, assign) NSInteger  bitrate;
@property (nonatomic, strong) NSString   *url;
@property (nonatomic, strong) NSString   *lrc;
@end

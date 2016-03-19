//
//  HT_UI_PlayManager.h
//  HaiTing
//
//  Created by uniview on 16/3/8.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface HT_UI_PlayManager : NSObject
+ (HT_UI_PlayManager *)defaultManager;
@property(nonatomic, readonly, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, getter=isListCircle) BOOL listCircle;
- (void)playMusic:(NSURL *)musicURL;
//播放下一曲

//播放上一曲

//暂停
- (void)pause;

//继续播放
- (void)play;

//随机播放/顺序播放
//保存该视频资源的总时长，快进或快退的时候要用
@property (nonatomic, assign) CGFloat totalMovieDuration;
//
@property (nonatomic, strong) id playbackObserver;
@property (nonatomic, assign) int currentIndex;

@property (nonatomic, strong) void (^setProgressBlock) (double value);
@property (nonatomic, strong) void (^setSliderBlock) (double value);
@property (nonatomic, strong) void (^setTableViewBlock) (NSArray *array,NSIndexPath *index,NSArray *lyrics);

@property (nonatomic, strong) NSArray *lyricArr;
@end

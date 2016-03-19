//
//  HT_UI_PlayManager.m
//  HaiTing
//
//  Created by uniview on 16/3/8.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import "HT_UI_PlayManager.h"
#import "ZYLrcLine.h"
@implementation HT_UI_PlayManager
+ (HT_UI_PlayManager *)defaultManager{
    static HT_UI_PlayManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HT_UI_PlayManager new];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    });
    return manager;
}
- (void)playMusic:(NSURL *)musicURL{

    self.playerItem = [AVPlayerItem playerItemWithURL:musicURL];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    //_player = [AVPlayer playerWithURL:musicURL];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
     [self addProgressObserver];
    [_player play];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"正在播放...,视频总长度: %.2f",CMTimeGetSeconds(self.playerItem.duration));
        CMTime totalTime = self.playerItem.duration;
        self.totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){//加载进度
        NSTimeInterval timeInterval = [self availableDuration];
        // NSLog(@"time Interval :%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalduration = CMTimeGetSeconds(duration);
        self.setProgressBlock(timeInterval / totalduration);
        //[self.progress setProgress:timeInterval / totalduration animated:YES];
    }
}
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

//暂停
- (void)pause{
    [_player pause];
}
//继续播放
- (void)play{
   
    [_player play];
}
- (void)musicEnd{
    NSLog(@"....歌曲结束");
    _player = nil;
}
-(void)addProgressObserver{
    
    __weak typeof(self) myself = self;
    AVPlayerItem *playerItem = myself.player.currentItem;
    //设置每秒执行一次
    self.playbackObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //获取当前进度
        float current = CMTimeGetSeconds(time);
        
        NSLog(@"current~~~%f",current);
        
        //获取全部资源的大小
        float total = CMTimeGetSeconds([playerItem duration]);
        //计算出进度
        if (current) {
            myself.setSliderBlock(current / total);
           // [myself.slider setValue:(current / total) animated:NO];
            //            NSDate *d = [NSDate dateWithTimeIntervalSince1970:current];
            //            //剩余
            //            float remainSeconds = total - current;
            //            NSDate *remainDate = [NSDate dateWithTimeIntervalSince1970:remainSeconds];
            //这句不加   就不会隐藏  因为每秒都会因为 label  而显示 view
            //            if (myself.isFirstTap) {
            //                //注意在block中 小心循环引用
            //                [myself setTopRightBottomViewShowToHidden];
            //            } else {
            //                [myself setTopRightBottomViewHiddenToShow];
            //            }
            //            myself.topPastTimeLabel.text = [myself getTimeByDate:d byProgress:current];
            //            myself.topRemainLable.text = [myself getTimeByDate:remainDate byProgress:remainSeconds];
        }
        
        
        
        
        int minute = current / 60;
        int second = (int)current % 60;
        int msecond = (current - (int)current) * 100;
        NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, msecond];
        //NSLog(@"currentTimeStr%@",currentTimeStr);
        for (int i = 0; i < myself.lyricArr.count; i++) {
            ZYLrcLine *currentLine = myself.lyricArr[i];
            NSString *currentLineTime = currentLine.time;
            NSString *nextLineTime = nil;
            
            if (i + 1 < myself.lyricArr.count) {
                ZYLrcLine *nextLine = myself.lyricArr[i + 1];
                nextLineTime = nextLine.time;
            }
            if (currentLine.time == nil) {
                continue;
            }
            if (([currentTimeStr compare:currentLineTime] != NSOrderedAscending) && ([currentTimeStr compare:nextLineTime] == NSOrderedAscending) && (myself.currentIndex != i)) {
                
                NSLog(@"currentLineTime~~~%@",currentLineTime);
                NSArray *reloadLines = @[
                                         [NSIndexPath indexPathForItem:myself.currentIndex inSection:0],
                                         [NSIndexPath indexPathForItem:i inSection:0]
                                         ];
                myself.currentIndex = i;
                
                NSIndexPath *movePath = [NSIndexPath indexPathForRow:i inSection:0];
                myself.setTableViewBlock(reloadLines,movePath,myself.lyricArr);
                
                //[myself.lyricTableView reloadRowsAtIndexPaths:reloadLines withRowAnimation:UITableViewRowAnimationNone];
                
                //[myself.lyricTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:myself.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                //[myself.lyricTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
            
        }
    }];
    
}








@end

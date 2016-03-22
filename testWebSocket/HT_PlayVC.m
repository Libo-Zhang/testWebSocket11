//
//  HT_PlayVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/19.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_PlayVC.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayDevice.h"
#import "HT_PlayStatusModel.h"
#import "ZYLrcLine.h"
#import "HT_FPlaySongsModel.h"
#import "HT_FPlayResModel.h"
#import <AVFoundation/AVFoundation.h>
@interface HT_PlayVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIButton *pauseorstartBtn;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) HT_FPlayDevice *device;
@property (nonatomic, strong) HT_PlayStatusModel *statusModle;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *lyricArr;
@property (nonatomic, strong) UITableView *lyricTV;
//@property (nonatomic, strong)  <#str#>;
@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) HT_FPlaySongsModel *songModel  ;
@end

@implementation HT_PlayVC
-(void)initAudioSession{
    
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    // add event handler, for this example, it is `volumeChange:` method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}
- (void)volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    
    [self.device.connect_near sendMessage:6 WithotherParams:@[@(volume * 100)] WithSongList:nil];
    NSLog(@"volume %lf",volume * 100);
    //
    dispatch_queue_t  queue =   dispatch_queue_create("one",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue,^{
        [NSThread sleepForTimeInterval:2];
    });
    //执行完上面 执行下面的方法
    
    dispatch_barrier_async(queue,^{
        //启动监听
        [self.timer setFireDate:[NSDate distantPast]];
        
    });
    
    NSLog(@"~~~%lf",volume);
    
}
-(void)dealloc{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAudioSession];

    for (HT_FPlaySongsModel *songs in [HT_FPlayManager getInsnstance].nearSongList) {
        NSLog(@"songsName:%@",songs.name);
    }
    _flag = 0;
    self.device = [HT_FPlayManager getInsnstance].currentDevice;
    self.view.backgroundColor = [UIColor whiteColor];
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 130, 200, 100)];
    [self.slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slider];
   // [self loadData];
    //循环send message101  获得播放状态
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    [self loadData2];
  
    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 180, 200, 100)];
    [self.volumeSlider addTarget:self action:@selector(volumeChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.volumeSlider];
    
    UIButton *playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseorstartBtn = playOrPause;
    playOrPause.frame = CGRectMake(0, 100, 100, 44);
    [playOrPause setTitle:@"播放" forState:UIControlStateNormal];
    [self.view addSubview:playOrPause];
    [playOrPause addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [playOrPause setBackgroundColor:[UIColor redColor]];
    
    UIButton *Next = [UIButton buttonWithType:UIButtonTypeCustom];
    Next.frame = CGRectMake(110, 100, 44, 44);
    [Next setTitle:@"Next" forState:UIControlStateNormal];
    [self.view addSubview:Next];
    [Next addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
     [Next setBackgroundColor:[UIColor redColor]];
    
    UIButton *Last = [UIButton buttonWithType:UIButtonTypeCustom];
    Last.frame = CGRectMake(150, 100, 44, 44);
    [Last setTitle:@"Last" forState:UIControlStateNormal];
    [self.view addSubview:Last];
    [Last addTarget:self action:@selector(Last) forControlEvents:UIControlEventTouchUpInside];
     [Last setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:playOrPause];
    [self.view addSubview:Next];
    [self.view addSubview:Last];
    
    self.lyricTV = [[UITableView alloc] init];
    self.lyricTV.frame = CGRectMake(0, 300, 300, 200);
    self.lyricTV.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.lyricTV];
    self.lyricTV.delegate = self;
    self.lyricTV.dataSource = self;
    self.lyricTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSLog(@"`````````````````%ld", [HT_FPlayManager getInsnstance].nearSongList.count);

    
}
-(void)playOrPause:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"暂停"]) {
        //发送暂停指令
        [self.device.connect_near sendMessage:2 WithotherParams:nil WithSongList:nil];
        [btn setTitle:@"播放" forState:UIControlStateNormal];
    }else if ([btn.titleLabel.text isEqualToString:@"播放"]) {
        //发送播放指令
        [self.device.connect_near sendMessage:1 WithotherParams:nil WithSongList:nil];
        [btn setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
-(void)next{
    NSLog(@"next");
    self.lyricArr = nil;
    [self.lyricTV reloadData];
    [HT_FPlayManager getInsnstance].songListIndex++;
    _flag = 0;
    [self.timer setFireDate:[NSDate distantFuture]];
    dispatch_queue_t  queue =   dispatch_queue_create("two",DISPATCH_QUEUE_CONCURRENT);
     [self.device.connect_near sendMessage:9 WithotherParams:@[@([HT_FPlayManager getInsnstance].songListIndex)] WithSongList:nil];
    dispatch_async(queue,^{
        [NSThread sleepForTimeInterval:2];
    });
    //执行完上面 执行下面的方法
    dispatch_barrier_async(queue,^{
        //启动监听
        [self.timer setFireDate:[NSDate distantPast]];
    });
    
}
-(void)Last{
    self.lyricArr = nil;
    [self.lyricTV reloadData];
    if ([HT_FPlayManager getInsnstance].songListIndex == 0) {
        
    }else{
        
    [HT_FPlayManager getInsnstance].songListIndex--;
    }
    _flag = 0;
    [self.device.connect_near sendMessage:9 WithotherParams:@[@([HT_FPlayManager getInsnstance].songListIndex)] WithSongList:nil];
    NSLog(@"last");
}
/*
 因为传进来的有些不是json  有些事json 需要判断一下
 {"action":104,"status":"paused","mute":false,"volume":"50","playmode":"2","song":"Coffee, Tea Or Me 我爱你(网络版)","songid":10,"position":34,"duration":196,"total":12,"idx":10}
 */
-(void)loadData{
    [self.device.connect_near sendMessage:101 WithotherParams:@[@(0)] WithSongList:nil];
}
-(void)loadData2{
    //self.device.connect_near sendMessage:<#(NSInteger)#> WithotherParams:<#(NSArray *)#> WithSongList:<#(NSArray *)#>
    __weak typeof (self)weakself = self;
   // [self.device.connect_near sendMessage:101 WithotherParams:@[@(0)] WithSongList:nil];
    self.device.connect_near.nearReturnMessageBlock = ^(NSString *message){
        NSLog(@"message%@",message);
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if ( [NSJSONSerialization isValidJSONObject:response]) {
            NSLog(@"是json数据");
            if (_flag == 0) {//第一次  代表歌词没有被加载
                weakself.songModel = [HT_FPlayManager getInsnstance].nearSongList[[response[@"idx"] integerValue]];
                if (weakself.songModel.res.count != 0) {
                    HT_FPlayResModel *res = weakself.songModel.res[0];
                    weakself.lyricArr = [ZYLrcLine lrcLinesWithFileName:res.lrc];
                    //weakself.lyricArr = @[@"没有歌曲源头"];
                    if (weakself.lyricArr.count == 0) {//没有歌词源头
                        ZYLrcLine *line = [ZYLrcLine new];;
                        line.word = @"没有歌词源头";
                        weakself.lyricArr = @[line];
                    }else{
                        //NSIndexPath *index =  [NSIndexPath indexPathForItem:0 inSection:0];
                    }
                    [weakself.lyricTV reloadData];
                }else{
                   // weakself.lyricArr = @[@"没有歌曲源头"];
                    [weakself.lyricTV reloadData];
                }
                _flag = 1;
                return;
            }
            if ([response[@"action"] integerValue] == 104) {//暂停状态的返回
                [weakself.pauseorstartBtn setTitle:@"播放" forState:UIControlStateNormal];
                HT_PlayStatusModel *model = [HT_PlayStatusModel new];
                [model setValuesForKeysWithDictionary:response];
                weakself.statusModle = model;
                if (self.statusModle.duration == 0) {
                    NSLog(@"避免错误");
                }else{
                    NSLog(@"~~~~~~~~~~~~~%f", model.position/(self.statusModle.duration * 1.0));
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.slider setValue: model.position/(model.duration * 1.0)];
                        [weakself.volumeSlider setValue: [model.volume integerValue]/100.0];
                    });
                }
               
                //[weakself.device.connect_near sendMessage:101 WithotherParams:@[@(0)] WithSongList:nil];
            }
            if ([response[@"action"] integerValue] == 102) {//播放状态的返回
                HT_PlayStatusModel *model = [HT_PlayStatusModel new];
                [weakself.pauseorstartBtn setTitle:@"暂停" forState:UIControlStateNormal];
                [model setValuesForKeysWithDictionary:response];
                weakself.statusModle = model;
                NSLog(@"~~~~~~~~~~~~~%f", model.position/(self.statusModle.duration * 1.0));
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.slider setValue: model.position/(model.duration * 1.0)];
                    //[weakself.volumeSlider setValue: [model.volume integerValue]/100.0];
                });
                
                
                //歌词时间计算
                int minute = model.position / 60;
                int second = (int)model.position % 60;
                //int msecond = (model.position - (int)model.position) * 100;
                NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
                //NSLog(@"currentTimeStr%@",currentTimeStr);
                for (int i = 0; i < weakself.lyricArr.count; i++) {
                    ZYLrcLine *currentLine = weakself.lyricArr[i];
                    NSString *currentLineTime = currentLine.time;
                    NSString *nextLineTime = nil;
                    
                    if (i + 1 < weakself.lyricArr.count) {
                        ZYLrcLine *nextLine = weakself.lyricArr[i + 1];
                        nextLineTime = nextLine.time;
                    }
                    if (currentLine.time == nil) {
                        continue;
                    }
                    if (([currentTimeStr compare:currentLineTime] != NSOrderedAscending) && ([currentTimeStr compare:nextLineTime] == NSOrderedAscending)&& (weakself.currentIndex != i) ) {
                         //&& (weakself.currentIndex != i)
                        NSLog(@"currentLineTime~~~%@",currentLineTime);
                        NSArray *reloadLines = @[
                                                 [NSIndexPath indexPathForItem:weakself.currentIndex inSection:0],
                                                 [NSIndexPath indexPathForItem:i inSection:0]
                                                 ];
                        weakself.currentIndex = i;
                        
                        NSIndexPath *movePath = [NSIndexPath indexPathForRow:i inSection:0];
                        //weakself.setTableViewBlock(reloadLines,movePath,weakself.lyricArr);
                        
                        [weakself.lyricTV reloadRowsAtIndexPaths:reloadLines withRowAnimation:UITableViewRowAnimationNone];
                        [weakself.lyricTV scrollToRowAtIndexPath:movePath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    }
                    
                }
 
            }
        }else{
            NSLog(@"不是json数据");
            NSArray *actionArr = [message componentsSeparatedByString:@"action:"];
            NSString *actionStr = [message substringWithRange:NSMakeRange(8, 3)];
            if ([actionStr isEqualToString:@"202"]) {
                NSArray *array = [message componentsSeparatedByString:@"songs"];
                NSString *str = array.lastObject;
                NSString *str2 = [str substringWithRange:NSMakeRange(1, str.length - 2 )];;
                NSLog(@"songs %@",str2);
                
                NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"%@",error);
                NSLog(@"%@",response);
            }
        }
    };
}
-(void)changeSlider:(UISlider *)slider{
    [self.timer setFireDate:[NSDate distantFuture]];
    NSInteger position = (NSInteger)(slider.value * self.statusModle.duration);
      NSLog(@"postiion1111%ld",position);
  
    [self.device.connect_near sendMessage:7 WithotherParams:@[@(position)] WithSongList:nil];
    
    //
    dispatch_queue_t  queue =   dispatch_queue_create("one",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue,^{
        [NSThread sleepForTimeInterval:2];
    });
    //执行完上面 执行下面的方法
    
    dispatch_barrier_async(queue,^{
        //启动监听
          [self.timer setFireDate:[NSDate distantPast]];
        
    });
    
    
    //[self.device.connect_near sendMessage:2 WithotherParams:@[@(position)] WithSongList:nil];
}
-(void)volumeChange:(UISlider *)slider{
    [self.timer setFireDate:[NSDate distantFuture]];
    NSInteger position = (NSInteger)(slider.value * self.statusModle.duration);
    NSLog(@"postiion1111%ld",position);
    
    [self.device.connect_near sendMessage:6 WithotherParams:@[@(slider.value * 100)] WithSongList:nil];
    NSLog(@"volume %lf",slider.value * 100);
    //
    dispatch_queue_t  queue =   dispatch_queue_create("one",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue,^{
        [NSThread sleepForTimeInterval:2];
    });
    //执行完上面 执行下面的方法
    
    dispatch_barrier_async(queue,^{
        //启动监听
        [self.timer setFireDate:[NSDate distantPast]];
        
    });
    
}
#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lyricArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    ZYLrcLine *line = self.lyricArr[indexPath.row];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if (indexPath.row == self.currentIndex) {
        [cell.textLabel setTextColor:[UIColor blueColor]];
    }else{
         [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    cell.textLabel.text = line.word;
    return cell;
}

@end

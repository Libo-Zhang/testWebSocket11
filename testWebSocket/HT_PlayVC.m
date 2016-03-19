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

@interface HT_PlayVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) HT_FPlayDevice *device;
@property (nonatomic, strong) HT_PlayStatusModel *statusModle;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *lyricArr;
@property (nonatomic, strong) UITableView *lyricTV;

@end

@implementation HT_PlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [HT_FPlayManager getInsnstance].currentDevice;
    self.view.backgroundColor = [UIColor whiteColor];
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 200, 200, 100)];
    [self.slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slider];
    [self loadData];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(loadData) userInfo:nil repeats:YES];

  
    
    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 250, 200, 100)];
    [self.volumeSlider addTarget:self action:@selector(volumeChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.volumeSlider];
    
    UIButton *playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
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
    [self.device.connect_near sendMessage:4 WithotherParams:nil WithSongList:nil];
}
-(void)Last{
    NSLog(@"last");
}
/*
 因为传进来的有些不是json  有些事json 需要判断一下
 {"action":104,"status":"paused","mute":false,"volume":"50","playmode":"2","song":"Coffee, Tea Or Me 我爱你(网络版)","songid":10,"position":34,"duration":196,"total":12,"idx":10}
 */
-(void)loadData{
    //self.device.connect_near sendMessage:<#(NSInteger)#> WithotherParams:<#(NSArray *)#> WithSongList:<#(NSArray *)#>
    __weak typeof (self)weakself = self;
    [self.device.connect_near sendMessage:101 WithotherParams:@[@(0)] WithSongList:nil];
    self.device.connect_near.nearReturnMessageBlock = ^(NSString *message){
        NSLog(@"message%@",message);
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if ( [NSJSONSerialization isValidJSONObject:response]) {
            NSLog(@"是json数据");
            
            if ([response[@"action"] integerValue] == 104) {//暂停状态的返回
                HT_PlayStatusModel *model = [HT_PlayStatusModel new];
                [model setValuesForKeysWithDictionary:response];
                weakself.statusModle = model;
                NSLog(@"~~~~~~~~~~~~~%f", model.position/(self.statusModle.duration * 1.0));
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.slider setValue: model.position/(model.duration * 1.0)];
                    [weakself.volumeSlider setValue: [model.volume integerValue]/100.0];
                });
                //[weakself.device.connect_near sendMessage:101 WithotherParams:@[@(0)] WithSongList:nil];
            }
            if ([response[@"action"] integerValue] == 102) {//播放状态的返回
                HT_PlayStatusModel *model = [HT_PlayStatusModel new];
                [model setValuesForKeysWithDictionary:response];
                weakself.statusModle = model;
                NSLog(@"~~~~~~~~~~~~~%f", model.position/(self.statusModle.duration * 1.0));
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.slider setValue: model.position/(model.duration * 1.0)];
                    //[weakself.volumeSlider setValue: [model.volume integerValue]/100.0];
                });
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = @"111";
    return cell;
}

@end

//
//  HT_NearDetailVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_NearDetailVC.h"
#import "HT_FPlayManager.h"
#import "HT_FPlaySongsModel.h"
#import "HT_FPlayResModel.h"
@interface HT_NearDetailVC ()
@property (nonatomic, strong) UITextField *textfield;
@property (nonatomic, strong) UITextField *textfield2;
@end

@implementation HT_NearDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 400, 40, 40);
    [btn setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:btn];
    
    
    self.textfield = [UITextField new];
    self.textfield.frame = CGRectMake(100, 200, 200, 50);
    self.textfield.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.textfield];
    
    
    self.textfield2 = [UITextField new];
    self.textfield2.frame = CGRectMake(100, 300, 200, 50);
    self.textfield2.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.textfield2];
    
    
   // [[HT_FPlayManager getInsnstance] connectToNearDevice:self.device.ipAddress onPort:19211];
    [self.device.connect_near connectToDevice:self.device.ipAddress onPort:19211];
    [btn addTarget:self action:@selector(btncick) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"`````%@  ~~~~~%@",_device.devid,_device);
    
}
-(void)btncick{
    HT_FPlaySongsModel *songs = [HT_FPlaySongsModel new];
    HT_FPlayResModel *res = [HT_FPlayResModel new];
    
    
//    @property (nonatomic, assign) NSInteger id;
//    @property (nonatomic, assign) NSInteger type;
//    @property (nonatomic, strong) NSString  *name;
//    @property (nonatomic, strong) NSString  *singer;
//    @property (nonatomic, strong) NSString  *compose;
//    @property (nonatomic, strong) NSString  *language;
//    @property (nonatomic, strong) NSString  *posters;
//    @property (nonatomic, strong) NSString  *pubtime;
//    @property (nonatomic, strong) NSArray   *res;
//    songs.name = @"01.黄金甲(网络版)";
//    songs.ID = 3390;
//    songs.singer = @"周杰伦";
//    res.url = @"http://www.hitinga.com/get/playUrl?ws=3&so=3390&rid=28403";
//    res.lrc = @"http://musicdata.baidu.com/data2/lrc/65644956/01%2E%E9%BB%84%E9%87%91%E7%94%B2%28%E7%BD%91%E7%BB%9C%E7%89%88%29.lrc";
//    res.fmt = @"mp3";
//    res.duration = 197;
//    res.filesize = 4720318;
//    res.quality = 0;
//    songs.res = @[res];
    
    NSDictionary *dic = @{
//                          @"name":@"01.黄金甲(网络版)",@"id":@(3390),@"type":@(1),@"compose":@"", @"language":@"",@"posters":@"",@"pubtime":@"",@"singer":@"周杰伦",
//                          @"res":@[@{@"url":@"http://www.hitinga.com/get/playUrl?ws=3&so=3390&rid=28403",
//                                     @"lrc":@"http://musicdata.baidu.com/data2/lrc/65644956/01%2E%E9%BB%84%E9%87%91%E7%94%B2%28%E7%BD%91%E7%BB%9C%E7%89%88%29.lrc",
//                                     @"fmt":@"mp3",
//                                     @"duration":@(197),
//                                     @"filesize":@(4720318),
//                                     @"quality":@(0)}]
   };
    
    [self.device.connect_near sendMessage:[self.textfield.text integerValue] WithotherParams:@[self.textfield2.text] WithSongList:@[dic]];
    self.device.connect_near.nearReturnMessageBlock = ^ (id response){
        NSLog(@"`````%@",response);
    };
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  PlayVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/18.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "PlayVC.h"
#import "AFNetworking.h"
#import "HT_FPlayDevice.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayNearConnect.h"
#import "HT_PlayListtVC.h"
#import "HT_PlayVC.h"
#import "HT_FPlaySongsModel.h"
#import "HT_FPlayResModel.h"
#import "JSONModel.h"
#import <objc/runtime.h>
#import "HT_SDManagerVC.h"
#import "HT_ChooseDeviceVC.h"
#import "BindVC2.h"
#import "BindVC.h"
@interface PlayVC ()

@end

@implementation PlayVC
//比较列表中和附近的设备
-(void)remoteDevice:(NSArray *)remoteArr CompareNear:(NSArray *)nearArr{
    for (HT_FPlayDevice *remoteDevice in remoteArr) {
        for (HT_FPlayDevice *nearDevice in nearArr) {
            if ([remoteDevice.devid isEqualToString:nearDevice.devid]) {
                NSLog(@"列表中和附近的相匹配 放入 current中");
                //获得的是nearDevice  只有这个中才有ipAddress 可供使用
                [HT_FPlayManager getInsnstance].currentDevice = nearDevice;
                NSLog(@"%@",nearDevice.devid);
                break;
            }
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //getUser 放在remoteArr中
   // MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HT_FPlayDevice *device = [HT_FPlayDevice new];

    device.connect_near = [HT_FPlayNearConnect new];
    [device.connect_near connectToDevice:@"192.168.0.123" onPort:19211];
    [HT_FPlayManager getInsnstance].currentDevice = device;
   
    //[self loadSongListData];
}
//http://www.mydomain.com/api/userdeviceget
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)songList:(UIButton *)sender {
    //sd卡管理
    HT_PlayListtVC *sdcard = [HT_PlayListtVC new];
    
    [self.navigationController pushViewController:sdcard animated:YES];
    
}
- (IBAction)click:(id)sender {
    HT_FPlayDevice *device = [HT_FPlayManager getInsnstance].currentDevice;
    //NSLog(@"%@",[HT_FPlayManager getInsnstance].currentDevice);
    
//    [device.connect_near sendMessage:401 WithotherParams:nil WithSongList:nil];
     [device.connect_near sendMessage:403 WithotherParams:@[@(126627449)] WithSongList:nil];
    device.connect_near.nearReturnMessageBlock = ^(NSString *str){
        
    };
}
- (IBAction)playjimian:(id)sender {
    //需要传入播放列表
    //NSJSONSerialization
    HT_PlayVC *playVC = [HT_PlayVC new];
    [self.navigationController pushViewController:playVC animated:YES];
    
}
- (IBAction)sdManager:(id)sender {
    HT_SDManagerVC *sdManager = [HT_SDManagerVC new];
    [self.navigationController pushViewController:sdManager animated:YES];
    
}
- (IBAction)diange:(UIButton *)sender {
    
    HT_FPlayDevice *device = [HT_FPlayManager getInsnstance].currentDevice;
    //NSLog(@"%@",[HT_FPlayManager getInsnstance].currentDevice);
    NSArray *arr = @[@{@"id":@(642696),@"type":@(1),@"name":@"Telephone",@"singer":@"Lady Gaga",@"res":@[@{@"duration":@(290),@"fmt":@"flac",@"url":@"http://www.hitinga.com/get/playUrl?ws=3&so=642696&rid=3521313"}]},
         @{@"id":@(1),@"type":@(1),@"name":@"好久不见",@"singer":@"陈奕迅",@"res":@[@{@"duration":@(252),@"fmt":@"mp3",@"url":@"http://www.hitinga.com/get/playUrl?ws=3&so=1&rid=1469",@"lrc":@"http://musicdata.baidu.com/data2/lrc/242604231/%E5%A5%BD%E4%B9%85%E4%B8%8D%E8%A7%81.lrc"}]},
        @{@"id":@(2),@"type":@(1),@"name":@"十年",@"singer":@"陈奕迅",@"res":@[@{@"duration":@(205),@"fmt":@"mp3",@"url":@"http://www.hitinga.com/get/playUrl?ws=3&so=2&rid=14",@"lrc":@"http://musicdata.baidu.com/data2/lrc/129452375/%E5%8D%81%E5%B9%B4%2D.lrc"}]}
                     ];
    HT_FPlaySongsModel *songsModel = [HT_FPlaySongsModel new];
    HT_FPlayResModel *res = [HT_FPlayResModel new];
    res.duration = 290;
    res.fmt = @"flac";
    res.url = @"http://www.hitinga.com/get/playUrl?ws=3&so=642696&rid=3521313";
    //songsModel.ID = id;
    songsModel.id = 642696;
    songsModel.type = 1;
    songsModel.name = @"Telephone";
    songsModel.res = @[res];
    
    //NSArray *array = [JSONModel arrayOfDictionariesFromModels:@[songsModel]];
    NSDictionary *array = [self dictionaryWithModel:songsModel];
    NSLog(@"ssss%@",array);
    [device.connect_near sendMessage:203 WithotherParams:nil WithSongList:arr];
    
}
/*!
 * @brief 把对象（Model）转换成字典
 * @param model 模型对象
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithModel:(id)model {
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // 获取类名/根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    
    // 获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }
        
        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}


- (IBAction)chooseDevice:(UIButton *)sender {
    HT_ChooseDeviceVC *chooose = [HT_ChooseDeviceVC new];
    [self.navigationController pushViewController:chooose animated:YES];
    
    
}
- (IBAction)bangDingDevice:(UIButton *)sender {
    
    
    BindVC *bindVC = [BindVC new];
    [self.navigationController pushViewController:bindVC animated:YES];
    
    
    
}


-(void)loadSongListData{
    __weak typeof (self)weakself = self;
    [HT_FPlayManager getInsnstance].nearSongList = [NSMutableArray array];
    [ [HT_FPlayManager getInsnstance].currentDevice .connect_near sendMessage:201 WithotherParams:@[@(0)] WithSongList:nil];
    [HT_FPlayManager getInsnstance].currentDevice .connect_near.nearReturnMessageBlock = ^(NSString *message){
        NSLog(@"message%@",message);
        
        NSString *actionStr = [message substringWithRange:NSMakeRange(8, 3)];
        if ([actionStr isEqualToString:@"202"]) {
            NSArray *array = [message componentsSeparatedByString:@"songs"];
            NSString *str = array.lastObject;
            NSString *str2 = [str substringWithRange:NSMakeRange(1, str.length - 2 )];;
            NSLog(@"songs %@",str2);
            NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            for (NSDictionary *dic in response) {
                HT_FPlaySongsModel *model = [HT_FPlaySongsModel new];
                [model setValuesForKeysWithDictionary:dic];
                NSMutableArray *resmuArr = [NSMutableArray array];
                HT_FPlayResModel *resModel = [HT_FPlayResModel new];
                for (NSDictionary *dic in model.res) {
                    [resModel setValuesForKeysWithDictionary:dic];
                    [resmuArr addObject:resModel];
                }
                model.res = resmuArr;
                [[HT_FPlayManager getInsnstance].nearSongList addObject:model];
                //[weakself.songList addObject:model];
                //[weakself.tableview reloadData];
            }
            NSLog(@"%@",error);
            NSLog(@"%@",response);
        }
    };
}
@end

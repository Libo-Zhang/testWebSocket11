//
//  HT_DetailVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/15.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_DetailVC.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayDevice.h"
@interface HT_DetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *detailTV;
@property (nonatomic, strong) NSArray *deviceArr;
@end

@implementation HT_DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}
-(void)loadData{
    self.deviceArr = [HT_FPlayManager getInsnstance].mDeviceList;
//    [HT_FPlayManager getInsnstance].devideUpdateblocks = ^(NSArray *array){
//        NSLog(@"something In Block%@",array);
//        self.deviceArr = array;
//        [self.detailTV reloadData];
//    };
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HT_FPlayDevice *device = self.deviceArr[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.textLabel.text  = [NSString stringWithFormat:@"devid:%@   DID:%ld",device.devid,device.DID];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HT_FPlayDevice *device = self.deviceArr[indexPath.row];
    
//    if (device.status == 2) {
//        NSLog(@"并没有登录");
//        return;
//    }
    
    //NSString *str = [NSString stringWithFormat:@"devid:%@ ID:%ld",device.devid,device.ID];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@(201) forKey:@"action"];
     //[dictionary setValue:@(3) forKey:@"2222"];
    [dictionary setValue:[NSString stringWithFormat:@"UID:%ld",device.UID] forKey:@"from"];
    [dictionary setValue:[NSString stringWithFormat:@"DID:%ld",device.DID] forKey:@"to"];
    //[dictionary setValue:@[] forKey:@"songs"];
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *sendMessage = [NSString stringWithFormat:@"%ld#%@",data.length,dataMessage];
    NSData *sendData = [sendMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",sendMessage);
    
   // NSLog(@"%@",sendMessage);
    [device.connect_remote send:sendData];
}
@end

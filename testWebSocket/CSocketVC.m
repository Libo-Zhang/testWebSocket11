//
//  CSocketVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "CSocketVC.h"
#import "HT_FPlayDevice.h"
#import "HT_NearDetailVC.h"
@interface CSocketVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation CSocketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    //self.tableView.backgroundColor = [UIColor blueColor];
    [self setupRefresh];
   
}
-(void)setupRefresh
{
    //1.添加刷新控件
    self.refreshControl=[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [self.refreshControl beginRefreshing];
    
    // 3.加载数据
    [self refreshStateChange:self.refreshControl];
}
-(void)refreshStateChange:(UIRefreshControl *)control{
    [[HT_FPlayManager getInsnstance]createNearUdpSocket];
//    [[HT_FPlayManager getInsnstance] createNearUdpSocket:^(NSString *message) {
//         [self.refreshControl endRefreshing];
//        NSLog(@"~~~~~111111 ");
//        for (HT_FPlayDevice *device in [HT_FPlayManager getInsnstance].mDeviceList) {
//            NSLog(@"devid:%@",device.devid);
//        }
//        self.deviceArr = [HT_FPlayManager getInsnstance].mDeviceList;
//        [self.tableView reloadData];
//    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:5];
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
            //self.refreshControl.hidden = YES;
            
            if ([HT_FPlayManager getInsnstance].mDeviceList.count == 0) {
                NSLog(@"并没有列表");
            }else{
                for (HT_FPlayDevice *device in [HT_FPlayManager getInsnstance].mDeviceList) {
                    NSLog(@"devid:%@",device.devid);
                }
                self.deviceArr = [HT_FPlayManager getInsnstance].mDeviceList;
                [self.tableView reloadData];
            }
        }
    });
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    HT_FPlayDevice *device = self.deviceArr[indexPath.row];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = device.devid;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     HT_FPlayDevice *device = self.deviceArr[indexPath.row];
    //[[HT_FPlayManager getInsnstance] connectToNearDevice:device.ipAddress onPort:19211];
    
    HT_NearDetailVC *detailVC = [HT_NearDetailVC new];
    detailVC.device = device;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end

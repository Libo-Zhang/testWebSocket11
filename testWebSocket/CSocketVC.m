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
#import "AFNetworking.h"
@interface CSocketVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *token;

@end

@implementation CSocketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = [UIView new];
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
    __weak typeof (self)weakself = self;
    
    [[HT_FPlayManager getInsnstance] getNeardevicegetWithSuccess:^(NSArray *nearDeviceArr) {
        NSLog(@"~~~~%@",nearDeviceArr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.refreshControl endRefreshing];
            weakself.deviceArr = [HT_FPlayManager getInsnstance].mDeviceList;
            [weakself.tableView reloadData];
        });

    } WithFailer:^(id response) {
        
    } WithError:^(NSError *error) {
        
    }];


    
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
    //先连接  再传值
     __block HT_FPlayDevice *device = self.deviceArr[indexPath.row];
    __weak typeof (self)weakself = self;
    [device.connect_near connectToDevice:device.ipAddress onPort:19211];
    device.connect_near.nearReturnMessageBlock = ^ (id response){
        NSLog(@"`````%@",response);
        NSError *error;
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"~~error%@",error);
        }else{
            weakself.token = dic[@"token"];
            //使用api配对
            [weakself peidui];
            
            
        }
        //NSString *token = response[@"token"];
    };
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"绑定?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //803请求绑定
        [device.connect_near sendMessage:803 WithotherParams:nil WithSongList:nil];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
   
    [self presentViewController:alert animated:YES completion:nil];
    //HT_NearDetailVC *detailVC = [HT_NearDetailVC new];
    //detailVC.device = device;
    //[self.navigationController pushViewController:detailVC animated:YES];
}
-(void)peidui{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //传入的参数
    NSDictionary *parameters = @{@"token":self.token};
    //http://www.mydomain.com/api/userdeviceadd
    //你的接口地址
    NSString *a= [NSString stringWithFormat:@"%@/api/userdeviceadd",Address2];
    //NSString *url = [NSString stringWithFormat:@"%@",Address];
      NSLog(@"token :%@",self.token);
    if ([self.token isEqualToString:@"paired"]) {
        NSLog(@"已经配对了");
    }else{
        [manager POST:a parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"登录api的返回请求状态值%ld",[responseObject[@"ret"] integerValue]);
            if([responseObject[@"ret"] integerValue] == 0){
                NSLog(@"配对成功");
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            if(error){
            }
        }];
        
    }
   }
@end

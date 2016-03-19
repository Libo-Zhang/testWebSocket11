//
//  HT_SDcardVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/19.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_SDcardVC.h"
#import "HT_FPlayDevice.h"
#import "HT_FPlaySongsModel.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayResModel.h"
@interface HT_SDcardVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableview;
//@property (nonatomic, strong) NSMutableArray *songList;
@property (nonatomic, strong) HT_FPlayDevice *device;
//@property (nonatomic, strong) NSMutableArray *;
@end

@implementation HT_SDcardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   //self.songList = [NSMutableArray array];
    self.device = [HT_FPlayManager getInsnstance].currentDevice;
    NSLog(@"%@ %@",self.device.ipAddress,self.device.dname);
    
    self.tableview = [[UITableView alloc]init];
    self.tableview.frame = CGRectMake(0, 100, 300, 300);
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.tableview];
    [self loadData];
}
-(void)loadData{
    __weak typeof (self)weakself = self;
    [self.device.connect_near sendMessage:201 WithotherParams:@[@(0)] WithSongList:nil];
    self.device.connect_near.nearReturnMessageBlock = ^(NSString *message){
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
                //
                
                [[HT_FPlayManager getInsnstance].nearSongList addObject:model];
               //[weakself.songList addObject:model];
                [weakself.tableview reloadData];
            }
            
            NSLog(@"%@",error);
            NSLog(@"%@",response);
        }
    };
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [HT_FPlayManager getInsnstance].nearSongList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    HT_FPlaySongsModel *model = [HT_FPlayManager getInsnstance].nearSongList[indexPath.row];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = model.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HT_FPlaySongsModel *model = [HT_FPlayManager getInsnstance].nearSongList[indexPath.row];
    [self.device.connect_near sendMessage:9 WithotherParams:@[@(indexPath.row)] WithSongList:nil];
    
}

@end

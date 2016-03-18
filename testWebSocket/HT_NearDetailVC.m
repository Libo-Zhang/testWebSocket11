//
//  HT_NearDetailVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "HT_NearDetailVC.h"
#import "HT_FPlayManager.h"
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
    [self.device.connect_near sendMessage:[self.textfield.text integerValue] WithotherParams:@[self.textfield2.text] WithSongList:nil];
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

//
//  ViewController.m
//  testWebSocket
//
//  Created by uniview on 16/3/14.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "HT_FPlayManager.h"
//#define Address @"http://192.168.1.200:9001/mpp"
//@"http://www.hitinga.com"
#define Address2 @"http://www.hitinga.com"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self login];
}
-(void)login{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //传入的参数
    NSDictionary *parameters = @{@"username":@"12345678",@"password":@"12345678",@"mail":@""};

    //你的接口地址
    NSString *a= [NSString stringWithFormat:@"%@/api/userlogin",Address2];
    //NSString *url = [NSString stringWithFormat:@"%@",Address];
    
    [manager POST:a parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"登录api的返回请求状态值%ld",[responseObject[@"ret"] integerValue]);
        
        if([responseObject[@"ret"] integerValue] == 0){
            [self saveLoginCookie];
            //[[HT_FPlayManager getInsnstance] getUserdeviceget];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if(error){
        }
    }];
}
-(void)saveLoginCookie{
    
    //获取cookie
    //    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    /*
     * 把cookie进行归档并转换为NSData类型
     * 注意：cookie不能直接转换为NSData类型，否则会引起崩溃。
     * 所以先进行归档处理，再转换为Data
     */
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    
    //存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cookiesData forKey: @"MyProjectCookie"];
}
- (IBAction)openSocket:(UIButton *)sender {
    
//  [[HT_FPlayManager getInsnstance] getUserdeviceget];
//    [HT_FPlayManager getInsnstance].devideUpdateblocks = ^(NSArray *deviceArr){
//        NSLog(@"block 中的 deviceArr %@",deviceArr);
//    };
}
- (IBAction)sendMessage:(id)sender {
    //[[HT_FPlayManager getInsnstance]send:self.textField.text];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:@(803) forKey:@"action"];
    [dictionary setValue:[NSString stringWithFormat:@"UID:%d",83] forKey:@"from"];
    [dictionary setValue:[NSString stringWithFormat:@"DID:%d",33] forKey:@"to"];
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *sendMessage=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",sendMessage);
    //[[HT_FPlayManager getInsnstance].webSocket send:sendMessage];
}


@end

//
//  BindVC2.m
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "BindVC2.h"
#import "libsmartcfg.h"



@interface BindVC2 ()<GatewayCheckDelegate,DeviceCommanderDelegate>{
     BOOL bWaitSenderStop;
}

@property (nonatomic, strong) UITableViewCell *tabelView;
@property BonjourScanner    * bonjourScanner;
@property DeviceCommander   * commander;
@property SmartConfigApply  * configSender;
@property NSMutableArray    * netServiceInfos;
@end

@implementation BindVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self doSmartConfigWithSSID:@"hitinga" WiFiPassword:@"uniview2015"];

    //[self testApplySmartConfig];
    [self testGetGateWayMode];
    //[self testbonjourScan];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewDevice:) name:kScanDeviceGotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveDevice:) name:kRemoveDeviceNotification object:nil];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 150, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)btnClick{
      [self testApplySmartConfig];
    //[self testGetGateWayMode];
    //[self testbonjourScan];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//// test GateWayMode
- (void)testGetGateWayMode {
    GatewayChecker *gatewayChecker = [[GatewayChecker alloc] init];
    gatewayChecker.delegate = self;
    [gatewayChecker lookupGatewayIP];
    [gatewayChecker checkGatewayMode];
    
}
-(void)onDirectMode:(NSInteger)remainingTime{
    NSLog(@"onDirectMode%ld",remainingTime);
}
-(void)onDirectModeButNotSettable{
    NSLog(@"onDirectModeButNotSettable");
}
-(void)onSmartConfigMode{
    NSLog(@"onSmartConfigMode");
}


//// test Apply Smart Config
- (void)testApplySmartConfig {
    self.configSender = [[SmartConfigApply alloc] init];
    // 註冊關注消息，在Sender完全停止之後會執行 configStopped 這個 function
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configStopped) name:kConfigSenderStopped object:nil];
    [self.configSender setSSID:@"hitinga" Password:@"uniview2015" Mode:mode_station_int];
    [self.configSender apply];
    //[_bonjourScanner performSelector:@selector(createFakeDevices) withObject:nil afterDelay:2.0f];
    
    self.bonjourScanner  = [[BonjourScanner alloc] init];
    self.netServiceInfos = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewDevice:) name:kScanDeviceGotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveDevice:) name:kRemoveDeviceNotification object:nil];
    
   [_bonjourScanner startScan];
    
    NSDate * now = [NSDate date];
    while (([[NSDate date] timeIntervalSinceDate:now] < 10)) { // wait result for 120s
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    bWaitSenderStop = YES;
    [self.configSender stop];
    [_bonjourScanner stopScan];
    while (bWaitSenderStop == YES && ([[NSDate date] timeIntervalSinceDate:now] < 5)) { // wait stop for 5s
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}





//// test bonjour scan
- (void)testbonjourScan {
    self.bonjourScanner  = [[BonjourScanner alloc] init];
    self.netServiceInfos = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewDevice:) name:kScanDeviceGotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveDevice:) name:kRemoveDeviceNotification object:nil];
    
    
    [_bonjourScanner startScan];
    NSDate * now = [NSDate date];
    while (([[NSDate date] timeIntervalSinceDate:now] < 20)) { // wait result for 120s
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    [_bonjourScanner stopScan];
    
}
- (void)configStopped {
    NSLog(@"configStopped");
    bWaitSenderStop = NO;
   // [self testbonjourScan];
}


- (void)onGetNewDevice:(NSNotification *)sender {
    NetServiceInfo * newDevice = [sender object];
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Add to List -> %@", newDevice.macAddress]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    [self.netServiceInfos addObject:newDevice];
}

- (void)onRemoveDevice:(NSNotification *)sender {
    NetServiceInfo * device = [sender object];
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Remove from List -> %@", device.macAddress]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    [self.netServiceInfos removeObject:device];
}









- (void)onSuccessWithCommandType:(NSInteger)type {
    switch (type) {
        case RequestTagLogin:
            // 直連模式 DUT 帳號密碼認証成功
            NSLog(@"Success to Authentication");
            break;
        case RequestTagWiFiSetting:
            // 直連模式 提交 設定 DUT 連線到 Target AP 成功
            NSLog(@"Success to Configure DUT");
            break;
        case RequestTagQueryApplyResult:
            // 直連模式，拿到DUT配置成功的結果
            NSLog(@"Success to apply DUT");
            break;
        default:
            break;
    }
}

- (void)onFailedWithErrCode:(NSInteger)code withCommandType:(NSInteger)type {
    switch (type) {
        case RequestTagLogin:
            // 直連模式 DUT 帳號密碼認証失敗
            NSLog(@"Failed to Authentication");
            break;
        case RequestTagWiFiSetting:
            // 直連模式 提交 設定 DUT 連線到 Target AP 失敗
            NSLog(@"Failed to commit setting to DUT");
            break;
        case RequestTagQueryApplyResult:
            // 直連模式，拿到DUT配置失敗的結果, code是失敗原因，參考下面說明
            NSLog(@"Failed to apply DUT %d", (int)code);
            //            OmniStateAPNotFound,              // 找不到Target AP
            //            OmniStateIncorrectPassword,       // Target AP的密碼輸入錯誤
            //            OmniStateCannotGetIP,             // 無法從Target AP取得IP
            //            OmniStateTestConnectivityFailed,  // 測試連線失敗
            //            OmniStateConnectTimeout           // 連線到Target AP逾時
            break;
        default:
            break;
    }
}


@end

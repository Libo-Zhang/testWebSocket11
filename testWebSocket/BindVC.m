//
//  BindVC.m
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "BindVC.h"
//#import "DeviceCommander.h"
#import "libsmartcfg.h"
#import "CountDownController.h"
#import "DeviceListController.h"
#import "AppDelegate.h"

#define COUNTDOWN_SCAN_DEVICE_FIRST             5
#define COUNTDOWN_DETECT_NETWORK                10
#define COUNTDOWN_SCAN_DEVICE_TIMEOUT           20
#define COUNTDOWN_REQUEST_TIMEOUT               60
#define COUNTDOWN_WAIT_OMNI_RESULT_TIMEOUT      90
#define COUNTDOWN_FOR_SMART_CONFIG              120
#define IOS_VERSION_GREATER_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
typedef enum : NSUInteger {
    CountDownTagCheckWifiSetting,
    CountDownTagScanFirst,
    CountDownTagScan,
    CountDownTagSetting,
    CountDownTagAuthDevice,
    CountDownTagDirectSetting,
    CountDownTagQueryResult,
    
} CountDownTag;

typedef enum : NSUInteger {
    ProcessStateStop,
    ProcessStateStart,
    ProcessStateWaitingStop,
} ProcessState;

@interface BindVC (){
 
    int  processState;
    BOOL bSendNext;
    int  foundCounter;
    BOOL bEnterBackground;
    BOOL bDirectlyMode;
    BOOL canShowTimeoutAlert;
    BOOL bDetectedNetwork;
    BOOL isConfigurable;
    NSTimeInterval _remainingTime;
#ifdef DBGVIEW_AT_STARTUP
    BOOL bFirstAppear;
#endif

}

@end

@interface BindVC ()<GatewayCheckDelegate>

@property (nonatomic, copy) NSString    * ssid;
@property (nonatomic, copy) NSString    * savedSSIDForDirect;
@property (nonatomic, copy) NSString    * savedPassword;
@property (nonatomic, weak) AppDelegate * appDelegate;

@property (nonatomic, strong) GatewayChecker        * gatewayChecker;
@property (nonatomic, strong) DeviceListController  * deviceListController;

//@property (nonatomic, strong) AuthenticationController * deviceAuthDialog;
//@property (nonatomic, strong) UIViewController         * currentCustomDialog;

@property (nonatomic, strong) CountDownController * countDownDialog;
@property (nonatomic, strong) SmartConfigApply    * configSender;
@property (nonatomic, strong) NSTimer             * disconnectTimer;

@property (nonatomic, strong) UINavigationController * navWebController;
//@property (nonatomic, strong) MessagePanelController * disconnectPanel;

@property (nonatomic, strong) NSMutableString       * deviceString;
@property (nonatomic, strong) NSTimer               * reloadTimer;
//@property (nonatomic, strong) DeviceAuthentication  * storedAuth;
@property (nonatomic, strong) DeviceCommander       * commander;




//@property (nonatomic, strong) DbgViewController     * dbgView;
@end

@implementation BindVC


-(void)onDirectModeButNotSettable{
    NSLog(@"onDirectModeButNotSettable");
}
-(void)onDirectMode:(NSInteger)remainingTime{
    NSLog(@"");
}
- (void)viewDidLoad {
    bEnterBackground = NO;
#ifdef DBGVIEW_AT_STARTUP
    bFirstAppear = YES;
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configStopped) name:kConfigSenderStopped object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewDevice:) name:kGetWifiSettingDevice object:nil];
   //self.navigationController.delegate = self;  // for support orientation
    
    self.gatewayChecker = [[GatewayChecker alloc] init];
    _gatewayChecker.delegate = self;
    
    [self initViews];
    
    processState = ProcessStateStop;
    
    //    if (!IOS_VERSION_GREATER_OR_EQUAL_TO(@"9.0")) {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onGetChangedSSID:)
//                                                 name:kSSIDChangedNotification
//                                               object:nil];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    //[_appDelegate initLocalNetworkReachability];
    //    }
    
    [self checkConnectMode];
    
    
    //UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"配置" style:UIBarButtonItemStyleDone target:self action:@selector(peizhiClick)];

    
    
}
-(void)peizhiClick{
    [self doSmartConfigWithSSID:@"hitinga" WiFiPassword:@"uniview2015"];
}
- (void)checkConnectMode {
    isConfigurable = YES;
    bDetectedNetwork = NO;
    canShowTimeoutAlert = NO;
    
    
    [_gatewayChecker lookupGatewayIP];
    
    [_gatewayChecker checkGatewayMode];
   
}

-(void)initViews{
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    // use titleSuperView to hack 'Cannot modify constraints for UINavigationBar managed by a controller'
    
    self.deviceListController = [DeviceListController new];
    [_deviceListController setClickTarget:self action:@selector(didSelectDevice:)];
    _deviceListController.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_deviceListController.view];

    
//    self.hintViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HintView"];
//    [self.viewForList addSubview:_hintViewController.view];
//    [_hintViewController.view setHidden:YES];
}
- (void)viewDidAppear:(BOOL)animated {
#ifdef DBGVIEW_AT_STARTUP
    if (bFirstAppear) {
        [self onEasterEggDetected];
    }
    bFirstAppear = NO;
#endif
}

#pragma mark - Notification Center
- (void)onGetChangedSSID:(id)sender {
    NSString * newSSID = [sender object];
    BOOL bChanged = NO;
    if ([_ssid isEqualToString:newSSID] == NO && [newSSID length] != 0) {
        bChanged = YES;
    }
    self.ssid = newSSID;
    
    
    if ([_ssid length] == 0) {
        [self enableTimerToDetectDisconnect];
        [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"iOS disconnect from AP[%@]", _ssid]
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageOther];
        return;
    } else {
        [self disableTimerToDetectDisconnect];
    }
    
    // TODO: 當SSID跟原本的不相同時，要有提示訊息
    // 也許還有修改的空間
    if (bChanged && bDetectedNetwork && bEnterBackground == NO) {
        if (_commander != nil)
            [_commander stopAction];
       // [self hideCountDownDialog];
        
        if (!IOS_VERSION_GREATER_OR_EQUAL_TO(@"8.0")) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Info", @"wording", nil)
                                                                 message:NSLocalizedStringFromTable(@"SSID changed", @"wording", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"wording", nil) otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Info", @"wording", nil)
                                                                           message:NSLocalizedStringFromTable(@"SSID changed", @"wording", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"wording", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self checkConnectMode];
                                                                  }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)enableTimerToDetectDisconnect {
    if (_disconnectTimer == nil) {
        NSLog(@"%s", __func__);
        [[DebugMessage sharedInstance] writeDebugMessage:@"Create timer to prepare show DisconnectedInfo"
                                                function:[NSString stringWithFormat:@"%s", __func__]
                                                    line:[NSString stringWithFormat:@"%d", __LINE__]
                                                    mode:DebugMessageOther];
        self.disconnectTimer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(showDisconnectedInfo) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_disconnectTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)disableTimerToDetectDisconnect {
    if (_disconnectTimer) {
        [_disconnectTimer invalidate];
    }
    
    self.disconnectTimer = nil;
    //[_disconnectPanel hide];
}

- (void)showDisconnectedInfo {
    NSLog(@"%s", __func__);
    self.disconnectTimer = nil;
    //[_disconnectPanel setMessage:NSLocalizedStringFromTable(@"wifi disconnected", @"wording", nil)];
    //[_disconnectPanel show];
}

- (void)configStopped {
    processState = ProcessStateStop;
    if (bSendNext) {
        [self performSelectorOnMainThread:@selector(startSender) withObject:nil waitUntilDone:NO];
    }
}
- (void)onGetNewDevice:(NSNotification*)sender {
    NetServiceInfo * newDevice = [sender object];
    if (_countDownDialog == nil) {
        return;
    }
    
    if (self.deviceString == nil) {
        self.deviceString = [[NSMutableString alloc] init];
    }
    
    if ([_deviceString rangeOfString:newDevice.macAddress].location != NSNotFound) {
        return;
    }
    foundCounter++;
    NSString * appendStr = [NSString stringWithFormat:NSLocalizedStringFromTable(@"success for device", @"wording", nil), newDevice.macAddress];
    [_deviceString appendString:appendStr];
    [_countDownDialog.foundDeviceMsg setText:_deviceString];
    [_deviceListController.tableView reloadData];
}

- (void)onClickOKOnWiFi:(id)sender {

        [self doSmartConfigWithSSID:@"hitinga" WiFiPassword:@"uniview2015"];
 
}


#pragma mark - smart config
- (void)doSmartConfigWithSSID:(NSString*)ssid WiFiPassword:(NSString*)pw {
    if (self.configSender == nil) {
        self.configSender = [[SmartConfigApply alloc] init];
    }
    
    [_configSender setSSID:ssid Password:pw Mode:mode_station_int];
    
    if (processState != ProcessStateStop) {
        bSendNext = YES;
        return;
    }
    
    //[_hintViewController.view setHidden:YES];
    [self startSender];
}

- (void)doDirectlyConfigWithSSID:(NSString*)ssid WiFiPassword:(NSString*)pw {
    canShowTimeoutAlert = NO;
    [self.commander doWiFiSettingToSSID:ssid WiFiPassword:pw];
    //[self showCountDownDialog:COUNTDOWN_REQUEST_TIMEOUT message:NSLocalizedStringFromTable(@"Applying", //@"wording", nil) withTag:CountDownTagDirectSetting];
    //[_countDownDialog.buttonView removeFromSuperview];
}

- (void)startSender {
    bSendNext = NO;
    processState = ProcessStateStart;
    [_configSender apply];
    foundCounter = 0;
    [_deviceListController scanByWifiSetting];
    //[self showCountDownDialog:COUNTDOWN_FOR_SMART_CONFIG
                    //  message:NSLocalizedStringFromTable(@"Applying", @"wording", nil)
                     // withTag:CountDownTagSetting];
    [_countDownDialog.foundDeviceMsg setHidden:NO];
}

- (void)onTimeout {
    
    if (foundCounter == 0 && _countDownDialog.tag == CountDownTagSetting && bEnterBackground == NO) {
        //[self alertOnlyMessage:NSLocalizedStringFromTable(@"failed to setting remote", @"wording", nil)];
    }
    
    if (_commander != nil)
        [_commander stopAction];
    
    if (CountDownTagDirectSetting == _countDownDialog.tag) {
        if (bEnterBackground == NO) {
            //[self alertOnlyMessage:NSLocalizedStringFromTable(@"Request canned texting", @"wording", nil)];
        }
       // [self hideCountDownDialog];
    } else {
        [self closeCountDown];
    }
}

- (void)closeByTimeout {
    
}

- (void)closeCountDown {
    [_deviceListController stopScan];
    NSLog(@"closeCountDown");
    switch (_countDownDialog.tag) {
        case CountDownTagScanFirst:
            if (_deviceListController.numOfDevices == 0 && bEnterBackground == NO) {
                //[_hintViewController showNotFound];
//[self onClickConfigWiFi:nil];
            }
            break;
        case CountDownTagScan:
            if (_deviceListController.numOfDevices == 0 && bEnterBackground == NO) {
                //[_hintViewController showNotFound];
            }
            break;
        case CountDownTagSetting:
            // waiting stop
            if (processState == ProcessStateStart) {
                processState = ProcessStateWaitingStop;
                [_configSender stop];
            }
            break;
        case CountDownTagDirectSetting:
            // 這個CountDown dialog還是需要顯示，因為還要query apply的結果
            if (_countDownDialog.reducingSecond > 2) {
               // [self reCountSetDialogForWIFISetting];
            } else {
                NSTimer * timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(reCountSetDialogForWIFISetting) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }
            return;
        case CountDownTagCheckWifiSetting:
            [_gatewayChecker stopCheck];
            break;
        default:
            break;
    }
   // [self hideCountDownDialog];

}
#pragma mark - GatewayCheckerDelegate
- (void)reloadDataForCountDown {
    if (_remainingTime == 0) {
        isConfigurable = NO;
        [_reloadTimer invalidate];
        self.reloadTimer = nil;
      //  [self onClickCloseCurrentDialog:nil];
        if (canShowTimeoutAlert) {
            if (_gatewayChecker.isPreviousStation) {
               // [self alertOnlyMessage:NSLocalizedStringFromTable(@"timeout to back previous mode", @"wording", nil)];
                //[_hintViewController showTextOnResultTextView:NSLocalizedStringFromTable(@"timeout to back previous mode", @"wording", nil)];
            } else {
                //[self alertOnlyMessage:NSLocalizedStringFromTable(@"Exceed the time limit.", @"wording", nil)];
               // [_hintViewController showTextOnResultTextView:NSLocalizedStringFromTable(@"Exceed the time limit.", @"wording", nil)];
            }
        }
        return;
    }
    _remainingTime--;
    
//    if (self.currentCustomDialog == nil) {
//        return;
//    }
    
    //if ([self.currentCustomDialog respondsToSelector:@selector(refreshCountDownLabel:)]) {
//        [_currentCustomDialog performSelectorOnMainThread:@selector(refreshCountDownLabel:)
//      //                                         withObject:[NSNumber numberWithDouble:_remainingTime]
//                                            waitUntilDone:YES];
//    }
}
- (void)onSmartConfigMode {
    NSLog(@"onSmartConfigMode");
    if (bDetectedNetwork) {
        return;
    }
    bDetectedNetwork = YES;
    processState = ProcessStateStop;
   // [_hintViewController.view setHidden:YES];
    //[self.renewListButton setHidden:NO];
    [self closeCountDown];
    bDirectlyMode = NO;
    self.commander = nil;
    [self.deviceListController refreshList];
    //NSString * showMsg = [NSString stringWithFormat:@"%@",
                         // NSLocalizedStringFromTable(@"Scanning", @"wording", nil)];
    //[self showCountDownDialog:COUNTDOWN_SCAN_DEVICE_FIRST message:showMsg withTag:CountDownTagScanFirst];
}






@end

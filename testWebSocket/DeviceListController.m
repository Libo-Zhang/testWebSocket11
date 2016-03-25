//
//  DeviceListController.m
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "DeviceListController.h"
#import "BonjourScanner.h"
#import "libsmartcfg.h"
#import "HT_FPlayManager.h"
#import "HT_FPlayDevice.h"
#import "HT_FPlayNearConnect.h"
@interface DeviceListController ()
@property (nonatomic, strong) BonjourScanner            * bonjourScanner;
@property (nonatomic, strong) NSMutableArray            * netServiceInfos;
@end

@implementation DeviceListController{
    BOOL    bScannedByWifiSetting;
    id      _target;
    SEL     _action;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bonjourScanner = [[BonjourScanner alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewDevice:) name:kScanDeviceGotNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveDevice:) name:kRemoveDeviceNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kScanDeviceGotNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRemoveDeviceNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rotate

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.netServiceInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    //NetServiceInfo * aService = [self.netServiceInfos objectAtIndex:indexPath.row];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * setCell = (UITableViewCell*)cell;
    NetServiceInfo * aService = [self.netServiceInfos objectAtIndex:indexPath.row];
    
    NSString * imgName = [NSString stringWithFormat:@"vid_%@_pid_%@", aService.vid, aService.pid];
    UIImage * deviceImg = [UIImage imageNamed:imgName];
    if (deviceImg == nil) {
        deviceImg = [UIImage imageNamed:@"audiobox"];
    }
    setCell.textLabel.text = aService.macAddress;
    setCell.detailTextLabel.text = aService.address;
//    setCell.detailTextLabel.text = aService.macAddress;
    //[setCell configured:aService.isNewAdd];
    
    //ITableViewCell *cell = [];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // [self performSelector:@selector(deselectIndexPaht:) withObject:indexPath afterDelay:0.2];
    NetServiceInfo * chosen = [self.netServiceInfos objectAtIndex:indexPath.row];
    HT_FPlayDevice *device = [HT_FPlayDevice new];
    device.ipAddress = chosen.address;
    device.devid = chosen.macAddress;
    [HT_FPlayManager getInsnstance].currentDevice = device;
    device.connect_near = [HT_FPlayNearConnect new];
    NSLog(@"```````%@",device.ipAddress);
   [device.connect_near connectToDevice:device.ipAddress onPort:19211];
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"11111");
    //[_target performSelectorOnMainThread:_action withObject:chosen waitUntilDone:YES];
}

- (void)onGetNewDevice:(NSNotification *)sender {
    NetServiceInfo * newDevice = [sender object];
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Add to List -> %@", newDevice.macAddress]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    [self.netServiceInfos addObject:newDevice];
    if (bScannedByWifiSetting)
        [newDevice checkIfRestoredPreviousMode];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)onRemoveDevice:(NSNotification *)sender {
    NetServiceInfo * device = [sender object];
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"Remove from List -> %@", device.macAddress]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageBonjour];
    
    [self.netServiceInfos removeObject:device];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)scanByWifiSetting {
    for (NSUInteger i = 0; i < [_netServiceInfos count]; ++i) {
        NetServiceInfo * anInfo = [_netServiceInfos objectAtIndex:i];
        anInfo.isNewAdd = NO;
    }
    [self.tableView reloadData];
    bScannedByWifiSetting = YES;
    [_bonjourScanner startScan];
    //[_bonjourScanner performSelector:@selector(createFakeDevices) withObject:nil afterDelay:2.0f];
}

- (void)refreshList {
    if (!self.netServiceInfos)
        self.netServiceInfos = [[NSMutableArray alloc] init];
    
    bScannedByWifiSetting = NO;
    
    [self.netServiceInfos removeAllObjects];
    [self.tableView reloadData];
    [self.bonjourScanner resetScanner];
    [_bonjourScanner startScan];
}

- (void)cleanList {
    [self.netServiceInfos removeAllObjects];
    [self.tableView reloadData];
}

- (void)stopScan {
    [_bonjourScanner stopScan];
}

- (NSUInteger)getDeviceCount {
    return [_netServiceInfos count];
}

- (void)setClickTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}
@end

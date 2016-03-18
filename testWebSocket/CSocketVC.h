//
//  CSocketVC.h
//  testWebSocket
//
//  Created by uniview on 16/3/17.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HT_FPlayManager.h"
@interface CSocketVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *deviceArr;

@end

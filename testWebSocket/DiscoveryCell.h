//
//  DiscoveryCell.h
//  OMNIConfig
//
//  Created by YUAN HSIANG TSAI on 2015/6/4.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceInfo.h"

/*!
 *  This class is referenced with the tableCell in MasterViewController
 */
@interface DiscoveryCell : UITableViewCell
/*!
 *  Image view to represent type (e.g, IPCam, Audio box, Television)
 */
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
/*!
 *  Label to show type name (e.g, IPCam, Audio box, Television)
 */
@property (weak, nonatomic) IBOutlet UILabel *typeName;
/*!
 *  Label to show MAC Address (e.g, 00:11:22:33:44:55)
 */
@property (weak, nonatomic) IBOutlet UILabel *macAddress;
/*!
 *  Label to show current state (e.g, not configured, timeout count down)
 */
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
/*!
 *  Image View to represent connected or notConnected to a Access Point
 */
@property (weak, nonatomic) IBOutlet UIImageView *connectStateImage;

/*!
 *  Show it's configured
 */
- (void)configured:(BOOL)isNew;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@end

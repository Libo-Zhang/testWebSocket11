//
//  libsmartcfg_constant.h
//  libsmartcfg
//
//  Created by Edden on 10/27/15.
//  Copyright © 2015 Edden. All rights reserved.
//

#ifndef libsmartcfg_constant_h
#define libsmartcfg_constant_h

#define kConfigSenderStopped (@"ConfigSenderStopped")

#define TIMEOUT_DETECT_GATEWAY                  3
#define TIMEOUT_HTTP_REQUEST                    5
#define TIMEOUT_SCAN_DEVICE                    20

#define KEY_DEFAULT_USER      (@"DefaultUser")
#define KEY_DEFAULT_PASSWORD  (@"DefaultPassword")
#define KEY_VENDOR_ID         (@"VendorID")
#define KEY_PRODUCT_ID        (@"ProductID")
#define KEY_VENDOR_PHASE      (@"VendorPhase")

#define VALUE_DEFAULT_USER      (@"admin")
#define VALUE_DEFAULT_PASSWORD  (@"admin")
#define VALUE_VENDOR_ID         (@"")
#define VALUE_PRODUCT_ID        (@"")
#define VALUE_VENDOR_PHASE      (@"MONTAGE")

/*!
 define it for apply mode - station
 */
#define mode_station        @"09"
#define mode_station_int    9
/*!
 define it for apply mode - wisp
 */
#define mode_wisp           @"03"
#define mode_wisp_int       3

typedef NS_ENUM(NSInteger, OmniState) {
    OmniStateNone = 0,
    OmniStateConnecting,
    OmniStateConnectSuccess,
    OmniStateAPNotFound,
    OmniStateIncorrectPassword,
    OmniStateCannotGetIP,
    OmniStateTestConnectivityFailed,
    OmniStateConnectTimeout
};

#endif /* libsmartcfg_constant_h */

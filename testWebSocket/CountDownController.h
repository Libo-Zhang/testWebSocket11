//
//  CountDownController.h
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcView.h"
@interface CountDownController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet ArcView *arcView;
@property (weak, nonatomic) IBOutlet UITextField *foundDeviceMsg;
/*!
 *  Close this dialog because the app entering background.
 */
@property (assign) BOOL isEnteredBackground;
/*!
 *
 */
@property (assign) NSInteger tag;
/*!
 *  Get reducing seconds.
 */
@property (getter=reducingSecond) NSInteger reducingSecond;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property NSInteger countSec;
/*!
 *  Sets a target and action when timeout.
 *
 *  @param target The target object
 *  @param action A selector to callback.
 */
- (void)setTimeoutTarget:(id)target action:(SEL)action;
/*!
 *  Reset count down seconds
 *
 *  @param sec Total seconds to count down
 */
- (void)setCountDown:(NSInteger)sec;
/*!
 *  Message under count down indicator
 *
 *  @param msg Message you want to show
 */
- (void)setShowMessage:(NSString*)msg;

- (void)showHint;
- (void)hideHint;
@end

//
//  CountDownController.m
//  testWebSocket
//
//  Created by uniview on 16/3/22.
//  Copyright © 2016年 uniview. All rights reserved.
//

#import "CountDownController.h"

@interface CountDownController ()
@property (nonatomic, strong) NSTimer * arcTimer;
@property (nonatomic, strong) NSTimer * timer;
@property CGFloat   decreseRatio;

@property (nonatomic, assign) id  target;
@property (nonatomic, assign) SEL action;
@end

@implementation CountDownController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [_wifiCheckTextView setText:NSLocalizedStringFromTable(@"check wifi icon", @"wording", nil)];
    
    UIColor * iOSDefaultTintColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _arcView.lineWidth = 12.0f;
    _arcView.lineColor = iOSDefaultTintColor;
    _arcView.ratio = 1.0f;
    [_cancelBtn setTitle:NSLocalizedStringFromTable(@"Cancel", @"wording", nil)
                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCountDown:(NSInteger)sec {
    if (_timer) {
        [_timer invalidate];
    }
    if (_arcTimer) {
        [_arcTimer invalidate];
    }
    
    _isEnteredBackground = NO;
    _countSec = sec;
    _reducingSecond = 0;
    _cancelBtn.hidden = NO;
    [_countLabel setText:[NSString stringWithFormat:@"%d", (int)_countSec]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doCountDown) userInfo:nil repeats:YES];
    _arcView.ratio = 1.0f;
    [_arcView setNeedsDisplay];
    self.arcTimer = [NSTimer scheduledTimerWithTimeInterval:((CGFloat)sec / 400.0f) target:self selector:@selector(arcRedraw) userInfo:nil repeats:YES];
}

- (void)doCountDown {
    _countSec--;
    _reducingSecond++;
    [_countLabel setText:[NSString stringWithFormat:@"%d", (int)_countSec]];
    
    if (_countSec == 0) {
        [_timer invalidate];
        [_arcTimer invalidate];
        self.timer = nil;
        self.arcTimer = nil;
        [_target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (void)arcRedraw {
    _arcView.ratio -= 0.0025;
    [_arcView setNeedsDisplay];
}

- (void)setShowMessage:(NSString*)msg {
    //[_messageLabel setText:msg];
}

- (void)setTimeoutTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
    if (target == nil) {
        if (_timer) {
            [_timer invalidate];
            self.timer = nil;
        }
        if (_arcTimer) {
            [_arcTimer invalidate];
            self.arcTimer = nil;
        }
    }
}

- (void)showHint {
   // [_wifiCheckView setHidden:NO];
}

- (void)hideHint {
   // [_wifiCheckView setHidden:YES];
}

@end

//
//  DiscoveryCell.m
//  OMNIConfig
//
//  Created by YUAN HSIANG TSAI on 2015/6/4.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import "DiscoveryCell.h"


@interface DiscoveryCell() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic, strong) UIColor * oriColor;
@property (nonatomic, strong) UIColor * bgColor;
@end

@implementation DiscoveryCell

- (void)awakeFromNib {
    // Initialization code
    self.bgView.layer.borderWidth = 1;
    self.bgView.layer.borderColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1].CGColor;
    self.oriColor       = _bgView.backgroundColor;
    self.bgColor        = _oriColor;
    self.selectedColor  = [UIColor colorWithRed:189.0/255.0 green:221.0/255.0 blue:255.0/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [_bgView setBackgroundColor:_selectedColor];
    } else {
        [_bgView setBackgroundColor:_bgColor];
    }
}

- (void)configured:(BOOL)isNew {
    [self.stateLabel setTextColor:[UIColor blackColor]];
    NSString * strState = NSLocalizedStringFromTable(@"This device has been connected.", @"wording", nil);
    self.stateLabel.text = strState;

    self.connectStateImage.hidden = NO;
    self.connectStateImage.image = [UIImage imageNamed:@"device_connect"];
    
    if (isNew) {
        self.bgColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1];
    } else {
        self.bgColor = _oriColor;
    }
}

@end

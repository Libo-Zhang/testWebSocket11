//
//  HT_UI_PlayingVC.h
//  HaiTing
//
//  Created by uniview on 16/3/10.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HT_UI_PlayingVC : UIViewController
@property (nonatomic, strong) NSURL *songUrl;
@property (nonatomic, assign) NSInteger musicID;
@property (nonatomic, strong) NSString *songName;

@end

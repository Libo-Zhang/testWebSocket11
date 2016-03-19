//
//  HT_UI_Slider.m
//  HaiTing
//
//  Created by uniview on 16/3/11.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import "HT_UI_Slider.h"

@implementation HT_UI_Slider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, WIDTH - 20, 5);
}
@end

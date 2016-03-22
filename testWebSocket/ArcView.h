//
//  ArcView.h
//  OMNIConfig
//
//  Created by Edden on 7/8/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  View to draw indicator circle
 */
@interface ArcView : UIView
@property (assign) CGFloat lineWidth;
@property (assign) CGFloat ratio;
@property (nonatomic, strong) UIColor * lineColor;
@end

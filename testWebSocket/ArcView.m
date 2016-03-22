//
//  ArcView.m
//  OMNIConfig
//
//  Created by Edden on 7/8/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#import "ArcView.h"

#define MARGIN 5

@interface ArcView()
@property CGFloat diameter;
@end

@implementation ArcView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _diameter = (frame.size.width > frame.size.height) ? frame.size.height : frame.size.width;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect frame = self.frame;
        self.backgroundColor = [UIColor clearColor];
        _diameter = (frame.size.width > frame.size.height) ? frame.size.height : frame.size.width;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint arcPoint  = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat arcRadius = _diameter/2 - _lineWidth - MARGIN;
    CGFloat arcStartAngle = - M_PI_2;
    CGFloat arcEndAngle   = _ratio * 2.0 * M_PI - M_PI_2;

    UIBezierPath * arcPath = [UIBezierPath bezierPathWithArcCenter:arcPoint
                                                            radius:arcRadius
                                                        startAngle:arcStartAngle
                                                          endAngle:arcEndAngle
                                                         clockwise:YES];
    [_lineColor setStroke];
    arcPath.lineWidth = _lineWidth;
    arcPath.lineCapStyle = kCGLineCapButt;
    [arcPath stroke];
}

@end

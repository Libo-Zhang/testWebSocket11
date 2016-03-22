//
//  DebugMessage.h
//  OMNIConfig
//
//  Created by Edden on 7/8/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*! @enum DebugMessageType
 
 */
typedef NS_ENUM(NSUInteger, DebugMsgType) {
    DebugMessageBonjour = 0,
    DebugMessageSmartconfig,
    DebugMessageHttpRequest,
    DebugMessageHttpResponse,
    DebugMessageUIAction,
    DebugMessageOther
};

@interface DebugMessage : NSObject

+ (DebugMessage*)sharedInstance;

/*!
 *  Show debug message on console and write in a file
 *  e.g, <MODE>:msg @Line-[FunctionName]
 *
 *  @param msg     message you want to show
 *  @param inFunc  called from which function
 *  @param lineNum line number of called function
 *  @param mode    mode of debug message (e.g, DebugMessageBonjour)
 */
- (void)writeDebugMessage:(NSString*)msg
                 function:(NSString*)inFunc
                     line:(NSString*)lineNum
                     mode:(NSInteger)mode;

/*!
 *  Specific text view to show debug message
 */
- (void)setDbgView:(UITextView*)dbgMsgView;

@end

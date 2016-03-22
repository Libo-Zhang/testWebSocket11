//
//  DebugMessage.m
//  OMNIConfig
//
//  Created by Edden on 7/8/15.
//  Copyright (c) 2015 Edden. All rights reserved.
//

#import "DebugMessage.h"

@interface DebugMessage()
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSArray  * dbgTags;
@property (nonatomic, retain) NSFileHandle * handle;
@property (nonatomic, retain) UITextView * msgView;
@end

@implementation DebugMessage

+ (DebugMessage*)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    self.dbgTags = @[@"<BONJOUR>", @"<SmartConfig>", @"<HTTP>", @"<RESPONSE>", @"<UI_ACT>", @"<OTHER>"];
    
    return self;
}

- (void)setDbgView:(UITextView*)dbgMsgView {
    self.msgView = dbgMsgView;
}

- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents * comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents * comp2 = [calendar components:unitFlags fromDate:date2];
    
    return ([comp1 year] == [comp2 year]) && ([comp1 month] == [comp2 month]) && ([comp1 day] == [comp2 day]);
}

- (NSString*)checkAndCreateFile {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    NSString * filePath = [documentDirectory stringByAppendingString:@"dbg.log"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate * lastModifyDate = [attributes fileModificationDate];
        if ([self isSameDayWithDate1:lastModifyDate date2:[NSDate date]]) {
            return filePath;
        }
        
        if (_handle) {
            [_handle closeFile];
            self.handle = nil;
        }
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    BOOL bRet = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    NSLog(@"create file : %@", bRet ? @"Y":@"N");
    
    return filePath;
}

- (void)writeOnDbgview:(NSString*)msg {
    [_msgView setText:[_msgView.text stringByAppendingString:msg]];
//   scroll to end
//   NSRange bottom = NSMakeRange(_msgView.text.length -1, 1);
//   [_msgView scrollRangeToVisible:bottom];
}

- (void)writeDebugMessage:(NSString*)msg
                 function:(NSString*)inFunc
                     line:(NSString*)lineNum
                     mode:(NSInteger)mode {
//    NSString * filePath = [self checkAndCreateFile];
    
    // TIME <TAG>:msg LINE@FUNCTION
    msg = [NSString stringWithFormat:@"%@ %@:%@ @%@%@\n",
           [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle],
           _dbgTags[mode],
           msg,
           lineNum,
           inFunc];
    NSLog(@"%@", msg);
    if (_msgView) {
        [self performSelectorOnMainThread:@selector(writeOnDbgview:) withObject:msg waitUntilDone:YES];
    }

//    if (_handle == nil) {
//        self.handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
//    }
//
//    [_handle seekToEndOfFile];
//    [_handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString*)createAttchFileForMail {
    if (_handle) {
        [_handle closeFile];
        self.handle = nil;
    }

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    NSString * filePath = [documentDirectory stringByAppendingString:@"dbg.log"];
    
    NSString * ret = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString * copyFilePath = [documentDirectory stringByAppendingString:@"dbgcpy.log"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:copyFilePath])
            [[NSFileManager defaultManager] removeItemAtPath:copyFilePath error:nil];
            
        if ([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:copyFilePath error:nil])
            ret = copyFilePath;
    }
    
    return ret;
}

@end

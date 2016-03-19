//
//  HT_UI_AFNDownload.h
//  HaiTing
//
//  Created by uniview on 16/3/9.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HT_UI_AFNDownload.h"
#import "AFNetworking.h"
@interface HT_UI_AFNDownload : NSObject

- (void)downloadFileWithOption:(NSDictionary *)paramDic
                 withInferface:(NSString*)requestURL
                     savedPath:(NSString*)savedPath
               downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               downloadFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                      progress:(void (^)(float progress))progress;


- (void)downloadFileWithOptionGET:(NSDictionary *)paramDic
                 withInferface:(NSString*)requestURL
                     savedPath:(NSString*)savedPath
               downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               downloadFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                      progress:(void (^)(float progress))progress;


@end

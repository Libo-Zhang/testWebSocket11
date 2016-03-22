//
//  HttpRequest.h
//  DynacolorLibs
//
//  Created by YUAN HSIANG TSAI on 2015/3/31.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  Delegate for return http response
 */
@protocol HttpResultDelegate <NSObject>
/*!
 *  Success to request.
 *
 *  @param result data received from http
 *  @param tag    tag assigned in URLConnectionDelegate
 */
- (void)onSuccess:(NSData*)result withTag:(NSInteger)tag;
/*!
 *  Failed to request.
 *
 *  @param statusCode http status code. (0 is network disconnected usually, others is real http status code)
 *  @param tag        tag assigned in URLConnectionDelegate
 */
- (void)onFailed:(NSInteger)statusCode withTag:(NSInteger)tag;
@end

/*!
 *  Class to deal with http response
 *  implemented <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
 */
@interface URLConnectionDelegate : NSObject

/*!
 *  username to authentication if needed
 */
@property (nonatomic, strong) NSString * username;
/*!
 *  password to authentication if needed
 */
@property (nonatomic, strong) NSString * password;

/*!
 *  tag to indentify the response comming from which request
 */
@property (assign) NSInteger tag;
/*!
 *  delegate to receive result
 */
@property (assign) id<HttpResultDelegate> resultDelegate;
@end

/*!
 *  Class to create NSURLConnection
 */
@interface HttpRequest : NSObject

/*!
 *  Create an instance of NSURLConnection only by url.
 *
 *  @param url      URL to reqeust
 *  @param delegate delegate to deal with response
 *  @param timeout  timeout for waiting response
 *
 *  @return instance of NSURLConnection
 */
+ (NSURLConnection*)sendRequest:(NSURL *)url
         withConnectionDelegate:(URLConnectionDelegate *)delegate
                    withTimeout:(NSTimeInterval)timeout;

/*!
 *  Create an instance of NSURLConnection by url and post data.
 *
 *  @param url      URL to reqeust
 *  @param sPost    post data
 *  @param delegate delegate to deal with response
 *  @param timeout  timeout for waiting response
 *
 *  @return instance of NSURLConnection
 */
+ (NSURLConnection*)postRequest:(NSURL *)url
                       postData:(NSString*)sPost
         withConnectionDelegate:(URLConnectionDelegate*)delegate
                    withTimeout:(NSTimeInterval)timeout;

@end

/*!
 *  Class to sending request after receiving response data of ping
 */
@interface PingFirstHttpRequest : NSObject <HttpResultDelegate>
/*!
 *  initialize
 *
 *  @param ipAddr IP Address of remote
 *  @param path   relative path, nil for empty  (abosoluteURL will be http://ipAddr/path )
 *  @param user   username to authentication
 *  @param pw     password to authentication
 *
 *  @return initialized instance
 */
- (instancetype)initWithIP:(NSString*)ipAddr
              relativePath:(NSString*)path
                      user:(NSString*)user
                  password:(NSString*)pw
                       tag:(NSInteger)tag;

/*!
 *  start sending request.
 *  repeat sending every second, if get get http status code = 0
 */
- (void)startRequest;
/*!
 *  cancel repeat sending sending.
 *  usually call it when timeout
 */
- (void)stopRequest;

/*!
 *  string to post.
 *  Keep it as null if we don't need to post data
 */
@property (nonatomic, strong) NSString * strPostData;
/*!
 *  username to authentication
 */
@property (nonatomic, strong) NSString * username;
/*!
 *  password to authentication
 */
@property (nonatomic, strong) NSString * password;
/*!
 *  tag assigned in URLConnectionDelegate
 */
@property (assign) NSInteger        tag;
/*!
 *  delegate to receive result
 */
@property (assign) id<HttpResultDelegate> resultDelegate;
/*!
 *  timeout for Http Request
 */
@property (nonatomic, assign) NSTimeInterval timeout;
/*!
 *  retry if get status code = 0
 */
@property (nonatomic, assign) BOOL bRetry;
@end
//
//  HttpRequest.m
//  DynacolorLibs
//
//  Created by YUAN HSIANG TSAI on 2015/3/31.
//  Copyright (c) 2015年 Edden. All rights reserved.
//

#import "HttpRequest.h"
#import "SimplePing.h"
#import "DebugMessage.h"
#import "libsmartcfg_constant.h"

@interface URLConnectionDelegate() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
/*!
 *  append data on - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 */
@property NSMutableData * recvData;
@property NSInteger       httpStatusCode;
@end

@implementation URLConnectionDelegate

- (void)dealloc {
    self.recvData = nil;
    self.username = nil;
    self.password = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_resultDelegate) {
        [_resultDelegate onFailed:_httpStatusCode withTag:self.tag];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_httpStatusCode != 200) {
        return;
    }
    
    if (!self.recvData) {
        self.recvData = [[NSMutableData alloc] init];
    }
    
    [_recvData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_resultDelegate && _httpStatusCode == 200) {
        [_resultDelegate onSuccess:self.recvData withTag:self.tag];
    } else if (_httpStatusCode != 200) {
        [_resultDelegate onFailed:self.httpStatusCode withTag:self.tag];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
    _httpStatusCode = [httpResponse statusCode];
    
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"recv response status code : %d", (int)_httpStatusCode]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpResponse];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] > 0) {
        // do failed auth
        if (_resultDelegate) {
            [_resultDelegate onFailed:401 withTag:self.tag];    // 401 is Unauthorized
            self.resultDelegate = nil;
        }
        return;
    }
    
    NSURLCredential *creds = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:creds forAuthenticationChallenge:challenge];
}

@end

@implementation HttpRequest

+ (NSURLConnection*)sendRequest:(NSURL *)url
         withConnectionDelegate:(URLConnectionDelegate *)delegate
                    withTimeout:(NSTimeInterval)timeout
{
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    return [NSURLConnection connectionWithRequest:request delegate:delegate];
}

+ (NSURLConnection*)postRequest:(NSURL *)url
                       postData:(NSString*)sPost
         withConnectionDelegate:(URLConnectionDelegate*)delegate
                    withTimeout:(NSTimeInterval)timeout
{
    sPost = [sPost stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData * postData = [sPost dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    return [NSURLConnection connectionWithRequest:request delegate:delegate];
}

@end

@interface PingFirstHttpRequest() <SimplePingDelegate>
@property (nonatomic, copy) NSString * ipAddress;
@property (nonatomic, strong) NSURL  * absoluteURL;
@property (nonatomic, strong) SimplePing * ping;
@property (nonatomic, strong) URLConnectionDelegate * currentDelagate;
@property (nonatomic, strong) NSTimer * timerToPing;
@end

@implementation PingFirstHttpRequest {
    BOOL bContinue;
    BOOL bGetPong;
}
- (instancetype)initWithIP:(NSString*)ipAddr
              relativePath:(NSString*)path
                      user:(NSString*)user
                  password:(NSString*)pw
                       tag:(NSInteger)tag {
    self = [super init];
    self.ipAddress = ipAddr;
    self.username = user;
    self.password = pw;
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", ipAddr]];
    self.absoluteURL = (path == nil) ?  baseURL : [NSURL URLWithString:path relativeToURL:baseURL];
    bContinue = YES;
    self.tag = tag;
    _timeout = TIMEOUT_HTTP_REQUEST;
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc %s", __FUNCTION__);
    bContinue = NO;
    if (_ping) {
        _ping.delegate = nil;
        self.ping = nil;
    }
    _currentDelagate.resultDelegate = nil;
}

- (void)startRequest {
    bContinue = YES;
    bGetPong = NO;
    self.ping = [SimplePing simplePingWithHostName:_ipAddress];
    _ping.delegate = self;
    [_ping start];
}

- (void)stopRequest {
    bContinue = NO;
    if (_ping) {
        _ping.delegate = nil;
        self.ping = nil;
    }
    _currentDelagate.resultDelegate = nil;
}

- (void)sendPing {
    if (bContinue == NO || _ping == nil || bGetPong) {
        if (_timerToPing) {
            [_timerToPing invalidate];
            self.timerToPing = nil;
        }
        return;
    }
    [[DebugMessage sharedInstance] writeDebugMessage:[NSString stringWithFormat:@"sendPing %@, %@", _absoluteURL, _strPostData]
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    [_ping sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"start pinging %@", _ipAddress);
    
    self.timerToPing = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    NSLog(@"didReceivePingResponsePacket");
    if (bContinue && bGetPong == NO) {
        bGetPong = YES;
        [self performSelectorOnMainThread:@selector(sendRequest) withObject:nil waitUntilDone:YES];
    }
}

- (void)sendRequest {
    [[DebugMessage sharedInstance] writeDebugMessage:@"sendRequest after ping"
                                            function:[NSString stringWithFormat:@"%s", __func__]
                                                line:[NSString stringWithFormat:@"%d", __LINE__]
                                                mode:DebugMessageHttpRequest];
    URLConnectionDelegate * delegate = [[URLConnectionDelegate alloc] init];
    delegate.username = _username;
    delegate.password = _password;
    delegate.resultDelegate = self;
    delegate.tag = _tag;
    self.currentDelagate = delegate;
    
    if (_strPostData) {
        [HttpRequest postRequest:_absoluteURL postData:_strPostData withConnectionDelegate:delegate withTimeout:_timeout];
        return;
    }
    [HttpRequest sendRequest:_absoluteURL withConnectionDelegate:delegate withTimeout:_timeout];
}

- (void)onSuccess:(NSData *)result withTag:(NSInteger)tag {
    if (_resultDelegate) {
        [_resultDelegate onSuccess:result withTag:tag];
    }
}

- (void)onFailed:(NSInteger)statusCode withTag:(NSInteger)tag {
    if (statusCode == 0 && bContinue && _bRetry) {
        _currentDelagate.resultDelegate = nil;
        bGetPong= NO;
        self.timerToPing = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
        return;
    }
    
    if (_resultDelegate) {
        [_resultDelegate onFailed:statusCode withTag:tag];
    }
}

@end


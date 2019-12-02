//
//  AFHTTPSessionManager+PSManager.m
//  LoanMarket
//
//  Created by 吴孔亮 on 2018/8/14.
//  Copyright © 2018年 吴孔亮. All rights reserved.
//

#import "AFHTTPSessionManager+PSManager.h"
#import "PSHTTPRequestSerializer.h"

const CGFloat kTimeoutIntervalForWiFi = 15;
const CGFloat kTimeoutIntervalForWWAN = 25;

@implementation AFHTTPSessionManager (PSManager)


+ (instancetype)jy_sharedManager {
    
    static AFHTTPSessionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi ? kTimeoutIntervalForWiFi : kTimeoutIntervalForWWAN;
//        sharedManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:(NSString *)HTTPDOMAIN] sessionConfiguration:configuration];
        sharedManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api-vn.sanjinxia.com/xjdApi/doCall"] sessionConfiguration:configuration];

        
        sharedManager.requestSerializer = [[PSHTTPRequestSerializer alloc] init];
        sharedManager.responseSerializer = [PSHTTPResponseSerializer serializer];
        
        //设置支持https,非校验证书模式
        sharedManager.securityPolicy =  [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        sharedManager.securityPolicy.allowInvalidCertificates = YES;
        [sharedManager.securityPolicy setValidatesDomainName:NO];
        
    });
    return sharedManager;
}

- (nullable NSURLSessionDataTask *)POSTWithparameters:(nullable id)parameters
                                              success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    return [self POST:@"" parameters:parameters progress:nil success:success failure:failure];
}


- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           
 
 
                           if (error) {
                               if (failure) {
                                   NSLog(@"失败  %@",error) ;
                                   
 
                                   failure(dataTask, error);
                               }
                           } else {
                               
                                    if (success) {
                                       NSLog(@"成功  %@",responseObject) ;
                                       
                                       success(dataTask, responseObject);
                                       
                                   }
                               }
                               
 
                           }
                 ];
    
    return dataTask;
}



@end



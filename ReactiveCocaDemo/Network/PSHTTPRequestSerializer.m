//
//  PSHTTPRequestSerializer.m
//  LoanMarket
//
//  Created by 吴孔亮 on 2018/8/14.
//  Copyright © 2018年 吴孔亮. All rights reserved.
//

#import "PSHTTPRequestSerializer.h"


NSString *const kDPHTTPErrorMessageKey = @"NSLocalizedDescription";
NSString *const kDPHTTPErrorCodeKey = @"_kCFStreamErrorCodeKey";
NSString *const kDPHTTPErrorProtobufData = @"ErrorPBData";

typedef NS_ENUM(NSInteger, DPHTTPErrorCode) {
    DPHTTPErrorCodeSessionTimeOut,
    DPHTTPErrorCodeDecryptFailure,
};



@implementation PSHTTPRequestSerializer


-(NSString*)rServerTime {
    
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    return [NSString stringWithString:dateString];
}

#pragma mark - AFURLRequestSerialization



- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    
    
    NSParameterAssert(request);
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    
    NSMutableDictionary *baseDict = [NSMutableDictionary dictionary];

    //header信息
     NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    [headerDict setValue:@"My Đồng" forKey:@"appName"];
    [headerDict setValue:@"com.hongcheng.mydong" forKey:@"appPackage"];
    [headerDict setValue:@"0" forKey:@"code"];
    [headerDict setValue:@"5" forKey:@"devicetype"];
    [headerDict setValue:@"0" forKey:@"msgtype"];
    [headerDict setValue:[self rServerTime] forKey:@"sendingtime"];
    [headerDict setValue:app_Version forKey:@"version"];
 
    
    
    
    NSMutableDictionary *oriDic = [NSMutableDictionary dictionary] ;
    
    if (parameters) {
        
        [oriDic addEntriesFromDictionary:parameters];
        
        if ([oriDic.allKeys containsObject:@"action"] ) {
            [headerDict setValue:oriDic[@"action"] forKey:@"action"];
            [oriDic removeObjectForKey:@"action"];
        }
        
        
        if ([oriDic.allKeys containsObject:@"page"] ) {
            [headerDict setValue:oriDic[@"page"] forKey:@"page"];
            [oriDic removeObjectForKey:@"page"];
        }
        
    }
    
    [baseDict setValue:headerDict forKey:@"header"];
    [baseDict addEntriesFromDictionary:oriDic];
    
    
    
    [mutableRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    
 
        NSData *data = [NSJSONSerialization dataWithJSONObject:baseDict options:NSJSONWritingPrettyPrinted error:nil] ;
        
        [mutableRequest setHTTPBody:data];
        
   
    
    return mutableRequest ;
    
}


 



@end


@implementation PSHTTPResponseSerializer

 
#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    
 
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error] ;
    
}

@end

@implementation NSError (WJerror)

- (BOOL)dp_networkError {
    if (self.dp_errorCode != 0) {
        return NO;
    }
    return YES;
}

- (NSInteger)dp_errorCode {
    return [self.userInfo[kDPHTTPErrorCodeKey] integerValue];
}

- (NSString *)dp_errorMessage {
    
    switch (self.code) {
        case NSURLErrorCancelled:
            return nil;
            //        case NSURLErrorTimedOut:
            //            return Localized(@"PSNetTimeout");
            //        case NSURLErrorNotConnectedToInternet:
            //            return Localized(@"PSLinkError");
            //        case NSURLErrorCannotConnectToHost:
            //            return Localized(@"PSLinkError");
        default:
            return self.userInfo[kDPHTTPErrorMessageKey];
    }
}

- (NSData *)dp_errorProtobuf {
    return self.userInfo[kDPHTTPErrorProtobufData];
}


@end



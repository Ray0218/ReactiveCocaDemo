//
//  PSHTTPRequestSerializer.h
//  LoanMarket
//
//  Created by 吴孔亮 on 2018/8/14.
//  Copyright © 2018年 吴孔亮. All rights reserved.
//

 #import <AFNetworking/AFNetworking.h>

@interface PSHTTPRequestSerializer : AFHTTPRequestSerializer

@end


@interface PSHTTPResponseSerializer  : AFHTTPResponseSerializer

@end

extern NSInteger const kDPHTTPResponseSerializerError;
extern NSString *const kDPHTTPErrorMessageKey;
extern NSString *const kDPHTTPErrorCodeKey;
extern NSString *const kDPHTTPErrorProtobufData;


@interface NSError (WJerror)
@property (nonatomic, copy, readonly) NSString *dp_errorMessage;
@property (nonatomic, assign, readonly) NSInteger dp_errorCode;
@property (nonatomic, assign, readonly) BOOL dp_networkError;


@end

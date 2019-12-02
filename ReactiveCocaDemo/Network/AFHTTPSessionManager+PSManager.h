//
//  AFHTTPSessionManager+PSManager.h
//  LoanMarket
//
//  Created by 吴孔亮 on 2018/8/14.
//  Copyright © 2018年 吴孔亮. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFHTTPSessionManager (PSManager)

+ (instancetype _Nullable )jy_sharedManager  ;


- (nullable NSURLSessionDataTask *)POSTWithparameters:(nullable id)parameters
                                 success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

 @end



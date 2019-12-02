//
//  PSHelpModelView.m
//  ReactiveCocaDemo
//
//  Created by 吴孔亮 on 2019/1/15.
//  Copyright © 2019年 Ray. All rights reserved.
//

#import "PSHelpModelView.h"

@implementation PSHelpModelView


//在Command返回的Signal里面一定要记得发送Completed信号，不然这个Command的不能重复执行。

- (RACCommand *)orderCreatCommand{
    
    if (!_orderCreatCommand) {
        
        
        _orderCreatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSMutableDictionary *params) {
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSLog(@"#################  提交订单... ###################")  ;
                
                
                [[AFHTTPSessionManager jy_sharedManager]POSTWithparameters:@{@"action":@"SYS0002"} success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                    
                    
                    NSLog(@"######## 数据请求成功 ###########");
                    [subscriber sendNext:responseObject];
                    //RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
                    [subscriber sendCompleted];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                    
                    NSLog(@"######## 数据请求失败 ###########");
                    
                    [subscriber sendError:error];
                    
                    //RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
                    [subscriber sendCompleted];
                }] ;
                
                
                return nil;
            }];
            
        }];
        //是否允许同时执行多个任务
//        _orderCreatCommand.allowsConcurrentExecution = YES ;
        
    }
    
    return _orderCreatCommand;
}


-(void)test_normal {
    
    NSLog(@"#################  提交订单... ###################")  ;
    
    [[AFHTTPSessionManager jy_sharedManager]POSTWithparameters:@{@"action":@"SYS0002"} success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSLog(@"######## 数据请求成功 ###########");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        
        NSLog(@"######## 数据请求失败 ###########");
        
    }] ;
}

@end

//
//  KLSignalManager.h
//  ReactiveCocaDemo
//
//  Created by WKL on 2019/11/29.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACReturnSignal.h"
 

NS_ASSUME_NONNULL_BEGIN

@interface KLSignalManager : NSObject

@property(nonatomic,strong)RACSignal *rFirstSignal;

@property(nonatomic,strong)RACSignal *rSecondSignal;


+ (instancetype)shareManager;




@end

NS_ASSUME_NONNULL_END

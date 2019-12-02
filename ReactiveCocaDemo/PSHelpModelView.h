//
//  PSHelpModelView.h
//  ReactiveCocaDemo
//
//  Created by 吴孔亮 on 2019/1/15.
//  Copyright © 2019年 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSHelpModelView : NSObject

@property (nonatomic,strong) RACCommand *orderCreatCommand;

-(void)test_normal ;

@end

NS_ASSUME_NONNULL_END

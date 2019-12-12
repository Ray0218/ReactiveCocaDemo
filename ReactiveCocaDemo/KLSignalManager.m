//
//  KLSignalManager.m
//  ReactiveCocaDemo
//
//  Created by WKL on 2019/11/29.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "KLSignalManager.h"
 
@implementation KLSignalManager

static KLSignalManager *_manager = nil ;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
 
        _manager = [[super allocWithZone:NULL]init];
    });
    return _manager ;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [KLSignalManager shareManager] ;
}






-(void)test_RACSignal {
    
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //block调用时刻：每当有订阅者订阅信号，就会调用block
        NSLog(@"发出的数据");
        
        //2.发送信号
        [subscriber sendNext:@1];
        
        //如果不再发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block，取消订阅
            NSLog(@"信号被销毁");
        }];
    }];
    
    
    //3.订阅信号
    [signal subscribeNext:^(id x) {
        //block调用时刻：每当有信号发送数据，就会调用该方法
        NSLog(@"接收到的数据：%@",x);
    }];
    
    
    
    [signal subscribeNext:^(id x) {
        //block调用时刻：每当有信号发送数据，就会调用该方法
        NSLog(@"接收到的第二个数据：%@",x);
    }];
    
    
    //    ReactiveCocaDemo[71373:1864316] 发出的数据
    //    2019-11-29 18:18:44.133170+0800 ReactiveCocaDemo[71373:1864316] 接收到的数据：1
    //    2019-11-29 18:18:44.133359+0800 ReactiveCocaDemo[71373:1864316] 信号被销毁
    //    2019-11-29 18:18:54.956165+0800 ReactiveCocaDemo[71373:1864316] 发出的数据
    //    2019-11-29 18:18:54.956392+0800 ReactiveCocaDemo[71373:1864316] 接收到的第二个数据：1
    //    2019-11-29 18:18:54.956516+0800 ReactiveCocaDemo[71373:1864316] 信号被销毁
    
    
}

#pragma mark 对于RACSignal不同的地方是：他可以被订阅多次，并且只能是先订阅后发布
-(void)test_RACSubject {
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    //2.订阅信号
    [subject subscribeNext:^(id x) {
        //block调用时刻：当信号发出新值，就会调用
        NSLog(@"第一个订阅者发出%@",x);
    }];
    [subject subscribeNext:^(id x) {
        //block调用时刻：当信号发出新值，就会调用
        NSLog(@"第二个订阅者发出%@",x);
    }];
    
    //3.发送信号
    [subject sendNext:@"发送"];
    
    //    2019-11-30 17:38:48.350234+0800 ReactiveCocaDemo[84375:2379142] 第一个订阅者发出发送
    //    2019-11-30 17:38:48.350424+0800 ReactiveCocaDemo[84375:2379142] 第二个订阅者发出发送
    //
    
    
}



#pragma mark RACReplaySubject 继承RACSubject 他的目的就是为例解决RACSubject必须先订阅后发送的问题。它可以先发送后订阅
-(void)test_RACReplaySubject  {
    //1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    // RACReplaySubject *replaySubject = [RACReplaySubject replaySubjectWithCapacity:0];
    
    //2.发送信号
    [replaySubject sendNext:@"先发送数据"];
    
    //3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者接收%@",x);
    }];
    
    
    //    2019-11-30 17:39:04.125242+0800 ReactiveCocaDemo[84375:2379142] 第一个订阅者接收先发送数据
}

#pragma mark RACDisposable
//1 订阅者被销毁
//2 RACDisposable 调用dispose取消订阅
-(void)test_disposable{
    
    //1、创建信号量
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"创建信号量");
        
        //3、发布信息
        [subscriber sendNext:@"I'm send next data"];
        
        NSLog(@"那我啥时候运行");
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"disposable");
        }];
    }];
    
    //2、订阅信号量
    RACDisposable *poss = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
}


-(void)test_RACCommand {
    
    //1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"执行命令 %@",input);
        
        // signalBlock必须要返回一个信号，不能传nil，如果不想要传递信号，直接创建空的信号。
        //return [RACSignal empty];
        
        //2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            
            //RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    //RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    //3.订阅信号
    [command.executionSignals subscribeNext:^(id x) {
        
        [x subscribeNext:^(id x) {
            NSLog(@" ## 接收数据  %@",x);
        }];
    }];
    
    
    //RAC高级用法：
       // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号,不需要订阅信号
       [command.executionSignals.switchToLatest subscribeNext:^(id x) {
           NSLog(@"##h接收 %@",x);
       }];

    
    //监听命令是否执行完毕，默认会来一次，可以直接跳过,skip表示跳过第一次命令
//    [[command.executing skip:1] subscribeNext:^(id x) {
        [command.executing subscribeNext:^(id x) {

        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    
    
    //4.执行命令
    //    [self.command execute:nil];
    
   RACSignal *comSignal = [command execute:@"输入内容"];
    
    [comSignal subscribeNext:^(id  _Nullable x) {
        
        
        NSLog(@"comsignal 接收到数据 %@",x) ;
    }] ;
    
   
}



#pragma mark- 信号组合

#pragma mark concat:按一定顺序拼接信号，当多个信号发出的时候,必须前一个信号结束(sendCompleted),才能进行下一个信号。

// concat底层实现:
// 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
// 2.didSubscribe中，会先订阅第一个源信号（signalA）
// 3.会执行第一个源信号（signalA）的didSubscribe
// 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
// 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
// 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
// 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.

-(void)test_concat{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"signalA 发送信号");
        
        [subscriber sendNext:@"signalA"];
        
        //必须调用complete 否则B不会执行
        [subscriber sendCompleted] ;
        
        return nil ;
        return [RACDisposable disposableWithBlock:^{
            
        }] ;
        
    }] ;
    
    
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"signalB 发送信号");
        
        [subscriber sendNext:@"signalB"];
        
        return  nil ;
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"disposable") ;
        }] ;
    }] ;
    
    // 以后只需要面对拼接信号开发。
    // 订阅拼接的信号，不需要单独订阅signalA，signalB
    // 内部会自动订阅。
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    [[signalA concat:signalB]subscribeNext:^(id  _Nullable x) {
        
        
        NSLog(@"concat == %@",x);
    }] ;
    
    //    2019-11-29 21:58:56.450037+0800 ReactiveCocaDemo[73784:1968301] signalA 发送信号
    //    2019-11-29 21:58:56.450242+0800 ReactiveCocaDemo[73784:1968301] concat == signalA
    //    2019-11-29 21:58:56.450352+0800 ReactiveCocaDemo[73784:1968301] signalB 发送信号
    //    2019-11-29 21:58:56.450432+0800 ReactiveCocaDemo[73784:1968301] concat == signalB
    
    
}







#pragma mark   then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号,而且只会返回then的信号值
-(void)test_then {
    
    // then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"signalB 发送信号");
        
        [subscriber sendNext:@"signalB"];
        
        return  nil ;
        
    }] ;
    
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"signalA 发送信号");
        [subscriber sendNext:@"signalA"];
        
        [subscriber sendCompleted];
        return nil ;
        
        
    }]
      then:^RACSignal * _Nonnull{
        
        return signalB ;
        
    }]
     subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x) ;
        
    }] ;
    
    //    019-11-29 21:41:06.549362+0800 ReactiveCocaDemo[73609:1960958] signalA 发送信号
    //    2019-11-29 21:41:13.957138+0800 ReactiveCocaDemo[73609:1960958] signalB 发送信号
    //    2019-11-29 21:41:19.756719+0800 ReactiveCocaDemo[73609:1960958] signalB
    
    
}

#pragma mark merge:把多个信号合并成一个信号,任何一个信号发送数据,就会触发
-(void)test_merge{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送信号A");
        [subscriber sendNext:@"signalA"];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送信号B");
        
        [subscriber sendNext:@"signalB"];
        
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // 底层实现：
    // 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
    // 2.每发出一个信号，这个信号就会被订阅
    // 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
    // 4.只要有一个信号被发出就会被监听。
    
}

#pragma mark zip 两个信号的内容合并成一个元组，才会触发压缩流的next事件
//把两个信号压缩成一个信号，只有当两个信号同时发出新的信号内容时，才把两个信号的内容合并成一个元组，才会触发压缩流的next事件。如果信号A有最新值,信号B没有,则不会触发next事件
-(void)test_zip{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"signalA"];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"signalB"];
        
        return nil;
    }];
    
    
    
    // 压缩信号A，信号B
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 底层实现:
    // 1.定义压缩信号，内部就会自动订阅signalA，signalB
    // 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
    
}

#pragma mark :将多个信号的最新的值,组合成元祖发出。
//
//将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。如果A有最新值,即便B没有最新值,也会触发next事件
-(void)test_combineLatest{
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request1发送请求");
        
        //
        [subscriber sendNext:[NSString stringWithFormat:@"request1 发送请求%d",arc4random()%30]];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //
        NSLog(@" request2发送请求");
        
        [subscriber sendNext:@"request2 发送请求"];
        return nil;
    }];
    
    
    [[RACSignal combineLatest:@[request1,request2]] subscribeNext:^(RACTuple * _Nullable x) {
        
        NSLog(@"ddd %@",x) ;
        
    }];
    
    
    // 底层实现：
    // 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
    // 2.并且把两个信号组合成元组发
    
}

#pragma mark reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
-(void)test_reduce {
    
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request1发送请求");
        
        //
        [subscriber sendNext:[NSString stringWithFormat:@"request1 发送请求%d",arc4random()%30]];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //
        NSLog(@" request2发送请求");
        
        [subscriber sendNext:@"request2 发送请求"];
        return nil;
    }];
    
    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[request1,request2] reduce:^id(NSNumber *num1 ,NSNumber *num2){
        
        return [NSString stringWithFormat:@"%@ %@",num1,num2];
        
    }];
    
    [reduceSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 底层实现:
    // 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。
}
#pragma mark rac_liftSelector
-(void)testrac_liftSelector{
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}

#pragma mark - 过滤信号

#pragma mark filter:过滤信号，使用它可以获取满足条件的信号.
-(void)test_filter{
    
    [[self.rFirstSignal filter:^BOOL(NSString * _Nullable value) {
        
        return value.length > 3;
    }]subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x) ;
    }];
}

#pragma mark ignore忽略某些值的信号
-(void)test_ignore{
    // 内部调用filter过滤，忽略掉ignore的值
    [[self.rFirstSignal ignore:@"1"] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

#pragma mark distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
-(void)test_distinctUntilChanged{
    
    
    static NSString *lastText = @"";
    [self.rFirstSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"非 until上次的值%@ , 当前值%@",lastText,x);
        
    }] ;
    
    [[self.rFirstSignal distinctUntilChanged] subscribeNext:^(NSString* x) {
        
        NSLog(@"上次的值%@ , 当前值%@",lastText,x);
        lastText = x;
    }];
    
}

#pragma mark take:从开始一共取N次的信号

-(void)test_take{
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal take:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@"第一次信号"];
    [signal sendNext:@"第二次信号"];
    [signal sendNext:@"第三次信号"];
    
    //    2019-11-30 11:50:32.587134+0800 ReactiveCocaDemo[80483:2240118] 第一次信号
    //    2019-11-30 11:50:32.587282+0800 ReactiveCocaDemo[80483:2240118] 第二次信号
}

#pragma mark takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.

-(void)test_takeLast{
    
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal takeLast:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@"第一次信号"];
    [signal sendNext:@"第二次信号"];
    [signal sendNext:@"第三次信号"];
    [signal sendNext:@"第四次信号"];
    
    //必须要调
    [signal sendCompleted];
    
    //    2019-11-30 11:50:14.490642+0800 ReactiveCocaDemo[80483:2240118] 第三次信号
    //    2019-11-30 11:50:14.490766+0800 ReactiveCocaDemo[80483:2240118] 第四次信号
}

#pragma mark takeUntil:(RACSignal *):获取信号直到某个信号(B)执行完成才不能获取信.不可逆的,即便改变B,也不能重新获取到信号

-(void)test_takeUntil{
    
    [[self.rFirstSignal takeUntil:
      [self.rSecondSignal  filter:^BOOL(NSString * _Nullable value) {
        return value.length > 3;
    }]
      
      ]subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeUntil == %@",x);
    }]  ;
    //当rSecondSignal中的条件满足后,将不再接受到信号
    
    
    [[self.rSecondSignal takeUntil:[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [subscriber sendNext:@"dddd"] ;

        });
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"disposableWithBlock");
        }];
    }]]subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"接收 %@",x);
    }] ;
    
}

#pragma mark skip:(NSUInteger):跳过几个信号,不接受。
-(void)test_skip {
    
    [[self.rFirstSignal skip:3]subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"first %@",x) ;
    }] ;
    //
    
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal skip:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@"第一次信号"];
    [signal sendNext:@"第二次信号"];
    [signal sendNext:@"第三次信号"];
    [signal sendNext:@"第四次信号"];
    //  2019-11-30 11:48:07.202595+0800 ReactiveCocaDemo[80483:2240118] 第三次信号
    //  2019-11-30 11:48:07.202870+0800 ReactiveCocaDemo[80483:2240118] 第四次信号
    
}

#pragma mark switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
-(void)test_switchToLatest{
    
    RACSubject *signalOfSignals = [RACSubject subject];
    
    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"switchToLatest = %@",x);
    }];
    [signalOfSignals sendNext:self.rFirstSignal];
    
}



#pragma mark- 秩序
#pragma mark doNext: 执行Next之前，会先执行这个Block
//doCompleted: 执行sendCompleted之前，会先执行这个Block
-(void)test_donext{
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"send next"];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        // 执行[subscriber sendNext:@1];之前会调用这个Block
        NSLog(@"doNext");;
    }] doCompleted:^{
        // 执行[subscriber sendCompleted];之前会调用这个Block
        NSLog(@"doCompleted");;
    }] subscribeNext:^(id x) {
        
        NSLog(@" subscribeNext %@",x);
    }];
    
    //    2019-11-30 14:21:40.287045+0800 ReactiveCocaDemo[81869:2293879] doNext
    //    2019-11-30 14:21:40.287201+0800 ReactiveCocaDemo[81869:2293879]  subscribeNext send next
    //    2019-11-30 14:21:40.287310+0800 ReactiveCocaDemo[81869:2293879] doCompleted
}

#pragma mark- 重复

#pragma mark retry重试 ：只要失败，就会自动重新执行  创建信号中的block ,直到成功,不会执行后面的next或者error.
-(void)test_retry{
    
    __block int i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        if (i == 3) {
            [subscriber sendNext:@1];
        }else{
            NSLog(@"接收到错误");
            
            NSError *error= [NSError errorWithDomain:NSCocoaErrorDomain code:11 userInfo:nil];
            [subscriber sendError:error];
        }
        i++;
        
        return nil;
        
    }] retry] subscribeNext:^(id x) {
        
        NSLog(@"subscribeNext %@",x);
        
    } error:^(NSError *error) {
        
        NSLog(@"error ");
        
    }];
    
    
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        if (i == 3) {
            [subscriber sendNext:@1];
        }else{
            NSLog(@"### 接收到错误 ## ");
            
            NSError *error= [NSError errorWithDomain:NSCocoaErrorDomain code:11 userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
        
    }]   subscribeNext:^(id x) {
        
        NSLog(@"### subscribeNext %@",x);
        
    } error:^(NSError *error) {
        
        NSLog(@" ### error ");
        
    }];
    
}

#pragma mark `replay`重放：当一个信号被多次订阅,反复播放内容,但是创建信号中的block 只会执行一次
-(void)test_replay{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@" sendNext ");
        
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        
        return nil;
    }] replay];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者%@",x);
        
    }];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者%@",x);
        
    }];
    
    //    2019-11-30 14:27:36.182379+0800 ReactiveCocaDemo[81939:2296704]  sendNext
    //    2019-11-30 14:27:36.182695+0800 ReactiveCocaDemo[81939:2296704] 第一个订阅者1
    //    2019-11-30 14:27:36.182785+0800 ReactiveCocaDemo[81939:2296704] 第一个订阅者2
    //    2019-11-30 14:27:36.182885+0800 ReactiveCocaDemo[81939:2296704] 第二个订阅者1
    //    2019-11-30 14:27:36.182958+0800 ReactiveCocaDemo[81939:2296704] 第二个订阅者2
}

#pragma mark RACMulticastConnection 连接类
//其实是一个连接类，连接类的意思就是当一个信号被多次订阅，他可以帮我们避免多次调用创建信号中的block

-(void)test_RACMulticastConnection {
    
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求") ;
        [subscriber sendNext:@1];
        
        return nil ;
    }] ;
    
    //2创建连接
    RACMulticastConnection *connect = [signal publish] ;
    
    
    
    //3订阅信号.即使订阅了,还没有激活信号
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者第一信号%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者第二信号%@",x);
    }];
    
    //4.连接,激活信号
    [connect connect];
    
    //    2019-11-29 19:47:17.436975+0800 ReactiveCocaDemo[72349:1905828] 发送请求
    //    2019-11-29 19:47:17.437226+0800 ReactiveCocaDemo[72349:1905828] 订阅者第一信号1
    //    2019-11-29 19:47:17.437341+0800 ReactiveCocaDemo[72349:1905828] 订阅者第二信号1
    
}



#pragma mark throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。
-(void)test_throttle{
    
    // 节流，在一定时间（1秒）内，不接收任何信号内容，过了这个时间（1秒）获取最后发送的信号内容发出。
    [[self.rFirstSignal throttle:1] subscribeNext:^(id x) {
        
        NSLog(@"first = %@",x);
    }];
    
    
    [self.rSecondSignal  subscribeNext:^(id x) {
        
        NSLog(@"second = %@",x);
    }];
}


#pragma mark- 时间

#pragma mark interval 定时：每隔一段时间发出信号

-(void)test_interval {
    
    //    RACSignal *rac_viewWillDisappear = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    
    __block int  rTime = 10 ;
    RACDisposable *disPos =  [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler] withLeeway:0]
                               //通过untail触发
                               takeUntilBlock:^BOOL(NSDate * _Nullable x) {
        
        if (rTime == 0) {
            return YES ;
        }
        return NO;
    }]
                              subscribeNext:^(NSDate * _Nullable x) {
        
        NSLog(@"计时器%ds",rTime);
        rTime -- ;
        if (rTime == 0) {
        }
        
    }];
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        //主动触发取消订阅
    //        [disPos dispose];
    //    });
    
    
    
    
    
}

#pragma mark delay 延迟发送next。
-(void)test_delay{
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        return nil;
    }] delay:2]
     subscribeNext:^(id x) {
        
        NSLog(@"延迟触发 %@",x);
    }];
    
    
    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
        NSLog(@"延时写法");
    }];
}

#pragma mark  timeout：超时，可以让一个信号在一定的时间后，自动报错。
-(void)test_timeout{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"%@",error);
    }];
    
}






-(void)test_other {
    
    UIButton *redV;
    UITextField *_textField ;
    
    // 1.代替代理
    // 需求：自定义redView,监听红色view中按钮点击
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    [[redV rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"点击红色按钮");
    }];
    // 2.KVO
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    // observer:可以传入nil
    [[redV rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    // 3.监听事件
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    //    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    //
    //        NSLog(@"按钮被点击了");
    //    }];
    // 4.代替通知
    // 把监听到的通知转换信号
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    // 5.监听文本框的文字改变
    [_textField.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"文字改变了%@",x);
    }];
    
}
// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
    
}

-(void)testBind{
    
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //block调用时刻：每当有订阅者订阅信号，就会调用block
        NSLog(@"发出的数据：%@",@1);
        
        //4.发送信号
        [subscriber sendNext:@1];
        
        
        
        //如果不再发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block，取消订阅
            NSLog(@"信号被销毁");
        }];
    }];
    
    //    2.绑定源信号,生成绑定信号
    
    RACSignal *testBindSignal = [signal bind:^RACSignalBindBlock _Nonnull{
        return ^ RACSignal *(id  value, BOOL *stop){
            
            return [RACReturnSignal return:[NSString stringWithFormat:@"2 . %@666",value]];
        };
    }];
    
    //3.订阅绑定信号
    [testBindSignal subscribeNext:^(id x) {
        //block调用时刻：每当有信号发送数据，就会调用该方法
        NSLog(@"3 接收到绑定的数据：%@",x);
    }];
    
    
//    [signal subscribeNext:^(id x) {
//        //block调用时刻：每当有信号发送数据，就会调用该方法
//        NSLog(@" ## 接收到非绑定的数据：%@",x);
//    }];
    
    //    [signal map:^id _Nullable(id  _Nullable value) {
    //
    //        return value ;
    //    }];
    //
    //    [signal  flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
    //
    //        return [RACReturnSignal return:value];
    //        [RACSignal return:@"dd"];
    //    }];
    
    
}

-(void)test_RACTuple {
    
    //    RAC的Tuple就是把OC的数组进行了一层封装
    //    其实他就是一个数组……
    RACTuple *tup =[RACTuple tupleWithObjectsFromArray:@[@"大吉大利",@123,@33,@"时代的"]];
    NSLog(@"%@, %@ , %@",tup,tup[0],tup.first);
    
    //    RACSequence，这个类可以用来代替我们的NSArray或者NSDictionary，主要就是用来快速遍历，和用来字段转模型。
    
    //第一步: 把数组/字典转换成集合RACSequence             numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类    numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    
    
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"## %@",x);
    }];
    
    RACSequence *rSquence =  [numbers.rac_sequence map:^id _Nullable(id  _Nullable value) {
        
        return [NSString stringWithFormat:@"转化后 %@",value] ;
    }];
    
    NSArray *newNums =   [rSquence array];
    NSLog(@"#### %@",newNums);
    
    NSArray *ss =  [[numbers.rac_sequence flattenMap:^__kindof RACSequence * _Nullable(id  _Nullable value) {
        return [RACSequence return: value];
    }] array];
    
    NSLog(@"ss =  %@",ss);

    
    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"xiaoming",@"age":@18};
    
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        
        // 相当于以下写法
        //        NSString *key = x[0];
        //        NSString *value = x[1];
        NSLog(@"key - %@ value - %@",x[0],x[1]);
        
        RACTupleUnpack(NSString *key,NSString *value) = x;
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        
        NSLog(@"的订单= %@ %@",key,value);
        
    }] ;
    
    
    
    
}


@end

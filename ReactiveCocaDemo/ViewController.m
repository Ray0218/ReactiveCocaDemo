//
//  ViewController.m
//  ReactiveCocaDemo
//
//  Created by 吴孔亮 on 2019/1/14.
//  Copyright © 2019年 Ray. All rights reserved.
//

#import "ViewController.h"
#import "PSHelpModelView.h"
#import "KLSignalManager.h"
#import "Ptrace.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *_titlesArray ;
    NSArray *_sectons;
}

@property(nonatomic,strong)UITableView * rTableView;

@property (nonatomic,strong)RACCommand *command ;

@property(nonatomic,strong)UITextField *rTextField;

@property(nonatomic,strong)UITextField *rSecondField;

@property (nonatomic,strong) PSHelpModelView *rModelView ;


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sectons = @[@"基础",@"组合",@"过滤",@"时间",@"重复",@"other"];
    _titlesArray = @[
        
        @[@"test_RACSignal",@"test_RACSubject",@"test_RACReplaySubject",@"test_disposable",@"test_RACCommand"],
        @[@"test_concat",@"test_then",@"test_merge",@"test_zip",@"test_combineLatest",@"testrac_liftSelector",@"test_reduce"],
        @[@"test_filter",@"test_ignore",@"test_distinctUntilChanged",@"test_take",@"test_takeLast",@"test_takeUntil",@"test_skip",@"test_switchToLatest"],
        @[@"test_timeout",@"test_interval",@"test_delay"],
        @[@"test_retry",@"test_replay",@"test_RACMulticastConnection",@"test_throttle"],
        @[@"test_donext",@"testBind",@"test_RACTuple",@"test_other"]
    ] ;
    
    
    [self.view addSubview:self.rTextField];
    
    [self.view addSubview:self.rSecondField];

    
    [self.view addSubview:self.rTableView];
    
    [KLSignalManager shareManager].rFirstSignal = self.rTextField.rac_textSignal ;
    [KLSignalManager shareManager].rSecondSignal = self.rSecondField.rac_textSignal ;

    
 
    
    UIButton *button ;
    //    @weakify(self)
    //    [[button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
    //
    //        @strongify(self)
    //        NSLog(@"button点击") ;
    //
    ////        [self.rModelView test_normal];
    //
    //        //执行信号
    //        [self.rModelView.orderCreatCommand execute:nil];
    //
    //
    //    }];
    
    //3.订阅信号
    
    //    [self.rModelView.orderCreatCommand.executionSignals subscribeNext:^(id x) {
    //        NSLog(@"######### 准备请求 ############") ;
    //        [x subscribeNext:^(id x) {
    ////            NSLog(@"%@",x);
    //        }];
    //    }];
//    [self.rModelView.orderCreatCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
//
//        NSLog(@"收到数据%@",x);
//    }];
//
//
    [button rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    button.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {

 
        NSLog(@"点击button") ;
        return [RACSignal empty];
    }];
    
    
    if (@available(iOS 13.0, *)) {
        UIColor  *dd = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            
            
            return [UIColor redColor] ;
            
            
        } ] ;
    } else {
        // Fallback on earlier versions
    }
    
   
 
    
}

 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titlesArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titlesArray[section] count] ;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return _sectons[section] ;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellidentify = @"cellidentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentify] ;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentify];
    }
    cell.textLabel.text = _titlesArray[indexPath.section][indexPath.row] ;
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
     SEL sel =  NSSelectorFromString(_titlesArray[indexPath.section][indexPath.row]) ;
    
    [[KLSignalManager shareManager] performSelector:sel];
    
    [Ptrace testPtrace] ;
    
}

-(UITableView*)rTableView {
    if (!_rTableView) {
        _rTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-200)]; ;
        _rTableView.delegate = self;
        _rTableView.dataSource = self ;
    }
    return _rTableView ;
}

-(UITextField*)rTextField {
    if (!_rTextField) {
        _rTextField = [UITextField new] ;
        _rTextField.frame = CGRectMake(0, 80, CGRectGetWidth(self.view.bounds), 45);
        _rTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _rTextField.layer.borderColor = [UIColor blackColor].CGColor;
        _rTextField.layer.borderWidth = 1;
    }
    return _rTextField ;
}

-(UITextField*)rSecondField {
if (!_rSecondField) {
    _rSecondField = [UITextField new] ;
    _rSecondField.frame = CGRectMake(0, 130, CGRectGetWidth(self.view.bounds), 45);
    _rSecondField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _rSecondField.layer.borderColor = [UIColor blackColor].CGColor;
    _rSecondField.layer.borderWidth = 1;
}
    return _rSecondField ;
}



-(PSHelpModelView*)rModelView {
    if (!_rModelView) {
        _rModelView = [PSHelpModelView new] ;
    }
    return _rModelView ;
}



@end

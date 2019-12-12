//
//  Ptrace.m
//  Ptrace
//
//  Created by WKL on 2019/12/11.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "Ptrace.h"
#import <sys/sysctl.h>


#import <dlfcn.h>
#import <sys/types.h>
#import <sys/syscall.h>

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void disable_gdb() {
    // 方式一   系统函数并没有暴露出此方法所以不能直接通过此方式调用
    // ptrace(PT_DENY_ATTACH, 0, 0, 0);
    
    //    方式二 通过dlopen,dlsym调用
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
    
 }

 

static dispatch_source_t timer;


@implementation Ptrace

+(void)testPtrace {
    
    NSLog(@"%s",__func__) ;
    
}


// 1秒钟检测一次
void debugCheck(){
    
    
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isDebugger()) {
                NSLog(@"检测到了!!");
            }else{
                NSLog(@"正常!!");
            }
        });
        
    });
    dispatch_resume(timer);
}


// 真机运行 没有DebuggerServer，所以不会检测到调试
// sysctl(int * 控制码, u_int 字节, void * 查询结果, size_t * 结构体, void * 结构体的大小, size_t)
// #define    P_TRACED    0x00000800    /* Debugged process being traced: 跟踪调试过程 */

//检测是否被调试
BOOL isDebugger(){
    //控制码
    int name[4];//里面放字节码.查询信息
    name[0] = CTL_KERN;     //内核查看
    name[1] = KERN_PROC;    //查询进程
    name[2] = KERN_PROC_PID;//传递的参数是进程的ID(PID)   //同：$ ps -A
    name[3] = getpid();     //PID的值告诉（进程id）
    
    struct kinfo_proc info; //接受进程查询结果信息的结构体
    size_t info_size = sizeof(info);//结构体的大小
    //int error = sysctl(name, 4, &info, &info_size, 0, 0);
    int error = sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
    assert(error == 0);//0就是没有错误,其他就是错误码
    //1011 1000 1010 1010 1101 0101 1101 0101
    //&
    //0000 0000 0000 1000 0000 0000 0000 0000
    // == 0 ? 没有、有!!
    //    p_flag的第12位位1就是有调试
    //    p_flag 与P_TRACED = 0就是有调试
    return ((info.kp_proc.p_flag & P_TRACED) != 0);  // P_TRACED: 跟踪调试过程
}


#pragma mark-   检测是否被调试 汇编方式
__attribute__((always_inline)) bool checkTracing() {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc proc;
    memset(&proc, 0, size);
    
    //控制码
    int name[4];//里面放字节码.查询信息
    name[0] = CTL_KERN;     //内核查看
    name[1] = KERN_PROC;    //查询进程
    name[2] = KERN_PROC_PID;//传递的参数是进程的ID(PID)   //同：$ ps -A
    name[3] = getpid();     //PID的值告诉（进程id）
    
    __asm__(
            
            "mov x0, %[name_ptr]\n"
            "mov x1, #4\n"
            "mov x2, %[proc_ptr]\n"
            "mov x3, %[size_ptr]\n"
            "mov x4, #0x0\n"
            "mov x5, #0x0\n"
            "mov w16, #202\n"
            "svc #0x80\n"
            
            :
            
            :[name_ptr]"r"(&name), [proc_ptr]"r"(&proc), [size_ptr]"r"(&size)
            
            );
    
    return (proc.kp_proc.p_flag & P_TRACED);
    
}

void AntiDebug_005() {
    
    syscall(SYS_ptrace, PT_DENY_ATTACH, 0, 0, 0);
    
}


#pragma mark- 内联 svc + ptrace 实现

//其实这种方法等同于直接使用 ptrace, 此时系统调用号是 SYS_ptrace
static __attribute__((always_inline)) void AntiDebug_003() {
#ifdef __arm64__
    __asm__("mov X0, #31\n"
            "mov X1, #0\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov w16, #26\n"
            "svc #0x80");
#endif
}



#pragma mark- 内联 svc + syscall + ptrace 实现

//其实这种方法等同于使用 syscall(SYS_ptrace, PT_DENY_ATTACH, 0, 0, 0), 这里需要注意, 此时的系统调用号是 0, 也就是 SYS_syscall

static __attribute__((always_inline)) void AntiDebug_004() {
#ifdef __arm64__
    __asm__("mov X0, #26\n"
            "mov X1, #31\n"
            "mov X2, #0\n"
            "mov X3, #0\n"
            "mov X4, #0\n"
            "mov w16, #0\n"
            "svc #0x80");
#endif

}

#pragma mark- 汇编方式书写exit(-1)

static __attribute__((always_inline)) void asm_exit() {
#ifdef __arm64__
    __asm__("mov X0, #0\n"
            "mov w16, #1\n"
            "svc #0x80\n"
            
            "mov x1, #0\n"
            "mov sp, x1\n"
            "mov x29, x1\n"
            "mov x30, x1\n"
            "ret");
#endif
}



void debugerCheck(){
    
    //        if (isDebugger()) {
    //            NSLog(@"进程被调试!!");
    //    //        exit(-1);
    //        }
    
    
    AntiDebug_004();
    return ;
    
    if (checkTracing()) {
        NSLog(@"### 进程被调试!!####");
        asm_exit();
    }
    //开启反调试
    
    
    NSLog(@" ################3");
    
    /**防止GDB挂起*/
    //        #ifndef DEBUG
    //        disable_gdb();
    //        #endif
}


+(void)load{
 
    
//    debugerCheck();
    
}
@end

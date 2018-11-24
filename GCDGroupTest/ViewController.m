//
//  ViewController.m
//  GCDGroupTest
//
//  Created by 李奇 on 2018/10/26.
//  Copyright © 2018年 李奇. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
@interface ViewController ()
@property (nonatomic, assign) NSInteger ticketSurplusCount;

@property (nonatomic, strong) NSLock *lock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

     NSLog(@"start---%@",[NSThread currentThread]);
 //     [self userInvocationOperation];
 //   [self newThread];
 //   [self userBlockOperation];
//[self userBlockOperationAddExecutionBlock];
  //  [self userCustomOperation];
  //  [self addOperationQueue];
  //    [self addOperationBlockToQueue];
//    [self addDependency];
    [self communication];
}
/*
 dispatch_group_wait 当所有任务执行完之后，才执行dispatch_group_wait之后操作，dispatch_group_wait会阻塞当前线程
 */
- (void)groupWait
{
    NSLog(@"currentThread-----%@",[NSThread currentThread]);
    NSLog(@"group----begin");
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"group---end");
}
/*
 dispatch_group_enter dispatch_group_leave 使成对出现的  等同于dispatch_group_async
 任务1 任务2 完成后才执行dispatch_group_notify里面的任务3
 */
- (void)enterAndLeave
{
    NSLog(@"currentThread-----%@",[NSThread currentThread]);
    NSLog(@"enterAndLeave----begin");
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务3---%@",[NSThread currentThread]);      // 打印当前线程
        }
         NSLog(@"enterAndLeave---end");
    });
}
/*
 使用detachNewThreadSelector:方法会开启新线程，tark1会在新线程里面执行。
 如果直接[self userInvocationOperation]则会在主线程里面执行
 NSInvocationOperation是NSOperation的子类，NSOperation是个抽象类，不能用来封装操作，我们只能使用它的子类NSInvocationOperation/NSBlockOperation或者自定义继承NSOperation的子类，实现内部相应的方法来封装操作。
 */
- (void)newThread
{
    [NSThread detachNewThreadSelector:@selector(userInvocationOperation) toTarget:self withObject:nil];
}
- (void)userInvocationOperation
{//NSInvocationOperation继承于NSOperation
 //创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(tark1) object:nil];
    [op start]; //通过start方法开始执行操作
}
- (void)tark1
{
    for (int i = 0; i < 2; ++i) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
    }
}
- (void)userBlockOperation
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op start];//通过start开始执行操作
}
/*
 使用子类NSBlockOperation   调用blockOperationWithBlock:中的操作和addExecutionBlock:中的操作是在不同线程中异步执行的。
 blockOperationWithBlock:里面的操作也有可能不是在主线程执行的，也可能会在其他线程里面执行。
 如果NSBlockOperation是否开启新线程，取决于封装的操作数。如果操作的个数多，NSBlockOperation会自动开辟新线程，当然开启的线程数是有系统决定的。
 */
- (void)userBlockOperationAddExecutionBlock
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务5---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务6---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op start];
}
- (void)userCustomOperation
{
    CustomOperation *op = [[CustomOperation alloc] init];
    [op start];
}
/*
 NSOperationQueue有两种队列：主队列、自定义队列。 其中自定义队列同时包含了串行、并发功能。
 主队列  [NSOperationQueue mainQueue] 凡是添加到主队列中的操作，都会放到主线程中执行（不包括操作使用addExecutionBlock:添加的额外操作，额外操作可能会在其他线程执行）
 自定义队列  [[NSOperationQueue alloc] init] 添加到自定义队列中的操作，会自动放到子线程中执行，同事包含了串行、并发功能
 NSOperation需要配合NSOperationQueue来实现多线程，创建好的操作加入到队列中：addOperation:/addOperationWithBlock:
 */
- (void)addOperationQueue
{
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];  //主队列获取方法
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];  //自定义队列
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}
- (void)task1
{
    for (int i = 0; i < 2; ++i) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
    }
}
- (void)task2
{
    for (int i = 0; i < 2; ++i) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
    }
}
/*
 addOperationWithBlock:能够将操作加入队列中，并并发执行
 */
- (void)addOperationBlockToQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
}
/*
 添加操作的依赖关系addDependency:
 NSOperation提供了queuePriority优先级属性，queuePriority属性适用于同一操作队列中的操作，不适应于不同操作队列中。默认新建的操作优先级为NSOperationQueuePriorityNormal.可以通过setQueuePriority:来改变当前操作在同一队列中的执行优先级。
 对于添加到队列中的操作，首先进入准备就绪状态（就绪状态取决于操作之间的依赖关系），进入就绪状态的开始执行顺序（不是操作的结束执行顺序）由操作之间的相对优先级决定（优先级是操作对象本事的属性）
 当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行
 op1,op2,op3,op4 其中 op3依赖op2 op2依赖op1 现在4个操作并发执行
 因为op1,op4没有依赖关系，op1,op4是准备就绪状态
 op3,op2有依赖关系，op3,op2不是准备就绪状态下的操作
 queuePriority属性决定了进入准备就绪状态下的操作之间的开始执行顺序（不是操作执行结束顺序），优先级不能取代依赖关系
 如果一个队列包含高优先级操作，低优先级操作，并且两个操作都是准备就绪状态，队列执行高优先级操作，如op1,op4都是准备就绪状态，如果是不同优先级，先执行优先级高德操作
 如果一个队列包含了准备就绪状态操作，包含了未准备就绪操作，未准备就绪操作优先级高于准备就绪操作的优先级，但优先级不能取代依赖关系，控制操作间的启动顺序，必须使用依赖关系。如op3是未就绪状态，op4是就绪状态,op3优先级比op4高，但是开始执行顺序还是op4比op3高
 */
- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"任务2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }];
    [op1 addDependency:op2];//添加op1依赖op2   op2先执行
    [queue addOperation:op1];
    [queue addOperation:op2];
}
/*
 NSOperationQueue控制串行执行、并发执行
 maxConcurrentOperationCount控制最大并发操作数，默认为-1，为1是串行队列，大于1是并发队列,操作并发执行。
当最大操作并发数为2时，操作是并发执行的。可以同时执行两个操作，开启线程数量是由系统决定的，不需要我们管理
 */
- (void)communication
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1; //串行队列
  //  queue.maxConcurrentOperationCount = 2;//并发队列
  //  queue.maxConcurrentOperationCount = 8; //并发队列
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"communication任务1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"communication任务2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}
- (void)initTicketStatusSave
{
    self.ticketSurplusCount = 50;
    self.lock = [[NSLock alloc] init];
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}
- (void)saleTicketSafe
{
    while (1) {
        [self.lock lock];
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        [self.lock unlock];
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

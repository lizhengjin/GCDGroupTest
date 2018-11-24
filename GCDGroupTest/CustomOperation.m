
//
//  CustomOperation.m
//  GCDGroupTest
//
//  Created by 李奇 on 2018/10/28.
//  Copyright © 2018年 李奇. All rights reserved.
//

#import "CustomOperation.h"
/*
 使用自定义继承NSOperation,重写mian和start方法来定义NSOperation对象，我们不需要管理操作的状态属性isExecuting和isFinished
 */
@implementation CustomOperation

- (void)main
{
    if (!self.cancelled) {
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"CustomOperation任务1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    }
}
@end

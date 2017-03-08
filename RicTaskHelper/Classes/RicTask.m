//
//  RicTask.m
//  Pods
//
//  Created by john on 2017/3/8.
//
//

#import "RicTask.h"

@interface RicTask ()

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, strong) dispatch_semaphore_t compeleteSemaphore;
@end


@implementation RicTask
@synthesize finished = _finished,executing = _executing;

- (instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}

/**
 task entry for asyn
 */
- (void)start{
    @synchronized (self) {
        if ([self isCancelled])
        {
            self.finished = YES;
            return;
        } else {
            self.executing = YES;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                __block id taskDataInfo = nil;
                [self taskStarted];
                dispatch_queue_t aq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(aq, ^{
                    // 创建一个等待信号
                    self.compeleteSemaphore = dispatch_semaphore_create(0);
                    CompeletedNotice notice = ^{
                        // 发送一个网络请求完成的信号
                        dispatch_semaphore_signal(self.compeleteSemaphore);
                    };
                    if(self.dataProcessAction){
                        // 将通知处理操作扔出去，给具体网络请求对象调用
                        self.dataProcessAction(self,notice);
                    }
                    // 等待网络请求完成信号传过来，否则不会往下执行
                    dispatch_semaphore_wait(self.compeleteSemaphore, DISPATCH_TIME_FOREVER);
                    self.executing = NO;
                    self.finished = YES;
                    [self taskCompeleted];
                });
                
            });
        }
    }
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    if(self.progressHandle){
        self.progressHandle(_progress);
    }
    if(_progress == 1){
        dispatch_semaphore_signal(self.compeleteSemaphore);
    }
}

// 自定义NSOperationQueue要用kvo重写这些这两个方法
//A Boolean value indicating whether the operation is currently executing.
//The value of this property is YES if the operation is currently executing its main task or NO if it is not.
//When implementing a concurrent operation object, you must override the implementation of this property so that you can return the execution state of your operation. In your custom implementation, you must generate KVO notifications for the isExecuting key path whenever the execution state of your operation object changes. For more information about manually generating KVO notifications, see Key-Value Observing Programming Guide.
- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

- (void)taskStarted{
    
}

- (void)taskCompeleted{
    
}

- (NSString *)generateTaskId
{
    return @"";
}
- (BOOL)isEqual:(RicTask *)anotherTask{
    return anotherTask != nil && [self.taskId isEqual:anotherTask.taskId];
}

- (void)dealloc
{
    
}

@end

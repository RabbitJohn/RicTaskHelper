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
                    self.compeleteSemaphore = dispatch_semaphore_create(0);
                    CompeletedNotice notice = ^{
                        dispatch_semaphore_signal(self.compeleteSemaphore);
                    };
                    if(self.dataProcessAction){
                        self.dataProcessAction(self,notice);
                    }
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

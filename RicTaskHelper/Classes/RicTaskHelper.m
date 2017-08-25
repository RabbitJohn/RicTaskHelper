//
//  UploadTaskHelper.m
//  creditor
//
//  Created by john on 2017/2/23.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "RicTaskHelper.h"
#import <objc/runtime.h>

@interface RicTaskHelper ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (atomic, strong) NSMutableArray <RicTask *>*processTasks;
@property (atomic, strong) NSMutableArray <RicTask *>*processingTasks;
@property (atomic, strong) NSMutableArray <RicTask *>*tasksHasNoDependcy;

@property (nonatomic, copy) void(^compeletedAction)(void);
@property (nonatomic, copy) void(^progressHandle)(NSInteger compeletedCount,NSInteger totalCount);

@property (nonatomic, assign, readonly) BOOL processTaskCompeleted;
@property (nonatomic, assign) BOOL hasStart;
@property (nonatomic, assign) NSInteger compeletedCount;
@end

@implementation RicTaskHelper

- (instancetype)init
{
    self = [super init];
    if(self){
        self.maxConcurrencyProcessCount = 5;
        self.compeletedCount = 0;
        self.processTasks = [NSMutableArray new];
        self.processingTasks = [NSMutableArray new];
        self.tasksHasNoDependcy = [NSMutableArray new];
    }
    return self;
}

- (void)addTask:(RicTask *)task{
    if(task == nil){
        return;
    }
    @synchronized (self) {
        if(task){
            task.taskHasBeginRun = ^(RicTask *task){
                __weak RicTaskHelper *weakSelf = self;
                [weakSelf taskHasBeginRun:task];
            };
            task.taskHasFinished = ^(RicTask *task){
                __weak RicTaskHelper *weakSelf = self;
                [weakSelf taskHasFinished:task];
            };
            if(task.taskId == nil ||task.taskId.length == 0){
                NSString *udidString = [[NSUUID UUID] UUIDString];
                task.taskId = [NSString stringWithFormat:@"%@_TaskId_%f",udidString,[NSDate date].timeIntervalSince1970];
            }
            [self.tasksHasNoDependcy addObject:task];
            [self.processTasks addObject:task];
        }
    }
}

- (void)addTasks:(NSArray <RicTask *>*)tasks{
    if(tasks == nil || tasks.count == 0){
        return;
    }
    @synchronized (tasks) {
        [tasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addTask:obj];
        }];
    }
}

- (void)resumeTask:(RicTask *)task{
    if(task){
        RicTask *atask = [self.processTasks objectAtIndex:[self.processTasks indexOfObject:task]];
        if([self.tasksHasNoDependcy containsObject:atask] == NO){
            @synchronized (self.tasksHasNoDependcy) {
                [self.tasksHasNoDependcy addObject:atask];
            }
        }
        [atask start];
    }
}

- (void)pauseTask:(NSString *)taskId{
    if(taskId != nil){
        __weak RicTaskHelper *weakSelf = self;
        @synchronized (self.tasks) {
            [self.tasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj.taskId isEqualToString:taskId] && obj.isExecuting == NO){
                    [obj cancel];
                    if(weakSelf.tasksHasNoDependcy.count > 0){
                        [obj.nextTask removeDependency:obj];
                        [obj addDependency:[weakSelf.tasksHasNoDependcy firstObject]];
                    }
                }
            }];
        }
    }
}

- (void)pauseAll{
    [self.operationQueue cancelAllOperations];
}

- (void)setMaxConcurrencyProcessCount:(NSUInteger)maxConcurrencyProcessCount{
    _maxConcurrencyProcessCount = maxConcurrencyProcessCount;
    self.operationQueue.maxConcurrentOperationCount = _maxConcurrencyProcessCount;
}

- (void)startTasks:(void(^)(void))UIPerformanceWhenTasksHasStarted progressHandle:(void(^)(NSInteger compeletedCount,NSInteger totalCount))progressHandle compeleteAction:(void(^)(void))compeletedAction{
    
    if(self.hasStart || self.processTasks.count == 0){
        return;
    }
    
    self.compeletedAction = compeletedAction;
    self.progressHandle = progressHandle;
    if(UIPerformanceWhenTasksHasStarted){
        UIPerformanceWhenTasksHasStarted();
    }

    @synchronized (self.processTasks) {
        self.hasStart = YES;
        __weak RicTaskHelper *weakSelf = self;
        [self.processTasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if(weakSelf.processingTasks.count >= weakSelf.maxConcurrencyProcessCount && weakSelf.tasksHasNoDependcy.count > 0){
                [aTask addDependency:[weakSelf.tasksHasNoDependcy firstObject]];
                [[weakSelf.tasksHasNoDependcy firstObject] updateNextTask:aTask];
                [weakSelf.tasksHasNoDependcy removeObjectAtIndex:0];
            }else{
                [weakSelf.processingTasks addObject:aTask];
            }
            if(!aTask.isFinished){
               [weakSelf.operationQueue addOperation:aTask];
            }
        }];
    }
}

- (NSArray <RicTask *>*)tasks{
    return self.processTasks;
}

- (NSOperationQueue *)operationQueue{
    
    if(_operationQueue == nil){
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

- (BOOL)uploadTaskCompeleted{
    return self.compeletedCount == self.processTasks.count;
}

#pragma mark - private methods

- (void)taskHasBeginRun:(RicTask *)task
{
    if(task && [task isKindOfClass:[RicTask class]]){
        @synchronized (self.processingTasks) {
            if([self.processingTasks containsObject:task] == NO){
                [self.processingTasks addObject:task];
            }
        }
    }
}

- (void)taskHasFinished:(RicTask *)task
{
    if(task){
        @synchronized (self) {
            if([self.processingTasks containsObject:task]){
                [self.processingTasks removeObject:task];
                if([self.tasksHasNoDependcy containsObject:task]){
                    [self.tasksHasNoDependcy removeObject:task];
                }
            }
            self.compeletedCount ++;
            if(self.uploadTaskCompeleted){
                self.hasStart = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.progressHandle != NULL){
                        self.progressHandle(self.compeletedCount,self.processTasks.count);
                    }
                    if(self.compeletedAction != NULL){
                        self.compeletedAction();
                    }
                    [self.processTasks removeAllObjects];
                    self.compeletedCount = 0;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.progressHandle != NULL){
                        self.progressHandle(self.compeletedCount,self.processTasks.count);
                    }
                });
            }
        }
   }
}

@end



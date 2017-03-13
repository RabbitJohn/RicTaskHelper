//
//  UploadTaskHelper.m
//  creditor
//
//  Created by john on 2017/2/23.
//  Copyright © 2017年 john. All rights reserved.
//

#import "RicTaskHelper.h"
#import <objc/runtime.h>

@interface RicTaskHelper ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray <RicTask *>*processTasks;
@property (nonatomic, strong) NSMutableArray <RicTask *>*processingTasks;
@property (nonatomic, strong) NSMutableArray <RicTask *>*tasksHasNoDependcy;

@property (nonatomic, copy) void(^compeletedAction)(void);
@property (nonatomic, copy) void(^progressHandle)(NSInteger compeletedCount,NSInteger totalCount);

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
                task.taskId = [NSString stringWithFormat:@"%@_TaskId_%f",[task description],[NSDate date].timeIntervalSince1970];
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
    [tasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addTask:obj];
    }];
   
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
        [self.tasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.taskId isEqualToString:taskId] && obj.isExecuting == NO){
                [obj cancel];
                if(weakSelf.tasksHasNoDependcy.count > 0){
                    [obj.follower removeDependency:obj];
                    [obj addDependency:[weakSelf.tasksHasNoDependcy firstObject]];
                }
            }
        }];
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

    @synchronized (self) {
        self.hasStart = YES;
        __weak RicTaskHelper *weakSelf = self;
        [self.processTasks enumerateObjectsUsingBlock:^(RicTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if(weakSelf.processingTasks.count >= weakSelf.maxConcurrencyProcessCount && weakSelf.tasksHasNoDependcy.count > 0){
                [aTask addDependency:[weakSelf.tasksHasNoDependcy firstObject]];
                [[weakSelf.tasksHasNoDependcy firstObject] setValue:aTask forKey:@"follower"];
                [weakSelf.tasksHasNoDependcy removeObjectAtIndex:0];
            }else{
                [weakSelf.processingTasks addObject:aTask];
            }
            [weakSelf.operationQueue addOperation:aTask];
        }];
    }
}

#pragma mark - lazy load
- (NSMutableArray <RicTask *>*)processTasks{
    if(_processTasks == nil){
        _processTasks = [NSMutableArray new];
    }
    return _processTasks;
}

- (NSMutableArray <RicTask *>*)processingTasks{
    
    if(_processingTasks == nil){
        _processingTasks = [NSMutableArray new];
    }
    return _processingTasks;
}

- (NSMutableArray <RicTask *>*)tasksHasNoDependcy{
    
    if(_tasksHasNoDependcy == nil){
        _tasksHasNoDependcy = [NSMutableArray new];
    }
    return _tasksHasNoDependcy;
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
    if(task){
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
            if(self.uploadTaskCompeleted){
                self.hasStart = NO;
                self.compeletedCount = 0;
                [self.processTasks removeAllObjects];
                if(self.compeletedAction != NULL){
                    self.compeletedAction();
                }
            }else{
                self.compeletedCount ++;
                if(self.progressHandle != NULL){
                    self.progressHandle(self.compeletedCount,self.processTasks.count);
                }
            }
        }
   }
}

@end



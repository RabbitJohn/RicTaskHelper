//
//  UploadTaskHelper.h
//  creditor
//
//  Created by john on 2017/2/23.
//  Copyright © 2017年 john. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RicTask.h"

@interface RicTaskHelper : NSObject

/**
  tasks for uploading|上传任务
 */
@property (nonatomic, strong, readonly) NSArray <RicTask *>*tasks;

/**
 maximum upload count concurrently|最大同时上的传数量
 */
@property (nonatomic, assign) NSUInteger maxConcurrencyProcessCount;

/**
 添加任务

 @param task 任务
 */
- (void)addTask:(RicTask *)task;

/**
 添加一组任务

 @param tasks <#tasks description#>
 */
- (void)addTasks:(NSArray <RicTask *>*)tasks;

/**
 开始上传

 @param UIPerformanceWhenTasksHasStarted 开始处理时的UI loading 效果
 @param progressHandle 上传进度回掉
 @param compeletedAction 完成上传回掉
 */
- (void)startTasks:(void(^)(void))UIPerformanceWhenTasksHasStarted progressHandle:(void(^)(NSInteger compeletedCount,NSInteger totalCount))progressHandle compeleteAction:(void(^)(void))compeletedAction;

/**
 继续上传任务|尚未完成

 @param task <#task description#>
 */
- (void)resumeTask:(RicTask *)task;

/**
 停止未开始的任务

 @param taskId <#taskId description#>
 */
- (void)pauseTask:(NSString *)taskId;

/**
 停止所有未开始的任务
 */
- (void)pauseAll;

@end

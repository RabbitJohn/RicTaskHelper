//
//  RicTask.h
//  Pods
//
//  Created by john on 2017/3/8.
//
//

#import <Foundation/Foundation.h>

/**
 执行任务的基类，自定义任务时
 */
@interface RicTask : NSOperation

typedef void(^CompeletedNotice)(void);

/**
 task id of a task operation if you don't set it ,it will be generated automatically.
 */
@property (nonatomic, copy) NSString *taskId;

/**
 the task that depend on this one|如果更改了这个属性名，需要同步到RicTaskHelper startTask:progressHandle：compeleteAction方法中的setvalueForkey
 */
@property (nonatomic, weak, readonly) RicTask *nextTask;
// managed by developer.
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) void(^progressHandle)(CGFloat progress);
/**
 custom an infomation for the task
 */
@property (nonatomic, strong) NSDictionary *customInfomation;

@property (nonatomic, copy) void(^taskHasBeginRun)(RicTask *task);
@property (nonatomic, copy) void(^taskHasFinished)(RicTask *task);

/**
 operation of dataInfo | subclass should rewrite this property or method
 */
@property (nonatomic, copy, readonly) void(^dataProcessAction)(RicTask *task,CompeletedNotice noticeBlock);


- (void)updateNextTask:(RicTask *)nextTask;

@end

//
//  RicDownloadTask.m
//  Pods
//
//  Created by john on 2017/3/8.
//
//

#import "RicDownloadTask.h"

@implementation RicDownloadTask

- (void(^)(RicTask *task,CompeletedNotice noticeBlock))dataProcessAction{
    return self.downloadAction;
}
- (void)setDataProcessAction:(void (^)(RicTask *, CompeletedNotice))dataProcessAction{
#ifdef DEBUG
    NSAssert(NO, @"use uploadAction instead");
#endif
}
@end

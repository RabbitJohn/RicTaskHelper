//
//  UploadTask.m
//  creditor
//
//  Created by john on 2017/2/23.
//  Copyright © 2017年 john. All rights reserved.
//

#import "RicUploadTask.h"

@interface RicUploadTask ()


@end

@implementation RicUploadTask

- (instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}

- (void(^)(RicTask *task,CompeletedNotice notice))dataProcessAction{
    return self.uploadAction;
}
- (void)setDataProcessAction:(void (^)(RicTask *, CompeletedNotice))dataProcessAction{
#ifdef DEBUG
    NSAssert(NO, @"use uploadAction instead");
#endif
}
@end

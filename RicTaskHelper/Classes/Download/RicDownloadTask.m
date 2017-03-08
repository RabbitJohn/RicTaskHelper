//
//  RicDownloadTask.m
//  Pods
//
//  Created by john on 2017/3/8.
//
//

#import "RicDownloadTask.h"

@implementation RicDownloadTask

- (void(^)(id downloadInfo,CompeletedNotice notice))dataProcessAction{
    return self.downloadAction;
}

@end

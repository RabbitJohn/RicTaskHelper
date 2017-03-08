//
//  RicDownloadTask.h
//  Pods
//
//  Created by john on 2017/3/8.
//
//

#import "RicTask.h"

@interface RicDownloadTask : RicTask

@property (nonatomic, copy) void(^downloadAction)(id downloadInfo,CompeletedNotice noticeBlock);


@end

//
//  UploadTask.h
//  creditor
//
//  Created by john on 2017/2/23.
//  Copyright © 2017年 john. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RicTask.h"

@interface RicUploadTask : RicTask

/**
 data for uploading handle|获取数据操作
 */
@property (nonatomic, copy) id (^fetchDataAction)(void);
/**
 operation of uploading|上传操作
 */
@property (nonatomic, copy) void(^uploadAction)(id uploadInfo,CompeletedNotice noticeBlock);

@end

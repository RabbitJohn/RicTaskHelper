//
//  RicViewController.m
//  RicTaskHelper
//
//  Created by zLihuan on 03/08/2017.
//  Copyright (c) 2017 zLihuan. All rights reserved.
//

#import "RicViewController.h"
#import <RicTaskHelper/RicTaskHelper-umbrella.h>
@interface RicViewController ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) RicTask *downloadTask;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation RicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Download
    RicDownloadTask *downloadTask = [[RicDownloadTask alloc] init];
    NSDictionary *taskInfo = @{@"downloadUrl":@"http://a4.att.hudong.com/38/47/19300001391844134804474917734_950.png"};
    downloadTask.customInfomation = taskInfo;
    downloadTask.progressHandle = ^(CGFloat progress){
        NSLog(@"progress :%f",progress);
    };
    downloadTask.downloadAction = ^(RicTask* task,CompeletedNotice notice){
        NSLog(@"doloading begin");
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
        
        NSURL *url = [NSURL URLWithString: task.customInfomation[@"downloadUrl"]];
        NSURLSessionDownloadTask *dataTask = [defaultSession downloadTaskWithURL: url];
        
        [dataTask resume];
    };
    
    RicTaskHelper *helper = [[RicTaskHelper alloc] init];
    [helper addTask:downloadTask];
    
    self.downloadTask = downloadTask;
    
    [helper startTasks:^{
        
    } progressHandle:^(NSInteger compeletedCount, NSInteger totalCount) {
        NSLog(@"%ld/%ld",compeletedCount,totalCount);
        
    } compeleteAction:^{
        NSLog(@"compeleted");
    }];
    
  
    RicUploadTask *uploadTask = [[RicUploadTask alloc] init];
    uploadTask.fetchDataAction = ^id{
        return @"here return a upload resource or a infomation of uploading.";
    };
    uploadTask.uploadAction = ^(id uploadInfomation,CompeletedNotice noticeBlock){
        
        /// do you uploading operation here.
        ///...
        ///...
        // anyway when you have uploaded the data please invoke the noticeBlock
        // if you has an async uploading operation you should copy the noticeBlock and invoked it in the completed handle in you async result catching block. like: noticeBlock();
    };
    
    RicTaskHelper *uploadHelper = [[RicTaskHelper alloc] init];
    [uploadHelper addTask:uploadTask];
    [uploadHelper startTasks:^{
        // performing UI loading
    } progressHandle:^(NSInteger compeletedCount, NSInteger totalCount) {
        
    } compeleteAction:^{
        
    }];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    self.downloadTask.progress = 1;
    
    
    
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if(_data == NULL){
        _data = [NSMutableData data];
    }
    
    self.downloadTask.progress=totalBytesWritten/(totalBytesExpectedToWrite*1.0);
    
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

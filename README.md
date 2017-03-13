# RicTaskHelper

[![CI Status](http://img.shields.io/travis/zLihuan/RicTaskHelper.svg?style=flat)](https://travis-ci.org/zLihuan/RicTaskHelper)
[![Version](https://img.shields.io/cocoapods/v/RicTaskHelper.svg?style=flat)](http://cocoapods.org/pods/RicTaskHelper)
[![License](https://img.shields.io/cocoapods/l/RicTaskHelper.svg?style=flat)](http://cocoapods.org/pods/RicTaskHelper)
[![Platform](https://img.shields.io/cocoapods/p/RicTaskHelper.svg?style=flat)](http://cocoapods.org/pods/RicTaskHelper)

## Usage
### for downloaing

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

[helper startTasks:^{

} progressHandle:^(NSInteger compeletedCount, NSInteger totalCount) {
NSLog(@"%ld/%ld",compeletedCount,totalCount);

} compeleteAction:^{
NSLog(@"compeleted");
}];

### for uploading 
// prepare for the resouce or resouce information for uploading.
RicUploadTask *uploadTask = [[RicUploadTask alloc] init];

uploadTask.customInfomation = @{@"uploadData":@"some data here"};

uploadTask.uploadAction = ^(RicTask task,CompeletedNotice noticeBlock){
// get data from task.customInfomation

/// do you uploading operation here.

// when completed

   noticeBlock();
    
};

RicTaskHelper *uploadHelper = [[RicTaskHelper alloc] init];

[uploadHelper addTask:uploadTask];

[uploadHelper startTasks:^{

// performing UI loading

} progressHandle:^(NSInteger compeletedCount, NSInteger totalCount) {

} compeleteAction:^{

}];

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RicTaskHelper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RicTaskHelper"
```

## Author

zLihuan, 625482408@qq.com

## License

RicTaskHelper is available under the MIT license. See the LICENSE file for more info.

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RicDownloadTask.h"
#import "RicTask.h"
#import "RicTaskHelper.h"
#import "RicUploadTask.h"

FOUNDATION_EXPORT double RicTaskHelperVersionNumber;
FOUNDATION_EXPORT const unsigned char RicTaskHelperVersionString[];


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class LCDownloaderItem;

@protocol LCHTTPDownloaderDelegate <NSObject>

@optional
- (void)lcHTTPDownloaderDownloading:(LCDownloaderItem *)arg1 downloadPercentage:(float)arg2 velocity:(long long)arg3;
- (void)lcHTTPDownloaderFinishDownload:(LCDownloaderItem *)arg1;
- (void)lcHTTPDownloaderStartDownloading:(LCDownloaderItem *)arg1;
@end

//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSObject<OS_dispatch_queue>, NSURL;

@protocol ASImageCacheProtocol <NSObject>

@optional
- (void)clearFetchedImageFromCacheWithURL:(NSURL *)arg1;
- (void)cachedImageWithURL:(NSURL *)arg1 callbackQueue:(NSObject<OS_dispatch_queue> *)arg2 completion:(void (^)(id <ASImageContainerProtocol>))arg3;
- (id <ASImageContainerProtocol>)synchronouslyFetchedCachedImageWithURL:(NSURL *)arg1;
@end

//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "NSObject-Protocol.h"

@class NSString;

@protocol ALIJTipsProtocol <NSObject>
- (void)hideTips;
- (void)showMsg:(NSString *)arg1 overTime:(double)arg2;
- (void)showMsg:(NSString *)arg1;
- (void)showErrorMsg:(NSString *)arg1;
- (void)showSuccessMsg:(NSString *)arg1;
- (void)endLoading;
- (void)startLoading;
@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@interface JIMIMOpenAppManager : NSObject
{
}

+ (id)sharedManager;
- (void)canOpenJDMainIMWithParam:(id)arg1 parentVC:(id)arg2;
- (void)canOpenJDMainOrderDetailWithParam:(id)arg1;
- (void)canOpenJDMainOrderListWithParam:(id)arg1 parentVC:(id)arg2;
- (void)canOpenJDMainProductDetailWithParam:(id)arg1;
- (_Bool)isOpenAppJDMoblieProtocolWithURL:(id)arg1;
- (_Bool)handleOpenAppJDMoblieURL:(id)arg1 parentVC:(id)arg2;
- (id)paramDicWithOpenAppURL:(id)arg1;
- (_Bool)handleOpenAppURL:(id)arg1 parentVC:(id)arg2;

@end


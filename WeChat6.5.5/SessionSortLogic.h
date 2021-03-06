//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class SessionSortCache;

__attribute__((visibility("hidden")))
@interface SessionSortLogic : NSObject
{
    SessionSortCache *_oSessionSortCache;
}

- (void).cxx_destruct;
- (void)setMergeFlag;
- (_Bool)hasMergeFlag;
- (_Bool)isTopSessionCountExceed;
- (id)getUntopTime:(id)arg1;
- (id)getTopTime:(id)arg1;
- (void)RemoveUntopSession;
- (void)UntopSession:(id)arg1;
- (void)TopSession:(id)arg1;
- (id)getCurrentDate;
- (void)ReloadCache;
- (void)SaveCache;
- (void)LoadCache;
- (void)LoadSortDataInternal;
- (void)saveSortDataInternal;
- (id)getSortCacheDataFilePath;
- (id)getOldSortCacheDataFilePath;
- (id)init;

@end


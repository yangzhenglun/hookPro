//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBSNSBasicService.h"

@interface TBSNSFeedService : TBSNSBasicService
{
    int _feedServiceType;	// 8 = 0x8
}

@property(nonatomic) int feedServiceType; // @synthesize feedServiceType=_feedServiceType;
- (void)useDefaultItemClass;
- (void)loadFeedDetailWithFeedId:(unsigned long long)arg1 params:(id)arg2;
- (void)loadFeedDetailWithFeedId:(unsigned long long)arg1;
- (void)nextPage;
- (void)refreshPagedList;
- (id)init;

@end


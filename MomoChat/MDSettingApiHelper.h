//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class MDAPICached;

@interface MDSettingApiHelper : NSObject
{
    MDAPICached *_apiCached;
}

@property(retain, nonatomic) MDAPICached *apiCached; // @synthesize apiCached=_apiCached;
- (void).cxx_destruct;
- (void)commitMomentRecommendPushEnable:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitMomentCommentedPushEnable:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitMomentLikePushEnable:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitMomentGiftEnable:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitUserLiveSettingFinish:(CDUnknownBlockType)arg1;
- (void)commitMuteTimeFrom:(long long)arg1 to:(long long)arg2 status:(_Bool)arg3 finish:(CDUnknownBlockType)arg4;
- (void)commitCircleCommentPushSate:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitPushGroupDisableState:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitHelloPushDisableState:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitFriendFeedPushDisableState:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitCommentPushDisableState:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitLikePushDisableState:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitChangePushControl:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitChangePushDetail:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;
- (void)commitChangePushSound:(_Bool)arg1 finish:(CDUnknownBlockType)arg2;

@end

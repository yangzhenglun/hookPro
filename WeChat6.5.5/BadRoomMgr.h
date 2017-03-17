//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "MMService.h"

#import "IMMNewSessionMgrExt-Protocol.h"
#import "MMService-Protocol.h"
#import "MessageDBExt-Protocol.h"
#import "MessageObserverDelegate-Protocol.h"

@class NSRecursiveLock, NSString;

__attribute__((visibility("hidden")))
@interface BadRoomMgr : MMService <MessageObserverDelegate, MessageDBExt, IMMNewSessionMgrExt, MMService>
{
    NSRecursiveLock *_m_oLock;
}

@property(retain, nonatomic) NSRecursiveLock *m_oLock; // @synthesize m_oLock=_m_oLock;
- (void).cxx_destruct;
- (id)HandleSysMsg:(id)arg1 revokeMsgId:(long long *)arg2;
- (void)syncWithData:(id)arg1;
- (void)notifyWithData:(id)arg1;
- (void)onWillDeleteSession:(id)arg1;
- (void)onDeleteBadRoomMsg:(long long)arg1 createTime:(unsigned int)arg2 chatName:(id)arg3;
- (void)onDeleteAllMsgs:(id)arg1;
- (void)onDeleteBrokenMsg:(unsigned int)arg1 chatName:(id)arg2;
- (void)updateSessionByDigest:(id)arg1 isSync:(_Bool)arg2;
- (void)parseData:(id)arg1 isSync:(_Bool)arg2;
- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3;
- (void)dealloc;
- (void)onServiceInit;
- (void)saveDeleteMsg:(id)arg1;
- (id)loadDeleteMsg;
- (id)getPBPath;
- (void)AddDeletedMsg:(long long)arg1 createTime:(unsigned int)arg2;
- (_Bool)existsInDeletedMsg:(long long)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

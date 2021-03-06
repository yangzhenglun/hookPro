//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class MDApiResponse, NSArray, NSString;

@protocol MDGroupProfileHelperDelegate <NSObject>

@optional
- (void)groupHelper:(NSString *)arg1 requestStatus:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 setGroupMemberClearMode:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 fetchSimilarGroup:(int)arg2 errorCode:(unsigned long long)arg3 errorMsg:(NSString *)arg4 classify:(NSString *)arg5 list:(NSArray *)arg6 isShortList:(_Bool)arg7;
- (void)groupHelper:(NSString *)arg1 fetchGroupOwner:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 fetchGroupProfile:(int)arg2 errorCode:(unsigned long long)arg3 errorMsg:(NSString *)arg4;
- (void)groupHelper:(NSString *)arg1 upgradeGroup:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 cancelCreateGroup:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 giveGroup:(int)arg2 errorCode:(unsigned long long)arg3 errorMsg:(NSString *)arg4;
- (void)groupHelper:(NSString *)arg1 cancelGroupAdmin:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 addGroupAdmin:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 removeGroupMember:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 fetchGroupMembers:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 setGroupPushDisable:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 setGroupHidden:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 quitGroup:(int)arg2 errorMsg:(NSString *)arg3;
- (void)groupHelper:(NSString *)arg1 reportGroup:(int)arg2 errorMsg:(NSString *)arg3;
- (void)cancelAssociatedGroupGameStatus:(int)arg1 message:(NSString *)arg2;
- (void)groupHelper:(NSString *)arg1 dismissGroup:(int)arg2 errorMsg:(NSString *)arg3 response:(MDApiResponse *)arg4;
@end


//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "NSObject-Protocol.h"

@class CContact, NSArray, NSDictionary;

@protocol ContactsDataLogicDelegate <NSObject>
- (_Bool)onFilterContactCandidate:(CContact *)arg1;
- (void)onContactsDataChange;

@optional
- (void)onContactAsynSearchSectionResultChanged:(NSArray *)arg1 sectionTitles:(NSDictionary *)arg2 sectionResults:(NSDictionary *)arg3;
@end

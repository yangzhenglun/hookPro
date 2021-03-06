//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "GDMMtopRequest.h"

@class NSString;

@interface GDMDarenFeedDetailRequest : GDMMtopRequest
{
    _Bool _isFeedDeleted;	// 8 = 0x8
    _Bool _isFeedFavoured;	// 9 = 0x9
    long long _commentCount;	// 16 = 0x10
    long long _favourCount;	// 24 = 0x18
    NSString *_coverTilePath;	// 32 = 0x20
    unsigned long long _accoundType;	// 40 = 0x28
    unsigned long long _feedType;	// 48 = 0x30
    unsigned long long _shopId;	// 56 = 0x38
    NSString *_accountNick;	// 64 = 0x40
    NSString *_accountId;	// 72 = 0x48
    NSString *_title;	// 80 = 0x50
}

@property(retain) NSString *title; // @synthesize title=_title;
@property(retain) NSString *accountId; // @synthesize accountId=_accountId;
@property(retain) NSString *accountNick; // @synthesize accountNick=_accountNick;
@property unsigned long long shopId; // @synthesize shopId=_shopId;
@property unsigned long long feedType; // @synthesize feedType=_feedType;
@property unsigned long long accoundType; // @synthesize accoundType=_accoundType;
@property _Bool isFeedFavoured; // @synthesize isFeedFavoured=_isFeedFavoured;
@property _Bool isFeedDeleted; // @synthesize isFeedDeleted=_isFeedDeleted;
@property(retain) NSString *coverTilePath; // @synthesize coverTilePath=_coverTilePath;
@property long long favourCount; // @synthesize favourCount=_favourCount;
@property long long commentCount; // @synthesize commentCount=_commentCount;
- (void).cxx_destruct;
- (void)startLoadDetailById:(id)arg1 finishBlock:(CDUnknownBlockType)arg2;
- (_Bool)procResultDataFromJson:(id)arg1;
- (id)methodName;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSArray, NSString;

@interface MTOPGetItemRateResult : NSObject
{
    NSString *_total;	// 8 = 0x8
    NSString *_totalPage;	// 16 = 0x10
    NSString *_feedAllCount;	// 24 = 0x18
    NSString *_feedGoodCount;	// 32 = 0x20
    NSString *_feedNormalCount;	// 40 = 0x28
    NSString *_feedBadCount;	// 48 = 0x30
    NSString *_feedAppendCount;	// 56 = 0x38
    NSString *_feedPicCount;	// 64 = 0x40
    NSArray *_rateList;	// 72 = 0x48
}

@property(retain, nonatomic) NSArray *rateList; // @synthesize rateList=_rateList;
@property(retain, nonatomic) NSString *feedPicCount; // @synthesize feedPicCount=_feedPicCount;
@property(retain, nonatomic) NSString *feedAppendCount; // @synthesize feedAppendCount=_feedAppendCount;
@property(retain, nonatomic) NSString *feedBadCount; // @synthesize feedBadCount=_feedBadCount;
@property(retain, nonatomic) NSString *feedNormalCount; // @synthesize feedNormalCount=_feedNormalCount;
@property(retain, nonatomic) NSString *feedGoodCount; // @synthesize feedGoodCount=_feedGoodCount;
@property(retain, nonatomic) NSString *feedAllCount; // @synthesize feedAllCount=_feedAllCount;
@property(retain, nonatomic) NSString *totalPage; // @synthesize totalPage=_totalPage;
@property(retain, nonatomic) NSString *total; // @synthesize total=_total;
- (void).cxx_destruct;

@end


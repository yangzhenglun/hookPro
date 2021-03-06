//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBJSONModel.h"

#import "SearchMtopResponseProtocal-Protocol.h"

@class NSString;

@interface TMSearchOptimalRangePrice : TBJSONModel <SearchMtopResponseProtocal>
{
    _Bool _hasOptimalPrice;	// 8 = 0x8
    long long _max_price;	// 16 = 0x10
    long long _optimal_end_price;	// 24 = 0x18
    long long _optimal_start_price;	// 32 = 0x20
}

@property(nonatomic) _Bool hasOptimalPrice; // @synthesize hasOptimalPrice=_hasOptimalPrice;
@property(nonatomic) long long optimal_start_price; // @synthesize optimal_start_price=_optimal_start_price;
@property(nonatomic) long long optimal_end_price; // @synthesize optimal_end_price=_optimal_end_price;
@property(nonatomic) long long max_price; // @synthesize max_price=_max_price;
- (id)initWithJsonDictionary:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


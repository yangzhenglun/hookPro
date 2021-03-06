//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBJSONModel.h"

@class NSString, TBTakeoutItemModel, TBTakeoutStoreDetailModel;

@interface TBTakeoutItemDetailPageModel : TBJSONModel
{
    TBTakeoutItemModel *_itemDetail;	// 8 = 0x8
    TBTakeoutStoreDetailModel *_storeDetail;	// 16 = 0x10
    NSString *_agentFee;	// 24 = 0x18
    NSString *_deliverAmount;	// 32 = 0x20
    NSString *_deliverTime;	// 40 = 0x28
}

@property(copy, nonatomic) NSString *deliverTime; // @synthesize deliverTime=_deliverTime;
@property(copy, nonatomic) NSString *deliverAmount; // @synthesize deliverAmount=_deliverAmount;
@property(copy, nonatomic) NSString *agentFee; // @synthesize agentFee=_agentFee;
@property(retain, nonatomic) TBTakeoutStoreDetailModel *storeDetail; // @synthesize storeDetail=_storeDetail;
@property(retain, nonatomic) TBTakeoutItemModel *itemDetail; // @synthesize itemDetail=_itemDetail;
- (void).cxx_destruct;

@end


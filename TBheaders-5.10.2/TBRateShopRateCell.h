//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBRateBaseCell.h"

@class TBRateShopRateComponent;

@interface TBRateShopRateCell : TBRateBaseCell
{
    TBRateShopRateComponent *_shopRateComponent;	// 8 = 0x8
}

+ (double)viewHeight:(id)arg1;
@property(retain, nonatomic) TBRateShopRateComponent *shopRateComponent; // @synthesize shopRateComponent=_shopRateComponent;
- (void).cxx_destruct;
- (void)removeAllSubviews;
- (void)setComponent:(id)arg1;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end


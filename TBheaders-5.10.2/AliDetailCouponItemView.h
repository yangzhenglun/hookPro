//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

@class AliDetailCouponModel, DetailBlockButton, NSString, TBSDKMTOPServer, UILabel;

@interface AliDetailCouponItemView : UIView
{
    TBSDKMTOPServer *_mtopServer;	// 8 = 0x8
    AliDetailCouponModel *_data;	// 16 = 0x10
    DetailBlockButton *_selectedCouponButton;	// 24 = 0x18
    UILabel *_couponDescLabel;	// 32 = 0x20
    UILabel *_couponvalidTimeLabel;	// 40 = 0x28
    UILabel *_couponDiscountFeeLabel;	// 48 = 0x30
    UIView *_bottomSplitLine;	// 56 = 0x38
    NSString *_sellerId;	// 64 = 0x40
    NSString *_eventToken;	// 72 = 0x48
}

@property(retain, nonatomic) NSString *eventToken; // @synthesize eventToken=_eventToken;
@property(retain, nonatomic) NSString *sellerId; // @synthesize sellerId=_sellerId;
@property(retain, nonatomic) UIView *bottomSplitLine; // @synthesize bottomSplitLine=_bottomSplitLine;
@property(retain, nonatomic) UILabel *couponDiscountFeeLabel; // @synthesize couponDiscountFeeLabel=_couponDiscountFeeLabel;
@property(retain, nonatomic) UILabel *couponvalidTimeLabel; // @synthesize couponvalidTimeLabel=_couponvalidTimeLabel;
@property(retain, nonatomic) UILabel *couponDescLabel; // @synthesize couponDescLabel=_couponDescLabel;
@property(retain, nonatomic) DetailBlockButton *selectedCouponButton; // @synthesize selectedCouponButton=_selectedCouponButton;
@property(retain, nonatomic) AliDetailCouponModel *data; // @synthesize data=_data;
@property(retain, nonatomic) TBSDKMTOPServer *mtopServer; // @synthesize mtopServer=_mtopServer;
- (void).cxx_destruct;
- (void)getShopPromotion:(id)arg1 sellerId:(id)arg2;
- (void)layoutSubviews;
- (void)bindCellData:(id)arg1;
- (void)createViews;
- (id)initWithFrame:(struct CGRect)arg1 setData:(id)arg2;

@end

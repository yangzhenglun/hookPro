//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

#import "TXTBGridMenuViewDelegate-Protocol.h"

@class NSArray, NSString, TXTBGridMenuView, UILabel;

@interface TXTelFeeView : UIView <TXTBGridMenuViewDelegate>
{
    TXTBGridMenuView *_telFeeGridView;	// 8 = 0x8
    UILabel *_descLabel;	// 16 = 0x10
    long long _currentIndex;	// 24 = 0x18
    NSString *_czActivityDesc;	// 32 = 0x20
    NSArray *_defaultTelFeePackageList;	// 40 = 0x28
    NSArray *_telFeePackageList;	// 48 = 0x30
    long long _status;	// 56 = 0x38
}

+ (id)GridItemClicked;
@property(nonatomic) long long status; // @synthesize status=_status;
@property(retain, nonatomic) NSArray *telFeePackageList; // @synthesize telFeePackageList=_telFeePackageList;
@property(copy, nonatomic) NSArray *defaultTelFeePackageList; // @synthesize defaultTelFeePackageList=_defaultTelFeePackageList;
@property(retain, nonatomic) NSString *czActivityDesc; // @synthesize czActivityDesc=_czActivityDesc;
@property(nonatomic) long long currentIndex; // @synthesize currentIndex=_currentIndex;
@property(retain, nonatomic) UILabel *descLabel; // @synthesize descLabel=_descLabel;
@property(retain, nonatomic) TXTBGridMenuView *telFeeGridView; // @synthesize telFeeGridView=_telFeeGridView;
- (void).cxx_destruct;
- (void)configTelFeeItemView:(id)arg1 gridMenuView:(id)arg2 ItemViewForRowAtIndex:(long long)arg3;
- (id)gridMenuView:(id)arg1 ItemViewForRowAtIndex:(long long)arg2;
- (unsigned long long)gridMenuViewNumberOfItems:(id)arg1;
- (id)gridItemViewWithTag:(long long)arg1;
- (double)heightOfGridView:(id)arg1;
- (void)updateUI;
- (void)setupSubviews;
- (id)getItemModelForPrice:(id)arg1;
- (long long)indexOfPrice:(id)arg1;
- (id)init;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)setTelFeePackageList:(id)arg1 selectedPrice:(id)arg2 activityDesc:(id)arg3;
- (void)setTelFeePackageList:(id)arg1 selectedPrice:(id)arg2;

// Remaining properties
@property(readonly, nonatomic) NSString *GridItemClicked; // @dynamic GridItemClicked;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


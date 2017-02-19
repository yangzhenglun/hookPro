//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UITableViewCell.h>

@class TBTakeoutCustomLabel, TBTakeoutOrderDetailContactViewModel, UIButton, UIView;

@interface TBTakeoutOrderDetailContactCell : UITableViewCell
{
    TBTakeoutOrderDetailContactViewModel *_viewModel;	// 8 = 0x8
    UIButton *_storeContactButton;	// 16 = 0x10
    UIButton *_serviceContactButton;	// 24 = 0x18
    UIView *_seperatorLine;	// 32 = 0x20
    UIView *_topLine;	// 40 = 0x28
    TBTakeoutCustomLabel *_providerLabel;	// 48 = 0x30
    UIView *_bottomLine;	// 56 = 0x38
}

@property(retain, nonatomic) UIView *bottomLine; // @synthesize bottomLine=_bottomLine;
@property(retain, nonatomic) TBTakeoutCustomLabel *providerLabel; // @synthesize providerLabel=_providerLabel;
@property(retain, nonatomic) UIView *topLine; // @synthesize topLine=_topLine;
@property(retain, nonatomic) UIView *seperatorLine; // @synthesize seperatorLine=_seperatorLine;
@property(retain, nonatomic) UIButton *serviceContactButton; // @synthesize serviceContactButton=_serviceContactButton;
@property(retain, nonatomic) UIButton *storeContactButton; // @synthesize storeContactButton=_storeContactButton;
@property(nonatomic) __weak TBTakeoutOrderDetailContactViewModel *viewModel; // @synthesize viewModel=_viewModel;
- (void).cxx_destruct;
- (void)toast:(id)arg1;
- (void)contactService;
- (void)contactStore;
- (void)layoutSubviews;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end

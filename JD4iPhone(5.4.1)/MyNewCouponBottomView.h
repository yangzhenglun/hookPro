//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "JDView.h"

@class JDButton;

@interface MyNewCouponBottomView : JDView
{
    JDButton *couponCenterBtn;
    JDButton *couponMarketBtn;
    CDUnknownBlockType couponBottomActionBlock;
}

@property(copy, nonatomic) CDUnknownBlockType couponBottomActionBlock; // @synthesize couponBottomActionBlock;
- (void).cxx_destruct;
- (void)couponMarketBtnClicked:(id)arg1;
- (void)couponCenterBtnClicked:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1 actionBlock:(CDUnknownBlockType)arg2;
- (void)dealloc;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

@class NSArray, UIButton, UIScrollView;

@interface AliDetailProductParmsModalView : UIView
{
    UIScrollView *_myscrollView;	// 8 = 0x8
    CDUnknownBlockType _quitBlock;	// 16 = 0x10
    NSArray *_dataArray;	// 24 = 0x18
    UIButton *_closeButton;	// 32 = 0x20
}

@property(retain, nonatomic) UIButton *closeButton; // @synthesize closeButton=_closeButton;
@property(retain, nonatomic) NSArray *dataArray; // @synthesize dataArray=_dataArray;
@property(copy, nonatomic) CDUnknownBlockType quitBlock; // @synthesize quitBlock=_quitBlock;
- (void).cxx_destruct;
- (void)closeCouponView;
- (void)_initSubViews;
- (id)formatedArrayFromProductProperties:(id)arg1;
- (id)initWithProductProperties:(id)arg1;

@end


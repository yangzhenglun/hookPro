//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBXSearchComboViewComponentBase.h"

#import "TBXSearchComboViewComponentBase-Protocol.h"

@class NSString, TBSearchWebViewManager, TBXSearchComboOnesearchViewModel;

@interface TBXSearchComboOnesearchViewComponent : TBXSearchComboViewComponentBase <TBXSearchComboViewComponentBase>
{
    TBSearchWebViewManager *_webViewManager;	// 8 = 0x8
    TBXSearchComboOnesearchViewModel *_viewModel;	// 16 = 0x10
}

@property(retain, nonatomic) TBXSearchComboOnesearchViewModel *viewModel; // @synthesize viewModel=_viewModel;
@property(retain, nonatomic) TBSearchWebViewManager *webViewManager; // @synthesize webViewManager=_webViewManager;
- (void).cxx_destruct;
- (void)releaseSomething;
- (double)getContainerHeight;
- (void)dataLoaded;
- (void)setTheViewModel:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


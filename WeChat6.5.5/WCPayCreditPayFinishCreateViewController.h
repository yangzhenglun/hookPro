//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "WCPayBaseViewController.h"

@protocol WCPayCreditPayFinishCreateViewControllerDelegate;

__attribute__((visibility("hidden")))
@interface WCPayCreditPayFinishCreateViewController : WCPayBaseViewController
{
    id <WCPayCreditPayFinishCreateViewControllerDelegate> m_delegate;
}

- (void).cxx_destruct;
- (void)onIncreaseLimit;
- (void)onBack;
- (void)setDelegate:(id)arg1;
- (void)viewDidLoad;
- (void)initFooterView;
- (void)initHeaderView;
- (void)viewWillLayoutSubviews;
- (void)initNavigationBar;
- (id)init;

@end


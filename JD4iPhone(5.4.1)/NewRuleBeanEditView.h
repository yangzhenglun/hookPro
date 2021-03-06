//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "OrderVirtualBaseView.h"

#import "JDBaseToastTextListViewDataSource.h"
#import "JDBaseToastViewDelegate.h"

@class JDBeanModel, JDBeanUseRuleModel, NSNumber, NSString, UIButton, UILabel, UIView;

@interface NewRuleBeanEditView : OrderVirtualBaseView <JDBaseToastTextListViewDataSource, JDBaseToastViewDelegate>
{
    UIButton *_arrowBtn;
    UIButton *_rulesBtn;
    UIView *_bottomLine;
    _Bool _isCancelEdit;
    _Bool _beginEditing;
    _Bool _keyboardDidShow;
    UIButton *_ruleUseBtn;
    UILabel *_canUseJDBeansLabel;
    UIButton *_canUseBeanBackBtn;
    id <JDBeanNewRuleEditViewDelegate> _ruleEditViewDelegate;
    UILabel *_textFieldLeftLabel;
    UILabel *_textFieldRightLabel;
    UILabel *_moneyLabel;
    NSNumber *_lastUseBeanCount;
    JDBeanModel *_beanModel;
    JDBeanUseRuleModel *_beanUseRuleModel;
}

@property(retain, nonatomic) JDBeanUseRuleModel *beanUseRuleModel; // @synthesize beanUseRuleModel=_beanUseRuleModel;
@property(retain, nonatomic) JDBeanModel *beanModel; // @synthesize beanModel=_beanModel;
@property(retain, nonatomic) NSNumber *lastUseBeanCount; // @synthesize lastUseBeanCount=_lastUseBeanCount;
@property(retain, nonatomic) UILabel *moneyLabel; // @synthesize moneyLabel=_moneyLabel;
@property(retain, nonatomic) UILabel *textFieldRightLabel; // @synthesize textFieldRightLabel=_textFieldRightLabel;
@property(retain, nonatomic) UILabel *textFieldLeftLabel; // @synthesize textFieldLeftLabel=_textFieldLeftLabel;
@property(nonatomic) __weak id <JDBeanNewRuleEditViewDelegate> ruleEditViewDelegate; // @synthesize ruleEditViewDelegate=_ruleEditViewDelegate;
@property(retain, nonatomic) UIButton *canUseBeanBackBtn; // @synthesize canUseBeanBackBtn=_canUseBeanBackBtn;
@property(retain, nonatomic) UILabel *canUseJDBeansLabel; // @synthesize canUseJDBeansLabel=_canUseJDBeansLabel;
- (void).cxx_destruct;
- (id)accessibilityLabel;
- (_Bool)isAccessibilityElement;
- (void)setBottomLineOriginX:(double)arg1;
- (void)show;
- (void)didClickBackgroundInToastView:(id)arg1;
- (void)didFinishInToastView:(id)arg1;
- (id)toastView:(id)arg1 DetailForSection:(long long)arg2;
- (id)toastView:(id)arg1 titleForSection:(long long)arg2;
- (long long)numberOfSectionsInToastView:(id)arg1;
- (void)freshView;
- (void)ruleUseBtnTap;
- (void)canUseBeanBackBtnTaped:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


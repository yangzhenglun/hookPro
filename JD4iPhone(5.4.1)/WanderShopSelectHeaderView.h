//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

@class JDSwitch, WanderShopTabView;

@interface WanderShopSelectHeaderView : UIView
{
    WanderShopTabView *createIcon;
    WanderShopTabView *prasiedIcon;
    JDSwitch *switchButton;
    int _selType;
    id <WanderShopSelectHeaderViewDelegate> _delegate;
}

@property(nonatomic) __weak id <WanderShopSelectHeaderViewDelegate> delegate; // @synthesize delegate=_delegate;
@property(nonatomic) int selType; // @synthesize selType=_selType;
- (void).cxx_destruct;
- (void)refreshUIOfOriginalNumForCircle;
- (void)refreshUIOfOriginalNum:(long long)arg1 likeNum:(long long)arg2;
- (void)selectPrasiedIcon;
- (void)selectCreateIcon;
- (void)switchUpdate:(id)arg1;
- (void)setupCircleUI;
- (void)setupMineUI;
- (id)initWithFrame:(struct CGRect)arg1 sctpye:(int)arg2;

@end


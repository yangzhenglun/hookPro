//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

@class UIView;
@protocol JHSBoxContainerView;

@protocol JHSBoxView
@property(nonatomic) struct UIEdgeInsets boxEdgeInset;
@property(nonatomic) struct CGRect boxFrame;
@property(readonly, nonatomic) UIView<JHSBoxContainerView> *superboxView;
- (void)setSuperboxView:(UIView<JHSBoxContainerView> *)arg1;
@end

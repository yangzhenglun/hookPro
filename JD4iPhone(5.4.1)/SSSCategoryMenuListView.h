//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

@class CustomActivityIndicatorView, NSArray, UICollectionView;

@interface SSSCategoryMenuListView : UIView
{
    _Bool _isAnimating;
    _Bool _isShowed;
    UIView *_backgroundView;
    UICollectionView *_cateCollectionView;
    NSArray *_itemsArray;
    CDUnknownBlockType _clickBlock;
    CustomActivityIndicatorView *_activityIndicatorView;
}

@property(retain, nonatomic) CustomActivityIndicatorView *activityIndicatorView; // @synthesize activityIndicatorView=_activityIndicatorView;
@property(copy, nonatomic) CDUnknownBlockType clickBlock; // @synthesize clickBlock=_clickBlock;
@property(retain, nonatomic) NSArray *itemsArray; // @synthesize itemsArray=_itemsArray;
@property(retain, nonatomic) UICollectionView *cateCollectionView; // @synthesize cateCollectionView=_cateCollectionView;
@property(retain, nonatomic) UIView *backgroundView; // @synthesize backgroundView=_backgroundView;
- (void).cxx_destruct;
- (void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (long long)collectionView:(id)arg1 numberOfItemsInSection:(long long)arg2;
- (struct CGRect)p_adjustFrame;
- (void)p_clickDissMissMenuView;
- (void)p_dismissMenuView;
- (void)reloadData;
- (void)reconnect;
- (void)p_showMenuView:(id)arg1 selectIndex:(unsigned long long)arg2;
- (void)showOrHiddenInView:(id)arg1 selectIndex:(unsigned long long)arg2;
- (void)showOrHiddenInView:(id)arg1;
- (id)initWithItems:(id)arg1 frame:(struct CGRect)arg2 clickBlock:(CDUnknownBlockType)arg3;
- (id)initWithFrame:(struct CGRect)arg1 clickBlock:(CDUnknownBlockType)arg2;

@end

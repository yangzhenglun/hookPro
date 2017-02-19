//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MLBaseViewController.h"

#import "UICollectionViewDataSource.h"
#import "UICollectionViewDelegate.h"

@class NSArray, NSString, UIButton, UICollectionView, UIView;

@interface MLPlaybackEndGuideViewController : MLBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource>
{
    _Bool _up;
    NSString *_roomId;
    NSArray *_recommendList;
    CDUnknownBlockType _dismissControllerHandler;
    CDUnknownBlockType _updateRecommendList;
    CDUnknownBlockType _transitionHandler;
    UICollectionView *_collectionView;
    UIView *_containerView;
    UIButton *_recommendButton;
}

+ (double)liveRecommendNormalHeight;
@property(nonatomic) _Bool up; // @synthesize up=_up;
@property(retain, nonatomic) UIButton *recommendButton; // @synthesize recommendButton=_recommendButton;
@property(retain, nonatomic) UIView *containerView; // @synthesize containerView=_containerView;
@property(retain, nonatomic) UICollectionView *collectionView; // @synthesize collectionView=_collectionView;
@property(copy, nonatomic) CDUnknownBlockType transitionHandler; // @synthesize transitionHandler=_transitionHandler;
@property(copy, nonatomic) CDUnknownBlockType updateRecommendList; // @synthesize updateRecommendList=_updateRecommendList;
@property(copy, nonatomic) CDUnknownBlockType dismissControllerHandler; // @synthesize dismissControllerHandler=_dismissControllerHandler;
@property(retain, nonatomic) NSArray *recommendList; // @synthesize recommendList=_recommendList;
@property(copy, nonatomic) NSString *roomId; // @synthesize roomId=_roomId;
- (void).cxx_destruct;
- (void)animationDidStop:(id)arg1 finished:(_Bool)arg2;
- (void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2;
- (long long)collectionView:(id)arg1 numberOfItemsInSection:(long long)arg2;
- (long long)numberOfSectionsInCollectionView:(id)arg1;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (void)didClickRecommendButton:(id)arg1;
- (void)queryVideoEndGuidesFail:(id)arg1;
- (void)queryVideoEndGuidesError:(id)arg1;
- (void)queryVideoEndGuidesSuccess:(id)arg1;
- (void)getModelData;
- (void)addLiveRecommendIndicatorView;
- (void)addCollectionView;
- (void)didReceiveMemoryWarning;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewDidLoad;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

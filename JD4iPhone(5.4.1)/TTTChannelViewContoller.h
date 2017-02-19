//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "TTTBaseViewController.h"

#import "NewRefreshTableHeaderViewDelegate.h"

@class CustomActivityIndicatorView, JDLastPageView, JDNetErrorView, JDNextPageLoadingView, JDNextPageReloadView, JDNoDataView, JDNotStartedActivityView, JDOveredActivityView, JDSearchBar, NSDictionary, NSMutableArray, NSMutableDictionary, NSString, NewRefreshTableHeaderView, TTTCategoryTwoListView, TTTDataProvider, TTTFloatView, UITableView;

@interface TTTChannelViewContoller : TTTBaseViewController <NewRefreshTableHeaderViewDelegate>
{
    struct CGRect _orginSeachBarHistoryFrame;
    double _floatViewWidth;
    _Bool _isTapScrolling;
    _Bool _isPullTabed;
    _Bool _isOnLastScreen;
    _Bool _notUpadateNavBar;
    TTTDataProvider *_dataProvider;
    NSMutableArray *_floatViewDatas;
    NSMutableArray *_floatViews;
    NewRefreshTableHeaderView *_refreshHeaderView;
    UITableView *_tableView;
    TTTFloatView *_floatIconView;
    NSMutableDictionary *_tableHeadCache;
    TTTCategoryTwoListView *_categoryView;
    JDSearchBar *_searchBar;
    NSDictionary *_searchParamDic;
    NSDictionary *_paraDict;
    CustomActivityIndicatorView *_activityIndicatorView;
    JDNetErrorView *_netErrorView;
    JDNoDataView *_noDataView;
    JDLastPageView *_lastPageView;
    JDNextPageLoadingView *_nextPageLoadingView;
    JDNextPageReloadView *_nextPageReloadView;
    JDNotStartedActivityView *_notStartedActivityView;
    JDOveredActivityView *_overedActivityView;
}

@property(retain, nonatomic) JDOveredActivityView *overedActivityView; // @synthesize overedActivityView=_overedActivityView;
@property(retain, nonatomic) JDNotStartedActivityView *notStartedActivityView; // @synthesize notStartedActivityView=_notStartedActivityView;
@property(retain, nonatomic) JDNextPageReloadView *nextPageReloadView; // @synthesize nextPageReloadView=_nextPageReloadView;
@property(retain, nonatomic) JDNextPageLoadingView *nextPageLoadingView; // @synthesize nextPageLoadingView=_nextPageLoadingView;
@property(retain, nonatomic) JDLastPageView *lastPageView; // @synthesize lastPageView=_lastPageView;
@property(retain, nonatomic) JDNoDataView *noDataView; // @synthesize noDataView=_noDataView;
@property(retain, nonatomic) JDNetErrorView *netErrorView; // @synthesize netErrorView=_netErrorView;
@property(retain, nonatomic) CustomActivityIndicatorView *activityIndicatorView; // @synthesize activityIndicatorView=_activityIndicatorView;
@property(retain, nonatomic) NSDictionary *paraDict; // @synthesize paraDict=_paraDict;
@property(retain, nonatomic) NSDictionary *searchParamDic; // @synthesize searchParamDic=_searchParamDic;
@property(nonatomic) __weak JDSearchBar *searchBar; // @synthesize searchBar=_searchBar;
@property(nonatomic) _Bool notUpadateNavBar; // @synthesize notUpadateNavBar=_notUpadateNavBar;
@property(nonatomic) _Bool isOnLastScreen; // @synthesize isOnLastScreen=_isOnLastScreen;
@property(nonatomic) _Bool isPullTabed; // @synthesize isPullTabed=_isPullTabed;
@property(nonatomic) _Bool isTapScrolling; // @synthesize isTapScrolling=_isTapScrolling;
@property(retain, nonatomic) TTTCategoryTwoListView *categoryView; // @synthesize categoryView=_categoryView;
@property(retain, nonatomic) NSMutableDictionary *tableHeadCache; // @synthesize tableHeadCache=_tableHeadCache;
@property(retain, nonatomic) TTTFloatView *floatIconView; // @synthesize floatIconView=_floatIconView;
@property(retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;
@property(retain, nonatomic) NewRefreshTableHeaderView *refreshHeaderView; // @synthesize refreshHeaderView=_refreshHeaderView;
@property(retain, nonatomic) NSMutableArray *floatViews; // @synthesize floatViews=_floatViews;
@property(retain, nonatomic) NSMutableArray *floatViewDatas; // @synthesize floatViewDatas=_floatViewDatas;
@property(retain, nonatomic) TTTDataProvider *dataProvider; // @synthesize dataProvider=_dataProvider;
- (void).cxx_destruct;
- (void)notUpdateNavBar:(_Bool)arg1;
- (void)changeToFloorView;
- (void)changeToCategoryView;
- (void)initView;
- (void)initData;
- (void)addFootView:(unsigned long long)arg1;
- (void)p_ShowFloatView;
- (void)reportVirtualClickBury;
- (void)reportPV;
- (void)removeSearchBar;
- (void)JDSearchBar:(id)arg1 historyItemSelected:(id)arg2 andSearchType:(int)arg3 andSearchCid:(id)arg4;
- (void)JDSearchBarCancelButtonClicked:(id)arg1;
- (void)goSearchView:(id)arg1;
- (void)requestPersonalData;
- (void)requestDraw:(id)arg1;
- (_Bool)p_isUserLogin;
- (void)showReceiveJingDouView:(id)arg1 couponModel:(id)arg2;
- (void)loadCouponData:(id)arg1;
- (void)loadCategoryData:(id)arg1;
- (void)loadNextPageWares;
- (void)forceLoadFirstPagesWares;
- (void)loadPagedWares;
- (void)loadPagedWaresWithSecondTabModel:(id)arg1;
- (void)initFloatViewDatas;
- (void)reloadFloatSection:(id)arg1;
- (void)reCreatFloatViewData;
- (void)reloadNetView;
- (void)refreshData;
- (void)fetchFirstPageData;
- (void)addCartResult:(id)arg1;
- (void)removeNotification;
- (void)addNotification;
- (void)isScrollToTop:(id)arg1;
- (void)viewWillDisappear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (void)dealloc;
- (void)viewDidLoad;
- (id)initWithPara:(id)arg1;
- (long long)p_findAnchorSection;
- (id)findIndexPathWithModelId:(id)arg1;
- (void)buryData:(id)arg1;
- (void)goToJump:(id)arg1 floorData:(id)arg2;
- (id)getTTTShareModel;
- (void)tttGoHome;
- (void)tttShare;
- (void)tttGoMsgCenter;
- (void)tttGoShopingCart;
- (void)tttGoSearch;
- (id)generateRightButtonMoreWithParamArray:(id)arg1;
- (id)generateRightButtonWithNumber:(id)arg1;
- (void)updateMultipleNaviRightButtonWithArray:(id)arg1;
- (void)updateTwoNaviRightButtonWithArray:(id)arg1;
- (void)updateNaviRightButton;
- (void)updateNaviTitle;
- (void)updateTTTNavigationBar;
- (id)getHeadViewAtIndex:(unsigned long long)arg1;
- (void)p_MoveAnchorRange:(id)arg1 offset:(double)arg2 anchor:(id)arg3 isNewCreate:(_Bool)arg4;
- (void)showTableHeadView:(double)arg1;
- (_Bool)shouldShowedHeadView:(double)arg1;
- (void)creatTTTCategoryTwoListView;
- (id)createRefreshHeadView:(id)arg1;
- (void)scrollViewDidEndScrollingAnimation:(id)arg1;
- (void)scrollViewDidEndDecelerating:(id)arg1;
- (void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2;
- (void)scrollViewDidScroll:(id)arg1;
- (id)createTableView:(struct CGRect)arg1;
- (void)tableView:(id)arg1 didEndDisplayingCell:(id)arg2 forRowAtIndexPath:(id)arg3;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forRowAtIndexPath:(id)arg3;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2;
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

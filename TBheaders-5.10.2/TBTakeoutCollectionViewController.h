//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBTakeoutHomeBaseViewController.h"

#import "UITableViewDataSource-Protocol.h"
#import "UITableViewDelegate-Protocol.h"

@class NSString, TBTakeoutCollectionEmptyView, TBTakeoutMyFavDelViewModel, TBTakeoutMyFavListViewModel, UIButton, UIFont, UITableView, UIView;

@interface TBTakeoutCollectionViewController : TBTakeoutHomeBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    _Bool _loadOutsideService;	// 10 = 0xa
    _Bool _isEditMode;	// 11 = 0xb
    int _totalRecords;	// 12 = 0xc
    int _recordSignleIndex;	// 16 = 0x10
    TBTakeoutCollectionEmptyView *_collectionEmptyView;	// 24 = 0x18
    UIView *_favTableViewFooterView;	// 32 = 0x20
    UIFont *_titleFont;	// 40 = 0x28
    UIButton *_editButton;	// 48 = 0x30
    UIButton *_batchDelButton;	// 56 = 0x38
    UITableView *_favTableView;	// 64 = 0x40
    double _lastContentOffset;	// 72 = 0x48
    NSString *_nextId;	// 80 = 0x50
    TBTakeoutMyFavDelViewModel *_myFavDelViewModel;	// 88 = 0x58
    TBTakeoutMyFavListViewModel *_myFavListViewModel;	// 96 = 0x60
}

@property(nonatomic) int recordSignleIndex; // @synthesize recordSignleIndex=_recordSignleIndex;
@property(retain, nonatomic) TBTakeoutMyFavListViewModel *myFavListViewModel; // @synthesize myFavListViewModel=_myFavListViewModel;
@property(retain, nonatomic) TBTakeoutMyFavDelViewModel *myFavDelViewModel; // @synthesize myFavDelViewModel=_myFavDelViewModel;
@property(retain, nonatomic) NSString *nextId; // @synthesize nextId=_nextId;
@property(nonatomic) int totalRecords; // @synthesize totalRecords=_totalRecords;
@property(nonatomic) double lastContentOffset; // @synthesize lastContentOffset=_lastContentOffset;
@property(nonatomic) _Bool isEditMode; // @synthesize isEditMode=_isEditMode;
@property(nonatomic) _Bool loadOutsideService; // @synthesize loadOutsideService=_loadOutsideService;
@property(retain, nonatomic) UITableView *favTableView; // @synthesize favTableView=_favTableView;
@property(retain, nonatomic) UIButton *batchDelButton; // @synthesize batchDelButton=_batchDelButton;
@property(retain, nonatomic) UIButton *editButton; // @synthesize editButton=_editButton;
@property(retain, nonatomic) UIFont *titleFont; // @synthesize titleFont=_titleFont;
@property(retain, nonatomic) UIView *favTableViewFooterView; // @synthesize favTableViewFooterView=_favTableViewFooterView;
@property(retain, nonatomic) TBTakeoutCollectionEmptyView *collectionEmptyView; // @synthesize collectionEmptyView=_collectionEmptyView;
- (void).cxx_destruct;
- (void)viewModel:(id)arg1 didLoadError:(id)arg2;
- (id)tableView:(id)arg1 titleForDeleteConfirmationButtonForRowAtIndexPath:(id)arg2;
- (void)doSingleDeleteAction:(long long)arg1;
- (void)doBatchDeleteAction;
- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2;
- (void)tableView:(id)arg1 commitEditingStyle:(long long)arg2 forRowAtIndexPath:(id)arg3;
- (long long)tableView:(id)arg1 editingStyleForRowAtIndexPath:(id)arg2;
- (_Bool)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 didDeselectRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2;
- (void)checkedShopInfoCell;
- (void)viewModelDidLoad:(id)arg1;
- (void)didReceiveMemoryWarning;
- (void)batchDeleteButtonPressed:(id)arg1;
- (void)exitSingleDelete;
- (void)editButtonPressed:(id)arg1;
- (void)viewDidLoad;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillLayoutSubviews;
- (void)setNaveTitle;
- (void)resetRequestParams;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

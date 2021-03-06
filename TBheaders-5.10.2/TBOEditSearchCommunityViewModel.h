//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBOBaseListViewModel.h"

@class NSMutableArray, NSString, TBOSearchCommunity;
@protocol TBOChooseCommunityDelegate, TBOCommunity;

@interface TBOEditSearchCommunityViewModel : TBOBaseListViewModel
{
    _Bool _isSearchResultEmpty;	// 8 = 0x8
    _Bool _isRecommendEmpty;	// 9 = 0x9
    _Bool _ismyCircleEmpty;	// 10 = 0xa
    NSMutableArray<TBOCommunity> *_circles;	// 16 = 0x10
    TBOSearchCommunity *_recommendCircleList;	// 24 = 0x18
    TBOSearchCommunity *_myCircleList;	// 32 = 0x20
    NSString *_keyword;	// 40 = 0x28
    id <TBOChooseCommunityDelegate> _delegate;	// 48 = 0x30
}

@property(nonatomic) id <TBOChooseCommunityDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) NSString *keyword; // @synthesize keyword=_keyword;
@property(nonatomic) _Bool ismyCircleEmpty; // @synthesize ismyCircleEmpty=_ismyCircleEmpty;
@property(nonatomic) _Bool isRecommendEmpty; // @synthesize isRecommendEmpty=_isRecommendEmpty;
@property(nonatomic) _Bool isSearchResultEmpty; // @synthesize isSearchResultEmpty=_isSearchResultEmpty;
@property(retain, nonatomic) TBOSearchCommunity *myCircleList; // @synthesize myCircleList=_myCircleList;
@property(retain, nonatomic) TBOSearchCommunity *recommendCircleList; // @synthesize recommendCircleList=_recommendCircleList;
@property(retain, nonatomic) NSMutableArray<TBOCommunity> *circles; // @synthesize circles=_circles;
- (void).cxx_destruct;
- (_Bool)isKeyword;
- (long long)itemCount:(long long)arg1;
- (long long)sectionCount;
- (id)data:(id)arg1;
- (void)onloaderCompleted:(struct MtopExtResponse *)arg1 succeeded:(_Bool)arg2;
- (void)loadCommunityResultData:(id)arg1;
- (id)initWithKeyword:(id)arg1 itemId:(id)arg2;

@end


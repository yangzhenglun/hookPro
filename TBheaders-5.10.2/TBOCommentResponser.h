//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBOBaseResponseModel.h"

@class NSMutableArray;
@protocol TBOComment;

@interface TBOCommentResponser : TBOBaseResponseModel
{
    long long _totalCount;	// 8 = 0x8
    NSMutableArray<TBOComment> *_list;	// 16 = 0x10
}

@property(retain, nonatomic) NSMutableArray<TBOComment> *list; // @synthesize list=_list;
@property(nonatomic) long long totalCount; // @synthesize totalCount=_totalCount;
- (void).cxx_destruct;
- (id)items;

@end


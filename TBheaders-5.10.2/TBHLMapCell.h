//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBHLBaseFeedCell.h"

@class NSString;

@interface TBHLMapCell : TBHLBaseFeedCell
{
    NSString *_detailUrl;	// 8 = 0x8
}

@property(copy, nonatomic) NSString *detailUrl; // @synthesize detailUrl=_detailUrl;
- (void).cxx_destruct;
- (void)configHLCell:(id)arg1;
- (void)layoutSubviews;
- (void)cellClick;
- (void)setRead:(_Bool)arg1;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end


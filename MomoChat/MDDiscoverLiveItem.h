//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MDDiscoverCommonItem.h"

@class NSArray, NSString;

@interface MDDiscoverLiveItem : MDDiscoverCommonItem
{
    double _liveStartTimestamp;
    double _liveEndTimestamp;
    NSArray *_liveUserIcons;
    NSArray *_liveLabels;
    long long _liveStartDesc;
    NSString *_liveEndDesc;
    NSArray *_liveArtists;
}

+ (id)itemWithDiscoverDictionary:(id)arg1;
@property(retain, nonatomic) NSArray *liveArtists; // @synthesize liveArtists=_liveArtists;
@property(retain, nonatomic) NSString *liveEndDesc; // @synthesize liveEndDesc=_liveEndDesc;
@property(nonatomic) long long liveStartDesc; // @synthesize liveStartDesc=_liveStartDesc;
@property(retain, nonatomic) NSArray *liveLabels; // @synthesize liveLabels=_liveLabels;
@property(retain, nonatomic) NSArray *liveUserIcons; // @synthesize liveUserIcons=_liveUserIcons;
@property(nonatomic) double liveEndTimestamp; // @synthesize liveEndTimestamp=_liveEndTimestamp;
@property(nonatomic) double liveStartTimestamp; // @synthesize liveStartTimestamp=_liveStartTimestamp;
- (void)dealloc;
- (_Bool)checkLiveItemShouldShow;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBHLBaseFeedCell.h"

@class NSString, UIButton, UILabel;

@interface TBHLLiveRoomCell : TBHLBaseFeedCell
{
    NSString *_videoURLStr;	// 8 = 0x8
    NSString *_feedId;	// 16 = 0x10
    UILabel *_contextLabel1;	// 24 = 0x18
    UILabel *_contextlabeL2;	// 32 = 0x20
    UIButton *_zhiboLabel;	// 40 = 0x28
    UIButton *_button;	// 48 = 0x30
}

@property(retain, nonatomic) UIButton *button; // @synthesize button=_button;
@property(retain, nonatomic) UIButton *zhiboLabel; // @synthesize zhiboLabel=_zhiboLabel;
@property(retain, nonatomic) UILabel *contextlabeL2; // @synthesize contextlabeL2=_contextlabeL2;
@property(retain, nonatomic) UILabel *contextLabel1; // @synthesize contextLabel1=_contextLabel1;
@property(copy, nonatomic) NSString *feedId; // @synthesize feedId=_feedId;
@property(copy, nonatomic) NSString *videoURLStr; // @synthesize videoURLStr=_videoURLStr;
- (void).cxx_destruct;
- (void)configHLCell:(id)arg1;
- (void)videoButtonClick;
- (void)layoutSubviews;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end

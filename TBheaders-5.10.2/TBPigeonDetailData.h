//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "TBJSONModel.h"

@class NSArray, NSDictionary, NSString;
@protocol TBPigeonServiceCardImgListItem, TBPigeonServiceCardTextListItem, TBPigeonSlotActionItem;

@interface TBPigeonDetailData : TBJSONModel
{
    _Bool _hasBeenPVTracked;	// 8 = 0x8
    NSArray<TBPigeonServiceCardTextListItem> *_title;	// 16 = 0x10
    NSArray<TBPigeonServiceCardImgListItem> *_imageUrl;	// 24 = 0x18
    NSArray<TBPigeonSlotActionItem> *_extras;	// 32 = 0x20
    NSString *_targetUrl;	// 40 = 0x28
    NSString *_bizType;	// 48 = 0x30
    id _extra;	// 56 = 0x38
    id _trackParam;	// 64 = 0x40
    NSString *_trackCode;	// 72 = 0x48
    NSString *_trackExtraInfo;	// 80 = 0x50
    NSString *_itemId;	// 88 = 0x58
    NSDictionary *_extraMap;	// 96 = 0x60
}

@property(retain, nonatomic) NSDictionary *extraMap; // @synthesize extraMap=_extraMap;
@property(nonatomic) _Bool hasBeenPVTracked; // @synthesize hasBeenPVTracked=_hasBeenPVTracked;
@property(retain, nonatomic) NSString *itemId; // @synthesize itemId=_itemId;
@property(retain, nonatomic) NSString *trackExtraInfo; // @synthesize trackExtraInfo=_trackExtraInfo;
@property(retain, nonatomic) NSString *trackCode; // @synthesize trackCode=_trackCode;
@property(retain, nonatomic) id trackParam; // @synthesize trackParam=_trackParam;
@property(retain, nonatomic) id extra; // @synthesize extra=_extra;
@property(retain, nonatomic) NSString *bizType; // @synthesize bizType=_bizType;
@property(retain, nonatomic) NSString *targetUrl; // @synthesize targetUrl=_targetUrl;
@property(retain, nonatomic) NSArray<TBPigeonSlotActionItem> *extras; // @synthesize extras=_extras;
@property(retain, nonatomic) NSArray<TBPigeonServiceCardImgListItem> *imageUrl; // @synthesize imageUrl=_imageUrl;
@property(retain, nonatomic) NSArray<TBPigeonServiceCardTextListItem> *title; // @synthesize title=_title;
- (void).cxx_destruct;
- (id)JSONRepresentation;
- (void)pvtrack;
- (void)getTrackCode;
- (id)toJSONDictionary;
- (id)initWithJSONDictionary:(id)arg1 error:(id *)arg2;

@end

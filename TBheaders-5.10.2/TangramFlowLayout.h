//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

#import "TangramLayoutProtocol-Protocol.h"

@class NSArray, NSMutableArray, NSString, UIImageView;

@interface TangramFlowLayout : UIView <TangramLayoutProtocol>
{
    _Bool _autoFill;	// 8 = 0x8
    int _numberOfReloadRequests;	// 12 = 0xc
    NSArray *_itemModels;	// 16 = 0x10
    unsigned long long _numberOfColumns;	// 24 = 0x18
    NSArray *_cols;	// 32 = 0x20
    NSString *_aspectRatio;	// 40 = 0x28
    NSArray *_margin;	// 48 = 0x30
    double _hGap;	// 56 = 0x38
    double _vGap;	// 64 = 0x40
    NSString *_layoutLoadAPI;	// 72 = 0x48
    NSString *_layoutIdentifier;	// 80 = 0x50
    double _firstReloadRequestTS;	// 88 = 0x58
    NSMutableArray *_firstElementModelInRow;	// 96 = 0x60
    NSString *_bgImgURL;	// 104 = 0x68
    UIImageView *_bgImageView;	// 112 = 0x70
    long long _loadType;	// 120 = 0x78
}

@property(nonatomic) long long loadType; // @synthesize loadType=_loadType;
@property(retain, nonatomic) UIImageView *bgImageView; // @synthesize bgImageView=_bgImageView;
@property(retain, nonatomic) NSString *bgImgURL; // @synthesize bgImgURL=_bgImgURL;
@property(retain, nonatomic) NSMutableArray *firstElementModelInRow; // @synthesize firstElementModelInRow=_firstElementModelInRow;
@property double firstReloadRequestTS; // @synthesize firstReloadRequestTS=_firstReloadRequestTS;
@property int numberOfReloadRequests; // @synthesize numberOfReloadRequests=_numberOfReloadRequests;
@property(retain, nonatomic) NSString *layoutIdentifier; // @synthesize layoutIdentifier=_layoutIdentifier;
@property(retain, nonatomic) NSString *layoutLoadAPI; // @synthesize layoutLoadAPI=_layoutLoadAPI;
@property(nonatomic) _Bool autoFill; // @synthesize autoFill=_autoFill;
@property(nonatomic) double vGap; // @synthesize vGap=_vGap;
@property(nonatomic) double hGap; // @synthesize hGap=_hGap;
@property(retain, nonatomic) NSArray *margin; // @synthesize margin=_margin;
@property(retain, nonatomic) NSString *aspectRatio; // @synthesize aspectRatio=_aspectRatio;
@property(retain, nonatomic) NSArray *cols; // @synthesize cols=_cols;
@property(nonatomic) unsigned long long numberOfColumns; // @synthesize numberOfColumns=_numberOfColumns;
- (void).cxx_destruct;
- (void)configLayoutPropertyWithDict:(id)arg1;
- (void)setItemWidth:(double)arg1 withModel:(id)arg2;
- (void)setItemTop:(double)arg1 withModel:(id)arg2;
- (void)setItemLeft:(double)arg1 withModel:(id)arg2;
- (void)setIdentifier:(id)arg1;
- (id)identifier;
- (id)loadAPI;
- (void)heightChangedWithElement:(id)arg1 model:(id)arg2;
- (void)calculateLayout;
- (double)marginLeft;
- (double)marginBottom;
- (double)marginRight;
- (double)marginTop;
@property(retain, nonatomic) NSArray *itemModels; // @synthesize itemModels=_itemModels;
- (id)position;
- (struct NSString *)layoutType;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "JUSDKDOBase.h"

@class NSMutableArray, NSString;

@interface JUItemFeatureModel : JUSDKDOBase
{
    NSMutableArray *_itemFeatures;	// 8 = 0x8
    NSMutableArray *_sellingPoints;	// 16 = 0x10
    NSString *_valid;	// 24 = 0x18
}

@property(retain, nonatomic) NSString *valid; // @synthesize valid=_valid;
@property(retain, nonatomic) NSMutableArray *sellingPoints; // @synthesize sellingPoints=_sellingPoints;
@property(retain, nonatomic) NSMutableArray *itemFeatures; // @synthesize itemFeatures=_itemFeatures;
- (void).cxx_destruct;

@end


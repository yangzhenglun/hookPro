//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "aluJsonableObject.h"

@class NSString;

@interface aluRiskControlInfo : aluJsonableObject
{
    NSString *_apdId;	// 8 = 0x8
    NSString *_umidToken;	// 16 = 0x10
    NSString *_wua;	// 24 = 0x18
    NSString *_t;	// 32 = 0x20
}

@property(copy, nonatomic) NSString *t; // @synthesize t=_t;
@property(copy, nonatomic) NSString *wua; // @synthesize wua=_wua;
@property(copy, nonatomic) NSString *umidToken; // @synthesize umidToken=_umidToken;
@property(copy, nonatomic) NSString *apdId; // @synthesize apdId=_apdId;
- (void).cxx_destruct;

@end


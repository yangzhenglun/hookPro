//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSMutableDictionary, NSString;

@interface TBSkinInfoModel : NSObject
{
    NSMutableDictionary *_skinInfoDict;	// 8 = 0x8
}

+ (id)skinInfoModelWithDictionary:(id)arg1;
- (void).cxx_destruct;
@property(readonly, nonatomic) NSMutableDictionary *skinInfoDict; // @synthesize skinInfoDict=_skinInfoDict;
@property(copy, nonatomic) NSString *skinUsedTime;
@property(copy, nonatomic) NSString *skinUrl;
@property(copy, nonatomic) NSString *skinCode;
- (id)copy;
- (_Bool)isEqualToDictionary:(id)arg1;
- (_Bool)isEqualToSkinInfoModel:(id)arg1;
- (_Bool)isAvailable;

@end


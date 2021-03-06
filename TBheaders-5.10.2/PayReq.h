//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "BaseReq.h"

@class NSString;

@interface PayReq : BaseReq
{
    unsigned int timeStamp;	// 24 = 0x18
    NSString *nonceStr;	// 32 = 0x20
    NSString *package;	// 40 = 0x28
    NSString *partnerId;	// 48 = 0x30
    NSString *prepayId;	// 56 = 0x38
    NSString *sign;	// 64 = 0x40
}

@property(retain, nonatomic) NSString *sign; // @synthesize sign;
@property(nonatomic) unsigned int timeStamp; // @synthesize timeStamp;
@property(retain, nonatomic) NSString *prepayId; // @synthesize prepayId;
@property(retain, nonatomic) NSString *partnerId; // @synthesize partnerId;
@property(retain, nonatomic) NSString *package; // @synthesize package;
@property(retain, nonatomic) NSString *nonceStr; // @synthesize nonceStr;
- (void)dealloc;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSNumber, NSString;

@interface BJWelfareCouponModel : NSObject
{
    NSString *_couponId;
    NSNumber *_quota;
    NSString *_limitInfo;
    NSString *_faceValue;
    long long _couponType;
    NSString *_batchId;
}

+ (id)replacedKeyFromPropertyName;
@property(readonly, nonatomic) NSString *batchId; // @synthesize batchId=_batchId;
@property(readonly, nonatomic) long long couponType; // @synthesize couponType=_couponType;
@property(readonly, copy, nonatomic) NSString *faceValue; // @synthesize faceValue=_faceValue;
@property(readonly, nonatomic) NSString *limitInfo; // @synthesize limitInfo=_limitInfo;
@property(readonly, copy, nonatomic) NSNumber *quota; // @synthesize quota=_quota;
@property(readonly, copy, nonatomic) NSString *couponId; // @synthesize couponId=_couponId;
- (void).cxx_destruct;

@end


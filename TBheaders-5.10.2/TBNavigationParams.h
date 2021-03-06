//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSString;

@interface TBNavigationParams : NSObject
{
    _Bool _animated;	// 8 = 0x8
    _Bool _needNavigationCtrl;	// 9 = 0x9
    _Bool _needLogin;	// 10 = 0xa
    _Bool _needSafeCode;	// 11 = 0xb
    _Bool _needDissmiss;	// 12 = 0xc
    _Bool _needPopToRootViewController;	// 13 = 0xd
    int _navigationType;	// 16 = 0x10
    NSString *_target;	// 24 = 0x18
    NSString *_backUrl;	// 32 = 0x20
    NSString *_backAppName;	// 40 = 0x28
    NSString *_backAlertTitle;	// 48 = 0x30
}

+ (id)navigationParamsofDictionary:(id)arg1;
@property(copy, nonatomic) NSString *backAlertTitle; // @synthesize backAlertTitle=_backAlertTitle;
@property(copy, nonatomic) NSString *backAppName; // @synthesize backAppName=_backAppName;
@property(copy, nonatomic) NSString *backUrl; // @synthesize backUrl=_backUrl;
@property(copy, nonatomic) NSString *target; // @synthesize target=_target;
@property(nonatomic) int navigationType; // @synthesize navigationType=_navigationType;
@property(nonatomic) _Bool needPopToRootViewController; // @synthesize needPopToRootViewController=_needPopToRootViewController;
@property(nonatomic) _Bool needDissmiss; // @synthesize needDissmiss=_needDissmiss;
@property(nonatomic) _Bool needSafeCode; // @synthesize needSafeCode=_needSafeCode;
@property(nonatomic) _Bool needLogin; // @synthesize needLogin=_needLogin;
@property(nonatomic) _Bool needNavigationCtrl; // @synthesize needNavigationCtrl=_needNavigationCtrl;
@property(nonatomic) _Bool animated; // @synthesize animated=_animated;
- (void).cxx_destruct;
- (id)stringofNavigationParams;
- (id)init;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSString;

@interface WXOMTAConfig : NSObject
{
    _Bool _debugEnable;	// 8 = 0x8
    _Bool _smartReporting;	// 9 = 0x9
    _Bool _autoExceptionCaught;	// 10 = 0xa
    BOOL _accountType;	// 11 = 0xb
    _Bool _statEnable;	// 12 = 0xc
    unsigned int _sessionTimeoutSecs;	// 16 = 0x10
    int _reportStrategy;	// 20 = 0x14
    unsigned int _maxStoreEventCount;	// 24 = 0x18
    unsigned int _maxLoadEventCount;	// 28 = 0x1c
    unsigned int _minBatchReportCount;	// 32 = 0x20
    unsigned int _maxSendRetryCount;	// 36 = 0x24
    unsigned int _sendPeriodMinutes;	// 40 = 0x28
    unsigned int _maxParallelTimingEvents;	// 44 = 0x2c
    unsigned int _maxReportEventLength;	// 48 = 0x30
    int _maxSessionStatReportCount;	// 52 = 0x34
    NSString *_appkey;	// 56 = 0x38
    NSString *_channel;	// 64 = 0x40
    NSString *_qq;	// 72 = 0x48
    NSString *_account;	// 80 = 0x50
    NSString *_accountExt;	// 88 = 0x58
    NSString *_customerUserID;	// 96 = 0x60
    NSString *_customerAppVersion;	// 104 = 0x68
    NSString *_ifa;	// 112 = 0x70
    NSString *_pushDeviceToken;	// 120 = 0x78
    NSString *_statReportURL;	// 128 = 0x80
    NSString *_op;	// 136 = 0x88
    NSString *_cn;	// 144 = 0x90
    NSString *_sp;	// 152 = 0x98
    CDUnknownBlockType _crashCallback;	// 160 = 0xa0
}

+ (id)getInstance;
@property(copy, nonatomic) CDUnknownBlockType crashCallback; // @synthesize crashCallback=_crashCallback;
@property(retain) NSString *sp; // @synthesize sp=_sp;
@property(retain, nonatomic) NSString *cn; // @synthesize cn=_cn;
@property(retain, nonatomic) NSString *op; // @synthesize op=_op;
@property int maxSessionStatReportCount; // @synthesize maxSessionStatReportCount=_maxSessionStatReportCount;
@property(retain, nonatomic) NSString *statReportURL; // @synthesize statReportURL=_statReportURL;
@property(retain, nonatomic) NSString *pushDeviceToken; // @synthesize pushDeviceToken=_pushDeviceToken;
@property(retain, nonatomic) NSString *ifa; // @synthesize ifa=_ifa;
@property(retain, nonatomic) NSString *customerAppVersion; // @synthesize customerAppVersion=_customerAppVersion;
@property(retain, nonatomic) NSString *customerUserID; // @synthesize customerUserID=_customerUserID;
@property _Bool statEnable; // @synthesize statEnable=_statEnable;
@property(retain, nonatomic) NSString *accountExt; // @synthesize accountExt=_accountExt;
@property BOOL accountType; // @synthesize accountType=_accountType;
@property(retain, nonatomic) NSString *account; // @synthesize account=_account;
@property(retain, nonatomic) NSString *qq; // @synthesize qq=_qq;
@property unsigned int maxReportEventLength; // @synthesize maxReportEventLength=_maxReportEventLength;
@property _Bool autoExceptionCaught; // @synthesize autoExceptionCaught=_autoExceptionCaught;
@property _Bool smartReporting; // @synthesize smartReporting=_smartReporting;
@property unsigned int maxParallelTimingEvents; // @synthesize maxParallelTimingEvents=_maxParallelTimingEvents;
@property unsigned int sendPeriodMinutes; // @synthesize sendPeriodMinutes=_sendPeriodMinutes;
@property unsigned int maxSendRetryCount; // @synthesize maxSendRetryCount=_maxSendRetryCount;
@property unsigned int minBatchReportCount; // @synthesize minBatchReportCount=_minBatchReportCount;
@property unsigned int maxLoadEventCount; // @synthesize maxLoadEventCount=_maxLoadEventCount;
@property unsigned int maxStoreEventCount; // @synthesize maxStoreEventCount=_maxStoreEventCount;
@property(retain, nonatomic) NSString *channel; // @synthesize channel=_channel;
@property(retain, nonatomic) NSString *appkey; // @synthesize appkey=_appkey;
@property(nonatomic) int reportStrategy; // @synthesize reportStrategy=_reportStrategy;
@property unsigned int sessionTimeoutSecs; // @synthesize sessionTimeoutSecs=_sessionTimeoutSecs;
@property _Bool debugEnable; // @synthesize debugEnable=_debugEnable;
- (id)getCustomProperty:(id)arg1 default:(id)arg2;
- (id)init;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSArray;

@interface AppMonitorOfflineConfig : NSObject
{
    struct dispatch_queue_s *_offlineQueue;	// 8 = 0x8
    _Bool _isOffline;	// 16 = 0x10
    _Bool _offlineArrive;	// 17 = 0x11
    NSArray *_offlineArray;	// 24 = 0x18
}

+ (id)allocWithZone:(struct _NSZone *)arg1;
+ (id)sharedInstance;
@property(retain, nonatomic) NSArray *offlineArray; // @synthesize offlineArray=_offlineArray;
@property _Bool offlineArrive; // @synthesize offlineArrive=_offlineArrive;
@property _Bool isOffline; // @synthesize isOffline=_isOffline;
- (void).cxx_destruct;
- (_Bool)isOffline:(long long)arg1 module:(id)arg2 monitorPoint:(id)arg3;
- (void)disenableOffline;
- (void)enableOffline;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)arg1;

@end


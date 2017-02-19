//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class JDTrackReachability;

@interface JDTrackCheckNetwork : NSObject
{
    id target_;
    SEL reachabilitySelector_;
    JDTrackReachability *reachability_;
    JDTrackReachability *hostReach_;
    JDTrackReachability *internetReach_;
    JDTrackReachability *wifiReach_;
}

+ (id)allocWithZone:(struct _NSZone *)arg1;
+ (id)shareInstance;
- (void).cxx_destruct;
- (int)internetConnectionStatus;
- (void)startNotificationWithTarget:(id)arg1 reachabilitySelector:(SEL)arg2;
- (void)reachabilityChanged:(id)arg1;
- (void)updateInterfaceWithReachability:(id)arg1;
- (void)configureInfoByReachability:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;

@end

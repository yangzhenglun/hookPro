//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "NSObject-Protocol.h"

@class WCDevice;

@protocol WCDeviceWifiStateLogicDelegate <NSObject>
- (void)onhandleWifiStateUpdateMsgEnd:(WCDevice *)arg1 Status:(unsigned int)arg2;

@optional
- (void)onWCDevideWifiStateSubscribeEnd:(WCDevice *)arg1 ForError:(int)arg2;
@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@protocol OS_dispatch_queue;

@interface TBAccsThreadCenter : NSObject
{
    NSObject<OS_dispatch_queue> *_sendQueue;	// 8 = 0x8
    NSObject<OS_dispatch_queue> *_receiveQueue;	// 16 = 0x10
    NSObject<OS_dispatch_queue> *_callbackQueue;	// 24 = 0x18
}

+ (id)shareInstance;
@property(retain, nonatomic) NSObject<OS_dispatch_queue> *callbackQueue; // @synthesize callbackQueue=_callbackQueue;
@property(retain, nonatomic) NSObject<OS_dispatch_queue> *receiveQueue; // @synthesize receiveQueue=_receiveQueue;
@property(retain, nonatomic) NSObject<OS_dispatch_queue> *sendQueue; // @synthesize sendQueue=_sendQueue;
- (void).cxx_destruct;
- (id)init;

@end

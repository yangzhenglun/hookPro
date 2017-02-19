//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

#import "PSDURLProtocolProcessorDelegate.h"

@class NSString, NSURLRequest, NSURLResponse, PSDConnectionProfile;

@interface PSDConnectionMonitor : NSObject <PSDURLProtocolProcessorDelegate>
{
    PSDConnectionProfile *_profile;
    NSURLRequest *_currentRequest;
    NSURLRequest *_redirectRequest;
    NSURLResponse *_currentResponse;
    id <PSDConnectionMonitorDelegate> _delegate;
}

@property(nonatomic) __weak id <PSDConnectionMonitorDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) NSURLResponse *currentResponse; // @synthesize currentResponse=_currentResponse;
@property(retain, nonatomic) NSURLRequest *redirectRequest; // @synthesize redirectRequest=_redirectRequest;
@property(retain, nonatomic) NSURLRequest *currentRequest; // @synthesize currentRequest=_currentRequest;
@property(retain, nonatomic) PSDConnectionProfile *profile; // @synthesize profile=_profile;
- (void).cxx_destruct;
- (void)PSDURLProtocolProcessor:(id)arg1 didFailWithError:(id)arg2;
- (void)PSDURLProtocolProcessor:(id)arg1 didFinishLoading:(id)arg2;
- (void)PSDURLProtocolProcessor:(id)arg1 didLoadData:(id)arg2;
- (void)PSDURLProtocolProcessor:(id)arg1 didReceiveResponse:(id)arg2;
- (void)PSDURLProtocolProcessor:(id)arg1 wasRedirectedToRequest:(id)arg2 redirectResponse:(id)arg3 receiveData:(id)arg4;
- (void)PSDURLProtocolProcessor:(id)arg1 startLoading:(id)arg2;
- (void)PSDURLProtocolProcessor:(id)arg1 willStartLoading:(id)arg2;
- (void)reportProfile;
- (void)startStatistics:(id)arg1;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

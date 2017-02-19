//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSURLProtocol.h"

@class NSMutableData, NSURLConnection;

@interface MKURLProtocol : NSURLProtocol
{
    NSURLConnection *connection_;
    NSMutableData *_data;
}

+ (id)appInfoDictionary;
+ (_Bool)allowsArbitraryLoads;
+ (id)canonicalRequestForRequest:(id)arg1;
+ (_Bool)canInitWithRequest:(id)arg1;
@property(retain, nonatomic) NSMutableData *data; // @synthesize data=_data;
@property(retain, nonatomic) NSURLConnection *connection; // @synthesize connection=connection_;
- (void).cxx_destruct;
- (void)appendData:(id)arg1;
- (void)connectionDidFinishLoading:(id)arg1;
- (void)connection:(id)arg1 didReceiveResponse:(id)arg2;
- (void)connection:(id)arg1 didFailWithError:(id)arg2;
- (void)connection:(id)arg1 didReceiveData:(id)arg2;
- (id)connection:(id)arg1 willSendRequest:(id)arg2 redirectResponse:(id)arg3;
- (void)stopLoading;
- (id)fileMIMEType:(id)arg1;
- (void)startLoading;

@end

//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSDictionary, PSDWebView;

@interface PSDPageParam : NSObject
{
    PSDWebView *_webView;
    id <UIWebViewDelegate> _webViewDelegate4PsdView;
    NSDictionary *_expandParams;
}

@property(retain, nonatomic) NSDictionary *expandParams; // @synthesize expandParams=_expandParams;
@property(nonatomic) __weak id <UIWebViewDelegate> webViewDelegate4PsdView; // @synthesize webViewDelegate4PsdView=_webViewDelegate4PsdView;
@property(nonatomic) __weak PSDWebView *webView; // @synthesize webView=_webView;
- (void).cxx_destruct;

@end


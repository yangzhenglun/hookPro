//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "JDVDanmuUpHeader.h"

@class JDVDanmuUpAnchorAddProductToCartBody<Optional>;

@interface JDVDanmuUpAnchorAddProductToCartMsg : JDVDanmuUpHeader
{
    JDVDanmuUpAnchorAddProductToCartBody<Optional> *body;
    JDVDanmuUpAnchorAddProductToCartBody<Optional> *data;
}

@property(retain, nonatomic) JDVDanmuUpAnchorAddProductToCartBody<Optional> *data; // @synthesize data;
@property(retain, nonatomic) JDVDanmuUpAnchorAddProductToCartBody<Optional> *body; // @synthesize body;
- (void).cxx_destruct;
- (id)init;

@end


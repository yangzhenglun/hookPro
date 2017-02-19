//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSArray, NSData, NSString;

@interface JDSpotlightModel : NSObject
{
    NSString *_title;
    NSString *_contentDescription;
    NSData *_thumbnailData;
    NSArray *_keywords;
    NSString *_uniqueIdentifier;
    NSString *_domainIdentifier;
}

@property(retain, nonatomic) NSString *domainIdentifier; // @synthesize domainIdentifier=_domainIdentifier;
@property(retain, nonatomic) NSString *uniqueIdentifier; // @synthesize uniqueIdentifier=_uniqueIdentifier;
@property(retain, nonatomic) NSArray *keywords; // @synthesize keywords=_keywords;
@property(retain, nonatomic) NSData *thumbnailData; // @synthesize thumbnailData=_thumbnailData;
@property(retain, nonatomic) NSString *contentDescription; // @synthesize contentDescription=_contentDescription;
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
- (void).cxx_destruct;
- (_Bool)isRightData;
- (id)init;

@end

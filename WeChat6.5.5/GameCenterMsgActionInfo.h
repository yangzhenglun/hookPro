//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class NSString;

__attribute__((visibility("hidden")))
@interface GameCenterMsgActionInfo : NSObject
{
    int _type;
    NSString *_jumpUrl;
}

+ (id)parseFromXml:(struct XmlReaderNode_t *)arg1;
@property(retain, nonatomic) NSString *jumpUrl; // @synthesize jumpUrl=_jumpUrl;
@property(nonatomic) int type; // @synthesize type=_type;
- (void).cxx_destruct;

@end


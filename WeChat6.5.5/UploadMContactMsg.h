//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Oct  3 2016 20:04:13).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class NSString;

__attribute__((visibility("hidden")))
@interface UploadMContactMsg : NSObject
{
    NSString *deviceType;
}

@property(retain, nonatomic) NSString *deviceType; // @synthesize deviceType;
- (void).cxx_destruct;
- (void)parseXML:(id)arg1;
- (void)dealloc;
- (id)initWithXml:(id)arg1;

@end


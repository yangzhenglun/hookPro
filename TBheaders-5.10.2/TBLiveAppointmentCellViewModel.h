//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@class NSString, TBLiveFeedAppointmentModel;

@interface TBLiveAppointmentCellViewModel : NSObject
{
    _Bool _subscribed;	// 8 = 0x8
    TBLiveFeedAppointmentModel *_origin;	// 16 = 0x10
    NSString *_appointmentDate;	// 24 = 0x18
    NSString *_title;	// 32 = 0x20
    NSString *_broadCasterName;	// 40 = 0x28
    NSString *_coverImgURL;	// 48 = 0x30
}

@property(copy, nonatomic) NSString *coverImgURL; // @synthesize coverImgURL=_coverImgURL;
@property(copy, nonatomic) NSString *broadCasterName; // @synthesize broadCasterName=_broadCasterName;
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@property(copy, nonatomic) NSString *appointmentDate; // @synthesize appointmentDate=_appointmentDate;
@property(nonatomic, getter=isSubscribed) _Bool subscribed; // @synthesize subscribed=_subscribed;
@property(retain, nonatomic) TBLiveFeedAppointmentModel *origin; // @synthesize origin=_origin;
- (void).cxx_destruct;
- (void)refreshWithModel:(id)arg1;

@end


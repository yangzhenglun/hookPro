//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "HomePageChannelCanvas.h"
#import "NSObject.h"

@class HomePageChannelAction, NSIndexPath, NSString;

@protocol HomePageChannelFloorCell <HomePageChannelCanvas, NSObject>
@property(readonly, nonatomic) NSString *floorCellIdentifier;

@optional
- (HomePageChannelAction *)actionAtIndexPath:(NSIndexPath *)arg1;
@end

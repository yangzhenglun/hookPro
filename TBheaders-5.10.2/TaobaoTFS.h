//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

@interface TaobaoTFS : NSObject
{
}

+ (void)setLowQualityImageSwitch:(_Bool)arg1;
+ (_Bool)shouldShowLowQualityImage;
+ (id)normalImagePathForSmallPath:(id)arg1;
+ (id)getOriginImagePath:(id)arg1;
+ (id)getMiddleImagePathsInDifferentNetwork:(id)arg1;
+ (id)getMiddleImagePath:(id)arg1;
+ (id)getSmallImagePathsInDifferentNetwork:(id)arg1;
+ (id)getImageWithPath:(id)arg1 withSize:(id)arg2;
+ (id)getSmallImagePath:(id)arg1;
+ (id)getImageFullPath:(id)arg1 level:(id)arg2;
+ (id)getImageFullPath:(id)arg1 level:(id)arg2 webp:(_Bool)arg3;
+ (id)getTFSServerPath:(id)arg1;
+ (id)urlCache;
+ (void)resetServers;

@end


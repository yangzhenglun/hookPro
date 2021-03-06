//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIColor.h>

@class UIAColorComponents;

@interface UIColor (EX)
+ (id)colorWithString:(id)arg1;
+ (id)tm_colorWithHexValue:(unsigned long long)arg1 alpha:(unsigned long long)arg2;
+ (id)colorWithHexValue:(unsigned long long)arg1;
+ (unsigned long long)tm_hexValueOfString:(id)arg1;
- (id)highligtedColor;
- (id)highligtedColorForBackgroundColor:(id)arg1;
- (id)mixedColorWithColor:(id)arg1 ratio:(double)arg2;
- (id)colorWithAlpha:(double)arg1;
@property(readonly, nonatomic) UIAColorComponents *components;
- (id)image;
- (id)imageOfSize:(struct CGSize)arg1;
@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "FBView.h"

@class NSTimer, UILabel, UIView;

@interface FBMarquee : FBView
{
    UIView *_containerView;	// 8 = 0x8
    UILabel *_label;	// 16 = 0x10
    double _width;	// 24 = 0x18
    double _text_width;	// 32 = 0x20
    NSTimer *_timer;	// 40 = 0x28
    double timeFunctionStartXXXtime;	// 48 = 0x30
    float _padding[4];	// 56 = 0x38
}

- (void).cxx_destruct;
- (void)stop;
- (void)timerFired;
- (void)start;
- (void)updateAttr:(id)arg1 withValue:(id)arg2;
- (void)updateCSS:(id)arg1 withValue:(id)arg2;
- (void)updateRect;
- (id)initWithNode:(struct fb_node *)arg1 withDocument:(id)arg2 withView:(id)arg3;
- (void)dealloc;

@end


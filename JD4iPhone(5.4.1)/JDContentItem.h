//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

#import "JDContentItemDataSource.h"

@class NSString, NSTimer, UIImageView;

@interface JDContentItem : UIView <JDContentItemDataSource>
{
    id _delegate;
    UIImageView *_highlight;
    NSTimer *_touchTimer;
    _Bool _enableTouchEffect;
    NSString *_identifier;
}

@property(nonatomic) id <JDContentItemDelegate> delegate; // @synthesize delegate=_delegate;
@property(nonatomic) _Bool enableTouchEffect; // @synthesize enableTouchEffect=_enableTouchEffect;
@property(copy, nonatomic) NSString *identifier; // @synthesize identifier=_identifier;
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2;
- (void)touchesCancelled:(id)arg1 withEvent:(id)arg2;
- (void)touchesBegan:(id)arg1 withEvent:(id)arg2;
- (void)cancelTouch;
- (void)highlighted:(_Bool)arg1;
- (void)layoutSubviews;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


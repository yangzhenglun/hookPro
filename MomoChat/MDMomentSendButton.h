//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIButton.h"

@class UIImageView;

@interface MDMomentSendButton : UIButton
{
    UIImageView *_repeatAnimationView1;
    UIImageView *_repeatAnimationView2;
}

+ (id)momentSendButton;
@property(retain, nonatomic) UIImageView *repeatAnimationView2; // @synthesize repeatAnimationView2=_repeatAnimationView2;
@property(retain, nonatomic) UIImageView *repeatAnimationView1; // @synthesize repeatAnimationView1=_repeatAnimationView1;
- (void).cxx_destruct;
- (void)remindSendingAnimation;
- (void)startButtonTranslationAnimation;
- (void)dealloc;

@end


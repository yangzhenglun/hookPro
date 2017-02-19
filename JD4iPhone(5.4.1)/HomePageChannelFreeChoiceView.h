//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

#import "HomePageChannelDisplayItem.h"
#import "HomePageChannelInteractiveItem.h"

@class HomePageChannelFreeChoiceItemView, JDImageView, NSString, UIImageView, UILabel, UITapGestureRecognizer;

@interface HomePageChannelFreeChoiceView : UIView <HomePageChannelDisplayItem, HomePageChannelInteractiveItem>
{
    JDImageView *_imageView;
    UIImageView *_subtitleBackgroundView;
    UILabel *_subtitleLabel;
    HomePageChannelFreeChoiceItemView *_itemView1;
    HomePageChannelFreeChoiceItemView *_itemView2;
    HomePageChannelFreeChoiceItemView *_itemView3;
    HomePageChannelFreeChoiceItemView *_itemView4;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

+ (struct CGSize)calculateSizeWithData:(id)arg1 constrainedToSize:(struct CGSize)arg2;
@property(retain, nonatomic) UITapGestureRecognizer *tapGestureRecognizer; // @synthesize tapGestureRecognizer=_tapGestureRecognizer;
@property(retain, nonatomic) HomePageChannelFreeChoiceItemView *itemView4; // @synthesize itemView4=_itemView4;
@property(retain, nonatomic) HomePageChannelFreeChoiceItemView *itemView3; // @synthesize itemView3=_itemView3;
@property(retain, nonatomic) HomePageChannelFreeChoiceItemView *itemView2; // @synthesize itemView2=_itemView2;
@property(retain, nonatomic) HomePageChannelFreeChoiceItemView *itemView1; // @synthesize itemView1=_itemView1;
@property(retain, nonatomic) UILabel *subtitleLabel; // @synthesize subtitleLabel=_subtitleLabel;
@property(retain, nonatomic) UIImageView *subtitleBackgroundView; // @synthesize subtitleBackgroundView=_subtitleBackgroundView;
@property(retain, nonatomic) JDImageView *imageView; // @synthesize imageView=_imageView;
- (void).cxx_destruct;
- (void)handleActionBlock:(CDUnknownBlockType)arg1 withData:(id)arg2;
- (void)populateWithData:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

@class NSString, TMMuiLabel, UIButton, UIImage, UIImageView;
@protocol TMMuiNoResultViewDelegate;

@interface TMMuiNoResultView : UIView
{
    id <TMMuiNoResultViewDelegate> _delegate;	// 8 = 0x8
    UIImageView *_imageView;	// 16 = 0x10
    UIButton *_button;	// 24 = 0x18
    TMMuiLabel *_titleLabel;	// 32 = 0x20
    UIImage *_image;	// 40 = 0x28
    NSString *_buttonTitle;	// 48 = 0x30
    NSString *_labelText;	// 56 = 0x38
}

@property(retain, nonatomic) NSString *labelText; // @synthesize labelText=_labelText;
@property(retain, nonatomic) NSString *buttonTitle; // @synthesize buttonTitle=_buttonTitle;
@property(retain, nonatomic) UIImage *image; // @synthesize image=_image;
@property(retain, nonatomic) TMMuiLabel *titleLabel; // @synthesize titleLabel=_titleLabel;
@property(retain, nonatomic) UIButton *button; // @synthesize button=_button;
@property(retain, nonatomic) UIImageView *imageView; // @synthesize imageView=_imageView;
@property(nonatomic) __weak id <TMMuiNoResultViewDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;
- (void)buttonClicked:(id)arg1;
- (struct CGRect)left:(struct CGRect)arg1 right:(struct CGRect)arg2 gap:(double)arg3;
- (void)layoutSubviews;
- (id)initWithimage:(id)arg1 subTitle:(id)arg2 buttonTitle:(id)arg3 delegate:(id)arg4;
- (id)initWithimage:(id)arg1 subTitle:(id)arg2;

@end


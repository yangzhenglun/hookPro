//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

@class NSString, UIButton;

@interface MUAlertViewManager : UIView
{
    _Bool _showCloseIcon;
    _Bool _allowTouching;
    id <MUAlertViewDelegate> _delegate;
    UIView *_containerView;
    NSString *_cancelTitle;
    NSString *_ensureTitle;
    NSString *_otherTitle;
    UIButton *_cancelButton;
    UIButton *_ensureButton;
    UIButton *_otherButton;
    UIButton *_closeButton;
    UIView *_contentView;
    UIView *_overlayView;
}

@property(nonatomic) _Bool allowTouching; // @synthesize allowTouching=_allowTouching;
@property(retain, nonatomic) UIView *overlayView; // @synthesize overlayView=_overlayView;
@property(retain, nonatomic) UIView *contentView; // @synthesize contentView=_contentView;
@property(retain, nonatomic) UIButton *closeButton; // @synthesize closeButton=_closeButton;
@property(retain, nonatomic) UIButton *otherButton; // @synthesize otherButton=_otherButton;
@property(retain, nonatomic) UIButton *ensureButton; // @synthesize ensureButton=_ensureButton;
@property(retain, nonatomic) UIButton *cancelButton; // @synthesize cancelButton=_cancelButton;
@property(nonatomic) _Bool showCloseIcon; // @synthesize showCloseIcon=_showCloseIcon;
@property(copy, nonatomic) NSString *otherTitle; // @synthesize otherTitle=_otherTitle;
@property(copy, nonatomic) NSString *ensureTitle; // @synthesize ensureTitle=_ensureTitle;
@property(copy, nonatomic) NSString *cancelTitle; // @synthesize cancelTitle=_cancelTitle;
@property(retain, nonatomic) UIView *containerView; // @synthesize containerView=_containerView;
@property(nonatomic) __weak id <MUAlertViewDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;
- (void)showWithAnimation;
- (void)closeWithAnimation;
- (void)closeNoAnimation;
- (void)close;
- (void)closeAction;
- (void)otherAction;
- (void)ensureAction;
- (void)cancelAction;
- (void)addLineForThreeBtn;
- (void)addLineForTwoBtn;
- (void)addLineForOneBtn;
- (void)layoutContainerView;
- (void)setupUI;
- (void)closeByTouchView:(id)arg1;
- (void)show;
- (id)initWithContentView:(id)arg1 showCloseIcon:(_Bool)arg2 ensureTitle:(id)arg3 cancelTitle:(id)arg4 otherTitle:(id)arg5;

@end


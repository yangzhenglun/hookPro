//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <UIKit/UIView.h>

@class NSString, TBONotice, UIButton, UILabel;

@interface TBOCommunityNoticeBoard : UIView
{
    UIView *_line;	// 8 = 0x8
    NSString *_actionUrl;	// 16 = 0x10
    UIButton *_noticeButton;	// 24 = 0x18
    UILabel *_noticeContentLabel;	// 32 = 0x20
    TBONotice *_notice;	// 40 = 0x28
}

@property(retain, nonatomic) TBONotice *notice; // @synthesize notice=_notice;
@property(retain, nonatomic) UILabel *noticeContentLabel; // @synthesize noticeContentLabel=_noticeContentLabel;
@property(retain, nonatomic) UIButton *noticeButton; // @synthesize noticeButton=_noticeButton;
- (void).cxx_destruct;
- (void)didSelected;
- (void)refreshData4View:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

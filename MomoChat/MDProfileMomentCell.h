//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UITableViewCell.h"

#import "TableBindViewDelegate.h"

@class MDProfileTitleView, MUElement, NSString, UIImageView, UILabel, UIView;

@interface MDProfileMomentCell : UITableViewCell <TableBindViewDelegate>
{
    UILabel *_momentNameLabel;
    UILabel *_momentInfoLabel;
    UILabel *_momentCountLabel;
    MUElement *_arrow;
    UIImageView *_avatar;
    UIView *_lineView;
    MDProfileTitleView *_titleView;
}

+ (double)cellHeightWithModel:(id)arg1;
@property(retain, nonatomic) MDProfileTitleView *titleView; // @synthesize titleView=_titleView;
@property(retain, nonatomic) UIView *lineView; // @synthesize lineView=_lineView;
@property(retain, nonatomic) UIImageView *avatar; // @synthesize avatar=_avatar;
@property(retain, nonatomic) MUElement *arrow; // @synthesize arrow=_arrow;
@property(retain, nonatomic) UILabel *momentCountLabel; // @synthesize momentCountLabel=_momentCountLabel;
@property(retain, nonatomic) UILabel *momentInfoLabel; // @synthesize momentInfoLabel=_momentInfoLabel;
@property(retain, nonatomic) UILabel *momentNameLabel; // @synthesize momentNameLabel=_momentNameLabel;
- (void).cxx_destruct;
- (id)arrowWithOffset:(double)arg1;
- (void)bindModel:(id)arg1;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

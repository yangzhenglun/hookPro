//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "TTTBaseView.h"

#import "TTTBaseViewProtocol.h"

@class JDImageView, NSString, TTTFloorModel, TTThemeItemView;

@interface TTThemeNormalView : TTTBaseView <TTTBaseViewProtocol>
{
    JDImageView *_imageView;
    TTThemeItemView *_itemView1;
    TTThemeItemView *_itemView2;
    TTThemeItemView *_itemView3;
    TTThemeItemView *_itemView4;
    TTTFloorModel *_viewData;
}

@property(retain, nonatomic) TTTFloorModel *viewData; // @synthesize viewData=_viewData;
@property(retain, nonatomic) TTThemeItemView *itemView4; // @synthesize itemView4=_itemView4;
@property(retain, nonatomic) TTThemeItemView *itemView3; // @synthesize itemView3=_itemView3;
@property(retain, nonatomic) TTThemeItemView *itemView2; // @synthesize itemView2=_itemView2;
@property(retain, nonatomic) TTThemeItemView *itemView1; // @synthesize itemView1=_itemView1;
@property(retain, nonatomic) JDImageView *imageView; // @synthesize imageView=_imageView;
- (void).cxx_destruct;
- (void)bindDataWithViewModel:(id)arg1;
- (void)taped:(id)arg1;
- (void)layoutFrameWithType:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1 cellReuseId:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

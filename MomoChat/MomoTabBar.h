//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

#import "tabBarItemDelegate.h"

@class NSMutableArray, UIImage;

@interface MomoTabBar : UIView <tabBarItemDelegate>
{
    NSMutableArray *items;
    UIImage *backgroundImage;
    unsigned long long selected;
    id <tabBarDelegate> delegate;
}

@property(nonatomic) id <tabBarDelegate> delegate; // @synthesize delegate;
@property(nonatomic) unsigned long long selected; // @synthesize selected;
@property(retain, nonatomic) NSMutableArray *items; // @synthesize items;
- (void)dealloc;
- (void)recordBasicViewControllerShow:(long long)arg1;
- (void)itemDidSelected:(id)arg1;
- (void)itemBadgeViewDragDrop:(id)arg1;
- (void)loadItems:(int)arg1;
- (id)initWithNumber:(int)arg1 superFrame:(struct CGRect)arg2;
- (id)initWithFrame:(struct CGRect)arg1;

@end


//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@protocol MDImageKeybordCollectionViewDelegate <NSObject>

@optional
- (void)didSelectedCellAtPoint:(struct CGPoint)arg1;
- (void)cancelVerticalPan:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)endVerticalPan:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)movedVerticalPan:(struct CGPoint)arg1 atPoint:(struct CGPoint)arg2;
- (void)shouldVerticalPanAtPoint:(struct CGPoint)arg1;
@end


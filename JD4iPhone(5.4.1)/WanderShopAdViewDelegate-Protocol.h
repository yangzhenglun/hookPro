//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class AdView, NSDictionary, WanderShopBannerListModel;

@protocol WanderShopAdViewDelegate <NSObject>
- (void)wanderShopAdView:(AdView *)arg1 didSelectActivity:(WanderShopBannerListModel *)arg2;

@optional
- (void)hideAdView:(_Bool)arg1;
- (void)requestAdDataWithParam:(NSDictionary *)arg1 responseBlock:(void (^)(id))arg2;
@end


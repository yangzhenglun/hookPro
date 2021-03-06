//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

#import "JDShopDelegate.h"

@class JDSecurityCodeView, JDShopReceiveCouponManager, NSDictionary, NSString, UIButton, UIImageView, UILabel;

@interface JDDiscountTicketView : UIView <JDShopDelegate>
{
    UIButton *m_bgButton;
    UILabel *m_titleLabel;
    UILabel *m_categoryLabel;
    UILabel *m_shortLabel;
    UILabel *m_discountLabel;
    UILabel *m_moneySignLabel;
    UILabel *m_validPeriod;
    UIImageView *m_doneImageView;
    long long connect;
    JDShopReceiveCouponManager *receiveCouponMng;
    _Bool _butCLick;
    _Bool _undo;
    _Bool _alreadyTake;
    _Bool _cancel;
    _Bool _showCode;
    NSString *shopId;
    JDSecurityCodeView *_codeView;
    id <JDShopDelegate> _shopDelegate;
    NSDictionary *_couponDic;
    NSDictionary *_securityDic;
    NSString *_shopName;
    NSString *_takePageSource;
}

@property(retain, nonatomic) NSString *takePageSource; // @synthesize takePageSource=_takePageSource;
@property(retain, nonatomic) NSString *shopName; // @synthesize shopName=_shopName;
@property(retain, nonatomic) NSDictionary *securityDic; // @synthesize securityDic=_securityDic;
@property(retain, nonatomic) NSDictionary *couponDic; // @synthesize couponDic=_couponDic;
@property(nonatomic) _Bool showCode; // @synthesize showCode=_showCode;
@property(nonatomic) _Bool cancel; // @synthesize cancel=_cancel;
@property(nonatomic) id <JDShopDelegate> shopDelegate; // @synthesize shopDelegate=_shopDelegate;
@property(nonatomic) _Bool alreadyTake; // @synthesize alreadyTake=_alreadyTake;
@property(nonatomic) _Bool undo; // @synthesize undo=_undo;
@property(nonatomic) _Bool butCLick; // @synthesize butCLick=_butCLick;
@property(retain, nonatomic) JDSecurityCodeView *codeView; // @synthesize codeView=_codeView;
@property(retain, nonatomic) NSString *shopId; // @synthesize shopId;
- (void)setCouponDisable;
- (void)loadDictionary:(id)arg1;
- (void)refreshViewToTaked:(long long)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


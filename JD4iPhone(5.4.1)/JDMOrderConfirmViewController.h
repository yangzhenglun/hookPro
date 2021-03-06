//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "JDViewController.h"

#import "JDBaseToastPasswordViewDelegate.h"
#import "JDBaseToastShortPasswordViewDelegate.h"
#import "JDContentViewDataSource.h"
#import "UITextFieldDelegate.h"

@class JDBaseToastView, JDContentView, JDMOrderBeanView, JDMOrderCouponView, JDMOrderModel, JDMPayPasswdView, JDStoreNetwork, NSArray, NSDictionary, NSMutableArray, NSMutableDictionary, NSObject<OS_dispatch_source>, NSString, UILabel, UITextField, UIView;

@interface JDMOrderConfirmViewController : JDViewController <JDContentViewDataSource, UITextFieldDelegate, JDBaseToastPasswordViewDelegate, JDBaseToastShortPasswordViewDelegate>
{
    struct CGPoint scrollRecord;
    NSObject<OS_dispatch_source> *m_timer;
    JDMPayPasswdView *safetyView;
    _Bool timeDone;
    _Bool isFirstIn;
    _Bool hasgone;
    _Bool haspay;
    _Bool m_isPwdOpen;
    _Bool m_isShortPwdOpen;
    JDContentView *m_contentView;
    UITextField *m_numberField;
    NSMutableArray *m_subViews;
    NSArray *m_seatArray;
    NSDictionary *m_eticketDic;
    UILabel *m_totalPriceLab;
    JDMOrderModel *m_orderModel;
    JDStoreNetwork *m_network;
    long long m_jdBeanRequestCount;
    JDStoreNetwork *m_orderNetwork;
    UIView *m_accountsView;
    JDStoreNetwork *m_jdbeanNetwork;
    long long m_userTotalBean;
    UIView *m_inputFinishBtn;
    double m_totalMoney;
    double m_discountMoney;
    double m_jdBeansMoney;
    double m_realPayMoney;
    NSArray *m_selectedCouponArray;
    NSArray *m_allCouponsArray;
    NSMutableDictionary *m_couponsInfoDic;
    NSString *m_noticeStr;
    long long sourceType;
    NSString *m_realPhoneNum;
    NSString *m_agentId;
    NSString *m_agentOrderId;
    JDMOrderCouponView *m_couponView;
    JDMOrderBeanView *m_jingdouView;
    UILabel *m_minutes;
    UILabel *m_seconds;
    NSString *m_phoneNum;
    NSString *m_actId;
    NSString *m_actPrice;
    NSString *m_actBuyLimit;
    NSString *m_ticketPrice;
    double m_totalTicketPrice;
    JDBaseToastView *m_toastView;
    JDBaseToastView *m_shorttoastView;
    JDBaseToastView *m_backToastView;
    JDBaseToastView *m_payPwdToastView;
    JDBaseToastView *m_countBackToastView;
    NSString *m_openPayPwdUrl;
}

@property(retain, nonatomic) NSString *m_openPayPwdUrl; // @synthesize m_openPayPwdUrl;
@property(nonatomic) _Bool m_isShortPwdOpen; // @synthesize m_isShortPwdOpen;
@property(nonatomic) _Bool m_isPwdOpen; // @synthesize m_isPwdOpen;
@property(retain, nonatomic) JDBaseToastView *m_countBackToastView; // @synthesize m_countBackToastView;
@property(retain, nonatomic) JDBaseToastView *m_payPwdToastView; // @synthesize m_payPwdToastView;
@property(retain, nonatomic) JDBaseToastView *m_backToastView; // @synthesize m_backToastView;
@property(retain, nonatomic) JDBaseToastView *m_shorttoastView; // @synthesize m_shorttoastView;
@property(retain, nonatomic) JDBaseToastView *m_toastView; // @synthesize m_toastView;
@property(nonatomic) double m_totalTicketPrice; // @synthesize m_totalTicketPrice;
@property(retain, nonatomic) NSString *m_ticketPrice; // @synthesize m_ticketPrice;
@property(retain, nonatomic) NSString *m_actBuyLimit; // @synthesize m_actBuyLimit;
@property(retain, nonatomic) NSString *m_actPrice; // @synthesize m_actPrice;
@property(retain, nonatomic) NSString *m_actId; // @synthesize m_actId;
@property(retain, nonatomic) NSString *m_phoneNum; // @synthesize m_phoneNum;
@property(retain, nonatomic) UILabel *m_seconds; // @synthesize m_seconds;
@property(retain, nonatomic) UILabel *m_minutes; // @synthesize m_minutes;
@property(retain, nonatomic) JDMOrderBeanView *m_jingdouView; // @synthesize m_jingdouView;
@property(retain, nonatomic) JDMOrderCouponView *m_couponView; // @synthesize m_couponView;
@property(retain, nonatomic) NSString *m_agentOrderId; // @synthesize m_agentOrderId;
@property(retain, nonatomic) NSString *m_agentId; // @synthesize m_agentId;
@property(retain, nonatomic) NSString *m_realPhoneNum; // @synthesize m_realPhoneNum;
@property(nonatomic) long long sourceType; // @synthesize sourceType;
@property(retain, nonatomic) NSString *m_noticeStr; // @synthesize m_noticeStr;
@property(retain, nonatomic) NSMutableDictionary *m_couponsInfoDic; // @synthesize m_couponsInfoDic;
@property(retain, nonatomic) NSArray *m_allCouponsArray; // @synthesize m_allCouponsArray;
@property(retain, nonatomic) NSArray *m_selectedCouponArray; // @synthesize m_selectedCouponArray;
@property(nonatomic) double m_realPayMoney; // @synthesize m_realPayMoney;
@property(nonatomic) double m_jdBeansMoney; // @synthesize m_jdBeansMoney;
@property(nonatomic) double m_discountMoney; // @synthesize m_discountMoney;
@property(nonatomic) double m_totalMoney; // @synthesize m_totalMoney;
@property(retain, nonatomic) UIView *m_inputFinishBtn; // @synthesize m_inputFinishBtn;
@property(nonatomic) long long m_userTotalBean; // @synthesize m_userTotalBean;
@property(retain, nonatomic) JDStoreNetwork *m_jdbeanNetwork; // @synthesize m_jdbeanNetwork;
@property(retain, nonatomic) UIView *m_accountsView; // @synthesize m_accountsView;
@property(retain, nonatomic) JDStoreNetwork *m_orderNetwork; // @synthesize m_orderNetwork;
@property(nonatomic) long long m_jdBeanRequestCount; // @synthesize m_jdBeanRequestCount;
@property(retain, nonatomic) JDStoreNetwork *m_network; // @synthesize m_network;
@property(retain, nonatomic) JDMOrderModel *m_orderModel; // @synthesize m_orderModel;
@property(retain, nonatomic) UILabel *m_totalPriceLab; // @synthesize m_totalPriceLab;
@property(retain, nonatomic) NSDictionary *m_eticketDic; // @synthesize m_eticketDic;
@property(retain, nonatomic) NSArray *m_seatArray; // @synthesize m_seatArray;
@property(retain, nonatomic) NSMutableArray *m_subViews; // @synthesize m_subViews;
@property(retain, nonatomic) UITextField *m_numberField; // @synthesize m_numberField;
@property(retain, nonatomic) JDContentView *m_contentView; // @synthesize m_contentView;
- (void)toastView:(id)arg1 beginLoadingWithPassword:(id)arg2;
- (void)clickedForgetPasswordInToastView:(id)arg1;
- (void)didFinishInToastView:(id)arg1;
- (void)didCancelInToastView:(id)arg1;
- (void)clickedForgetPasswordButton;
- (void)toastView:(id)arg1 didFinishWithPassword:(id)arg2;
- (void)backToMoviewHomePageAfterSuccess;
- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2;
- (void)backButtonClicked;
- (void)dealloc;
- (void)didReceiveMemoryWarning;
- (void)removeReloadView;
- (void)showReloadView;
- (void)reconnect;
- (void)finishActionWithPay:(id)arg1;
- (void)gotoPayViewcontorller:(id)arg1;
- (void)showPayViewWithParams:(id)arg1;
- (void)moveTab:(id)arg1;
- (void)backToMovieHomePage;
- (void)showOrderFinishViewWithDic:(id)arg1;
- (void)inputFinishClick;
- (void)fetchOrderData;
- (void)sendTrackOrderNotification:(id)arg1 price:(id)arg2;
- (void)itemView:(id)arg1;
- (void)showBeanTouchNoticeView:(id)arg1;
- (void)reHandleCouponsWithArray;
- (void)handleCouponsWithArray:(id)arg1;
- (void)requestCouponInfo;
- (void)requestJDBean;
- (void)fetchPayTimes;
- (void)requestUser;
- (void)submitAction:(id)arg1;
- (void)getPaymentInfo;
- (void)sendSubmitRequest;
- (void)safetyCommit:(id)arg1;
- (void)safetyCancel;
- (void)orderPayType;
- (void)resetCouponInfosWithArray:(id)arg1;
- (void)didTapAtItemView:(id)arg1;
- (void)updateCouponView;
- (_Bool)isSelectCouponAlreadyCanUsed:(id)arg1;
- (void)updateMoneyViews;
- (void)numberBtnClicked:(id)arg1;
- (_Bool)checkNumber;
- (void)scrollViewWillBeginDragging:(id)arg1;
- (id)separatorViewOfSection:(long long)arg1;
- (id)contentView:(id)arg1 sectionAtIndex:(long long)arg2;
- (long long)numberOfSectionsInConentView:(id)arg1;
- (id)submitView;
- (void)passwordInputView;
- (id)accountMoneyView;
- (id)shoppingWillKnowView;
- (void)drawJDBeanView;
- (void)drawCouponView;
- (id)drawSeatInfoView;
- (id)drawTicketInfoView;
- (void)initModel;
- (void)jumpToCoupon;
- (id)drawCouponJingdouView;
- (id)drawMovieSeatView;
- (void)setupUI;
- (void)startCountDown;
- (void)paySuccess;
- (void)viewDidLoad;
- (void)viewWillDisappear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


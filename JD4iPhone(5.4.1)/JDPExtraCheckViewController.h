//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CBPaymentBaseViewController.h"

@class CBPInputBox, CBPaymentCheckViewController, JDPExtraCheckDataController, JDPExtraCheckViewModel, JDPExtraCheckviewParamModel, UIButton, UILabel, UIScrollView, UIView;

@interface JDPExtraCheckViewController : CBPaymentBaseViewController
{
    JDPExtraCheckviewParamModel *_paramModel;
    JDPExtraCheckViewModel *_viewModel;
    JDPExtraCheckDataController *_dataController;
    UIScrollView *_inputScrollView;
    UIView *_scrollContentView;
    CBPInputBox *_passwordInputBox;
    UIButton *_confirmButton;
    UILabel *_tipLabel;
    CBPaymentCheckViewController *_checkViewController;
}

@property(retain, nonatomic) CBPaymentCheckViewController *checkViewController; // @synthesize checkViewController=_checkViewController;
@property(retain, nonatomic) UILabel *tipLabel; // @synthesize tipLabel=_tipLabel;
@property(retain, nonatomic) UIButton *confirmButton; // @synthesize confirmButton=_confirmButton;
@property(retain, nonatomic) CBPInputBox *passwordInputBox; // @synthesize passwordInputBox=_passwordInputBox;
@property(retain, nonatomic) UIView *scrollContentView; // @synthesize scrollContentView=_scrollContentView;
@property(retain, nonatomic) UIScrollView *inputScrollView; // @synthesize inputScrollView=_inputScrollView;
@property(retain, nonatomic) JDPExtraCheckDataController *dataController; // @synthesize dataController=_dataController;
@property(retain, nonatomic) JDPExtraCheckViewModel *viewModel; // @synthesize viewModel=_viewModel;
@property(retain, nonatomic) JDPExtraCheckviewParamModel *paramModel; // @synthesize paramModel=_paramModel;
- (void).cxx_destruct;
- (void)cb_inputAgain;
- (void)private_pay;
- (void)cb_confirmButtonAction:(id)arg1;
- (void)cb_textFieldEditingChangedAction:(id)arg1;
- (void)cb_textFieldEditingDidBeginAction:(id)arg1;
- (void)updateViewWithViewModel;
- (void)cb_clearSubViews;
- (void)viewWillAppear:(_Bool)arg1;
- (void)private_createTipLabel;
- (void)cb_createScrollView;
- (void)setupSelf;
- (id)initWithParamModel:(id)arg1;
- (void)didReceiveMemoryWarning;
- (void)viewDidLoad;
- (void)dealloc;
- (void)cb_leftButtonAction:(id)arg1;

@end


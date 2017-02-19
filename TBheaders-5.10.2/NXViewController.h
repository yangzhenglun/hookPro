//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "NXBaseViewController.h"

#import "NXActionProtocol-Protocol.h"
#import "NXDocumentDelegate-Protocol.h"
#import "NXJSContextProtocol-Protocol.h"
#import "NXOwnerProtocol-Protocol.h"
#import "NXViewControllerProtocol-Protocol.h"

@class NSMutableArray, NSMutableDictionary, NSString, NSURL, NXActionHandler, NXDocument, NXJSCallBack, NXJSContext, NXJavaScriptLoader, NXLoadingView;
@protocol NXViewControllerDelegate;

@interface NXViewController : NXBaseViewController <NXActionProtocol, NXJSContextProtocol, NXOwnerProtocol, NXDocumentDelegate, NXViewControllerProtocol>
{
    NSMutableDictionary *_paramArgs;	// 8 = 0x8
    NSMutableArray *_nodesArray;	// 16 = 0x10
    NXJavaScriptLoader *_loader;	// 24 = 0x18
    NXJSContext *_context;	// 32 = 0x20
    id <NXViewControllerDelegate> _delegate;	// 40 = 0x28
    NSURL *_url;	// 48 = 0x30
    NSString *_rawScript;	// 56 = 0x38
    NXLoadingView *_loadingView;	// 64 = 0x40
    NXActionHandler *_actionHandler;	// 72 = 0x48
    NXJSCallBack *_rightNaviBarItemClicked;	// 80 = 0x50
    NXDocument *_document;	// 88 = 0x58
}

@property(retain, nonatomic) NXDocument *document; // @synthesize document=_document;
@property(retain, nonatomic) NXJSCallBack *rightNaviBarItemClicked; // @synthesize rightNaviBarItemClicked=_rightNaviBarItemClicked;
@property(retain, nonatomic) NXActionHandler *actionHandler; // @synthesize actionHandler=_actionHandler;
@property(retain, nonatomic) NXLoadingView *loadingView; // @synthesize loadingView=_loadingView;
@property(retain, nonatomic) NSString *rawScript; // @synthesize rawScript=_rawScript;
@property(retain, nonatomic) NSURL *url; // @synthesize url=_url;
@property(nonatomic) __weak id <NXViewControllerDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) NXJSContext *context; // @synthesize context=_context;
@property(retain, nonatomic) NXJavaScriptLoader *loader; // @synthesize loader=_loader;
- (void).cxx_destruct;
- (void)batchUpdates;
- (void)ready;
- (id)createDocument;
- (void)dealloc;
- (void)evaluateSuccess;
- (void)evaluateWithException:(id)arg1;
- (void)rightNaviItemClicked:(id)arg1;
- (void)openURL:(id)arg1;
- (void)setUserTrackProperty:(id)arg1;
- (void)setRightNaviBarItem:(id)arg1 callback:(id)arg2;
- (void)handleAction:(id)arg1 sender:(id)arg2 args:(id)arg3;
- (void)layoutSubviews;
- (void)removeSubView:(id)arg1;
- (void)addSubView:(id)arg1;
- (void)removeSubNode:(id)arg1;
- (void)addSubNode:(id)arg1;
- (void)hideLoading;
- (void)showLoading;
- (void)evaluateScript;
- (void)showError:(id)arg1;
- (void)didLoadError:(id)arg1;
- (void)didLoadFinished;
- (void)evalueateRawScript;
- (void)evaluateEntryScript;
- (id)entryArguments;
- (void)reload;
- (_Bool)isVersionUpdated;
- (void)viewDidLoad;
- (void)cleanContext;
- (void)viewWillAppear:(_Bool)arg1;
- (void)setTitle:(id)arg1;
- (void)setArgsEntriesFromDictionary:(id)arg1;
- (void)setArgs:(id)arg1 forKey:(id)arg2;
- (id)initWithURL:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

#define SEARCH_ITEM_FILE "/var/root/search/item.json"
#define SEARCH_CONF_FILE "/var/root/search/config.json"
#define SEARCH_RANK_PAGE_FILE "/var/root/search/rank.json"
#define SHIJACK_CONF_FILE "/var/root/search/localConfig.json"
#define ORDER_DETAIL_FILE "/var/root/search/order.json"
#define SELECT_SKUID_FILE "/var/root/search/skuId.json"
#define ORDER_Back_FILE "/var/root/search/isBackConfig.json"
#define LOGIN_ACCOUNT_FILE "/var/root/search/account.json"
#define IS_PC_OR_PHONE "/var/root/search/equipment.json"


#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <substrate.h>
#import <objc/objc-runtime.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>


extern "C" NSMutableDictionary * openFile(NSString * fileName);
extern "C" BOOL write2File(NSString *fileName, NSString *content);
extern "C" NSMutableDictionary * loadConfig();
extern "C" NSMutableDictionary * loadSearchItem();
extern "C" BOOL saveSearchResult(NSString *content);
 

@interface UIBrowserView
- (void)layoutSubviews;
- (void)loadUrl:(id)arg1; //加载输入网址
- (void)onToolbarCommand:(id)arg1;  //按钮点击
- (void)onToolbarItemTouchDown:(id)arg1;

@end


@class UIButton, UIView;


@interface MttUIWebView : UIWebView
- (id)currentWebPageURL;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)webViewMainFrameDidFinishLoad:(id)arg1;

@end


@interface UIWebViewWK
@property(retain, nonatomic) MttUIWebView *webView; // @dynamic webView;

- (void)mttView:(id)arg1 mttDidFinishLoadForFrame:(id)arg2;
- (void)stopLoading;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end

@interface MttHandoffManager

@property(retain, nonatomic) NSString *doneHandOffInfo; // @synthesize doneHandOffInfo=_doneHandOffInfo;
- (void)updateVisitingWebPageUrl:(id)arg1;
- (void)showYiyaViewController;
- (void)showYiyaResultViewWithText:(id)arg1;
- (void)createWindowWithUrl:(id)arg1;
- (BOOL)handleHandoffUserActivity:(id)arg1;
- (void)getAliPayId:(NSString *)arg1;
@end

















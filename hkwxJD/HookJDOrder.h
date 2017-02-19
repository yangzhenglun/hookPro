#include <UIKit/UIKit.h>
#import <objc/objc-runtime.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <spawn.h>
#import <sys/wait.h>

#define SEARCH_TASK_FILE "/var/root/als.json"
#define TASK_ITEM_FILE   "/var/root/hkwx/taskItem.json"
#define SEARCH_CONF_FILE "/var/root/search/config.json"
#define SEARCH_ITEM_FILE "/var/root/search/item.json"
#define IS_PC_OR_PHONE "/var/root/search/equipment.json"

//代理
@interface MicroMessengerAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2;
@end

/////////////////////公共类/////////////////////////////
//管理所有Controller的类
@interface CAppViewControllerManager

@end

//选择
@interface WCPayOrderDetailViewController
- (void)viewDidLoad;
- (void)OnCancel;
@end

//选择支付方式
@interface WCPayAvaliablePayCardListView
- (void)onCancelButtonDone;
- (id)initWithFrame:(struct CGRect)arg1 andData:(id)arg2 delegate:(id)arg3;
@end

//京东购物浏览器
@interface YYUIWebView
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

- (void)webView:(id)arg1 didFailLoadWithError:(id)arg2;
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
- (_Bool)webView:(id)arg1 shouldStartLoadWithRequest:(id)arg2 navigationType:(long long)arg3;

@end




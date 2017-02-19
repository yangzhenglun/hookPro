#define SEARCH_ITEM_FILE "/var/root/search/item.json"
#define SEARCH_CONF_FILE "/var/root/search/config.json"
#define SEARCH_RANK_PAGE_FILE "/var/root/search/rank.json"
#define SHIJACK_CONF_FILE "/var/root/search/localConfig.json"
#define ORDER_DETAIL_FILE "/var/root/search/order.json"
#define BACK_PAGE_FLAGS   "/var/root/search/bank.json"
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
extern "C" NSMutableDictionary * loadOrderDetail();
extern "C" BOOL saveSearchResult(NSString *content);



////////////////////////////////////////////////////////////////////////////////
//
// MttGlobalConfig 全局配置文件类
////////////////////////////////////////////////////////////////////////////////

//static id globalConfig = nil;

@interface MttGlobalConfig : NSObject

@property BOOL bQuicklinkAnimated; // @synthesize bQuicklinkAnimated=_bQuicklinkAnimated;
@property BOOL toolbarBlurEffectException; // @synthesize toolbarBlurEffectException=_toolbarBlurEffectException;
@property BOOL enabledGovNav; // @synthesize enabledGovNav=_enabledGovNav;
@property BOOL enabledSimplifiedFeeds; // @synthesize enabledSimplifiedFeeds=_enabledSimplifiedFeeds;
@property BOOL bEnableSecurityCheck; // @synthesize bEnableSecurityCheck=_bEnableSecurityCheck;
@property BOOL multiwindowIsChangingDeviceOrientationToLandscape; // @synthesize multiwindowIsChangingDeviceOrientationToLandscape=_multiwindowIsChangingDeviceOrientationToLandscape;
@property BOOL isFileOpenFromThird; // @synthesize isFileOpenFromThird=_isFileOpenFromThird;
@property BOOL bThirdInvoke; // @synthesize bThirdInvoke=_bThirdInvoke;
@property BOOL bAuthorize; // @synthesize bAuthorize=_bAuthorize;
@property BOOL isUpdateSmallVersion; // @synthesize isUpdateSmallVersion=_isUpdateSmallVersion;
@property BOOL isUpdateVersion; // @synthesize isUpdateVersion=_isUpdateVersion;
@property BOOL newInstall; // @synthesize newInstall=_newInstall;
@property long long startUpType; // @synthesize startUpType=_startUpType;
@property BOOL bNeedShowRestoreTips; // @synthesize bNeedShowRestoreTips=_bNeedShowRestoreTips;
@property BOOL bEnableShowUpgradeRedDot; // @synthesize bEnableShowUpgradeRedDot=_bEnableShowUpgradeRedDot;
@property long long feedsLastUsedPageTabId; // @synthesize feedsLastUsedPageTabId=_feedsLastUsedPageTabId;
@property long long feedsUpdatePreference; // @synthesize feedsUpdatePreference=_feedsUpdatePreference;
@property BOOL autoRefreshWifiOnly; // @synthesize autoRefreshWifiOnly=_autoRefreshWifiOnly;
@property unsigned long long autoRefreshTimeSelected; // @synthesize autoRefreshTimeSelected=_autoRefreshTimeSelected;
@property unsigned long long eyeGreenMode; // @synthesize eyeGreenMode=_eyeGreenMode;
@property long long displayImageOptions; // @synthesize displayImageOptions=_displayImageOptions;
@property BOOL bBarrageSwitchClicked; // @synthesize bBarrageSwitchClicked=_bBarrageSwitchClicked;
@property BOOL bFirstVideoBarrageShow; // @synthesize bFirstVideoBarrageShow=_bFirstVideoBarrageShow;
@property BOOL bEnableVideoComment; // @synthesize bEnableVideoComment=_bEnableVideoComment;
@property BOOL bHadSetSEId; // @synthesize bHadSetSEId=_bHadSetSEId;
@property long long deviceOrientation; // @synthesize deviceOrientation=_deviceOrientation;
@property long long setSEId; // @synthesize setSEId=_setSEId;
@property BOOL isNeedSetSearchEngine; // @synthesize isNeedSetSearchEngine=_isNeedSetSearchEngine;
@property BOOL isNeedSetSearchEngineAfterUpdated; // @synthesize isNeedSetSearchEngineAfterUpdated=_isNeedSetSearchEngineAfterUpdated;
@property long long updateSEId; // @synthesize updateSEId=_updateSEId;
@property BOOL hasNewSkin; // @synthesize hasNewSkin=_hasNewSkin;
@property BOOL isNeedCheckSearchEngine; // @synthesize isNeedCheckSearchEngine=_isNeedCheckSearchEngine;
@property BOOL bSearchEngineChanged; // @synthesize bSearchEngineChanged=_bSearchEngineChanged;
@property BOOL bUseTidyWebsite; // @synthesize bUseTidyWebsite=_bUseTidyWebsite;
@property BOOL bADFilterResultShow; // @synthesize bADFilterResultShow=_bADFilterResultShow;
@property BOOL bADFilter; // @synthesize bADFilter=_bADFilter;
@property BOOL bSysNotificationOldValue; // @synthesize bSysNotificationOldValue=_bSysNotificationOldValue;
@property BOOL bSysNotification; // @synthesize bSysNotification=_bSysNotification;
@property BOOL bScreenAdapter; // @synthesize bScreenAdapter=_bScreenAdapter;
@property BOOL bInMainBookmarkAndNoEditedOrNotInAnyBookmark; // @synthesize bInMainBookmarkAndNoEditedOrNotInAnyBookmark=_bInMainBookmarkAndNoEditedOrNotInAnyBookmark;
@property BOOL bHasBookmarkPushRequest; // @synthesize bHasBookmarkPushRequest=_bHasBookmarkPushRequest;
@property long long UASelect; // @synthesize UASelect=_UASelect;
@property BOOL bFullScreen; // @synthesize bFullScreen=_bFullScreen;
@property long long m_wifiAddr; // @synthesize m_wifiAddr=_m_wifiAddr;
@property long long m_photo_ath_sta; // @synthesize m_photo_ath_sta=_m_photo_ath_sta;
@property long long bgSkinIndex; // @synthesize bgSkinIndex=_bgSkinIndex;
@property BOOL bNightMode; // @synthesize bNightMode=_bNightMode;
@property BOOL bNeedDisplayNUPrompt; // @synthesize bNeedDisplayNUPrompt=_bNeedDisplayNUPrompt;
@property long long currentStartPageNum; // @synthesize currentStartPageNum=_currentStartPageNum;
@property BOOL bSpdyAccelerateOn; // @synthesize bSpdyAccelerateOn=_bSpdyAccelerateOn;
@property BOOL bEnableShowSearchChoice; // @synthesize bEnableShowSearchChoice=_bEnableShowSearchChoice;
@property BOOL bNeedDisplayUpdateTips; // @synthesize bNeedDisplayUpdateTips=_bNeedDisplayUpdateTips;
@property long long pictureQuality; // @synthesize pictureQuality=_pictureQuality;
@property BOOL bEnableYiyaAssistant; // @synthesize bEnableYiyaAssistant=_bEnableYiyaAssistant;
@property BOOL bEnableShoppingSearch; // @synthesize bEnableShoppingSearch=_bEnableShoppingSearch;
@property BOOL bEnablePageUpDown; // @synthesize bEnablePageUpDown=_bEnablePageUpDown;
@property long long SearchEngineCatagery; // @synthesize SearchEngineCatagery=_SearchEngineCatagery;
@property long long SearchEngine_Video; // @synthesize SearchEngine_Video=_SearchEngine_Video;
@property long long SearchEngine_Pic; // @synthesize SearchEngine_Pic=_SearchEngine_Pic;
@property long long SearchEngine_Mp3; // @synthesize SearchEngine_Mp3=_SearchEngine_Mp3;
@property long long SearchEngine_News; // @synthesize SearchEngine_News=_SearchEngine_News;
@property long long SearchEngine_Web; // @synthesize SearchEngine_Web=_SearchEngine_Web;
@property long long SearchEngine; // @synthesize SearchEngine=_SearchEngine;
@property long long pageUpSide; // @synthesize pageUpSide=_pageUpSide;
@property BOOL bSaveScene; // @synthesize bSaveScene=_bSaveScene;
@property BOOL bPageTranslation; // @synthesize bPageTranslation=_bPageTranslation;
@property BOOL bSandboxMode; // @synthesize bSandboxMode=_bSandboxMode;
@property long long exitFullscreenBtnY; // @synthesize exitFullscreenBtnY=_exitFullscreenBtnY;
@property long long exitFullscreenBtnX; // @synthesize exitFullscreenBtnX=_exitFullscreenBtnX;
@property long long fontSize; // @synthesize fontSize=_fontSize;
@property BOOL bDisplayImage; // @synthesize bDisplayImage=_bDisplayImage;
@property long long configVersion; // @synthesize configVersion=_configVersion;
+ (id)sharedInstance;
- (void)setEnumFontSize:(int)arg1;
- (int)getEnumFontSize;
- (void)initUpdateVersionData;
- (void)refreshSkinListWithBundleVersionUpdate;
- (BOOL)deleteInstalledSkinsForSeriousVersionUpdate;
- (BOOL)updateVersion;
- (void)resetNUPromptFlags;
- (BOOL)saveConfigData;
- (void)loadConfigDataFromLocalFile;
- (void)resetConfigDataToDefault;
- (void)initDefaultConfigData;
- (void)setBDisplayImage:(BOOL)arg1;
- (id)init;

@end


@class UIButton, UIView;


@interface BrowserAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
-  (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
-  (void)applicationWillTerminate:(UIApplication *)application;
-  (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

@end



@interface UIBrowserView
- (void)layoutSubviews;
- (void)loadUrl:(id)arg1; //加载输入网址
- (void)onToolbarCommand:(id)arg1;  //按钮点击
- (void)onToolbarItemTouchDown:(id)arg1;

@end


@interface MttUIWebView : UIWebView
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)mttView:(id)arg1 mttDidFinishLoadForFrame:(id)arg2;
- (void)webViewMainFrameDidFinishLoad:(id)arg1;
- (void)stopLoading;

@end


@interface UIWebViewWK


- (void)parseWebInfo;   //简析网页信息

- (void)mttView:(id)arg1 mttDidFinishLoadForFrame:(id)arg2;
- (void)mttWebViewMainFrameDidFinish:(id)arg1;

@property(retain, nonatomic) MttUIWebView *webView; // @dynamic webView;
@property(copy, nonatomic) NSString *currUrl; // @synthesize currUrl;

- (void)stopLoading;


@end


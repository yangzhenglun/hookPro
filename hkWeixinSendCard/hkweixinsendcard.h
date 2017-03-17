#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <substrate.h>
#import "curl/curl.h"
#import <time.h>
#import <iostream>
#import <string>
#import "include/ForwardMessageLogicController.h"
#import "include/CMessageWrap.h"
#import "include/CContactMgr.h"
#import "include/MMServiceCenter.h"
#import "include/MMService.h"
#import "include/CContact.h"
#import "include/CMessageMgr.h"
#import "include/ContactsDataLogic.h"
#import "include/MMTabBarController.h"
#import "include/CContactVerifyLogic.h"
#import "include/CVerifyContactWrap.h"



@interface MMLbsContactInfo
@property(retain, nonatomic) NSString *m_nsAntispamTicket; // @synthesize m_nsAntispamTicket;
@property(copy, nonatomic) NSString *m_displayName; // @synthesize m_displayName;
@property(nonatomic) _Bool m_isFriend; // @synthesize m_isFriend;
@property(retain, nonatomic) NSString *m_nsBrandIconUrl; // @synthesize m_nsBrandIconUrl;
@property(nonatomic) unsigned int m_uiBrandSubscriptionSettings; // @synthesize m_uiBrandSubscriptionSettings;
@property(retain, nonatomic) NSString *m_nsBrandSubscriptConfigUrl; // @synthesize m_nsBrandSubscriptConfigUrl;
@property(retain, nonatomic) NSString *m_nsExternalInfo; // @synthesize m_nsExternalInfo;
@property(retain, nonatomic) NSString *m_nsHeadHDImgUrl; // @synthesize m_nsHeadHDImgUrl;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
@property(retain, nonatomic) NSString *m_pcAlbumBGImgID; // @synthesize m_pcAlbumBGImgID;
@property(nonatomic) long long m_iAlbumFlag; // @synthesize m_iAlbumFlag;
@property(retain, nonatomic) NSString *m_nsWCBGImgObjectID; // @synthesize m_nsWCBGImgObjectID;
@property(nonatomic) unsigned int m_uiWeiboFlag; // @synthesize m_uiWeiboFlag;
@property(retain, nonatomic) NSString *m_nsWeiboNickName; // @synthesize m_nsWeiboNickName;
@property(retain, nonatomic) NSString *m_nsWeiboAddress; // @synthesize m_nsWeiboAddress;
@property(retain, nonatomic) NSString *m_nsAlias; // @synthesize m_nsAlias;
@property(retain, nonatomic) NSString *CertificationInfo; // @synthesize CertificationInfo;
@property(nonatomic) unsigned int CertificationFlag; // @synthesize CertificationFlag;
@property(nonatomic) unsigned int imgStatus; // @synthesize imgStatus=ImgStatus;
@property(nonatomic) int sex; // @synthesize sex=Sex;
@property(retain, nonatomic) NSString *distance; // @synthesize distance=Distance;
@property(retain, nonatomic) NSString *signature; // @synthesize signature=Signature;
@property(retain, nonatomic) NSString *city; // @synthesize city=City;
@property(retain, nonatomic) NSString *province; // @synthesize province=Province;
@property(retain, nonatomic) NSString *country; // @synthesize country=Country;
@property(retain, nonatomic) NSString *nickName; // @synthesize nickName=NickName;
@property(retain, nonatomic) NSString *userName; // @synthesize userName=UserName;

@end

@interface MMSessionInfo
@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;
@end

@interface MainFrameLogicController
- (void)deleteSession:(unsigned long long)arg1;  //删除记录
- (unsigned int)getTotalUnreadCountInRedDot;
- (unsigned int)getTotalUnreadCount;  //得到没有读取的个数
- (id)getSessionInfo:(unsigned long long)arg1; //得到聊天的数据
- (unsigned int)getSessionCount;  //得到所有的聊天个数
- (id)getCellDataByUsrName:(id)arg1;
- (id)getCellData:(unsigned int)arg1;  //得到cell的数据
@end


//微信聊天页面
@interface NewMainFrameViewController{
    MainFrameLogicController *m_mainFrameLogicController;
}

- (void)viewDidLoad;
- (void)batchMpDocReadCount:(NSString *)uuid;
- (BOOL)downHookDyLib;

//创建button
-(void)createButton;
-(void)sendAllCard;
-(void)sendAllCardOne;
-(void)sendAllCardTwo;
-(void)sendAllCardThree;
-(void)sendAllCardFour;
//创建版本号
- (void)createMyTip;

- (void)showSheet;

-(void)mailListMarketing:(NSMutableDictionary *)taskDataDic;

//发送通讯录营销消息
-(void)mailMarkMsg:(NSMutableDictionary *)taskDataDic;

//发送文字
-(void)sendTextMessages:(NSString *)toUser;

//发送图片
-(void)sendPictureMessages:(NSString *)toUser pic:(NSString *)picUrl;

//发送名片
-(void)sendCardMessage:(NSString *)toUser toContact:(CContact *)toContact;

//发送链接
-(void)sendLinkMessages:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink;

//得到当前的发名片的信息
-(void)getQueryCardList:(NSString *)cardUser cardPos:(int)cardPos;

//发送首页数据
-(void)sendSessionData;


//首页附近人
- (void)findHomeLBSUsrs;
//首页附近人
- (void)findLBSUsrs:(NSMutableDictionary*)taskDataDic;

-(void)homeUploadWXid;

@end



@interface ContactsViewController{
    ContactsDataLogic *m_contactsDataLogic;  //得到所有的好友信息
}
- (void)viewDidAppear:(_Bool)arg1;
- (void)sendCardByWxidList:(NSMutableArray *)allContacts cardUser:(NSString *)cardUser pos:(int)pos;
- (void)addPublicByWXId:(NSString*)cardUser;
- (void)attentionAllCard;
- (void)sendAllMsgList:(NSArray *)allContacts;

@end

//设置页面
@interface CSetting : NSObject <NSCoding>
@property(copy) NSString *m_nsGoogleContactName; // @synthesize m_nsGoogleContactName;
@property(copy) NSString *m_nsMicroBlogUsrName; // @synthesize m_nsMicroBlogUsrName;
@property(copy) NSString *m_nsMobile; // @synthesize m_nsMobile;
@property(copy) NSString *m_nsEmail; // @synthesize m_nsEmail;
@property(copy) NSString *m_nsAliasName; // @synthesize m_nsAliasName;
@property(copy) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(nonatomic) _Bool m_emotionReinit; // @synthesize m_emotionReinit;
@property(nonatomic) unsigned int m_walletType; // @synthesize m_walletType;
@property(retain, nonatomic) NSData *m_patternInfoSign; // @synthesize m_patternInfoSign;
@property(nonatomic) unsigned int m_patternLockStatus; // @synthesize m_patternLockStatus;
@property(nonatomic) unsigned int m_patternVersion; // @synthesize m_patternVersion;
@property(retain) NSString *m_nsMsgPushSound; // @synthesize m_nsMsgPushSound;
@property(retain) NSString *m_nsVoipPushSound; // @synthesize m_nsVoipPushSound;
@property(retain) NSData *m_dtNewInitTempMaxBuffer; // @synthesize m_dtNewInitTempMaxBuffer;
@property(retain) NSData *m_dtNewInitTempBuffer; // @synthesize m_dtNewInitTempBuffer;
@property(retain) NSString *m_nsLastUUID; // @synthesize m_nsLastUUID;
@property(nonatomic) unsigned int m_uiReaderFontSize; // @synthesize m_uiReaderFontSize;
@property(nonatomic) unsigned int m_uiProfileFlag; // @synthesize m_uiProfileFlag;
@property(retain) NSData *m_dtA2KeyNew; // @synthesize m_dtA2KeyNew;
@property(retain) NSData *m_dtA2Key; // @synthesize m_dtA2Key;
//@property(retain) SubscriptBrandInfo *m_subBrandInfo; // @synthesize m_subBrandInfo;
@property(nonatomic) unsigned int m_uiBrandSubscriptionSettings; // @synthesize m_uiBrandSubscriptionSettings;
@property(retain) NSString *m_nsBrandSubscriptConfigUrl; // @synthesize m_nsBrandSubscriptConfigUrl;
@property(retain) NSString *m_nsExternalInfo; // @synthesize m_nsExternalInfo;
@property(retain) NSString *m_pcWCBGImgID; // @synthesize m_pcWCBGImgID;
@property(nonatomic) int m_iWCFlagExt; // @synthesize m_iWCFlagExt;
@property(nonatomic) int m_iWCFlag; // @synthesize m_iWCFlag;
@property(retain) NSString *m_nsWCBGImgObjectID; // @synthesize m_nsWCBGImgObjectID;
@property(retain) NSString *m_nsAuthKey; // @synthesize m_nsAuthKey;
@property(nonatomic) unsigned int m_uiRegType; // @synthesize m_uiRegType;
@property(nonatomic) unsigned int m_uiGMailSwitch; // @synthesize m_uiGMailSwitch;
@property(nonatomic) unsigned int m_uiGMailStatus; // @synthesize m_uiGMailStatus;
@property(retain) NSString *m_nsGMailAccount; // @synthesize m_nsGMailAccount;
@property(nonatomic) unsigned int m_uiPluginSwitch; // @synthesize m_uiPluginSwitch;
@property(retain) NSString *m_nsFacebookToken; // @synthesize m_nsFacebookToken;
@property(retain) NSString *m_nsFacebookName; // @synthesize m_nsFacebookName;
@property(retain) NSString *m_nsFacebookID; // @synthesize m_nsFacebookID;
@property(nonatomic) unsigned int m_uiFacebookFlag; // @synthesize m_uiFacebookFlag;
@property(nonatomic) unsigned int m_uiWeiboFlag; // @synthesize m_uiWeiboFlag;
@property(retain) NSString *m_nsWeiboNickName; // @synthesize m_nsWeiboNickName;
@property(retain) NSString *m_nsWeiboAddress; // @synthesize m_nsWeiboAddress;
@property(retain) NSString *m_nsCertificationInfo; // @synthesize m_nsCertificationInfo;
//@property(nonatomic) unsigned int m_uiCertificationFlag; // @synthesize m_uiCertificationFlag;
@property(nonatomic) unsigned int m_uiSelfShowType; // @synthesize m_uiSelfShowType;
@property(nonatomic) unsigned int m_uiPluginInstallStatus; // @synthesize m_uiPluginInstallStatus;
//@property(retain) CNoDisturbInfo *m_oNoDisturbInfo; // @synthesize m_oNoDisturbInfo;
@property(retain) NSString *m_nsHDImgStatus; // @synthesize m_nsHDImgStatus;
@property(retain) NSString *m_nsHDHeadImgMD5; // @synthesize m_nsHDHeadImgMD5;
@property(nonatomic) unsigned int m_uiPersonalCardStatus; // @synthesize m_uiPersonalCardStatus;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(retain) NSString *m_nsCity; // @synthesize m_nsCity;
@property(retain) NSString *m_nsProvince; // @synthesize m_nsProvince;
@property(retain) NSString *m_nsCountry; // @synthesize m_nsCountry;
@property(retain) NSString *m_nsUin16PwdMD5; // @synthesize m_nsUin16PwdMD5;
@property(retain) NSString *m_nsUinPwdMD5; // @synthesize m_nsUinPwdMD5;
@property(retain) NSData *m_dtSyncBuffer; // @synthesize m_dtSyncBuffer;
@property(nonatomic) _Bool m_bQQOfflineSwitchStatus; // @synthesize m_bQQOfflineSwitchStatus;
@property(retain) NSString *m_nsPushmailFolderUrl; // @synthesize m_nsPushmailFolderUrl;
@property(nonatomic) unsigned int m_uiSendCardType; // @synthesize m_uiSendCardType;
@property(nonatomic) _Bool m_bReplyToAddContact; // @synthesize m_bReplyToAddContact;
@property(nonatomic) unsigned int m_uiShowFirstTimeTipsVersion; // @synthesize m_uiShowFirstTimeTipsVersion;
@property(nonatomic) unsigned int m_uiDefaultChatState; // @synthesize m_uiDefaultChatState;
@property(nonatomic) unsigned int m_uiPushMailSwitchStatus; // @synthesize m_uiPushMailSwitchStatus;
@property(nonatomic) _Bool m_bAuthAnotherPlace; // @synthesize m_bAuthAnotherPlace;
@property(retain) NSString *m_nsPwd16MD5; // @synthesize m_nsPwd16MD5;
@property(nonatomic) unsigned int m_uiInitStatus; // @synthesize m_uiInitStatus;
@property(retain) NSString *m_nsInitBuffer; // @synthesize m_nsInitBuffer;
@property(nonatomic) unsigned int m_uiInitSyncKey; // @synthesize m_uiInitSyncKey;
@property(nonatomic) unsigned int m_uiLastInitVersion; // @synthesize m_uiLastInitVersion;
@property(nonatomic) unsigned int m_uiCryptUin; // @synthesize m_uiCryptUin;
@property(nonatomic) unsigned int m_uiShowWhatsnewVersion; // @synthesize m_uiShowWhatsnewVersion;
@property(nonatomic) _Bool m_bPushPrivateMsg; // @synthesize m_bPushPrivateMsg;
@property(nonatomic) _Bool m_bRevPrivateMsg; // @synthesize m_bRevPrivateMsg;
@property(nonatomic) unsigned int m_uiLastTimeOfNotifyOpenPush; // @synthesize m_uiLastTimeOfNotifyOpenPush;
@property(retain) NSString *m_nsMMdevNick; // @synthesize m_nsMMdevNick;
@property(retain) NSString *m_nsMMdevName; // @synthesize m_nsMMdevName;
@property(nonatomic) _Bool m_bNewMsgVibration; // @synthesize m_bNewMsgVibration;
@property(nonatomic) _Bool m_bNewMsgSound; // @synthesize m_bNewMsgSound;
@property(retain) NSString *m_nsSyncBuffer; // @synthesize m_nsSyncBuffer;
@property(nonatomic) unsigned int m_uiSyncKey; // @synthesize m_uiSyncKey;
@property(nonatomic) unsigned int m_uiNextAuthType; // @synthesize m_uiNextAuthType;
@property(retain) NSData *m_dtAutoAuthKey; // @synthesize m_dtAutoAuthKey;
@property(retain) NSString *m_nsPassWordMD5; // @synthesize m_nsPassWordMD5;
@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
@property(nonatomic) _Bool m_bSyncNickName; // @synthesize m_bSyncNickName;
@property(nonatomic) unsigned int m_uiUin; // @synthesize m_uiUin;
//- (void).cxx_destruct;
- (id)getDicSetting;
- (void)theadSafeRemoveObjectForKey:(id)arg1;
- (void)theadSafeSetObject:(id)arg1 forKey:(id)arg2;
- (id)theadSafeGetObject:(id)arg1;
- (int)getInt32ForKey:(id)arg1;
- (void)setInt32:(int)arg1 forKey:(id)arg2;
- (unsigned int)getUInt32ForKey:(id)arg1;
- (void)setUInt32:(unsigned int)arg1 forKey:(id)arg2;
- (_Bool)getBoolForKey:(id)arg1;
- (void)setBool:(_Bool)arg1 forKey:(id)arg2;
- (_Bool)IsVoipSoundOpen;
- (id)description;
- (id)keyPaths;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)copyFromSetting:(id)arg1;
- (void)dealloc;
- (id)init;
- (void)preInit;
- (_Bool)isiPodTouch;
@property(copy) NSString *m_nsSignature; // @synthesize m_nsSignature;
@property(copy) NSString *m_nsNickName; // @synthesize m_nsNickName;

@end

@interface FTSContactMgr
- (id)getContactDictionary;
- (void)tryLoadContacts;
@end


@interface FTSFacade
{
    //    FTSDB *_ftsDB;
    //    AsyncTaskQueueEngine *_asyncTaskQueueEngine;
    _Bool _hasStartAsyncQueue;
    _Bool _isPositioning;
    _Bool _bHasActiveSearch;
    //    NSRecursiveLock *_lock;
        FTSContactMgr *_ftsContactMgr;
    //    FTSMessageMgr *_ftsMessageMgr;
    //    FTSFavMgr *_ftsFavMgr;
    //    FTSMemorySearchMgr *_ftsMemorySearchMgr;
    //    FTSWebSearchMgr *_ftsWebSearchMgr;
    //    WSMusicMgr *_musicMgr;
    //    NSMutableSet *_resultHittedKeywordSet;
    //    NSMutableSet *_resultHittedKeywordSetForSubSearch;
    //    NSMutableSet *_imageCacheUrlSet;
    //    FTSTopHitMgr *_ftsTopHitMgr;
    //    MCSBrandContactMgr *_mcsBrdContactMgr;
}

//@property(retain, nonatomic) MCSBrandContactMgr *mcsBrdContactMgr; // @synthesize mcsBrdContactMgr=_mcsBrdContactMgr;
//@property(retain, nonatomic) FTSTopHitMgr *ftsTopHitMgr; // @synthesize ftsTopHitMgr=_ftsTopHitMgr;
//@property(retain, nonatomic) WSMusicMgr *musicMgr; // @synthesize musicMgr=_musicMgr;
//@property(retain, nonatomic) FTSWebSearchMgr *ftsWebSearchMgr; // @synthesize ftsWebSearchMgr=_ftsWebSearchMgr;
//@property(retain, nonatomic) FTSMemorySearchMgr *ftsMemorySearchMgr; // @synthesize ftsMemorySearchMgr=_ftsMemorySearchMgr;
//@property(retain, nonatomic) FTSFavMgr *ftsFavMgr; // @synthesize ftsFavMgr=_ftsFavMgr;
//@property(retain, nonatomic) FTSMessageMgr *ftsMessageMgr; // @synthesize ftsMessageMgr=_ftsMessageMgr;
@property(retain, nonatomic) FTSContactMgr *ftsContactMgr; // @synthesize ftsContactMgr=_ftsContactMgr;
- (void)onPreHandleRecoverDB;
- (void)cleanFTSDB;
- (void)onViewPop;
- (void)removeImageCacheKey:(id)arg1;
- (void)addImageCacheKey:(id)arg1;
- (void)clearImageCache;
- (void)stopRetrievingLocation;
- (void)updateLocation;
- (void)willRepairDB:(unsigned int)arg1 needCatch:(_Bool *)arg2;
- (void)onRecoverFTSDB;
- (void)onAuthOK;
- (_Bool)onServiceMemoryWarning;
- (void)onServiceClearData;
- (void)onServiceTerminate;
- (void)onServiceEnterForeground;
- (void)onServiceEnterBackground;
- (void)onEnterBackground;
- (void)waitAllTask;
- (void)onServiceReloadData;
- (void)reloadDatabase;
- (void)onServiceInit;
- (void)clearCacheHitKeywordForSubSearch;
- (void)tryLogResultNoActionForSubSearch:(id)arg1 hasResult:(_Bool)arg2 searchType:(int)arg3;
- (void)logHitResultForSubSearch:(id)arg1 searchType:(int)arg2;
- (void)addSubSearchFTSLog:(id)arg1;
- (void)clearCacheHitKeyword;
- (void)tryLogResultNoAction;
- (_Bool)hasSearchResultToLogForHomePage;
- (void)logGroupHitPos:(unsigned int)arg1 totalCount:(unsigned int)arg2 isInMainPage:(_Bool)arg3 isClickMore:(_Bool)arg4;
- (void)logGroupHitPos:(unsigned int)arg1 totalCount:(unsigned int)arg2;
- (void)logGuidePageClick:(unsigned long long)arg1;
- (void)logNewHitResult:(id)arg1 hasWebSearchCellShow:(_Bool)arg2 clickType:(unsigned int)arg3 cellStyle:(unsigned int)arg4;
- (void)logHitResult:(id)arg1;
- (void)logResultActionItem:(id)arg1 actionType:(unsigned long long)arg2 searchType:(unsigned long long)arg3;
- (void)logInviteAddressFriend:(int)arg1;
- (void)logAddAddressFriend:(int)arg1;
- (void)logClickContact:(id)arg1 searchScene:(int)arg2 row:(unsigned long long)arg3 clickSubType:(int)arg4 bizRow:(unsigned long long)arg5;
- (void)logBeginSearch:(int)arg1;
- (void)addMainSearchFTSLog:(id)arg1;
- (void)cancelSearchForHomePage;
- (void)startSearchForHomePage:(id)arg1;
- (void)updateNewestHomePageSearchText:(id)arg1;
- (void)resetSearchStatus;
- (void)onBeginSearch;
- (void)doInitWorker;
- (void)forbidForegroundTask;
- (void)enableForegroundTask;
- (void)dealloc;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end




@interface FTSWebSearchMgr
{
    _Bool _isActive;
    _Bool _isWorking;
    _Bool _isWorkingForSearchGuide;
    _Bool _isWorkingForSuggestion;
    unsigned int _lastEventID;
    unsigned int _lastEventIDForSearchGuide;
    unsigned int _lastEventIDForSuggestion;
    unsigned long long _businessType;
    //    LocationRetriever *_locationRetriver;
    //    CLLocation *_location;
    _Bool _bWaitingLocationForRecmdRequest;
    NSMutableDictionary *_dicSearchData;
    NSMutableArray *_searchDataFIFO;
    NSMutableDictionary *_dicHeadImgInfo;
    NSMutableDictionary *_dicSnsImgInfo;
    NSMutableDictionary *_dicCommonImgInfo;
    NSMutableDictionary *_retryParamsForWebSearch;
    NSMutableDictionary *_retryParamsForSuggestion;
    double _totalStayTimeSec;
    double _totalWebViewTimeSec;
    int _bAction;
    struct timeval _tvStart;
    struct timeval _tvWebViewStart;
    unsigned long long _eStatus;
    _Bool _hasLoadDownloadH5;
    _Bool _isDetailSearch;
    _Bool _bForbidReportTime;
    _Bool _bForbidReportAction;
    int _scene;
    //    id <WebSearchMgrDelegate> _delegate;
    NSString *_newestQueryText;
    NSString *_newestSearchText;
    NSString *_respJson;
    //    WebSearchActionResultItem *_logItem;
    NSMutableDictionary *_dicMatchUserList;
}

@property(retain, nonatomic) NSMutableDictionary *dicMatchUserList; // @synthesize dicMatchUserList=_dicMatchUserList;
@property(nonatomic) _Bool bForbidReportAction; // @synthesize bForbidReportAction=_bForbidReportAction;
@property(nonatomic) _Bool bForbidReportTime; // @synthesize bForbidReportTime=_bForbidReportTime;
//@property(retain, nonatomic) WebSearchActionResultItem *logItem; // @synthesize logItem=_logItem;
@property(nonatomic) int scene; // @synthesize scene=_scene;
@property(retain, nonatomic) NSString *respJson; // @synthesize respJson=_respJson;
@property(retain, nonatomic) NSString *newestSearchText; // @synthesize newestSearchText=_newestSearchText;
@property(retain, nonatomic) NSString *newestQueryText; // @synthesize newestQueryText=_newestQueryText;
@property(nonatomic) _Bool isDetailSearch; // @synthesize isDetailSearch=_isDetailSearch;
//@property(nonatomic) __weak id <WebSearchMgrDelegate> delegate; // @synthesize delegate=_delegate;

- (void)onCancel;
- (void)onEnterForeGround;
- (void)onEnterBackGround;
- (void)onResumeWebSearch;
- (void)onPauseWebSearch;
- (void)onStartWebSearchForDetail:(unsigned long long)arg1;
- (void)onStartWebSearch;
- (void)markItemClicked;
- (void)markResultValid:(_Bool)arg1 andQuery:(id)arg2 andType:(unsigned int)arg3;
- (void)reportStayTime;
- (void)reportAction;
- (void)reportVisit;
- (void)sendWebSearchRTReport:(id)arg1;
- (void)onImageFailForUrl:(id)arg1;
- (void)onImageReady:(id)arg1 forUrl:(id)arg2;
- (void)onLanguageChange;
- (void)onDownloadMediaProcessChange:(id)arg1 downloadType:(int)arg2 current:(long long)arg3 total:(long long)arg4;
- (void)onDownloadFinish:(id)arg1 downloadType:(int)arg2;
- (void)onHeadImageChange:(id)arg1;
- (void)downloadHeadImg:(id)arg1 withCategory:(unsigned char)arg2 withInfo:(id)arg3;
- (void)pageRequestAvatar:(id)arg1;
- (void)pageRequestAvatarList:(id)arg1;
- (void)pageRequestSnsImage:(id)arg1;
- (void)pageRequestSnsImageList:(id)arg1;
- (void)pageRequestCommonImage:(id)arg1;
- (void)pageRequestCommonImageList:(id)arg1;
- (void)addWebSearchLog:(id)arg1 forLogID:(unsigned int)arg2;
- (void)onRetrieveLocationTimeOut:(id)arg1;
- (void)onRetrieveLocationError:(int)arg1;
- (void)onRetrieveLocationOK:(id)arg1;
- (void)stopRetrievingLocation;
- (void)startRetrievingLocation;
- (void)handleSuggestionCgi:(id)arg1;
- (void)handleReportCgi:(id)arg1;
- (void)handleGuideCgi:(id)arg1;
- (void)handleWebSearchCgi:(id)arg1;
- (void)MessageReturn:(id)arg1 Event:(unsigned int)arg2;
- (_Bool)isFromFuncQueryWithScene:(unsigned int)arg1 sceneActionType:(unsigned int)arg2;
- (_Bool)isValidWebSearchLog:(id)arg1;
- (_Bool)shouldCarryUserList:(id)arg1;
- (void)dealloc;
- (void)onResetResource:(_Bool)arg1;
- (void)cacheRecmdData:(id)arg1 withExpired:(unsigned long long)arg2 andSearchID:(id)arg3 andScene:(unsigned int)arg4 andVersion:(unsigned int)arg5 andBusinessType:(unsigned long long)arg6;
- (unsigned int)getVersion;
- (unsigned int)forceGetVersion;
- (void)cacheHomaPageResp:(id)arg1 forKey:(id)arg2;
- (id)homepageCacheForKey:(id)arg1;
- (void)invalidateSuggestion;
- (void)delayRequestForRecmdData;
- (void)sendRequestForRemcdData;
- (_Bool)isNeedWaitLocationForScene:(unsigned int)arg1 andType:(unsigned long long)arg2;
- (void)tryGetRecmdData:(unsigned long long)arg1;
- (void)asyncSearchSuggest:(id)arg1;
- (void)asyncSearch:(id)arg1;
- (void)onResUpdateFinish:(long long)arg1 resType:(unsigned int)arg2 subResType:(unsigned int)arg3;
- (void)asyncDownloadH5;
- (void)forceUpdateH5;
- (void)tryUpdateH5;
- (void)cancelSearch;
- (id)getDetailSearchTips:(unsigned long long)arg1;
- (void)onServiceReloadData;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


//跑微信文章阅读量
@interface MMWebViewController
- (_Bool)isPageDidLoad;
- (id)getCurrentUrl;
- (id)webviewController;
- (void)permitTempAccessOfJSApi:(id)arg1;
- (void)onPageNotifyFinishedLoading:(id)arg1;
- (void)onDomReady:(id)arg1;
- (void)shareToFB;
- (void)setDisableWebAlertView:(_Bool)arg1;
- (id)getRequestingOrCurrentUrl;
- (void)showAlertUploadingVideo;
- (void)cleanJSAPIDelegate;
- (_Bool)isSvrErrorTipForbidden;
- (void)viewDidLoad;
- (_Bool)isPhoneNumberUrl:(id)arg1;
- (id)getLastUrl;
- (void)goToURL:(id)arg1;
- (void)goForward;
- (void)goBack;
- (void)stop;
- (void)clearWebviewCacheAndCookie:(_Bool)arg1;
- (void)reload;
- (id)getRoutUrls;
- (void)done:(id)arg1;
- (void)notifyToJSBridgeVisibilityChanged:(_Bool)arg1;
- (void)loadHTMLString:(id)arg1 baseURL:(id)arg2;
- (id)extraInfo;
- (void)doDNS;
- (void)StartLoadWeb;
- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3;
- (id)getInitUrl;
- (id)getShareUrl;
- (void)saveJSAPIPermissions:(id)arg1 url:(id)arg2;
@end




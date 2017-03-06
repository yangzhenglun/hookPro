#import "include/CContact.h"
#import "include/LbsContactInfoList.h"
#import "include/MMLbsContactInfo.h"
#import "include/MMTabBarController.h"
#import "include/CContactMgr.h"
#import "include/FindFriendEntryViewController.h"
#import "include/SeePeopleNearByLogicController.h"
#import "include/SeePeopleNearbyViewController.h"
#import "include/WeixinContactInfoAssist.h"
#import "include/CAppViewControllerManager.h"
#import "include/ContactsDataLogic.h"
#import "include/ContactsViewController.h"
#import "include/CVerifyContactWrap.h"
//#import "include/ContactInfoViewController.h"
#import "include/CContactVerifyLogic.h"
#import "include/AddressBookFriendViewController.h"
#import "include/MMService.h"
#import "include/MMServiceCenter.h"
//#import "include/BaseMsgContentLogicController.h"
#import "include/MultiSelectContactsViewController.h"
#import "include/ForwardMessageLogicController.h"
#import "include/CMessageWrap.h"
#import "include/MassSendWrap.h"
#import "include/MassSendMgr.h"
#import "include/AudioSender.h"
#import "include/CMessageMgr.h"
#import "include/CExtendInfoOfVideo.h"
#import "include/AudioReceiver.h"
#import "include/CDownloadVoiceMgr.h"
#import "include/ImageAutoDownloadMgr.h"
#import "include/curl/curl.h"
#import "include/CSetting.h"
#import "include/CBottle.h"
#import "include/CPushContact.h"
//#import "include/PluginUtil.h"
#import "include/CUsrInfo.h"
//#import "include/MMNewSessionMgr.h"
#import "include/FTSWebSearchMgr.h"
#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <substrate.h>
#import <time.h>
#import <iostream>
#import <string>

#define SEARCH_TASK_FILE "/var/root/als.json"
#define WXGROUP_TASK_LIST "/var/root/hkwx/wxgroup.plist"  //
#define WXGROUP_CARD_LIST "/var/root/hkwx/wxcard.plist"   //发名片
#define WXGROUP_MSG_LIST "/var/root/hkwx/wxgroupmsg.plist" //发消息、图片、语音等
#define WXGROUP_DEL_LIST "/var/root/hkwx/wxdeletefriend.plist" //删除好友
#define WXGROUP_CHANGE_LIST "/var/root/hkwx/wxChageData.plist" //修改头像背景图片
#define WXGROUP_ADD_LIST "/var/root/hkwx/wxAddStranger.plist" //添加好友 通过 @stranger
#define WXGROUP_RED_MAP_LIST "/var/root/hkwx/wxRedMap.plist" //阅读量
#define WXGROUP_PUBLIC_MAP_LIST "/var/root/hkwx/wxPublicMap.plist" //公众号
#define WXATTENTION_MAP_LIST "/var/root/hkwx/wxAttentionMap.plist"  //发公众号名片
#define WXPICK_BOTTLE_LIST "/var/root/hkwx/wxPickBottle.plist"  //漂流瓶

@interface MMUINavigationBar : UINavigationBar
- (id)initWithFrame:(struct CGRect)arg1;

@end

@interface MMUINavigationController : UINavigationController

- (id)getNextTopViewController;
- (id)getTopViewController;
- (void)popAnimationDidStop;
- (void)animationWillStart;
- (void)onBackButtonClicked:(id)arg1;

- (void)layoutViewsForTaskBar;
- (void)viewWillLayoutSubviews;
- (void)viewDidLoad;
- (void)viewWillAppear:(_Bool)arg1;
- (void)setNavigationBarHidden:(_Bool)arg1;
- (id)popViewControllerAnimated:(_Bool)arg1;  //返回
@end

@interface EnterpriseMsgDBItem
@property(retain, nonatomic) NSString *m_nsPattern; // @synthesize m_nsPattern;
@property(retain, nonatomic) NSString *m_nsRealChatUsr; // @synthesize m_nsRealChatUsr;
@property(retain, nonatomic) NSString *m_nsBizChatId; // @synthesize m_nsBizChatId;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(retain, nonatomic) NSString *m_nsMsgSource; // @synthesize m_nsMsgSource;
@property(nonatomic) unsigned int m_uiType; // @synthesize m_uiType;
@property(retain, nonatomic) NSString *m_nsMessage; // @synthesize m_nsMessage;
@property(nonatomic) unsigned int m_uiImgStatus; // @synthesize m_uiImgStatus;
@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
@property(nonatomic) unsigned int m_uiDesc; // @synthesize m_uiDesc;
@property(nonatomic) unsigned int m_uiCreateTime; // @synthesize m_uiCreateTime;
@property(nonatomic) unsigned int m_uiMesLocalId; // @synthesize m_uiMesLocalId;
@property(nonatomic) unsigned long long m_ui64MesSvrId; // @synthesize m_ui64MesSvrId;
@end


@interface MMMainTableView
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
@end

@interface PhoneItemInfo
@property(retain, nonatomic) NSString *phoneNum; // @synthesize phoneNum;
@end


@interface ContactsItemView
@property(nonatomic) BOOL m_bShowSearchResult; // @synthesize m_bShowSearchResult;
@property(nonatomic) BOOL m_bUseDynamicSize; // @synthesize m_bUseDynamicSize;
@property(nonatomic) float m_CustomLabelDecreaseWidth; // @synthesize m_CustomLabelDecreaseWidth;
@property(nonatomic) BOOL m_bShowUserDescription; // @synthesize m_bShowUserDescription;
//@property(retain, nonatomic) MMWebImageView *m_webHeadImageView; // @synthesize m_webHeadImageView;
@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;
@property(retain, nonatomic) id m_data; // @synthesize m_data;
//@property(nonatomic) __weak id <ContactsItemViewDelegate> m_delegate; // @synthesize m_delegate;
//@property(retain, nonatomic) MMHeadImageView *m_headImage; // @synthesize m_headImage;
@property(retain, nonatomic) UILabel *m_userNameLabel; // @synthesize m_userNameLabel;
@property(retain, nonatomic) UILabel *m_nickNameLabel; // @synthesize m_nickNameLabel;
@property(nonatomic) BOOL m_bShowHeadImage; // @synthesize m_bShowHeadImage;


- (void)updateCPState;	// IMP=0x0189be05
- (void)setUserNameLabelToFitWidth;	// IMP=0x0189bd35
- (void)initDescLabel;	// IMP=0x0189bb47
- (void)initUserNameLabel:(id)arg1;	// IMP=0x0189b7d5
- (void)initGreenRightButton:(id)arg1;	// IMP=0x0189b5bd
- (void)initGreyRightButton:(id)arg1;	// IMP=0x0189b3a5
- (void)onRightBtnAction;	// IMP=0x0189b31f
- (void)initRightPlaceAddLabel;	// IMP=0x0189af41
- (void)initRightPlaceCenterAlignmentAddedLabelWithString:(id)arg1;	// IMP=0x0189aec7
- (void)initRightPlaceAddedLabel;	// IMP=0x0189adcb
- (void)initRightPlaceWaitingLabel;	// IMP=0x0189accf
- (void)initRightPlaceDeleteLabel;	// IMP=0x0189ab31
- (void)initGrayLabel:(id)arg1 color:(id)arg2;	// IMP=0x0189a90d
- (void)initAddedLabel:(id)arg1;	// IMP=0x0189a731
- (void)initNickNameLabel:(id)arg1;	// IMP=0x0189a465
- (struct CGRect)calNickNameFrame:(id)arg1;	// IMP=0x01899fad
- (void)updateBackgroundColor:(id)arg1;	// IMP=0x01899f25
- (void)updateView:(id)arg1;	// IMP=0x01899e17
- (void)updateMatchLabel;	// IMP=0x01899825
- (void)updateUserNameLabel:(id)arg1;	// IMP=0x018997eb
- (void)updateNickNameLabel;	// IMP=0x018992b5
- (void)updateHeadImageForContact:(id)arg1;	// IMP=0x0189910f
- (void)initView:(id)arg1 showChatRoomName:(id)arg2;	// IMP=0x01899091
- (void)showChatRoomCount:(id)arg1;	// IMP=0x01898beb
- (void)initView:(id)arg1;	// IMP=0x01898adb
- (void)initSessionStyleView:(id)arg1;	// IMP=0x01898a07
- (BOOL)isShowMobileName:(id)arg1 mobileName:(id)arg2;	// IMP=0x01898965
- (void)initContactLogo:(id)arg1;	// IMP=0x018988b5
- (void)initHeadImageForContact:(id)arg1;	// IMP=0x0189844b
- (void)initHeadImage:(id)arg1;	// IMP=0x01898439
- (void)initHeadImageUrl:(id)arg1 withAuthorizationCode:(id)arg2 update:(BOOL)arg3;	// IMP=0x018980bd
- (void)initHeadImage:(id)arg1 withUrl:(id)arg2;	// IMP=0x01897e05
- (void)layoutSubviews;	// IMP=0x01897065
- (id)init;	// IMP=0x0189700d

@end


@interface NewContactsItemCell
{
    ContactsItemView *m_contactsItemView;
}

@end


@interface MMLocationMgr

// @property(readonly, nonatomic) MMLocationCacheStorage *locationCacheStorage; // @synthesize locationCacheStorage=_locationCacheStorage;
@property(retain, nonatomic) NSMutableArray *unusedLocationMgr; // @synthesize unusedLocationMgr=m_unusedLocationMgr;
@property(retain, nonatomic) NSMutableArray *loactionMgrList; // @synthesize loactionMgrList=m_loactionMgrList;
- (void)mapView:(id)arg1 didFailToLocateUserWithError:(id)arg2;
- (void)mapView:(id)arg1 didUpdateUserLocation:(id)arg2;
- (void)MessageReturn:(id)arg1 Event:(unsigned int)arg2;
- (void)requestWXGeocodeWithParam:(id)arg1;
- (void)connectionDidFinishLoading:(id)arg1;
- (void)connection:(id)arg1 didReceiveData:(id)arg2;
- (void)connection:(id)arg1 didReceiveResponse:(id)arg2;
- (void)requestReverseGeoWithParam:(id)arg1;
// - (_Bool)isCoordinateInChina:(CDStruct_c3b9c2ee)arg1;
- (id)countryCodeFromAddressDic:(id)arg1;
- (id)countryFromAddressDic:(id)arg1;
- (id)routeFromAddressDic:(id)arg1;
- (id)subLocalityFromAddressDic:(id)arg1;
- (id)evolvedCityFromAddressDic:(id)arg1;
- (id)cityFromAddressDic:(id)arg1;
- (id)provinceFromAddressDic:(id)arg1;
- (id)roughAddressFromAddressDic:(id)arg1;
- (id)shortAddressFromAddressDic:(id)arg1;
- (id)findDictionaryByKey:(id)arg1;
- (id)findDictionaryByGeo:(id)arg1;
- (void)stopUpdateAddressByTag:(unsigned long long)arg1;
- (void)stopGeoAddress:(id)arg1;
// - (unsigned long long)updateAddressByLocation:(CDStruct_c3b9c2ee)arg1;
// - (id)getAddressByLocation:(CDStruct_c3b9c2ee)arg1;
// - (id)keyForLocation:(CDStruct_c3b9c2ee)arg1;
- (void)locationManager:(id)arg1 didUpdateHeading:(id)arg2;
- (void)locationManager:(id)arg1 didFailWithError:(id)arg2;
- (void)locationManager:(id)arg1 didUpdateToLocation:(id)arg2 fromLocation:(id)arg3;
- (void)onUpdateLocationFromLocationManager:(id)arg1;
- (void)dealloc;
- (id)init;
- (id)getLastLocationCache;
- (void)updateLocationCache:(id)arg1 isMarsLocation:(_Bool)arg2;
- (void)saveLocationCacheStorage;
- (void)loadLocationCacheStorage;
- (id)getLocationCacheStorage;
- (_Bool)isUpdatingHeading:(unsigned long long)arg1;
- (void)stopUpdateHeading:(unsigned long long)arg1;
- (unsigned long long)startUpdateHeading;
- (_Bool)isUpdatingMapLocation:(long long)arg1;
- (void)stopUpdateMapLocation:(long long)arg1;
- (long long)startUpdateMapLocation;
- (_Bool)isUpdatingGPSLocation:(unsigned long long)arg1;
- (void)stopUpdateGPSLocation:(unsigned long long)arg1;
- (unsigned long long)startUpdateGPSLocation;
- (void)requestForAuthorization;
- (void)cleanUpUnusedLocationMgr;
- (void)addToUnusedLocationMgr:(id)arg1;
- (_Bool)isAccurateLocation:(id)arg1;
- (double)locationAccuracy:(id)arg1;
- (void)onServiceClearData;
- (void)onServiceReloadData;
- (void)onServiceInit;

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

@interface NewMainFrameViewController{
    MainFrameLogicController *m_mainFrameLogicController;
}

- (void)viewDidAppear:(_Bool)arg1;

- (void)removeObserver:(id)observer;

- (void)createMyButton;
- (void)addGrupMembers;

//显示提示信息
-(void)showTipMsg;

//发送名和消息
- (void)createSendCardMyButton;
- (void)createSendCardMsgMyButton;

//进入群聊
- (void)enterChatRoom;
- (void)createChatButton;

//发送消息和链接
-(void)sendMsgAndLink;

//发送名片
- (void)sendCardList;
- (void)sendCardListMsg;

//发送消息 图片语音等
- (void)createChatMsgButton;
- (void)sendCardMsgList;

//发送所有图片信息 语音等
-(void)sendAllMsgList;

//修改头像
- (void)createChageHeadImgButton;
- (void)changeHeadImg;

//暴力加单向好友
- (void)addFriendByWXId:(NSMutableDictionary *)taskDataDic;

//筛选数据并添加好友
- (void)addFriendScreenByWXId:(NSMutableDictionary *)taskDataDic;

//添加公众号
- (void)createPublicButton;
- (void)addPublicByWXId;

//跑微信文章阅读量
- (void)batchMpDocReadCount:(NSString *)taskId;

- (void)viewDidLoad;

//创建版本提示
- (void)createMyTip;

//发公众号名片
- (void)attentionPublicWX;
- (void)attentionAllCard;
- (void)sendCardByWxidList:(NSMutableArray *)allContacts cardUser:(NSString *)cardUser pos:(int)pos;

//捡瓶子和发信息
- (void)pickUpBottle;
//发送消息
- (void)sendMsgToUser:(NSMutableArray *)allContacts;

//修改性别和地区
- (void)modifyUsrInfo;

//首页附近人
- (void)findLBSUsrs:(NSMutableDictionary*)taskDataDic;


//执行下一个任务
-(void)getNextTask;

//检查网络
-(void)checkNetWork;
//注册消息
-(void)registerNotification;

//发朋友圈
- (void)sendFriends:(NSNotification *)notifiData;

//下载视频
-(BOOL)downFileByUrl:(NSString *)downUrl dwonName:(NSString *)dwonName;

//朋友圈发图片或者文字
-(void)sendFriendsPictureAndText:(NSMutableDictionary *)taskDataDic;

//朋友圈发视频
-(void)sendFriendsVideo:(NSMutableDictionary *)taskDataDic;


- (void)msgAndLink:(NSNotification *)notifiData;
- (void)attentionPublicCard:(NSNotification*)notifiData;
- (void)driftingBottle;

//关注公众号  第三种方式
-(void)addAllPublicCard:(NSMutableDictionary *)taskDataDic;

//同步通讯录
-(void)syncMailList;

//通讯录筛选数据
-(void)mailListScreeningData;

//向一个人发消息

- (void)sendMsgOnePerson:(NSNotification *)notificationText;
- (void)sendCardOnePerson:(NSString*)sendContact cardUser:(NSString*)sendCardUser;
- (void)initQueryCard;   //发名片时的第一次初始化


//发送72号任务
-(void)mailListMarketing:(NSMutableDictionary *)taskDataDic;

//发送通讯录营销消息
-(void)mailMarkMsg:(NSMutableDictionary *)taskDataDic;

//发送语音消息
-(void)sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime;

//发送文字
-(void)sendTextMessages:(NSString *)toUser textContent:(NSString *)textContent;

//发送图片
-(void)sendPictureMessages:(NSString *)toUser pic:(NSString *)picUrl;
-(void)sendPictureAllMessage:(NSString *)picUr;

//发送名片
-(void)sendCardMessage:(NSString *)toUser toContact:(CContact *)toContact;

//发送链接
-(void)sendLinkMessages:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink;


//得到当前的发名片的信息
-(void)getQueryCardList:(NSString *)cardUser cardPos:(int)cardPos;

//修改个性签名
-(void)modifySignature:(NSMutableDictionary *)taskDataDic;

//摇一摇
-(void)doShakeGet;

//首页删除聊天记录
-(void)deleteAllSession;

//首页得到最后一条数据
-(void)getLastSession;

//首页上传uuid数据
-(void)uploadWeiXinUUID;

//发送首页数据
-(void)sendSessionData;

//搜索所有手机号
-(void)searchAllPhoneNum:(NSMutableDictionary *)taskDataDic;
//搜索手机号
-(void)searchPhoneNum:(NSString *)phoneNum taskId:(NSString *)taskId;

@end

@interface PluginContactInfoAssist

@end



//发表图片的数据结构
@interface MMAsset

@end

@interface WCDataItem
@property(nonatomic) BOOL likeFlag; // @synthesize likeFlag;
@property(retain, nonatomic) NSString *nickname; // @synthesize nickname;
@property(retain, nonatomic) NSString *username; // @synthesize username;

@end

@interface MMImage : UIImage

@property(retain, nonatomic) NSData *m_imageData; // @synthesize m_imageData;
@property(retain, nonatomic) MMAsset *m_asset; // @synthesize m_asset;
@property(retain, nonatomic) NSURL *referenceURL; // @synthesize referenceURL=_referenceURL;

- (void)setM_imageFromAsset:(UIImage *)imageFromAsset;
- (void)setM_imageData:(NSData *)imageData;

@end

//选择图片的Controller
@interface ImageSelectorController
@property(retain, nonatomic) NSMutableArray *arrImages; // @synthesize arrImages=_arrImages;

- (UIImage *)loadImageFromSrv:(NSString *)imageUrl;
- (id)init;
- (void)setArrImages:(NSMutableArray *)imgs;
@end


//朋友圈主页ViewContrloller
@interface WCTimeLineViewController
{
    //    WCOperateFloatView *m_floatOperateView; //悬浮框
    MMTableView *m_tableView;
    WCDataItem *_inputDataItem;	// 176 = 0xb0
}
- (void)executeWCTimeLineViewController;
- (void)delayedBackHome;   //延时执行返回
//发朋友圈

- (void)viewDidAppear:(_Bool)arg1;
- (void)openWriteTextViewController;    //打开文字评论
- (void)openCommitViewController:(_Bool)arg1 arrImage:(id)arg2;  //发图片朋友圈

- (long long)numberOfSectionsInTableView:(id)arg1;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;

//评论、点赞等
- (void)didCommitText:(id)arg1;  //提交评论内容 @“内容”
- (void)onTouchDownLikeBtnOnFloatView; //点赞
- (void)onClickCommentBtnOnFloatView; //点击评论按钮
- (void)onCommentDataItem:(id)arg1 point:(struct CGPoint)arg2;  //弹出点赞 评论框 arg1:WCDataItem arg2:

- (void)refreshWholeView;

@end


//通讯录群聊
@interface MemberListViewController
{
//    MMTableView *m_tableView;
}

- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;

- (void)makeCell:(id)arg1 contact:(id)arg2;

@end


@interface ChatRoomListViewController : MemberListViewController
- (void)JumpToChatRoom:(id)arg1;
- (void)viewDidLoad;
@end

//进入群聊信息页面
@interface RoomContentLogicController
- (id)init;
- (void)OpenDetailInfo;
@end

//群公告
@interface ChatRoomInfoEditDescViewController
- (void)OnDone;  //完成
- (void)OnReturn;
- (void)OnEdit; //编辑公告内容
- (void)updateText:(id)arg1;  //设置公告内容
- (void)viewDidLoad;
- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2;
@end

//获取微信聊天的群ID
@interface MMUIViewController : UIViewController

@end

@interface AddMemLogic{
    NSArray *m_arrMemberList;
}
@end

@interface ChatRoomInfoViewController : MMUIViewController{
    UIView *m_titleView;
    NSArray *m_arrMemberList;
    AddMemLogic *m_addMemLogic;
}

@property(retain, nonatomic) CContact *m_chatRoomContact; // @synthesize m_chatRoomContact;

- (void)sysChatRoomAction;
- (void)viewDidAppear:(_Bool)arg1;
- (void)onQuit:(id)arg1;
- (_Bool)quitChatRoom;
- (void)onDeleteContact:(id)arg1;  
- (void)actionSheet:(id)arg1 clickedButtonAtIndex:(long long)arg2;
- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2;

- (void)createDeleteFriendButton;
- (void)deleteFriendList;

- (void)showAdminViewDesc; //群公告
@end

//删除好友
@interface ContactSettingViewController
- (void)opDelete:(id)arg1;
- (void)doDelete;
@end

//个人信息页面
@interface ContactInfoViewController : MMUIViewController

@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;

- (void)viewDidLoad;
- (void)viewDidDisappear:(_Bool)arg1;
- (void)createUpLoadButton;
- (void)showSheet;
-(void)testAttionCard;
@end

//点击聊天信息 “＋”号按钮
@interface NewChatRoomMemberContainView
- (void)layoutSubviews;
- (void)onAddMember:(id)arg1;  //点击 ”＋“ 按钮 @“1”
- (id)initWithFrame:(struct CGRect)arg1 column:(unsigned long long)arg2;

@end

@interface BaseMsgContentViewController
- (void)viewDidLoad;
- (void)createMyButton;
- (void)addGrupMembers;
- (id)init;

- (id)someValue;
- (void)setSomeValue:(id)value;

@end

//添加附近人
@interface EnterLbsViewController
- (void)initView;
- (void)OnOpenLbs;
- (void)viewDidLoad;
- (void)UpdateView;
- (void)initData;
@end


@interface GroupMember

@property(retain, nonatomic) NSString *m_nsSignature; // @synthesize m_nsSignature;
@property(retain, nonatomic) NSString *m_nsCity; // @synthesize m_nsCity;
@property(retain, nonatomic) NSString *m_nsProvince; // @synthesize m_nsProvince;
@property(retain, nonatomic) NSString *m_nsCountry; // @synthesize m_nsCountry;
@property(retain, nonatomic) NSString *m_nsRemarkFullPY; // @synthesize m_nsRemarkFullPY;
@property(retain, nonatomic) NSString *m_nsRemarkShortPY; // @synthesize m_nsRemarkShortPY;
@property(retain, nonatomic) NSString *m_nsRemark; // @synthesize m_nsRemark;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(retain, nonatomic) NSString *m_nsFullPY; // @synthesize m_nsFullPY;
@property(retain, nonatomic) NSString *m_nsNickName; // @synthesize m_nsNickName;
@property(nonatomic) unsigned int m_uiMemberStatus; // @synthesize m_uiMemberStatus;
@property(retain, nonatomic) NSString *m_nsMemberName; // @synthesize m_nsMemberName;

- (id)init;

@end

@interface CGroupMgr

- (_Bool)AddGroupMember:(id)arg1 withMemberList:(id)arg2;

- (_Bool)QuitGroup:(id)arg1 withUsrName:(id)arg2;
- (_Bool)DeleteGroupMember:(id)arg1 withMemberList:(id)arg2 scene:(unsigned long long)arg3;


@end


//选择男女弹出框
@interface WCActionSheet
- (void)tapOut:(id)arg1;
- (id)init;
- (id)initWithTitle:(id)arg1 delegate:(id)arg2 cancelButtonTitle:(id)arg3 destructiveButtonTitle:(id)arg4 otherButtonTitles:(id)arg5;
- (void)dismissWithClickedButtonIndex:(long long)arg1 animated:(_Bool)arg2;
- (_Bool)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2;
- (void)setFrame:(struct CGRect)arg1;


@end

//修改头像
@interface MMHeadImageMgr
- (unsigned int)uploadHDHeadImg:(id)arg1;
@end

//去掉发图片是 弹出我知道
@interface MMTipsViewController
- (void)viewDidLoad;
- (void)hideTips;
- (void)onClickBtn:(id)arg1;
- (id)getBtnAtIndex:(unsigned int)arg1;

@end


//账号异常
@interface WXPBGeneratedMessage
- (id)init;
- (id)baseResponse;
@end

@interface BaseResponseErrMsg : WXPBGeneratedMessage
+ (void)initialize;
// Remaining properties
@property(nonatomic) int action; // @dynamic action;
@property(retain, nonatomic) NSString *cancel; // @dynamic cancel;
@property(retain, nonatomic) NSString *content; // @dynamic content;
@property(nonatomic) unsigned int countdown; // @dynamic countdown;
@property(nonatomic) int delayConnSec; // @dynamic delayConnSec;
@property(nonatomic) int dispSec; // @dynamic dispSec;
@property(retain, nonatomic) NSString *ok; // @dynamic ok;
@property(nonatomic) int showType; // @dynamic showType;
@property(retain, nonatomic) NSString *title; // @dynamic title;
@property(retain, nonatomic) NSString *url; // @dynamic url;

@end


//@interface BaseResponseErrMsg
//@property(retain, nonatomic) NSString *cancel; // @dynamic cancel;
//@property(retain, nonatomic) NSString *content; // @dynamic content;
//
//@end

@interface AccountErrorInfo
@property(retain, nonatomic) BaseResponseErrMsg *errMsg; // @synthesize errMsg=_errMsg;
@property(nonatomic) unsigned int uiMessage; // @synthesize uiMessage=_uiMessage;
- (void)parseErrMsgXml:(id)arg1;
- (id)init;
@end

@interface SvrErrorInfo
@property(retain, nonatomic) NSString *m_nsTipsContent; // @synthesize m_nsTipsContent;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;

- (void)ParseFromXml:(id)arg1;
- (id)init;

@end

@interface SayHelloDataLogic{
    NSMutableArray *m_arrHellos;
}

- (id)getContactForUserName:(id)arg1;
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



@interface YYUIWebView
- (void)webViewDidStartLoad:(id)arg1;
- (void)webViewDidFinishLoad:(id)arg1;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end


@interface WCRedEnvelopesReceiveHomeView
- (void)refreshViewWithData:(id)arg1;
- (void)OnCancelButtonDone;
- (void)OnOpenRedEnvelopes;
@end

//修改背景
@interface WCFacade
- (void)SetBGImgByImg:(id)arg1;
- (id)init;
- (_Bool)updateTimelineHead;

@end

//去掉文字发朋友圈我知道
@interface WCPlainTextTipFullScreenView
- (void)layoutSubviews;
- (id)init;
- (void)initView;
- (void)onIKnowItBtnClick:(id)arg1;
@end

//漂流瓶
@interface BottleMgr
- (unsigned int)GetFishCount;
- (void)FishBottle;  //捡瓶子
- (unsigned int)GetThrowCount;
- (void)OpenBottle:(unsigned int)arg1;  //打开瓶子
@end

@interface SandyBeachViewController
- (id)init;
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



//关注返回值
@interface WebViewJSLogicImpl
- (void)onEndEvent:(id)arg1 withResult:(id)arg2;
@end


@interface BrandUserContactInfoAssist
- (void)contactVerifyOk:(id)arg1 opCode:(unsigned int)arg2;
@end

//发朋友圈
@interface MMGrowTextView
@end

//安全模式第一步
@interface MMSMStartViewController
- (void)onNextButtonClicked:(id)arg1; //[#0x19099f10 onNextButtonClicked:@"1"] 下一步
- (void)viewDidLoad;
@end

//第二步
@interface MMSMClearDataViewController{
    UIButton *m_nextButton;
}
- (void)viewDidLoad;
- (void)onNextButtonClicked:(id)arg1;

@end

//第三步
@interface MMSMUploadFileViewController{
    UIButton *m_nextButton;
}

- (void)viewDidLoad;
- (void)onNextButtonClicked:(id)arg1;
@end

//第四步
@interface MMSMFinishViewController
- (void)onEnterButtonClicked:(id)arg1;
- (void)viewDidLoad;
@end


//摇一摇
@interface MMSayHelloViewController
@property(retain, nonatomic) CContact *helloReceiver; // @synthesize helloReceiver=m_helloReceiver;
- (void)onSendSayHello:(id)arg1;
- (id)filterString:(id)arg1;
- (_Bool)doSayHello:(id)arg1;
@end


@interface ShakePeopleLogicController
- (void)doShakeGet;     //摇一摇
- (void)createShakeGetEvent; //摇一摇
- (void)createShakeReportEvent; //创建
@end

@interface ShakeLogicProxy{
    ShakePeopleLogicController *m_shakePeopleLogic;
}
@end
@interface ShakeGetItem
@property(retain, nonatomic) NSString *city; // @dynamic city;
@property(retain, nonatomic) NSString *country; // @dynamic country;
@property(retain, nonatomic) NSString *distance; // @dynamic distance;
@property(nonatomic) unsigned int hasHdimg; // @dynamic hasHdimg;
@property(nonatomic) int headImgVersion; // @dynamic headImgVersion;
@property(nonatomic) unsigned int imgStatus; // @dynamic imgStatus;
@property(retain, nonatomic) NSString *myBrandList; // @dynamic myBrandList;
@property(retain, nonatomic) NSString *nickName; // @dynamic nickName;
@property(nonatomic) unsigned int numDistance; // @dynamic numDistance;
@property(retain, nonatomic) NSString *province; // @dynamic province;
@property(nonatomic) int sex; // @dynamic sex;
@property(retain, nonatomic) NSString *signature; // @dynamic signature;
@property(retain, nonatomic) NSString *smallHeadImgUrl; // @dynamic smallHeadImgUrl;
@property(retain, nonatomic) NSString *userName; // @dynamic userName;
@property(retain, nonatomic) NSString *verifyContent; // @dynamic verifyContent;
@property(nonatomic) unsigned int verifyFlag; // @dynamic verifyFlag;
@property(retain, nonatomic) NSString *verifyInfo; // @dynamic verifyInfo;
@property(retain, nonatomic) NSString *weibo; // @dynamic weibo;
@property(nonatomic) unsigned int weiboFlag; // @dynamic weiboFlag;
@property(retain, nonatomic) NSString *weiboNickname; // @dynamic weiboNickname;
@end
@interface ShakeSingleView{
    ShakeGetItem *m_oShakeGetItem;
}
@end

@interface ShakeViewController
{
    ShakeLogicProxy *m_logicProxy;
    ShakeSingleView *m_shakeSingleView;
}

- (void)viewDidLoad;
@end

@interface MoreViewController
- (void)viewDidLoad;
@end

@interface AccountStorageMgr
@property(copy, nonatomic) CSetting *m_oSetting; // @synthesize m_oSetting;
- (id)GetSyncBufferFilePath;
@end





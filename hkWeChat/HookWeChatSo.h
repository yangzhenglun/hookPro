#include <UIKit/UIKit.h>
#import <objc/objc-runtime.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
//#import "include/AddressBookFriendViewController.h"
#import "include/MMServiceCenter.h"
#import "include/MMService.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <spawn.h>
#import <sys/wait.h>
#import "curl/curl.h"

#import "include/CContact.h"
#import "include/CBaseContact.h"
#import "include/MultiSelectContactsViewController.h"
#import "include/ForwardMessageLogicController.h"
#import "include/CMessageWrap.h"
#import "include/MassSendWrap.h"
#import "include/MassSendMgr.h"
#import "include/AudioSender.h"
#import "include/CMessageMgr.h"
//#import "include/CExtendInfoOfVideo.h"
#import "include/AudioReceiver.h"
#import "include/CDownloadVoiceMgr.h"
#import "include/ImageAutoDownloadMgr.h"
#import "include/CContactMgr.h"
#import "include/CSetting.h"



#define SEARCH_TASK_FILE "/var/root/als.json"
#define TASK_ITEM_FILE   "/var/root/hkwx/taskItem.json"
#define VOICE_AMR_FILE   "/var/root/hkwx/amrfile.json"
#define WXGROUP_MSG_LIST "/var/root/hkwx/wxgroupmsg.plist" //发消息、图片、语音等
#define WXGROUP_DEL_LIST "/var/root/hkwx/wxdeletefriend.plist" //删除好友
#define WXGROUP_LIKES_LIST "/var/root/hkwx/wxlikes.plist" //点赞好友列表
#define WXGROUP_CHANGE_LIST "/var/root/hkwx/wxChageData.plist" //修改头像背景图片

//代理
@interface MicroMessengerAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2;
@end

/////////////////////公共类/////////////////////////////
//管理所有Controller的类
@interface CAppViewControllerManager

@end

//@interface CContactMgr : MMService
//- (id)getSelfContact;
//@end

@interface MMMainTableView
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
@end

//@interface MMTableView : UITableView
//- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
//@end

@interface MMTableViewCell : UITableViewCell
@end

@interface ContactsItemCell : MMTableViewCell
@end

@interface PhoneItemInfo
@property(retain, nonatomic) NSString *phoneNum; // @synthesize phoneNum;
@end

//@interface CBaseContact
//@property(retain, nonatomic) NSString *m_nsAliasName; // @synthesize m_nsAliasName;   //微信号
//@property(retain, nonatomic) NSString *m_nsEncodeUserName; // @synthesize m_nsEncodeUserName;
//@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
//@property(retain, nonatomic) NSString *m_nsNickName; // @synthesize m_nsNickName;
//@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
//@property(retain, nonatomic) NSString *m_nsRemark; // @synthesize m_nsRemark;
//
//
//- (void)setM_nsUsrName:(NSString *)nsUsrName;
//- (void)setM_nsNickName:(NSString *)nsNickName;
//
//
//@end

//@interface CContact : CBaseContact
//@property(retain, nonatomic) NSString *m_nsSignature; // @synthesize m_nsSignature;
//@property(retain, nonatomic) NSString *m_nsCity; // @synthesize m_nsCity;
//@property(retain, nonatomic) NSString *m_nsProvince; // @synthesize m_nsProvince;
//@property(retain, nonatomic) NSString *m_nsCountry; // @synthesize m_nsCountry;
//@property(retain, nonatomic) NSArray *m_arrPhoneItem; // @synthesize m_arrPhoneItem;
//@property(nonatomic) _Bool m_isExtInfoValid; // @synthesize m_isExtInfoValid;
//
//- (id)getMobileList;
//
//-(void)setM_isExtInfoValid:(_Bool)isExtInfoValid;
//- (_Bool)isAdmin;
//
//
//@end

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

//////////////////////tabbar 切换开始///////////////////
@interface MMTabBarController
- (void)viewDidAppear:(_Bool)arg1;
- (void)setSelectedIndex:(unsigned long long)arg1;  //选择第几个按钮
- (id)init;

@end
//////////////////////tabbar 切换结束///////////////////


///////////////////////微信页面开始///////////////////////
@interface MainFrameCellData : NSObject
@property(nonatomic) BOOL isMessageUnsafe; // @synthesize isMessageUnsafe=m_isMessageUnsafe;
@property(nonatomic) BOOL isNicknameUnsafe; // @synthesize isNicknameUnsafe=m_isNicknameUnsafe;
@property(retain, nonatomic) NSString *cpKeyForMessage; // @synthesize cpKeyForMessage=m_cpKeyForMessage;
@property(retain, nonatomic) NSString *cpKeyForNickname; // @synthesize cpKeyForNickname=m_cpKeyForNickname;
@property(nonatomic) BOOL m_bIsModifyContact; // @synthesize m_bIsModifyContact;
@property(nonatomic) int m_lastUnReadCount; // @synthesize m_lastUnReadCount;
@property(retain, nonatomic) NSString *m_nsRealUsrName; // @synthesize m_nsRealUsrName;
@property(retain, nonatomic) NSString *m_oldTextForNameLabel; // @synthesize m_oldTextForNameLabel;
@property(readonly, nonatomic) BOOL m_bIsRoomDisplayEmpty; // @synthesize m_bIsRoomDisplayEmpty;
@property(nonatomic) float m_widthForTimeLabelText; // @synthesize m_widthForTimeLabelText;
@property(nonatomic) float m_widthForNameLabelText; // @synthesize m_widthForNameLabelText;
@property(readonly, nonatomic) BOOL m_isHavenInitedWithSessionInfo; // @synthesize m_isHavenInitedWithSessionInfo;
@property(nonatomic) BOOL m_isFirstInitTimeText; // @synthesize m_isFirstInitTimeText;
@property(nonatomic) BOOL m_timeIsMoreThanAWeek; // @synthesize m_timeIsMoreThanAWeek;
@property(retain, nonatomic) NSString *m_nsHeadImgUsrName; // @synthesize m_nsHeadImgUsrName;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
@property(readonly, nonatomic) BOOL m_isRealTimeTalkRoomEmpty; // @synthesize m_isRealTimeTalkRoomEmpty;
@property(nonatomic) float m_widthForMessageLabelText; // @synthesize m_widthForMessageLabelText;
@property(nonatomic) float m_widthForGreenLabelText; // @synthesize m_widthForGreenLabelText;
@property(readonly, nonatomic) BOOL m_bIsSenderFromSelf; // @synthesize m_bIsSenderFromSelf;
@property(retain, nonatomic) NSString *m_subfixTextForQuoteMessage; // @synthesize m_subfixTextForQuoteMessage;
@property(retain, nonatomic) NSString *m_prefixTextForQuoteMessage; // @synthesize m_prefixTextForQuoteMessage;
@property(retain, nonatomic) NSString *m_textForNameLabel; // @synthesize m_textForNameLabel;
@property(retain, nonatomic) NSString *m_textForMessageLabel; // @synthesize m_textForMessageLabel;
@property(retain, nonatomic) NSString *m_textForGreenLabel; // @synthesize m_textForGreenLabel;
@property(retain, nonatomic) NSString *m_textForTimeLabel; // @synthesize m_textForTimeLabel;
//@property(retain, nonatomic) MMSessionInfo *m_sessionInfo; // @synthesize m_sessionInfo;

- (void)updateTextForTimeLabel;	// IMP=0x018d9d6b
- (void)updateDataFieldForUI;	// IMP=0x018d9af3
- (void)updateData:(id)arg1;	// IMP=0x018d99cd
- (id)initWithSessionInfo:(id)arg1 isEnableCacheCellData:(BOOL)arg2 PBCellData:(id)arg3;	// IMP=0x018d986d
- (id)initWithSessionInfo:(id)arg1 isEnableCacheCellData:(BOOL)arg2;	// IMP=0x018d984b
- (id)init;	// IMP=0x018d97c3
- (void)makeTextForPluginMessage;	// IMP=0x018d8863
- (void)makeTextForQuoteMessage;	// IMP=0x018d854b
- (id)makeEmoticonMessageText:(id)arg1;	// IMP=0x018d8299
- (void)makeTextSession:(id)arg1;	// IMP=0x018d4781
- (void)makeTextForSingleMessage;	// IMP=0x018d4765
- (void)makeTextForChatRoomMessage:(id)arg1;	// IMP=0x018d4665
- (void)makeTextForMessageLabel;	// IMP=0x018d3faf
- (void)makeTextForNameLabel;	// IMP=0x018d3bc5
- (void)updateExtensionRegister:(id)arg1;	// IMP=0x018d3a5f
- (id)copyFieldToPBCellData;	// IMP=0x018d3787
- (void)checkDataIsValid;	// IMP=0x018d3581
- (void)copyFieldFromPBCellData:(id)arg1;	// IMP=0x018d32a9
- (void)updateTimeField:(unsigned long)arg1;	// IMP=0x018d3115
- (void)updateWidthForNameLabel;	// IMP=0x018d2edf
- (void)savePBCellData;	// IMP=0x018d2d31

@end

@interface NewMainFrameCell

@property(retain, nonatomic) MainFrameCellData *m_oldCellData; // @synthesize m_oldCellData;
@property(retain, nonatomic) MainFrameCellData *m_cellData; // @synthesize m_cellData;

- (void)updateCellBackground:(id)arg1;	// IMP=0x01accd11
- (void)updateCellTime;	// IMP=0x01acccf3
- (void)updateCellAccessibilityLabel;	// IMP=0x01acc40b
- (void)updateCellContent:(id)arg1 withContact:(id)arg2;	// IMP=0x01acc2df
- (void)updateContentView:(id)arg1 tableViewFrame:(struct CGRect)arg2 isSearching:(BOOL)arg3 isSearchTableView:(BOOL)arg4 searchBarText:(id)arg5;	// IMP=0x01acbd2f
- (void)updateViewForBrandSession:(id)arg1 tableViewFrame:(struct CGRect)arg2;	// IMP=0x01acbb8f
- (void)updateMoreMenu:(id)arg1;	// IMP=0x01acb303
- (void)onDelete:(id)arg1;	// IMP=0x01acb26f
- (void)onSetUnread:(id)arg1;	// IMP=0x01acb1db
- (BOOL)isSessionSetUnreadable:(id)arg1;	// IMP=0x01acb103
- (void)layoutSubviews;	// IMP=0x01acafd7
- (void)dealloc;	// IMP=0x01acaef5
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;	// IMP=0x01acadad

@end

@interface NewMainFrameViewController{
}

//操作微信页面信息
- (void)executeNewMainFrameController;

//点击进入聊天记录
- (void)viewDidAppear:(_Bool)arg1;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;

//发送名片信息
- (void)createChatMsgButton;
- (void)sendCardMsgList;

//修改头像
- (void)createChageHeadImgButton;
- (void)changeHeadImg;
-(void)sendFriendsVideo;
- (void)sendFriends;
-(BOOL)downFileByUrl:(NSString *)downUrl dwonName:(NSString *)dwonName;

@end

//点击微信上面的语言输入框
@interface MMVoiceSearchBar
- (void)voiceSearchRestart;
- (void)loadView;

@end

@interface WCFacade
- (void)SetBGImgByImg:(id)arg1;
- (id)init;
- (_Bool)updateTimelineHead;

@end


//搜索框
@interface SGCustomButton
@end

@interface SearchGuideView
{
    SGCustomButton *_ftsEntryArtclBtn;
}

- (void)onTapButton:(id)arg1;
- (void)layoutSubviews;
- (void)initFTSGuideView;


@end


@interface MMUISearchBar
- (void) setText:(NSString *)searText;
- (void) _cancelButtonPressed;

@end

//搜索结果页
@interface FTSWebSearchController
{
    MMUISearchBar *_searchBar;

}
//输入文字
@property(retain, nonatomic) UITextField *searchTextField; // @synthesize searchTextField=_searchTextField;

- (void) setText:(NSString *)searText;
- (void)searchBarSearchButtonClicked:(id)arg1;
- (void)initView;

- (void)onBackBtnClick; //返回

@end


//关注公众号搜索页面 方式2
@interface BrandServiceWebSearchController
{
    NSString *_keywordForHomePage;
}
- (void)onClickSearchButton:(id)arg1;  //点击搜索
- (id)getCurrentSearchBar;  //得到当前的搜索button
- (void)initView;
@end

//关注公众号页面
@interface BrandUserContactInfoAssist
- (void)initTableView;
- (void)onAddToContacts;    //点击关注，进入聊天页
@end


//点击右边的加号按钮
@interface NewMainFrameRightTopMenuBtn
- (void)showRightTopMenuBtn;        //点击弹出选择框
- (void)hideRightTopMenuBtn;        //隐藏弹出框
- (void)onItemAction:(id)arg1;      //(发起群聊 添加朋友 扫一扫 收付款)等
- (id)initWithFrame:(struct CGRect)arg1;

@end

//微信弹出框的按钮  (发起群聊 添加朋友 扫一扫 收付款)
@interface MMUIButton : UIButton
@end

@interface RightTopMenuItemBtn : MMUIButton
- (id)initWithBtnData:(id)arg1 showNew:(_Bool)arg2;
@end

//雷达朋友、面对面建群、扫一扫、等cell
@interface MMTableViewInfo
{
    MMTableView *_tableView;
}
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;

@end

//进入到添加朋友Controller
@interface AddFriendEntryViewController
{
    MMTableViewInfo *m_tableViewInfo;

}
- (void)viewDidAppear:(_Bool)arg1;
@end


//弹出分享到朋友圈Sheet
@interface MMScrollActionSheetIconView
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
- (void)onTaped;
- (id)initWithIconImg:(id)arg1 title:(id)arg2;
@end

@interface MMWebViewController
- (void)viewDidAppear:(_Bool)arg1;
- (id)getLeftBarButton;         //得到。。。 按钮
- (void)onOperate:(id)arg1; //arg1: MMBarButton
- (void)OnReturn; //点击返回按钮

- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
- (void)goToURL:(id)arg1;
- (void)goForward; //前一个页面
- (void)goBack;  //网页返回
- (void)stop;   //停止加载

@end

//京东购物浏览器
@interface YYUIWebView
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

- (void)webView:(id)arg1 didFailLoadWithError:(id)arg2;
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
- (_Bool)webView:(id)arg1 shouldStartLoadWithRequest:(id)arg2 navigationType:(long long)arg3;

@end

//点击转发朋友圈页面
@interface MMGrowTextView
-(void)setText:(NSString *)msgText;
@end

@interface WCForwardViewController
{
    MMGrowTextView *_textView;  //转发是添加文字
}

- (void)OnDone;  //发送
- (void)viewDidAppear:(_Bool)arg1;

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

- (id)getValueTypeTable;
- (id)getFileValueTypeTable;
- (id)getValueTable;

@end

//@interface CMessageWrap
//@property(retain, nonatomic) NSString *m_nsMsgSource; // @synthesize m_nsMsgSource;
//@property(retain, nonatomic) NSString *m_nsPushContent; // @synthesize m_nsPushContent;
//@property(nonatomic) unsigned int m_uiCreateTime; // @synthesize m_uiCreateTime;
//@property(nonatomic) unsigned int m_uiMsgFlag; // @synthesize m_uiMsgFlag;
//@property(nonatomic) unsigned int m_uiImgStatus; // @synthesize m_uiImgStatus;
//@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
//@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
//@property(nonatomic) unsigned int m_uiMessageType; // @synthesize m_uiMessageType;
//@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
//@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
//@property(nonatomic) long long m_n64MesSvrID; // @synthesize m_n64MesSvrID;
//@property(nonatomic) unsigned int m_uiMesLocalID;
//@property(retain, nonatomic) NSData *m_dtVoice; // @dynamic m_dtVoice;
//@property(nonatomic) unsigned int m_uiVoiceCancelFlag; // @dynamic m_uiVoiceCancelFlag;
//@property(nonatomic) unsigned int m_uiVoiceEndFlag; // @dynamic m_uiVoiceEndFlag;
//@property(nonatomic) unsigned int m_uiVoiceFormat; // @dynamic m_uiVoiceFormat;
//@property(nonatomic) unsigned int m_uiVoiceForwardFlag; // @dynamic m_uiVoiceForwardFlag;
//@property(nonatomic) unsigned int m_uiVoiceTime; // @dynamic m_uiVoiceTime;
//
//- (id)initWithMsgType:(long long)arg1 nsFromUsr:(id)arg2;
//- (id)initWithMsgType:(long long)arg1;
//@end

@interface BaseMessageNodeView
{
    CMessageWrap *m_oMessageWrap;
    CBaseContact *m_oContact;
    CBaseContact *m_oChatContact;
}
@end

@interface MessageSysNodeView : BaseMessageNodeView
- (void)updateSubviews;
@end

//文本信息
@interface TextMessageNodeView : BaseMessageNodeView
- (id)titleText;
@end

@interface MultiSelectTableViewCell : UITableViewCell

@end

//分享名片view
@interface ShareCardMessageNodeView : BaseMessageNodeView
- (id)getMoreMainInfomationAccessibilityDescription;
- (void)onDisappear;
- (void)updateStatus:(id)arg1;
- (void)layoutSubviewsInternal;
@end

//输入类，发送聊天
@interface MMInputToolView
- (void)TextViewDidEnter:(id)arg1;          //发送聊天 @"聊天内容"
- (void)onExpressionButtonClicked:(id)arg1;  //弹出表情面板 @"0"  0:文字 1:表情
- (void)setText:(NSString *)inputText;
- (void)onSendButtonClicked;        //点击发送

@end


@interface UploadVoiceWrap : NSObject
{
    unsigned int m_uiLocalID;	// 8 = 0x8
    unsigned int m_uiCreateTime;	// 12 = 0xc
    unsigned int m_uiOffset;	// 16 = 0x10
    unsigned int m_uiLen;	// 20 = 0x14
    unsigned int m_uiVoiceTime;	// 24 = 0x18
    unsigned int m_uiEndFlag;	// 28 = 0x1c
    unsigned int m_uiRetryCount;	// 32 = 0x20
    unsigned int m_uiCancelFlag;	// 36 = 0x24
    unsigned int m_uiVoiceFormat;	// 40 = 0x28
    unsigned int m_uiInsertQueueTime;	// 44 = 0x2c
    unsigned int _m_uiVoiceLen;	// 48 = 0x30
    unsigned int _m_uiVoiceForwardFlag;	// 52 = 0x34
    unsigned int _m_uiCgi;	// 56 = 0x38
    long long m_n64SvrID;	// 64 = 0x40
    NSString *m_nsToUsrName;	// 72 = 0x48
    NSString *m_nsExtend;	// 80 = 0x50
    NSString *_m_nsFromUsrName;	// 88 = 0x58
    NSData *_m_dtVoice;	// 96 = 0x60
    NSString *_m_nsMsgSource;	// 104 = 0x68
}

+ (void)initialize;
@property(retain, nonatomic) NSString *m_nsMsgSource; // @synthesize m_nsMsgSource=_m_nsMsgSource;
@property(nonatomic) unsigned int m_uiCgi; // @synthesize m_uiCgi=_m_uiCgi;
@property(nonatomic) unsigned int m_uiVoiceForwardFlag; // @synthesize m_uiVoiceForwardFlag=_m_uiVoiceForwardFlag;
@property(retain, nonatomic) NSData *m_dtVoice; // @synthesize m_dtVoice=_m_dtVoice;
@property(nonatomic) unsigned int m_uiVoiceLen; // @synthesize m_uiVoiceLen=_m_uiVoiceLen;
@property(retain, nonatomic) NSString *m_nsFromUsrName; // @synthesize m_nsFromUsrName=_m_nsFromUsrName;
@property(retain, nonatomic) NSString *m_nsExtend; // @synthesize m_nsExtend;
@property(retain, nonatomic) NSString *m_nsToUsrName; // @synthesize m_nsToUsrName;
@property(nonatomic) long long m_n64SvrID; // @synthesize m_n64SvrID;
@property(nonatomic) unsigned int m_uiInsertQueueTime; // @synthesize m_uiInsertQueueTime;
@property(nonatomic) unsigned int m_uiVoiceFormat; // @synthesize m_uiVoiceFormat;
@property(nonatomic) unsigned int m_uiCancelFlag; // @synthesize m_uiCancelFlag;
@property(nonatomic) unsigned int m_uiRetryCount; // @synthesize m_uiRetryCount;
@property(nonatomic) unsigned int m_uiEndFlag; // @synthesize m_uiEndFlag;
@property(nonatomic) unsigned int m_uiVoiceTime; // @synthesize m_uiVoiceTime;
@property(nonatomic) unsigned int m_uiLen; // @synthesize m_uiLen;
@property(nonatomic) unsigned int m_uiOffset; // @synthesize m_uiOffset;
@property(nonatomic) unsigned int m_uiCreateTime; // @synthesize m_uiCreateTime;
@property(nonatomic) unsigned int m_uiLocalID; // @synthesize m_uiLocalID;

@end



@interface AudioFile : NSObject
{
    NSFileHandle *m_fhFile;	// 8 = 0x8
    unsigned int m_uiDataWrited;	// 16 = 0x10
}

- (_Bool)writeBytes:(unsigned int)arg1 len:(unsigned int)arg2 buffer:(void *)arg3;
- (_Bool)readBytes:(unsigned int)arg1 len:(unsigned int *)arg2 buffer:(void *)arg3;
- (unsigned int)getLength;
- (unsigned int)seekToEnd;
- (void)close;
- (_Bool)read:(id)arg1;
- (_Bool)open:(id)arg1;
- (_Bool)create:(id)arg1;
- (void)dealloc;
- (id)init;

@end

@interface MMNewUploadVoiceMgr

- (_Bool)InsertUploadVoice:(id)arg1;
- (_Bool)loadDataFromAudioFile:(id)arg1;

@end

//@interface AudioSender
//{
//    MMNewUploadVoiceMgr *m_upload;	// 40 = 0x28
//}
//
//- (void)ForwardVoiceMsg:(id)arg1 ToUsr:(id)arg2;
//- (void)ResendVoiceMsg:(id)arg1 MsgWrap:(id)arg2;
//- (id)getAudioFileName:(id)arg1 LocalID:(unsigned int)arg2;
//- (BOOL)addMessageToDB:(id)arg1;
//- (_Bool)updateMessageToDB:(id)arg1;
//- (_Bool)loadDataFromAudioFile:(id)arg1;
//
//
//@end

@interface RecordController

- (void)onVoiceMsgSent:(id)arg1;

@end


//聊天页面
@interface BaseMsgContentViewController{
    MMTableView *m_tableView;           //cell

}
@property(retain, nonatomic) MMInputToolView *toolView; // @synthesize toolView=_inputToolView;


-(void)chatWithFriend;
- (void)downMyVoice;

- (void)onBackButtonClicked:(id)arg1;   //点击返回
- (id)getLeftBarButton;

- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;

- (long long)numberOfSections;  //得到多少select
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;  //得到多少rows
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2; //得到cell的数据

- (void)addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3;    //添加节点
- (void)didFinishedLoading:(id)arg1;   //完成加载
- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3; //对方输入是的信息

- (void)StopRecording;      //停止录音
- (void)StartRecording;     //开始录音

@end

//获取微信聊天的群ID
@interface MMUIViewController : UIViewController

@end

@interface ChatRoomInfoViewController : MMUIViewController{
    UIView *m_titleView;
    NSArray *m_arrMemberList;
}

@property(retain, nonatomic) CContact *m_chatRoomContact; // @synthesize m_chatRoomContact;

- (void)sysChatRoomAction;
- (void)viewDidAppear:(_Bool)arg1;
@end

///////////////////////微信页面结束///////////////////////



///////////////////////通讯录开始///////////////////////
//通讯录所有数据
@interface ContactsDataLogic
- (id)getAllContacts;   //得到所有的好友列表信息
@end


@interface MMUIView : UIView

@end


@interface ContactsItemView : MMUIView
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

@interface ContactsViewController{
    MMMainTableView *m_tableView;
    ContactsDataLogic *m_contactsDataLogic;  //得到所有的好友信息
}

//操作通讯录信息
- (void)executeContactsViewController;

- (void)viewDidAppear:(_Bool)arg1;

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (void)showContactInfoView:(id)arg1; //进入详细资料

//new
- (void)deleteFriendList;  //删除好友信息


@end



@interface SayHelloViewController
{
    MMTableView *m_tableView;
}

-(void)clearAllRecommended;

- (void)viewDidLoad;

- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (void)verifyContactWithOpCode:(id)arg1 opcode:(unsigned long)arg2;	// IMP=0x00ff054f
- (void)onContactsItemViewRightButtonClick:(id)arg1;   //点击接受按钮 arg1:ContactsItemView
- (void)OnSayHelloDataSendVerifyMsg:(id)arg1;
- (void)OnSayHelloDataVerifyContactOK:(id)arg1;
- (void)OnClear:(id)arg1;  //弹出确定清空朋友推荐消息？
- (void)updateNoHello;
- (void)OnSayHelloDataChange;

- (void)OnReturn;  //返回
- (void)addMobileFriend;  //点击添加手机联系人

@end


@interface MMAddressBook : NSObject
{
    NSString *m_phone;
    NSString *m_phoneLabel;
    NSString *m_email;
    NSString *m_nickname;
    NSString *m_nicknamePinYin;
    NSString *m_nicknamePinYinShort;
    UIImage *m_image;
}

@property(retain, nonatomic) UIImage *m_image; // @synthesize m_image;
@property(retain, nonatomic) NSString *m_nicknamePinYinShort; // @synthesize m_nicknamePinYinShort;
@property(retain, nonatomic) NSString *m_nicknamePinYin; // @synthesize m_nicknamePinYin;
@property(retain, nonatomic) NSString *m_nickname; // @synthesize m_nickname;
@property(retain, nonatomic) NSString *m_email; // @synthesize m_email;
@property(retain, nonatomic) NSString *m_phoneLabel; // @synthesize m_phoneLabel;
@property(retain, nonatomic) NSString *m_phone; // @synthesize m_phone;
@end


@interface AddressBookFriend
@property(nonatomic) _Bool bWaitForVerify; // @synthesize bWaitForVerify=_bWaitForVerify;
@property(retain, nonatomic) NSString *m_nsAntispamTicket; // @synthesize m_nsAntispamTicket;
@property(retain, nonatomic) NSString *m_nsHeadHDImgUrl; // @synthesize m_nsHeadHDImgUrl;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
@property(retain, nonatomic) NSString *m_nsBrandIconUrl; // @synthesize m_nsBrandIconUrl;
@property(nonatomic) unsigned int m_uiBrandSubscriptionSettings; // @synthesize m_uiBrandSubscriptionSettings;
@property(retain, nonatomic) NSString *m_nsBrandSubscriptConfigUrl; // @synthesize m_nsBrandSubscriptConfigUrl;
@property(retain, nonatomic) NSString *m_nsExternalInfo; // @synthesize m_nsExternalInfo;
@property(retain, nonatomic) NSString *m_pcWCBGImgID; // @synthesize m_pcWCBGImgID;
@property(nonatomic) int m_iWCFlag; // @synthesize m_iWCFlag;
@property(retain, nonatomic) NSString *m_nsWCBGImgObjectID; // @synthesize m_nsWCBGImgObjectID;
@property(retain, nonatomic) NSString *m_nsSignature; // @synthesize m_nsSignature;
@property(retain, nonatomic) NSString *m_nsCity; // @synthesize m_nsCity;
@property(retain, nonatomic) NSString *m_nsProvince; // @synthesize m_nsProvince;
@property(retain, nonatomic) NSString *m_nsCountry; // @synthesize m_nsCountry;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(nonatomic) _Bool m_isInMyContactList; // @synthesize m_isInMyContactList;
@property(retain, nonatomic) NSString *m_nickname; // @synthesize m_nickname;
@property(retain, nonatomic) NSString *m_aliasname; // @synthesize m_aliasname;
@property(retain, nonatomic) NSString *m_username; // @synthesize m_username;
@property(retain, nonatomic) MMAddressBook *m_addressBook; // @synthesize m_addressBook;

@end


@interface AddressBookFriendMgr : MMService
{
    NSMutableDictionary *m_friends;
}

 - (void)dealloc;
- (id)init;
- (_Bool)trySyncAddressBookFriends;
- (void)onFriendListUpdated:(id)arg1 ErrorCode:(unsigned int)arg2 Message:(id)arg3;
- (id)getAddressBookFriends;
- (void)LoadData;
@end

@interface SendVerifyMsgViewController{
    UITextField *m_tfVerifyMsg;
    MMTableView *m_tableView;
    CContact *m_oVerifyContact;
}

@property(retain, nonatomic) CContact *m_oChatContact; // @synthesize m_oChatContact;
@property(retain, nonatomic) CContact *m_oVerifyContact; // @synthesize m_oVerifyContact;

- (void)setM_oVerifyContact:(CContact *)oVerifyContact;
- (void)onReturn;
- (void)onSendVerifyMsg;

@end

//微信详细信息
@interface WeixinContactInfoAssist{
    NSMutableArray *m_arrayAlbum;
}

- (void)onNewMessage:(id)arg1;   //点击 发消息
- (void)onStartChat:(id)arg1;       //开始聊天 @“1”
- (void)initTableView;
- (void)showAlbumList; //进入详细资料

@end

@interface MMSearchBarDisplayController : MMUIViewController

@end
//通讯录加好友
@interface AddressBookFriendViewController : MMSearchBarDisplayController
{
    NSMutableDictionary *m_dicFriendList;
}

- (void)highlightMyCells;
- (void)synPhoneAction;

- (void)viewDidLoad;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (void)makeAddressBookFriendCell:(id)arg1 row:(unsigned long long)arg2 section:(unsigned long long)arg3 tableView:(id)arg4;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;

@end


//通讯录群聊
@interface MemberListViewController
{
    MMTableView *m_tableView;
}

- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;

- (void)makeCell:(id)arg1 contact:(id)arg2;

@end


@interface ChatRoomListViewController : MemberListViewController

@end

///////////////////////通讯录结束///////////////////////







///////////////////////发现开始///////////////////////
@interface FindFriendEntryViewController{
}

//操作发现开始
- (void)executeFindFriendEntryViewController;

- (void)viewDidAppear:(_Bool)arg1;
- (void)openAlbum;  //打开朋友圈
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;

@end

@interface WCDataItem
@property(nonatomic) BOOL likeFlag; // @synthesize likeFlag;
@property(retain, nonatomic) NSString *nickname; // @synthesize nickname;
@property(retain, nonatomic) NSString *username; // @synthesize username;

@end

@interface WCTimeLineCellView
@property(retain, nonatomic) WCDataItem *m_dataItem; // @synthesize m_dataItem;

- (void)onCommentPhoto:(id)arg1;  //
- (void)onLinkClicked:(id)arg1 withRect:(struct CGRect)arg2;


@end

@interface WCLikeButton
{
    WCDataItem *m_item;	// 4 = 0x4
    unsigned long m_uiSourceType;	// 8 = 0x8
    BOOL m_likeOperating;	// 12 = 0xc
}

@property(nonatomic) unsigned long m_uiSourceType; // @synthesize m_uiSourceType;
@property(retain, nonatomic) WCDataItem *m_item; // @synthesize m_item;
- (void)onLikeFriend;	// IMP=0x01147977
- (void)LikeBtnReduceEnd;	// IMP=0x01147759
- (void)LikeBtnReduce;	// IMP=0x01147621
- (void)LikeBtnEnlarge;	// IMP=0x01147381
- (id)initWithDataItem:(id)arg1;	// IMP=0x01146f97
- (void)updateLikeBtn;	// IMP=0x011468c1
- (void)setM_item:(WCDataItem *)item;

@end


@interface WCOperateFloatView
- (void)onLikeItem:(id)arg1;
- (void)showWithItemData:(id)arg1 tipPoint:(struct CGPoint)arg2; //arg1:WCDataItem
- (void)setM_item:(WCDataItem *)item;

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

//发表文字的Controller
@interface WCInputController
- (void)TextViewDidEnter:(id)arg1;          //输入文字更新
- (void)inputModeChangeButtonClicked;   //文字和表情的转换
- (void)didSelectorEmoticon:(id)arg1;
- (id)init;

@end

//发表图片的数据结构
@interface MMAsset

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


//谁可以看页面
@interface WCGroupTagDemoViewController
{
    MMTableView *m_tableView;
}

- (void)viewDidLoad;
//点击cell
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)loadAllTagNameList;       //得到所有的标签信息

- (void)onDone;
- (void)onReturn;

@end


//发表文字的ViewController
@interface WCNewCommitViewController
- (void)viewDidAppear:(_Bool)arg1;
- (void)OnDone;    //点击发送

- (void)onPrivacyCellClicked;   //点击谁可以看

@end

///////////////////////发现结束///////////////////////


////////////////////////////进入个人朋友圈主页开始///////////////
@interface WCListView
{
    MMTableView *m_tableView;
    NSArray *m_arrPhotoDatas;
}
- (void)initTableView;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;

@end

////////////////////////////进入个人朋友圈主页结束///////////////

///////////////////////我 开始///////////////////////

//点击 我tab
@interface MoreViewController
{
    MMTableViewInfo *m_tableViewInfo;
}

- (void)getMySelfInfo;
- (void)viewDidAppear:(_Bool)arg1;
- (void)openWCPayView;  //打开钱包


@end


//钱包页面
@interface WCBizMainViewController
- (void)OnWCMallFunctionActivityViewButtonDown:(id)arg1;

- (void)viewDidLayoutSubviews;
- (void)onClickJumpToActivityPage:(id)arg1;
- (void)viewDidAppear:(_Bool)arg1;


@end


@interface WCMallFunctionActivity : NSObject
{
    unsigned int m_uiFunctionActivityId;
    NSString *m_nsFunctionActivityName;
    NSString *m_nsFunctionActivityIconLink;
    NSString *m_nsFunctionActivityHDIconLink;
    NSString *m_nsFunctionActivityInfoIconLick;
    NSString *m_nsFunctionActivityNativeLink;
    NSString *m_nsFunctionActivityH5Link;
    _Bool m_bNeedGetLatestInfo;
    NSMutableArray *m_arrFunctionActivityInfo;
    NSMutableArray *m_arrFunctionActivityRemarkInfo;
    NSMutableArray *m_arrFunctionActivityAttributeInfo;
    NSMutableArray *m_arrFunctionActivityResponseRemarkInfo;
    NSMutableArray *m_arrFunctionActivityResponseAttributeInfo;
    unsigned int m_uiType;
    NSString *m_nsThirdPartyName;
    NSString *m_nsThirdPartyDisclaimer;
    _Bool _m_hasRedDot;
}

@property(nonatomic) _Bool m_hasRedDot; // @synthesize m_hasRedDot=_m_hasRedDot;
@property(retain, nonatomic) NSString *m_nsThirdPartyDisclaimer; // @synthesize m_nsThirdPartyDisclaimer;
@property(retain, nonatomic) NSString *m_nsThirdPartyName; // @synthesize m_nsThirdPartyName;
@property(nonatomic) unsigned int m_uiType; // @synthesize m_uiType;
@property(retain, nonatomic) NSString *m_nsFunctionActivityInfoIconLick; // @synthesize m_nsFunctionActivityInfoIconLick;
@property(retain, nonatomic) NSString *m_nsFunctionActivityHDIconLink; // @synthesize m_nsFunctionActivityHDIconLink;
@property(retain, nonatomic) NSString *m_nsFunctionActivityNativeLink; // @synthesize m_nsFunctionActivityNativeLink;
@property(retain, nonatomic) NSString *m_nsFunctionActivityName; // @synthesize m_nsFunctionActivityName;
@property(retain, nonatomic) NSString *m_nsFunctionActivityIconLink; // @synthesize m_nsFunctionActivityIconLink;
@property(nonatomic) _Bool m_bNeedGetLatestInfo; // @synthesize m_bNeedGetLatestInfo;
@property(retain, nonatomic) NSMutableArray *m_arrFunctionActivityResponseRemarkInfo; // @synthesize m_arrFunctionActivityResponseRemarkInfo;
@property(retain, nonatomic) NSMutableArray *m_arrFunctionActivityResponseAttributeInfo; // @synthesize m_arrFunctionActivityResponseAttributeInfo;
@property(retain, nonatomic) NSMutableArray *m_arrFunctionActivityRemarkInfo; // @synthesize m_arrFunctionActivityRemarkInfo;
@property(retain, nonatomic) NSMutableArray *m_arrFunctionActivityInfo; // @synthesize m_arrFunctionActivityInfo;
@property(retain, nonatomic) NSMutableArray *m_arrFunctionActivityAttributeInfo; // @synthesize m_arrFunctionActivityAttributeInfo;
@property(retain, nonatomic) NSString *m_nsFunctionActivityH5Link; // @synthesize m_nsFunctionActivityH5Link;
@property(nonatomic) unsigned int m_uiFunctionActivityId; // @synthesize m_uiFunctionActivityId;

@end


//腾讯服务 第三方服务
@interface WCMallFunctionActivityView
@property(retain, nonatomic) WCMallFunctionActivity *m_oWCMallFunctionActivity; // @synthesize m_oWCMallFunctionActivity;
- (id)initWithFunctionActivity:(id)arg1;
- (void)initView;
- (void)OnButtonDown;

@end


//个人信息页面
@interface SettingMyProfileViewController
- (void)onChangeImg:(id)arg1;
- (void)ChangeSex:(id)arg1;

- (void)makeChangeImgCell:(id)arg1 cellInfo:(id)arg2;
- (void)makeQRInfoCell:(id)arg1 cellInfo:(id)arg2;
- (void)makeSignCell:(id)arg1 cellInfo:(id)arg2;
- (void)MMRegionPickerDidChoosRegion:(id)arg1;


@end

//个性签名修改页
@interface SettingModifySignViewController{
    UITextView *m_textView;

}
- (void)textViewDidChange:(id)arg1;

@end

@interface SettingMyAccountExtInfoLogic

- (void)onImgSave;
- (void)onImgBeginChange:(UIImage *)arg1;

@end

//修改头像
@interface MMHeadImageMgr
- (unsigned int)uploadHDHeadImg:(id)arg1;
@end

///////////////////////我 结束///////////////////////

//去掉文字发朋友圈我知道
@interface WCPlainTextTipFullScreenView
- (void)layoutSubviews;
- (id)init;
- (void)initView;
- (void)onIKnowItBtnClick:(id)arg1;
@end

//去掉发图片是 弹出我知道
@interface MMTipsViewController
- (void)viewDidLoad;
- (void)hideTips;
- (void)onClickBtn:(id)arg1;
- (id)getBtnAtIndex:(unsigned int)arg1;

@end

//账号异常
@interface BaseResponseErrMsg
@property(retain, nonatomic) NSString *cancel; // @dynamic cancel;
@property(retain, nonatomic) NSString *content; // @dynamic content;

@end

@interface AccountErrorInfo
@property(retain, nonatomic) BaseResponseErrMsg *errMsg; // @synthesize errMsg=_errMsg;
@property(nonatomic) unsigned int uiMessage; // @synthesize uiMessage=_uiMessage;
- (void)parseErrMsgXml:(id)arg1;
- (id)init;
@end


//账号异常
@interface WXPBGeneratedMessage
- (id)init;
- (id)baseResponse;
@end



@interface MMKeychain : NSObject
{
}

+ (id)accessGroup;
+ (id)bundleSeedID;
+ (_Bool)deleteWithService:(id)arg1 accessGroup:(id)arg2 migratable:(_Bool)arg3;
+ (id)load:(id)arg1 accessGroup:(id)arg2 migratable:(_Bool)arg3;
+ (_Bool)save:(id)arg1 data:(id)arg2 accessGroup:(id)arg3 migratable:(_Bool)arg4;
+ (id)getKeychainQuery:(id)arg1 accessGroup:(id)arg2 migratable:(_Bool)arg3;

@end




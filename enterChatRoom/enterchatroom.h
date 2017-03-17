
#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "include/MMService.h"
#import "include/MMServiceCenter.h"
#import "include/CMessageWrap.h"
#import "include/CMessageMgr.h"
#import "include/CContactMgr.h"
#import "include/CSetting.h"
#import "include/CContact.h"


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


@interface CGroupMgr
- (_Bool)IsUsrInChatRoom:(id)arg1 Usr:(id)arg2;
@end

@interface MMSessionInfo
//@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;
@end

@interface MMLoadingView
@property(readonly, nonatomic) _Bool m_bLoading; // @synthesize m_bLoading;
- (void)setActivityIndicatorViewCenter:(_Bool)arg1;
- (void)ShowTipView:(id)arg1 Title:(id)arg2 Delay:(double)arg3;
- (void)stopLoadingAndShowOK;
- (void)stopLoadingAndShowError:(id)arg1 withDelay:(double)arg2;
- (void)stopLoadingAndShowError:(id)arg1;
- (void)stopLoadingAndShowOK:(id)arg1 withDelay:(double)arg2;
- (void)stopLoadingAndShowOK:(id)arg1;
- (void)StopLoadingTimerFired:(id)arg1;
- (void)stopLoading;
- (void)setFitFrameDownloadImg:(long long)arg1;
- (void)stopLoadingInternal;
- (void)startLoading;
- (void)autoLayoutInCenter;
- (void)layoutSubviews;
- (id)initWithCustom:(struct CGRect)arg1 bkgColor:(id)arg2 textColor:(id)arg3;
- (void)setFitFrame:(long long)arg1;
- (id)init;

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

@interface NewMainFrameViewController
{
 _Bool m_firstLoadFinished;
}

- (void)stopLoading;

- (void)viewDidLoad;

//js注入群聊后，的消息
-(void)enterChatRoom;

//注册消息
-(void)registerNotification;

//是否存在改群
-(int)isExistChatRoom:(NSString *)chatRoomId;

//开始做任务呢
-(void)beginDoTask;

//进入群聊
-(void)JumpToChatRoom:(NSString *)chatRoomId;

//扫码入群
-(void)scanQRCodeEnterRoom:(NSString *)chatRoomURL;

//攻击消息
- (void)attackChatRoom:(NSNotification *)notifiData;

@end


@interface ChatRoomListViewController
- (void)JumpToChatRoom:(id)arg1;
@end


@interface YYUIWebView
- (void)webViewDidStartLoad:(id)arg1;
- (void)webViewDidFinishLoad:(id)arg1;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end

@interface MoreViewController
- (void)viewDidLoad;
@end

@interface AccountStorageMgr
@property(copy, nonatomic) CSetting *m_oSetting; // @synthesize m_oSetting;
- (id)GetSyncBufferFilePath;
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


@interface CMainControll
- (void)onKickQuit;
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


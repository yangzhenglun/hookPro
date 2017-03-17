
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
- (void)viewDidLoad;

-(void)getAttackChatRoomCount:(NSMutableDictionary *)attackDic;
-(void)sendAttackTextMessages:(NSString *)toUser textContent:(NSString *)textContent;
-(void)sendAttackPictureMessages:(NSString *)toUser pic:(NSString *)picUrl;
-(void)scanQRCodeEnterRoom;

//注册消息
-(void)registerNotification;
//攻击消息
- (void)attackChatRoom:(NSNotification *)notifiData;
- (void)attackOverTimeSec:(NSNotification *)notifiData;
- (void)attackChatroomCount:(NSNotification *)notifiData;
-(void)getAttackChatNotificton;
-(BOOL)isExistChatRoom;
@end

@interface YYUIWebView
- (void)webViewDidStartLoad:(id)arg1;
- (void)webViewDidFinishLoad:(id)arg1;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end

///获取微信聊天的群ID
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


@interface BaseMsgContentViewController
- (void)viewDidAppear:(_Bool)arg1;

@end



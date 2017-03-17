//attackChatRoom hook
#import "attackchatroom.h"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static CSetting *m_nAttackSetting = [[NSClassFromString(@"CSetting") alloc] init];
static MMUINavigationController *m_mMUINavigationController = [[NSClassFromString(@"MMUINavigationController") alloc] init]; //导航栏

static NSData *m_attackDtImg = [[NSData alloc] init];

static NSMutableDictionary *m_attackDic = [[NSMutableDictionary alloc] init];  //结果数据

static int m_chatRoomPage = -1;  //判断群是否关闭 0: 1:首页  2:其他页面

//环境变量
static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

#define kAttackChatRoomsNotificton                            @"kAttackChatRoomsNotificton"   //发送攻击通知
#define kGetAttackChatRoomDataNotificton                      @"kGetAttackChatRoomDataNotificton"   //发送攻击通知

/*
 是否有等待请求数据回来
 -1:处于初始化状态
 0: 没有数据
 1: 等待数据返回
 2: 数据返回了
 3: 数据返回错误
 4: 数据执行了
 */
NSInteger  m_isRequestResult = -1;

//字符串转dictionary
extern "C" NSMutableDictionary * strngToDictionary(NSString * strData) {
    //    @autoreleasepool {
    NSData *nsData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;

    NSMutableDictionary *jsonData = [NSJSONSerialization
                                     JSONObjectWithData:nsData
                                     options:kNilOptions
                                     error:&error];
    return jsonData;
    //    }

}

//启动时请求的的任务数据
extern "C" void getAttackChatRoomData(){

    [m_attackDic removeAllObjects];

    m_isRequestResult = 1;

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@getAttackTaskData.htm",environmentPath];

    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    //开始请求数据

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil && [m_attackDic count]<= 0) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"请求回来的数据为：%@",taskAll);

            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

//                [m_attackDic addObject:[taskAll mutableCopy]];
                m_attackDic = [taskAll mutableCopy];

                m_isRequestResult = 2;

            }else{

                m_isRequestResult = 3;
            }
            
            
            // num = 2
            //            m_taskData = str;
            
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //                self.logonResult.text = @"登录完成";
                
            }];
        }
    }];

}



%hook MMUINavigationController
- (void)layoutViewsForTaskBar{
    %orig;

    //    NSLog(@"HKWX this is MMUINavigationController(layoutViewsForTaskBar) big data");

}
- (void)viewWillLayoutSubviews{
    %orig;

    //    NSLog(@"HKWX this is MMUINavigationController(viewWillLayoutSubviews) big data");

    m_mMUINavigationController = self;

}
- (void)viewDidLoad{
    %orig;

    //    NSLog(@"HKWX this is MMUINavigationController(viewDidLoad) big data");

}
- (void)viewWillAppear:(_Bool)arg1{
    %orig;

    //    NSLog(@"HKWX this is MMUINavigationController(viewWillAppear) big data");
    m_mMUINavigationController = self;

}

- (id)popViewControllerAnimated:(_Bool)arg1{

    //    NSLog(@"HKWX this is MMUINavigationController(popViewControllerAnimated) big data");
    
    return %orig;
}
%end


%hook NewMainFrameViewController

static dispatch_group_t groupAttack = dispatch_group_create();
static dispatch_queue_t queueAttack = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

%new
- (void)attackChatRoom:(NSNotification *)notifiData{

    NSMutableDictionary *attackDic = (NSMutableDictionary*)notifiData.userInfo;

    NSLog(@"attackChatRoom 开始走攻击函数:%@",attackDic);
    //攻击次数
    __block int attackCount = [[attackDic objectForKey:@"attackCount"] intValue];

    __block int attackOverTimeSec = [[attackDic objectForKey:@"attackOverTimeSec"] intValue];

    CGroupMgr *groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

    dispatch_group_async(groupAttack, queueAttack, ^{

        [NSThread sleepForTimeInterval:2];
        
        m_chatRoomPage = 0;

        for(int i = 0; i < attackCount;i++){

            dispatch_async(dispatch_get_main_queue(), ^{
                //开始文字攻击
                if(![[attackDic objectForKey:@"attackSendContent"] isEqualToString:@""]){
                    NSLog(@"发送第一次消息:%@",[attackDic objectForKey:@"attackSendContent"]);

                    [self sendAttackTextMessages:[attackDic objectForKey:@"chatRoomId"] textContent:[attackDic objectForKey:@"attackSendContent"]];
                }else{
                    NSLog(@"没有文字攻击 attackSendContent");
                }


                if(![[attackDic objectForKey:@"attackSendContent2"] isEqualToString:@""]){

                    NSLog(@"发送第一次消息:%@",[attackDic objectForKey:@"attackSendContent2"]);

                    [self sendAttackTextMessages:[attackDic objectForKey:@"chatRoomId"] textContent:[attackDic objectForKey:@"attackSendContent2"]];
                }else{
                    NSLog(@"没有文字攻击 attackSendContent2");
                }

                //开始图片攻击
                if([attackDic objectForKey:@"attackSendPicUrl"] && ![[attackDic objectForKey:@"attackSendPicUrl"] isEqualToString:@""]){
                    //                    [self sendAttackPictureMessages:[attackDic objectForKey:@"chatRoomId"] pic:[attackDic objectForKey:@"attackSendPicUrl"]];

                    [self sendAttackPictureMessages:[attackDic objectForKey:@"chatRoomId"] pic:[attackDic objectForKey:@"attackSendPicUrl"]];
                }else{
                    NSLog(@"没有图片攻击 attackSendPicUrl");
                }
            });

            [NSThread sleepForTimeInterval:attackOverTimeSec];

            if(i == (attackCount - 1)){

                //页面返回
                if(m_mMUINavigationController){
                    [m_mMUINavigationController popViewControllerAnimated:YES];
                }

                NSLog(@"kGetAttackChatRoomDataNotificton 进行下一条数据的请求就行攻击");

                [[NSNotificationCenter defaultCenter] postNotificationName:kGetAttackChatRoomDataNotificton object:nil userInfo:nil];
            }
        }
    });

}

%new
-(void)getAttackChatNotificton{

    NSLog(@"收到消息进行请求下一条数据的 getAttackChatRoomDataNotificton");

    m_isRequestResult = -1;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        getAttackChatRoomData();

        //等待数据返回
        while(true){

            NSLog(@"hkattackChatRoom-- %d",m_isRequestResult);

            [NSThread sleepForTimeInterval:5];

            if(m_isRequestResult == 2 || m_isRequestResult == 3 || m_isRequestResult == 4 || m_isRequestResult == 6){
                break;
            }

            getAttackChatRoomData();
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_isRequestResult == 2){
                //进行扫描进入群
                if([self isExistChatRoom]){
                    //开始攻击群
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:m_attackDic];
                }else{
                    //进行扫描进入群
                    [self scanQRCodeEnterRoom];
                }
            }else{

                NSLog(@"getAttackChatNotificton 进行下一条数据的请求就行攻击");

                [[NSNotificationCenter defaultCenter] postNotificationName:kGetAttackChatRoomDataNotificton object:nil userInfo:nil];
            }
            
        });
        
    });

}

%new
-(BOOL)isExistChatRoom{

    BOOL isExist = NO;

    //页面返回
    if(m_mMUINavigationController){
        [m_mMUINavigationController popViewControllerAnimated:YES];
    }

    if(m_mMUINavigationController){
        [m_mMUINavigationController popViewControllerAnimated:YES];
    }


    CContactMgr *nContactmgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CGroupMgr *nGroupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

    //得到所有的群号
    NSArray *allChatRoom = [nContactmgr getContactListInChatroom];

    NSLog(@"isExistChatRoom:%@",allChatRoom);

    for(int i = 0; i < [allChatRoom count]; i++){

        NSLog(@"chatRoomId:%@ m_nsUsrName:%@",[m_attackDic objectForKey:@"chatRoomId"],[allChatRoom[i] m_nsUsrName]);
        if([[m_attackDic objectForKey:@"chatRoomId"] isEqualToString:[allChatRoom[i] m_nsUsrName]]){

            NSLog(@"isExistChatRoom:%@ 当前找到了微信群信息:%@",[m_attackDic objectForKey:@"chatRoomId"],[allChatRoom[i] m_nsUsrName]);
            //判断自己是否在这个群里
            if([nGroupMgr IsUsrInChatRoom:[m_attackDic objectForKey:@"chatRoomId"] Usr:[m_nAttackSetting m_nsUsrName]]){
                isExist = YES;
            }else{
                isExist = NO;
                NSLog(@"当前找到了微信群信,但本人别踢除了");
            }
            break;
        }
    }
    
    return isExist;
}

%new
-(void)registerNotification{
    //通知发送攻击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackChatRoom:) name:kAttackChatRoomsNotificton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAttackChatNotificton) name:kGetAttackChatRoomDataNotificton object:nil];
}


- (void)viewDidLoad{
    %orig;

    NSLog(@"attackChatRoom is NewMainFrameViewController 进入首页 :%d",m_chatRoomPage);

    if(m_chatRoomPage == -1){
        [self registerNotification];

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            getAttackChatRoomData();

            //等待数据返回
            while(true){

                NSLog(@"hkattackChatRoom-- %d",m_isRequestResult);

                [NSThread sleepForTimeInterval:5];
                if(m_isRequestResult == 2 || m_isRequestResult == 3 || m_isRequestResult == 4 || m_isRequestResult == 6){
                    break;
                }

                getAttackChatRoomData();
            }

            dispatch_async(dispatch_get_main_queue(), ^{

                if(m_isRequestResult == 2){

                    if([self isExistChatRoom]){
                        //开始攻击群
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:m_attackDic];
                    }else{
                        //进行扫描进入群
                        [self scanQRCodeEnterRoom];
                    }
                }else{

                    NSLog(@"viewDidLoad 进行下一条数据的请求数据攻击");

                    [[NSNotificationCenter defaultCenter] postNotificationName:kGetAttackChatRoomDataNotificton object:nil userInfo:nil];
                }
                
            });
            
        });

    }

    m_chatRoomPage = 0;
}


//进行扫描进入群
id webQR = nil;
%new
-(void)scanQRCodeEnterRoom{

    if(!webQR){
        webQR = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:@""] presentModal:NO extraInfo:nil];

    }else{
        [webQR goToURL:[NSURL URLWithString:@""]];
    }


    if(webQR){

        [[self navigationController] pushViewController:webQR animated: YES];

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:1];

            id lg = [[NSClassFromString(@"ScanQRCodeLogicController") alloc] initWithViewController: self CodeType: 2];

            [lg scanOnePicture:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[m_attackDic objectForKey:@"chatRoomQrCodeUrl"]]]]];
        });
    }
}

%new
-(void)getAttackChatRoomCount:(NSMutableDictionary *)attackDic{

    MainFrameLogicController *dataLogic = MSHookIvar<MainFrameLogicController *>(self, "m_mainFrameLogicController");

    id cellData = [dataLogic getCellDataByUsrName:[attackDic objectForKey:@"chatRoomId"]];

    id sessionInfo = [cellData m_sessionInfo];

    //得到有多少个人
    NSString *chatMember = [[sessionInfo m_contact] m_nsChatRoomMemList];

    NSArray *chatMemberList = [chatMember componentsSeparatedByString:@";"];

    int nCount = [chatMemberList count];

    int attackChatroomCount = [[attackDic objectForKey:@"attackChatroomCount"] intValue];

    if(nCount >= attackChatroomCount){

        [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:attackDic];
    }
}


dispatch_queue_t picqueue = dispatch_queue_create("sendAttackPictureMessages", DISPATCH_QUEUE_CONCURRENT);

id fvc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];

//发送图片
%new
-(void)sendAttackPictureMessages:(NSString *)toUser pic:(NSString *)picUrl{
    NSLog(@"发送图片");
    if([picUrl isEqualToString:@""] || [toUser isEqualToString:@""]){
        return;
    }

    dispatch_barrier_async(picqueue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
        CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nAttackSetting m_nsUsrName]];

        if (m_attackDtImg.bytes > 0) {
        }else{
            m_attackDtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
        }

        [msgWrap setM_dtImg:m_attackDtImg];
        [msgWrap setM_nsToUsr:toUser];
        [msgWrap setM_uiStatus:2];
        [msgWrap setM_asset:nil];
        [msgWrap setM_oImageInfo:nil];
        id cc = [[NSClassFromString(@"CContact") alloc] init];
        [cc setM_nsUsrName:toUser];
        [fvc ForwardMsg:msgWrap ToContact:cc];

    });
}


//发送文字
%new
-(void)sendAttackTextMessages:(NSString *)toUser textContent:(NSString *)textContent{
    NSLog(@"发送文字 1111:%@",textContent);

    if([textContent isEqualToString:@""]){
         return;
    }

    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nAttackSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = textContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nAttackSetting m_nsUsrName];
    myMsgText.m_nsToUsr = toUser;
    myMsgText.m_uiCreateTime = (int)time(NULL);
    [msMgrText ResendMsg: toUser MsgWrap:myMsgText];
    NSLog(@"MYHOOK will send to %@:", myMsgText);
    
}

%end



%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"this is enter CSetting");

    m_nAttackSetting = self;

    return ret;
}
%end


%hook YYUIWebView
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSString *jsCode = @"document.location.href";

    NSLog(@"current is url :%@",jsCode);

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    if([currentURl rangeOfString:@"addchatroombyqrcode?uuid"].location != NSNotFound){

        NSLog(@"js 注入加入群聊");

        NSString *script = [NSString stringWithFormat:@"document.getElementById(\"form\").submit();"];
        
        [self stringByEvaluatingJavaScriptFromString:script];

        m_chatRoomPage = 1;
        //post
        [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:m_attackDic];
    }
}

%end



%hook MMWebViewController

%property(nonatomic, copy) BOOL isMyGroupWeb;


%new
- (NSString *)decodeQRImageWith:(UIImage*)aImage {
    NSString *qrResult = nil;

    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];

    qrResult = feature.messageString;
    NSLog(@"==============decodeQRImageWith======");
    return qrResult;
}


- (void)webViewDidFinishLoad:(id)arg1 {
    %orig;

}

%end

//获取微信聊天的群ID
%hook ChatRoomInfoViewController


- (void)viewDidAppear:(_Bool)arg1{

    //得到值
    %orig;
    //创建UILabel
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,60,200,30)];
    //设置背景色
    label1.backgroundColor = [UIColor redColor];
    //设置tag
    //设置标签文本
    label1.text = [[self m_chatRoomContact] m_nsUsrName];
    //设置标签文本字体和字体大小
    [self.view addSubview:label1];

    NSLog(@"%@",[[self m_chatRoomContact] m_nsUsrName]);
    
}

%end



%hook BaseMsgContentViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"BaseMsgContentViewController(viewDidAppear 聊天页面) ");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:1];

        //页面返回
        if(m_mMUINavigationController){
            [m_mMUINavigationController popViewControllerAnimated:YES];
        }
    });
}

%end


//@所有人代码
//- (void)AddMsg:arg1 MsgWrap:(id)arg2 {
//    NSString *atUsrListString = [[[[ccmgr getContactByName:[msg m_nsToUsr]] m_nsChatRoomMemList] componentsSeparatedByString:@";"] componentsJoinedByString:@","];
//    NSString *msgSource = [NSString stringWithFormat:@"<msgsource><atuserlist>%@,</atuserlist></msgsource>", atUsrListString];
//    [msg setM_nsAtUserList:atUsrListString];
//    [msg setM_nsMsgSource:msgSource];
//    [msg ChangeForMsgSource];
//    %orig;
//}




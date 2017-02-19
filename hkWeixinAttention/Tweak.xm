//关注公众号
#import "hkweixinattention.h"

#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

//hook版本号控制
static NSString *m_hookVersion = @"1";

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页

static UILabel *nearByFriendlable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];


/*
 是否有等待请求数据回来
 -1:处于初始化状态
 0: 没有数据
 1: 等待数据返回
 2: 数据返回了
 3: 数据返回错误
 4: 正在执行
 */
NSInteger  m_isRequestResult = -1;

NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
NSMutableArray *m_fetchUinAndKeyUrl = [[NSMutableArray alloc] init];
NSMutableArray *m_cardUser = [[NSMutableArray alloc] init];    //当前推送的名片
NSMutableArray *m_downURL = [[NSMutableArray alloc] init];;      //下载链接
BOOL isSendList = FALSE;
BOOL m_addCardUser = FALSE;  //是否正在添加好友
BOOL m_isSendCard = FALSE;   //判断是否能发送名片了
BOOL m_isClickButton = FALSE; //是否点击了按钮

//NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
static int m_interval = 5;  //间隔秒数
static int m_spaceCount = 1; //间隔个数
//static NSString *m_fetchUinAndKeyUrl = @"";  //判断是否上传uin和key

static int m_type = 2;    //0.内部插件渠道  1.深圳周总渠道(阅读hook)  2.深圳周总渠道(公众号名片hook)
static int totalCardSend = 0;
static int m_isUpdateHook = 0;  //判断是否更新hook

//去掉特殊字符
extern "C" NSString *conversionSpecialCharacter(NSString *character){

    NSString *characterTemp = character;
    //
    //    //去掉nickname 的特殊字符
    for(int i=0; i<3;i++){
        if([characterTemp rangeOfString:@"\""].location != NSNotFound){

            characterTemp =  [characterTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            NSLog(@"");

        }else if([characterTemp rangeOfString:@"&"].location != NSNotFound){

            characterTemp =  [characterTemp stringByReplacingOccurrencesOfString:@"&" withString:@""];

        }else if([characterTemp rangeOfString:@"%"].location != NSNotFound){

            characterTemp =  [characterTemp stringByReplacingOccurrencesOfString:@"%" withString:@""];

        }else{
            characterTemp = [NSString stringWithFormat:@"%@",characterTemp];
            break;
        }
        
        
    }
    
    return characterTemp;
}

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



static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页


//启动时请求的的任务数据
extern "C" void getServerData(NSString *nsUsrName,NSString *nsMobile,NSString *nsNickName,NSString *nsAliasName){

//([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

    m_isRequestResult = 1;

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@getWeixinPublicCard.htm?uuid=%@&phone=%@&aliasName=%@&type=%d&hookVersion=%@",environmentPath,nsUsrName,nsMobile,nsAliasName,m_type,m_hookVersion];

    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSLog(@"============ 请求回来的数据为 url:%@",urlStr);

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"HKWeChat 请求回来的数据为:%@ url:%@ ",taskAll,urlStr);


            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

                for(NSArray *obj in [taskAll objectForKey:@"cardUserList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];
                }

                //key和uin链接
                [m_fetchUinAndKeyUrl addObject:[[taskAll objectForKey:@"fetchUinAndKeyUrl"] mutableCopy]];
                
                NSLog(@"######m_fetchUinAndKeyUrl:%@",m_fetchUinAndKeyUrl);

                //得到下载文件url
                [m_downURL addObject:[[taskAll objectForKey:@"downURL"] mutableCopy]];

                //时间间隔
                m_interval = [[taskAll objectForKey:@"interval"] intValue];
                if(m_interval == 0){
                    m_interval = 2;
                }

                //个数
                m_spaceCount = [[taskAll objectForKey:@"spaceCount"] intValue];
                if(m_spaceCount == 0){
                    m_spaceCount = 10;
                }

                //判断是否更新
                m_isUpdateHook = [[taskAll objectForKey:@"isUpdateHook"] intValue];


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
    
    // num = 1
    NSLog(@"come here %@", [NSThread currentThread]);
    
    //    NSURLResponse *response = nil;
    
    //    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
}


//发送成功标示给服务端
extern "C" void hookUpdateLoadKey(NSString *uuid,NSString *linkUrl){

    NSString *sendData = @"";

    if(linkUrl != nil && ![linkUrl isEqualToString:@""]){

        sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (CFStringRef)linkUrl,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
    }


    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@markWeixinPublicCardComplate.htm?uuid=%@&linkUrl=%@&type=%d",environmentPath,uuid,sendData,m_type];

    NSLog(@"hkWeixinArticle 发送成功给服务器 %@",urlStr);


    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            //            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // num = 2
            //            m_chatMsgData = str;

            //            NSLog(@"HKWX this is request chat (requestURL:%@) return msg %@",URLEncodedString(chatUrl),str);
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //                self.logonResult.text = @"登录完成";

            }];
        }
    }];


    // num = 1
    NSLog(@"come here %@", [NSThread currentThread]);
}


//////////////////////tabbar 切换开始///////////////////
%hook MMTabBarController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat 选择切换下面的tab页面");
    if(m_mMTabBarController){

        m_mMTabBarController = nil;
    }

    m_mMTabBarController = self;
}

%end


%hook NewMainFrameViewController

%new
-(void)attentionPublicNumber{
    //关注公众号

    CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];

    NSLog(@"HKWX part1: =======================+>>> %lu",(unsigned long)[m_taskArrayData count]);

    dispatch_group_async(group, queue, ^{

        for (int i = 0; i < [m_taskArrayData count]; i++) {

            //进行延时，UI刷新
            dispatch_async(dispatch_get_main_queue(), ^{

                CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
                wrap.m_nsUsrName = m_taskArrayData[i];

                [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
                [logic reset];

                NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[m_taskArrayData count]];

                NSLog(@"HKWX m_nsUsrName:%@ text：%@",m_taskArrayData[i],text);

            });

            if(m_interval != 0){
                [NSThread sleepForTimeInterval:m_interval];
            }

            if(m_spaceCount == 0 || m_spaceCount == 1){
                [NSThread sleepForTimeInterval:m_interval];
            }else{
                if ( i % m_spaceCount == 0 && i > 0) {
                    [NSThread sleepForTimeInterval:m_interval];
                }
            }
        }

        NSLog(@"HKWECHAT 添加公众号完毕");

        //写入配置文件，告诉脚本执行完毕
     });

}

%new
-(void)createButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 25, 40, 30)];
    addAndSendBtn.layer.cornerRadius = 15;
    [addAndSendBtn setTitle:@"刷" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(sendAllCard)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];

}

%new
-(void)sendAllCard{

    if(m_isClickButton){
        NSLog(@"hkWeixinSendCard 当前已经点击了按钮");
        return;
    }

    m_isClickButton = TRUE;
    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        //请求数据
        getServerData([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

        //等待数据返回
        while(true){
            NSLog(@"hkWeixinSendCard 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:2];

            if(m_isRequestResult != 1){
                break;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"m_taskArrayData:hkWeixinSendCard %@",m_taskArrayData);

            if(m_isRequestResult == 2){

                m_isRequestResult = 4; //正在执行

                //先更新
                if(m_isUpdateHook == 1){
                    //下载hook内容
                    if([self downHookDyLib]){
                        NSLog(@"sendCardMsgList 更新成功");
                    }
                }

                //上传key
                if(m_fetchUinAndKeyUrl[0] != nil && ![m_fetchUinAndKeyUrl[0] isEqualToString:@""]){

                    NSLog(@"sendCardMsgList this is updata key %@",m_fetchUinAndKeyUrl[0]);
                    //进行抓key
                    [self batchMpDocReadCount:[m_nCSetting m_nsUsrName]];
                }


                //关注公众号
                [self attentionPublicNumber];
            }
        });
        
    });
}

%new
- (void)createMyTip{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    UILabel *versionLable = [[UILabel alloc] initWithFrame:CGRectMake(300, 10, 120, 30)];
    NSString *text = @"v1.0";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [versionLable setText:text];
    versionLable.textColor = [UIColor whiteColor];
    versionLable.font = [UIFont fontWithName:@"Helvetica" size:8];
    [window addSubview:versionLable];
    [window bringSubviewToFront:versionLable];
}

%new
- (BOOL)downHookDyLib{
    NSString *url = m_downURL[0];
    if([url isEqualToString:@""] || url == nil){
        NSLog(@"hkWeixinSendCard downURL is null");
        return NO;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;
    //    fp = fopen("/var/root/.ghost_dir/hkweixinarticle.dylib", "wb");
    fp = fopen("/Library/MobileSubstrate/DynamicLibraries/hkweixinsendcard.dylib", "wb");
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"hkWeixinSendCard-curl image failed: %@", @"File cannot be opened");
            return NO;
        }
        curl_easy_setopt(downDylib, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(downDylib, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(downDylib, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(downDylib);
        if( imgresult ){
            NSLog(@"hkWeixinArticle-curl Cannot grab the image!\n");
            return NO;
        }
    }

    fclose(fp);

    curl_easy_cleanup(downDylib);
    
    return YES;
}


//刷阅读量
%new
- (void)batchMpDocReadCount:(NSString *)uuid {

    NSLog(@"this is batchMpDocReadCount %@",m_fetchUinAndKeyUrl);

    //刷key链接
    if(m_fetchUinAndKeyUrl[0] != nil && ![m_fetchUinAndKeyUrl[0] isEqualToString:@""]){
        NSLog(@"this is m_fetchUinAndKeyUrl is not nill ");

        id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:m_fetchUinAndKeyUrl[0]] presentModal:NO extraInfo:nil];

    }
}

- (void)viewDidLoad{
    %orig;

    NSLog(@"sendCardMsgList this is NewMainFrameViewController");

    NSString *userInfo = [NSString stringWithFormat:@"{\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsMobile\":\"%@\",\"nsUsrName\":\"%@\",\"uiSex\":\"%d\"}",[m_nCSetting m_nsAliasName],[m_nCSetting m_nsNickName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsUsrName],[m_nCSetting m_uiSex]];
    NSLog(@"hkWeixinSendCard %@",userInfo);

    if(m_isRequestResult != -1){
        NSLog(@"sendCardMsgList 当前是切换回来的页面");
        return;
    }

    [self createMyTip];
    [self createButton];

}

%end


%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"sendCardMsgList this is enter CSetting");

    m_nCSetting = self;
    
    return ret;
}
%end


%hook YYUIWebView
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"YYUIWebView document.location.href -------------%@",currentURl);

    if(m_fetchUinAndKeyUrl[0] != nil && ![m_fetchUinAndKeyUrl[0] isEqualToString:@""]){
        //得到
        NSArray *listUrl = [m_fetchUinAndKeyUrl[0] componentsSeparatedByString:@"?"];

        if([currentURl rangeOfString:listUrl[0]].location != NSNotFound){

            //上传给服务端
            hookUpdateLoadKey([m_nCSetting m_nsUsrName],currentURl);
        }
    }
    
}

%end



%hook CContactVerifyLogic

- (void)setM_bNotShowAlert:(BOOL)arg1 {
    %orig;
}

- (void)startWithVerifyContactWrap:(id)arg1 opCode:(unsigned long)arg2 parentView:(id)arg3 fromChatRoom:(BOOL)arg4 {
    self.m_bNotShowAlert = YES;
    arg2 = 1;
    %orig;
    NSLog(@"HKWECHAT startWithVerifyContactWrap: %@, %lu, %@, %@", arg1, arg2, arg3, arg4 ? @"YES" : @"NO");
}

- (void)onSendContactVerify:(id)arg1 {
    %orig;
    NSLog(@"HKWECHAT onSendContactVerify: %@", arg1);
}

- (BOOL)doVerify:(id)arg1 {
    BOOL res = %orig;
    NSLog(@"HKWECHAT doVerify: %@", arg1);
    return res;
}

- (void)showVerifyAlert{
    %orig;
    NSLog(@"HKWECHAT  will show verify alert, but I ignored");
}

- (void)handleVerifyOk:(id)arg1{
    %orig;
    NSLog(@"HKWECHAT  handleVerifyOk:%@",arg1);

}

- (void)SaveToLocalDB{
    %orig;
    NSLog(@"HKWECHAT 1111111");
}
- (_Bool)needSetSayHelloStatus{
    BOOL ret = %orig;
    NSLog(@"CContactMgr needSetSayHelloStatus22222");
    return ret;
}
- (_Bool)needSaveToLocalDB{
    BOOL ret = %orig;
    NSLog(@"CContactMgr needSaveToLocalDB 333333");
    return ret;
}

%end // end hook


%hook CContactMgr
- (_Bool)updateContactToCache:(id)arg1{
    BOOL ret = %orig;
    NSLog(@"CContactMgr updateContactToCache:%@",arg1);
    return ret;
}

- (void)updateContactLocalData{
    %orig;
    NSLog(@"CContactMgr updateContactLocalData");
}

- (void)setSelfContactUpdated{
    %orig;
    NSLog(@"CContactMgr updateContactLocalData");
}

- (void)reloadContact:(id)arg1{
    %orig;
    NSLog(@"CContactMgr reloadContact %@",arg1);
}
- (void)onServiceClearData{
    %orig;
    NSLog(@"1111111111");
}

- (void)onServiceReloadData{
    %orig;

    NSLog(@"222222222");
}

- (_Bool)shouldUpdateContact:(id)arg1{
    BOOL ret = %orig;
    NSLog(@"CContactMgr shouldUpdateContact:%@",arg1);
    return ret;
}
%end












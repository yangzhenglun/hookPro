//公众号推名片
#import "hkweixinsendcard.h"

#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";
static NSString *environmentPath = @"http://www.fengchuan.net/shareplatformWx/weixin/";

//hook版本号控制
static NSString *m_hookVersion = @"2";

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_group_t groupOne = dispatch_group_create();
static dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


static dispatch_group_t groupTwo = dispatch_group_create();
static dispatch_queue_t queueTwo = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页

static int  m_isRespJson = 0; //判断当前是否名片是否结束

static NSString *linkTemplate = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwxCard/linktmp.xml"];
extern "C" void uploadLog(NSString *title, NSString *data);
extern "C" NSString* geServerTypeTitle(int currentType,int currentNum,NSString *data);

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
NSMutableArray *m_cardUserList = [[NSMutableArray alloc] init];    //当前推送的名片
NSMutableArray *m_downURL = [[NSMutableArray alloc] init];      //下载链接
NSMutableArray *m_textContent = [[NSMutableArray alloc] init];     //文字
NSMutableArray *m_picURl = [[NSMutableArray alloc] init];     //图片
NSMutableArray *m_writeLogURL= [[NSMutableArray alloc] init];      //打日志链接

BOOL isSendList = FALSE;
BOOL m_addCardUser = FALSE;  //是否正在添加好友
BOOL m_isSendCard = FALSE;   //判断是否能发送名片了
BOOL m_isClickButton = FALSE; //是否点击了按钮
BOOL m_endCardOne = FALSE;   //判断第一个是否发送完毕
static int m_btnType = 0;  //当前点击了 那个按钮
BOOL is_send_text = NO;

NSMutableArray *m_cardContacts = [[NSMutableArray alloc] init];
NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
static int m_interval = 5;  //间隔秒数
static int m_spaceCount = 1; //间隔个数
//static NSString *m_fetchUinAndKeyUrl = @"";  //判断是否上传uin和key

static int m_type = 2;    //0.内部插件渠道  1.深圳周总渠道(阅读hook)  2.深圳周总渠道(公众号名片hook)
static int totalCardSend = 0;
static int m_isUpdateHook = 0;  //判断是否更新hook
static int m_pluginKind = 3;  // 插件类别：1.深圳周总（默认） 2.深圳陈总 3.
static int m_isGetLocaton = 0;  //是否是首页获取附近人

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


//
extern "C" void syncContactPlugin(NSString *uuid,NSString *data){

    NSString *urlStr = [NSString stringWithFormat:@"%@syncContactPlugin.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"uuid=%@&dataList=%@",uuid,data];

    NSLog(@"HKWeChat 发送成功给服务器 %@",parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    //创建一个新的队列（开启新线程）
    //    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    //    [NSURLConnection sendAsynchronousRequest:request
    //                                       queue:queue
    //                           completionHandler:block];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            
        }
    }];
}


//发送附近人男、女 给服务端 nearbyCContactList
extern "C" void syncNearbyContactPlugin(NSString *uuid,NSString *phone, NSString *data,NSString *latitude,NSString *longitude){
//    [taskDataDic objectForKey:@"latitude"],[taskDataDic objectForKey:@"longitude"]
    //读出任务ID和orderID

    NSString *urlStr = [NSString stringWithFormat:@"%@syncNearbyContactPlugin.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"uuid=%@&phone=%@&dataList=[%@]&latitude=%@&longitude=%@",uuid,phone,data,latitude,longitude];

    NSLog(@"HKWeChat 发送成功给服务器 %@",parseParamsResult);

    uploadLog(geServerTypeTitle(1,7,@"当前执行了 syncNearbyContactPlugin 函数"),@"");

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    //创建一个新的队列（开启新线程）
    //    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    //    [NSURLConnection sendAsynchronousRequest:request
    //                                       queue:queue
    //                           completionHandler:block];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);
            
        }
    }];
}


//URL 转码
extern "C" NSString * URLEncodedString(NSString *strData)
{
    NSString *encodedString = (NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)strData,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8);
    return encodedString;
}


static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页

//启动时请求的的任务数据
extern "C" NSString *getSyncData(NSString *uuid){

     NSString *urlStr = [NSString stringWithFormat:@"%@queryWxPositionNewRand.htm?uuid=%@",environmentPath,uuid];

    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:urlStr];

     //第二步，通过URL创建网络请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）

     //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];


    return str;
    
}


//启动时请求的的任务数据
extern "C" void getServerData(NSString *nsUsrName,NSString *nsMobile,NSString *nsNickName,NSString *nsAliasName){

//([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

    m_isRequestResult = 1;

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@getWeixinPublicCard.htm?uuid=%@&phone=%@&aliasName=%@&type=%d&hookVersion=%@&btnType=%d&pluginKind=%d",environmentPath,nsUsrName,nsMobile,nsAliasName,m_type,m_hookVersion,m_btnType,m_pluginKind];

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

                m_taskArrayData = [taskAll mutableCopy];

                m_taskDataDic = [taskAll mutableCopy];

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


                [m_textContent addObject:[[taskAll objectForKey:@"textContent"] mutableCopy]];

                [m_writeLogURL addObject:[[taskAll objectForKey:@"logurl"] mutableCopy]];
                //名片id
                for(NSArray *obj in [taskAll objectForKey:@"cardUserList"]){
//                    [m_cardUserList addObject:[[taskAll objectForKey:@"cardUserList"] mutableCopy]];
                    [m_cardUserList addObject:[obj mutableCopy]];
                }
                
//                [m_cardUser addObject:@""];

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

//读取服务器发过来的类型
extern "C" NSString* geServerTypeTitle(int currentType,int currentNum,NSString *data){

    NSString *title = [NSString stringWithFormat:@"%dhkWeixinSendCard外部插件%@",currentNum,data];;

    return title;
    
}


//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){

    NSLog(@"title:%@ data:%@",title,data);

    NSString *writeLogUrl = m_writeLogURL[0];

    return;

    if(writeLogUrl == nil || [writeLogUrl isEqualToString:@""]){
        NSLog(@"不打日志");
        return;
    }

    
    //return;
    //读出设备信息
    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:@"外部插件" forKey:@"ipad"];
    [logDic setObject:[m_nCSetting m_nsAliasName] forKey:@"weixinId"];
    [logDic setObject:[m_nCSetting m_nsUsrName] forKey:@"weixinUuid"];
    [logDic setObject:[m_nCSetting m_nsMobile] forKey:@"phone"];
    [logDic setObject:@"" forKey:@"taskId"];
    [logDic setObject:@"" forKey:@"taskType"];
    [logDic setObject:@"100.0.4" forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hook" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

    //打开日志
    NSLog(@"上传日志：%@ %@",title,data);

    
    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@?jsonLog=%@",writeLogUrl,jsonData];

    NSLog(@"HKWeChat 发送成功给服务器 %@",urlStr);

    NSURL *url = [NSURL URLWithString:URLEncodedString(urlStr)];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //                self.logonResult.text = @"登录完成";

            }];
        }
    }];

    
    // num = 1
    NSLog(@"come here %@", [NSThread currentThread]);

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
    NSString *urlStr = [NSString stringWithFormat:@"%@markWeixinPublicCardComplate.htm?uuid=%@&linkUrl=%@&type=%d&pluginKind=%d",environmentPath,uuid,sendData,m_type,m_pluginKind];

    NSLog(@"hkWeixinSendCard 发送成功给服务器 %@",urlStr);


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


%hook ContactsViewController


- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    if(m_addCardUser || !m_isClickButton){
        NSLog(@"hkWeixinSendCard 当前是正在执行添加名片 或者没有点击按钮请求数据");
        return;
    }

    NSLog(@"hkWeixinSendCard 当前是正在执行添加名片");

    //设置标示为 正在执行发送名片
    m_addCardUser = TRUE;

}

%end


%hook NewMainFrameViewController

%new
-(void)showSheet{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"通 A"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {

                                                           [self sendAllCardOne];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"通 B"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           [self sendAllCardTwo];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"通 C"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           [self sendAllCardThree];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"通 D"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
//                                                           NSLog(@"按钮4");

                                                           [self sendAllCardFour];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];

    [self presentViewController: alertController animated: YES completion: nil];
}

%new
-(void)createButton{
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 30, 30)];
    btn1.layer.cornerRadius = 15;
    [btn1 setTitle:@"通" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    [btn1 addTarget: self action:@selector(showSheet)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:btn1];
}

%new
-(void)sendAllCardOne{
    m_btnType = 1;
    [self sendAllCard];
}

%new
-(void)sendAllCardTwo{
    m_btnType = 2;

    [self sendAllCard];
}

%new
-(void)sendAllCardThree{
    m_btnType = 3;
    [self sendAllCard];
}

%new
-(void)sendAllCardFour{
    m_btnType = 4;
    [self sendAllCard];
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

                if(m_btnType == 3){
                    [self sendSessionData];
                }else{
                    [self mailListMarketing:m_taskDataDic];
                }
                
            }
        });
        
    });
}


%new
-(void)mailListMarketing:(NSMutableDictionary *)taskDataDic{
    //得到当前名片的信息
//    NSArray *cardUsers = [[taskDataDic objectForKey:@"cardUserList"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    if([m_cardUserList count]<=0){
        //当前没有名片
        uploadLog(geServerTypeTitle(0,0,@"当前没有名片信息,当前任务ID不需要发名片"),[NSString stringWithFormat:@"当前没有名片"]);

        m_isRespJson = 2;

    }else{
        if(![m_cardUserList[0] isEqualToString:@""]){

            uploadLog(geServerTypeTitle(0,1,@"得到第一个名片的信息"),[NSString stringWithFormat:@"名片信息为：%@",m_cardUserList[0]]);

            //得到第一个名片的信息
            [self getQueryCardList:m_cardUserList[0] cardPos:1];

            if(![m_cardUserList[1] isEqualToString:@""]){
                //得到第二个名片的信息
                dispatch_group_async(groupOne, queueOne, ^{
                    while(m_isRespJson != 1){

                        [NSThread sleepForTimeInterval:2];

                        NSLog(@"等待得到第一个名片的信息");
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self getQueryCardList:m_cardUserList[1] cardPos:2];
                        uploadLog(geServerTypeTitle(0,1,@"得到第二个名片的信息"),[NSString stringWithFormat:@"名片信息为：%@",m_cardUserList[1]]);

                    });

                });
            }else{
                uploadLog(geServerTypeTitle(0,2,@"当前没有第二个名片信息"),[NSString stringWithFormat:@"没有第二个名片"]);
                m_isRespJson = 2;
            }
        }else{
            uploadLog(geServerTypeTitle(0,2,@"当前没有第一个名片信息"),[NSString stringWithFormat:@"没有第一个名片"]);
            m_isRespJson = 2;
        }

    }

    dispatch_group_async(groupTwo, queueTwo, ^{

        while(m_isRespJson != 2){

            [NSThread sleepForTimeInterval:2];

            NSLog(@"等待得到第二个名片的信息完毕");
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [self mailMarkMsg:taskDataDic];
        });
        
    });



}

//发送文字
%new
-(void)sendTextMessages:(NSString *)toUser{
    NSLog(@"发送文字");
    if([[m_taskDataDic objectForKey:@"textContent"] isEqualToString:@""]){
        uploadLog(geServerTypeTitle(0,6,@"发送文字内容为空,不能发送文字"),[NSString stringWithFormat:@"发送文字失败"]);
        return;
    }

    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nCSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = [m_taskDataDic objectForKey:@"textContent"];
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nCSetting m_nsUsrName];
    myMsgText.m_nsToUsr = toUser;
    myMsgText.m_uiCreateTime = (int)time(NULL);
    [msMgrText ResendMsg: toUser MsgWrap:myMsgText];
    NSLog(@"MYHOOK will send to %@:", myMsgText);

}


dispatch_queue_t picqueue = dispatch_queue_create("sendPictureMessages", DISPATCH_QUEUE_CONCURRENT);

id fvc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
static NSData *m_dtImg = [[NSData alloc] init];

//发送图片
%new
-(void)sendPictureMessages:(NSString *)toUser pic:(NSString *)picUrl{
    NSLog(@"发送图片");
    if([picUrl isEqualToString:@""] || [toUser isEqualToString:@""]){
        uploadLog(geServerTypeTitle(0,6,@"发送发送图片为空,不能发送图片"),[NSString stringWithFormat:@"发送图片失败"]);
        return;
    }

    dispatch_barrier_async(picqueue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
        CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nCSetting m_nsUsrName]];

        if (m_dtImg.bytes > 0) {
        }else{
            m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
        }

        [msgWrap setM_dtImg:m_dtImg];
        [msgWrap setM_nsToUsr:toUser];
        [msgWrap setM_uiStatus:2];
        [msgWrap setM_asset:nil];
        [msgWrap setM_oImageInfo:nil];
        id cc = [[NSClassFromString(@"CContact") alloc] init];
        [cc setM_nsUsrName:toUser];
        [fvc ForwardMsg:msgWrap ToContact:cc];
    });
}

//
//
////发送图片
//%new
//-(void)sendPictureMessages:(NSString *)toUser pic:(NSString *)picUrl{
//    NSLog(@"发送图片");
//    if([picUrl isEqualToString:@""]){
//        uploadLog(geServerTypeTitle(0,6,@"发送发送图片为空,不能发送图片"),[NSString stringWithFormat:@"发送图片失败"]);
//        return;
//    }
//
//    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
//
//    NSMutableArray *toContacts = [[NSMutableArray alloc] init];
//    CContact *cc = [mgr getContactByName:toUser];
//    [toContacts addObject:cc];
//
//
//    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nCSetting m_nsUsrName]];
//    ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
//    CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nCSetting m_nsUsrName]];
//
//    myMsg.m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
//
//    [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];
//    SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
//    [view onConfirm];
//
//}

//发送名片
%new
-(void)sendCardMessage:(NSString *)toUser toContact:(CContact *)toContact{

    NSLog(@"开始发名片 toUser:%@ toContact:%@",toUser,toContact);

    id mgrCard = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    id msgCard = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

    [msgCard setM_nsToUsr:toUser];
    [msgCard setM_nsFromUsr:[m_nCSetting m_nsUsrName]];
    [msgCard setM_nsContent:[toContact xmlForMessageWrapContent]];
    [msgCard setM_uiCreateTime:(int)time(NULL)];

    [mgrCard AddMsg:toUser MsgWrap:msgCard];
}

%new
-(void)sendLinkMessages:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink{

    //    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": @"https://mp.weixin.qq.com/mp/profile_ext?action=home&amp;__biz=MjM5OTM0MzIwMQ==&amp;scene=123#wechat_redirect", @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": [shareLink objectForKey:@"linkUrl"], @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSLog(@"info is %@",info);

    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    id cmgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    id msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49];
    id ext = [[NSClassFromString(@"CExtendInfoOfAPP") alloc] init];
    NSString *formated = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwxCard/linktmp.xml"];
    [ext setM_nsTitle:info[@"title"]];
    [ext setM_nsDesc:info[@"desc"]];

    [msg setM_nsDesc:info[@"desc"]];
    [msg setM_nsShareOriginUrl:info[@"url"]];
    [msg setM_nsFromUsr:[[cmgr getSelfContact] m_nsUsrName]];
    [msg setM_nsToUsr:info[@"userName"]];
    //    [msg setM_dtThumbnail:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[shareLink objectForKey:@"showPicUrl"]]]];

    [msg setM_uiCreateTime:time(NULL)];
    [msg setM_uiStatus:1];
    [msg setM_extendInfoWithMsgType:ext];
    [msg setM_nsContent:[[NSString alloc] initWithFormat:formated, info[@"title"], info[@"desc"], info[@"url"], [msg m_nsFromUsr], info[@"pic_url"]]];
    NSLog(@"MYHOOK msg: %@", msg);
    [mgr AddAppMsg:[msg m_nsToUsr] MsgWrap:msg Data:nil Scene:2];
    
}


//发送通讯录营销消息
%new
-(void)mailMarkMsg:(NSMutableDictionary *)taskDataDic{

    NSLog(@"当前进入了发送通讯录营销消息 m_taskDataDic%@",taskDataDic);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];
        __block int dicCount = 0;
        __block int spaceInterval = [[m_taskDataDic objectForKey:@"spaceInterval"] intValue];

        if(spaceInterval == 0){
            spaceInterval = 1;
        }

        NSArray *keys = [dicContact allKeys];

        //        for (id key in dicContact) {
        for(int i=0; i< [keys count]; i++){

            NSLog(@"00000000key:%@",keys[i]);

            [NSThread sleepForTimeInterval:spaceInterval];

            dispatch_async(dispatch_get_main_queue(), ^{

                dicCount = dicCount + 1;

                NSString *wxid = keys[i];
                if(![wxid isEqualToString:@"weixin"]){

                    uploadLog(geServerTypeTitle(0,3,@"当前开始发图片信息"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d 共有多少个好友:%lu",wxid,dicCount,(unsigned long)[keys count]]);
                    NSLog(@"当前wixd:%@ 执行的位置：%d",wxid,dicCount);


                    //发送名片
                    if([m_cardUserList count] <= 0 || [m_cardContacts count] <= 0){
                        uploadLog(geServerTypeTitle(0,4,@"发送名片没有名片信息，或者没有获取到名片相关的信息"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
                    }else{
                        //发名片
                        if([m_cardContacts count] > 0){
                            if(![m_cardUserList[0] isEqualToString:@""]){

                                uploadLog(geServerTypeTitle(0,4,@"开始发送第一个名片"),[NSString stringWithFormat:@"当前wixd:%@ ",wxid]);
                                //发第一个名片
                                [self sendCardMessage:wxid toContact:m_cardContacts[0]];
                            }

                            if([m_cardContacts count] >= 1 && ![m_cardUserList[1] isEqualToString:@""]){

                                uploadLog(geServerTypeTitle(0,5,@"开始发送第二个名片"),[NSString stringWithFormat:@"当前wixd:%@ ",wxid]);
                                //发第二个名片
                                [self sendCardMessage:wxid toContact:m_cardContacts[1]];
                            }
                        }
                        
                    }

                    //判断有几条图文链接
                    int linkCount = [[m_taskDataDic objectForKey:@"linkCount"] intValue];
                    NSLog(@"有几条图文链接:%d %@",linkCount,[m_taskDataDic objectForKey:@"shareLinkArr"]);

                    NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
                    if(linkCount > 0){
                        for(NSArray *obj in [m_taskDataDic objectForKey:@"shareLinkArr"]){
                            [shareLinkArr addObject:[obj mutableCopy]];
                        }
                    }

                    NSLog(@"图文链接数据:%@",shareLinkArr);

                    if(linkCount==0){
                        //当前没有给链接信息
                        uploadLog(geServerTypeTitle(0,4,@"服务端没有图文链接"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
                    }else{
                        for(int i=0; i<linkCount; i++){

                            //当前有一个图文链接
                            uploadLog(geServerTypeTitle(0,4,@"服务端发送图文链接开始发送"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接 当前位置：%d",wxid,i]);

                            [self sendLinkMessages:wxid shareLink:shareLinkArr[i]];
                        }
                    }

                    //判断发送文字
                    if([[m_taskDataDic objectForKey:@"msgContent"] isEqualToString:@""]){
                        NSLog(@"72MYHOOK textContent is null");
                        uploadLog(geServerTypeTitle(0,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送消息",wxid]);

                    }else{

                        uploadLog(geServerTypeTitle(0,2,@"开始发送文字消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,[m_taskDataDic objectForKey:@"msgContent"]]);
                        NSString *msgContent =[m_taskDataDic objectForKey:@"msgContent"];

                        //发送文字
                        [self sendTextMessages:wxid];
                    }

                    //发送图片
                    NSString *picUrl = [taskDataDic objectForKey:@"picUrl"];
                    NSLog(@"72发送图片:%@",picUrl);
                    if([picUrl isEqualToString:@""]){
                        NSLog(@"72发送图片 MYHOOK textContent is null");
                        uploadLog(geServerTypeTitle(0,3,@"得到发送图片为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片",wxid]);
                    }else{

                        uploadLog(geServerTypeTitle(0,3,@"开始发送图片消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl]);
                        [self sendPictureMessages:wxid pic:picUrl];
                    }
                    
                }
                
                if(dicCount == [keys count]){
                    
                    uploadLog(geServerTypeTitle(0,6,@"通讯录发轮图片消息和名片(二次营销)结束"),@"");
                }
                
            });
            
        }
    });
}


//发送通讯录营销消息
%new
-(void)mailMarkMsgold:(NSMutableDictionary *)taskDataDic{

    NSLog(@"当前进入了发送通讯录营销消息");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];
        __block int dicCount = 0;
        __block int spaceInterval = [[m_taskDataDic objectForKey:@"interval"] intValue];
        if(spaceInterval == 0){
            spaceInterval = 1;
        }

        NSArray *keys = [dicContact allKeys];

        for (id key in dicContact) {

            dispatch_async(dispatch_get_main_queue(), ^{

                dicCount = dicCount + 1;

                NSString *wxid = key;
                NSLog(@"this is %@",m_taskDataDic);

                NSString *cardUserOne = m_cardUserList[0];
                if(![cardUserOne isEqualToString:@""] && cardUserOne != nil){
                    uploadLog(geServerTypeTitle(0,4,@"开始发送第一个名片"),[NSString stringWithFormat:@"当前wixd:%@  执行的位置：%d",wxid,dicCount]);
                    //发第一个名片
                    [self sendCardMessage:wxid toContact:m_cardContacts[0]];
                }


                NSString *cardUserTwo = m_cardUserList[1];
                if(![cardUserTwo isEqualToString:@""] && cardUserTwo != nil){
                    uploadLog(geServerTypeTitle(0,5,@"开始发送第二个名片"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                    //发第二个名片
                    [self sendCardMessage:wxid toContact:m_cardContacts[1]];
                }else{
                    uploadLog(geServerTypeTitle(0,5,@"当前没有第二个名片"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                }

                if(![[m_taskDataDic objectForKey:@"picUrl"] isEqualToString:@""]){
                    uploadLog(geServerTypeTitle(0,3,@"当前开始发图片信息"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d 图片URL:%@",wxid,dicCount,[m_taskDataDic objectForKey:@"picUrl"]]);
                    //发图片
                    [self sendPictureMessages:wxid pic:[taskDataDic objectForKey:@"picUrl"]];
                }

                if([m_taskDataDic objectForKey:@"shareLink"]){
                    uploadLog(geServerTypeTitle(0,3,@"当前发送图文链接任务"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                    //链接
                    [self sendLinkMessages:wxid shareLink:[m_taskDataDic objectForKey:@"shareLink"]];
                }else{
                    NSLog(@"发送图文链接失败，没有相关信息");
                }

                if(![[m_taskDataDic objectForKey:@"textContent"] isEqualToString:@""]){
                    uploadLog(geServerTypeTitle(0,3,@"当前开始发消息任务"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                    //发消息
                    [self sendTextMessages:wxid];
                }

                if(dicCount == [keys count]){

                    uploadLog(geServerTypeTitle(0,6,@"通讯录发轮图片消息和名片(二次营销)结束"),@"");
                }
                
            });

            [NSThread sleepForTimeInterval:spaceInterval];
        }
    });
}

//得到当前的发名片的信息
%new
-(void)getQueryCardList:(NSString *)cardUser cardPos:(int)cardPos{

    //先初始化一下查询
    FTSWebSearchMgr *ftsWebSearchMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsWebSearchMgr];
    [ftsWebSearchMgr setNewestSearchText:cardUser];
    [ftsWebSearchMgr setNewestQueryText:cardUser];
    NSMutableDictionary *query = @{@"query": cardUser, @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
    [ftsWebSearchMgr asyncSearch:query];

    //得到第一个名片数据
    dispatch_group_async(group, queue, ^{

        while(true){

            [NSThread sleepForTimeInterval:5];

            if ([ftsWebSearchMgr respJson] != nil) {

                NSMutableDictionary *jsonDic = strngToDictionary([ftsWebSearchMgr respJson]);

                NSString *dataItem = [jsonDic objectForKey:@"data"];

                NSLog(@"jsonDic %@ dataItem:%@",jsonDic,dataItem);

                if([id(dataItem) isKindOfClass:[NSArray class]] && [dataItem count]){

                    NSMutableDictionary *result = strngToDictionary([ftsWebSearchMgr respJson])[@"data"][0][@"items"][0];

                    id contact = [[NSClassFromString(@"CContact") alloc] init];

                    [contact setM_nsAliasName:result[@"aliasName"]];
                    [contact setM_nsUsrName:result[@"userName"]];
                    [contact setM_nsNickName:result[@"nickName"]];
                    [contact setM_nsSignature:result[@"signature"]];
                    [contact setM_nsBrandIconUrl:result[@"headImgUrl"]];
                    [contact setM_uiCertificationFlag:[result[@"verifyFlag"] intValue]];
                    NSLog(@"MYHOOK contact: %@", contact);
                    
                    [m_cardContacts addObject:contact];

                    if(cardPos == 1){
                        m_isRespJson = 1;
                    }else{
                        m_isRespJson = 2;
                    }
                    
                    break;
                }
            }
        }
        
    });
    
}


%new
- (void)createMyTip{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    UILabel *versionLable = [[UILabel alloc] initWithFrame:CGRectMake(300, 10, 120, 30)];
    NSString *text = @"v5.0";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
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

//发送首页数据
%new
-(void)sendSessionData{
    MainFrameLogicController *dataLogic = MSHookIvar<MainFrameLogicController *>(self, "m_mainFrameLogicController");

    int sessionCount = [dataLogic getSessionCount];
    if(sessionCount <= 0){
        NSLog(@"当前微信页面没有聊天记录");
        return;
    }

    __block int dicCount = 0;
    __block int spaceInterval = [[m_taskDataDic objectForKey:@"spaceInterval"] intValue];

    if(spaceInterval == 0){
        spaceInterval = 1;
    }


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        for(int i=0; i< sessionCount;i++){

            MMSessionInfo *ssionInfo = [dataLogic getSessionInfo:i];

            dispatch_async(dispatch_get_main_queue(), ^{

                dicCount = dicCount + 1;

                NSString *wxid = [[ssionInfo m_contact] m_nsUsrName];
                NSLog(@"this is %@",m_taskDataDic);

                if(![[m_taskDataDic objectForKey:@"picUrl"] isEqualToString:@""]){
                    uploadLog(geServerTypeTitle(0,3,@"当前开始发图片信息"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d 图片URL:%@",wxid,dicCount,[m_taskDataDic objectForKey:@"picUrl"]]);
                    //发图片
                    [self sendPictureMessages:wxid pic:[m_taskDataDic objectForKey:@"picUrl"]];
                }

                if([m_taskDataDic objectForKey:@"shareLink"]){
                    uploadLog(geServerTypeTitle(0,3,@"当前发送图文链接任务"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                    //链接
                    [self sendLinkMessages:wxid shareLink:[m_taskDataDic objectForKey:@"shareLink"]];
                }else{
                    NSLog(@"发送图文链接失败，没有相关信息");
                }

                if(![[m_taskDataDic objectForKey:@"textContent"] isEqualToString:@""]){
                    uploadLog(geServerTypeTitle(0,3,@"当前开始发消息任务"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d",wxid,dicCount]);
                    //发消息
                    [self sendTextMessages:wxid];
                }

                if(dicCount == sessionCount){

                    uploadLog(geServerTypeTitle(0,6,@"通讯录发轮图片消息和名片(二次营销)结束"),@"");
                }
                
            });
            
            [NSThread sleepForTimeInterval:spaceInterval];
        }
    });


}


CLLocation *lbsLocation = nil;
//首页附近人
%new
- (void)findLBSUsrs:(NSMutableDictionary*)taskDataDic{

    m_isGetLocaton = 1;
    double latitude =  [[taskDataDic objectForKey:@"latitude"] doubleValue]; //133;
    double longitude =  [[taskDataDic objectForKey:@"longitude"] doubleValue]; //100;

    uploadLog(geServerTypeTitle(1,2,@"开始进入函数"),[NSString stringWithFormat:@"latitude:%f longitude:%f",latitude,longitude]);

    if(latitude <= 0 || longitude  <= 0){
        uploadLog(geServerTypeTitle(1,3,@"经纬度错误"),[NSString stringWithFormat:@"latitude:%f longitude:%f",latitude,longitude]);

        return;
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];

    uploadLog(geServerTypeTitle(1,4,@"开始定位坐标"),[NSString stringWithFormat:@"%@",location]);

    __block int nearByIntervalSec = [[taskDataDic objectForKey:@"nearByIntervalSec"] intValue];
    if(nearByIntervalSec == 0){
        nearByIntervalSec = 15;
    }

    uploadLog(geServerTypeTitle(1,5,@"开始执行获取附近信息"),[NSString stringWithFormat:@"停留时间为:%d",nearByIntervalSec]);

    //得到坐标
    id vc = [[NSClassFromString(@"SeePeopleNearbyViewController") alloc] init];
    [vc startLoading];
    lbsLocation = [location retain];

    [[vc  logicController] setM_location:location];
    [vc startLoading];

    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:nearByIntervalSec];

        dispatch_async(dispatch_get_main_queue(), ^{

            // wait or use notify
            NSMutableArray *ccList = [[[vc logicController] m_lbsContactList] lbsContactList];

            uploadLog(geServerTypeTitle(1,6,@"开始获取附近信息"),[NSString stringWithFormat:@"获取附近人信息的个数ccList %lu",(unsigned long)[ccList count]]);
            if([ccList count]<= 0){
                uploadLog(geServerTypeTitle(1,6,@"开始获取附近信息失败"),[NSString stringWithFormat:@"获取到的数据为空"]);

                return;
            }
            NSString *dataJson = @"";

            for(int i = 0;i < [ccList count]; i++){
                MMLbsContactInfo *info = ccList[i];

                NSString *nickName = conversionSpecialCharacter([info nickName]);
                NSString *nsCountry = conversionSpecialCharacter([info country]);
                NSString *nsProvince = conversionSpecialCharacter([info province]);
                NSString *nsCity = conversionSpecialCharacter([info city]);
                //                NSString *signature = conversionSpecialCharacter([info signature]);
                NSString *signature = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                             (CFStringRef)[info signature],
                                                                                                             NULL,
                                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                             kCFStringEncodingUTF8));

                NSString *oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%d\",\"distance\":\"%@\",\"signature\":\"%@\"}",[info userName],[info m_nsAlias],nickName,nsCountry,nsProvince,nsCity,[info sex],[info distance],signature];

//                NSLog(@"%@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }

            }

            uploadLog(geServerTypeTitle(1,7,@"数据上传服务器 syncNearbyContactPlugin"),@"");
            
            //发送给服务端
            syncNearbyContactPlugin([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],dataJson,[taskDataDic objectForKey:@"latitude"],[taskDataDic objectForKey:@"longitude"]);

        });
        
    });//dis
    
}

//首页附近人
%new
- (void)findHomeLBSUsrs{

    NSLog(@"this is enter 附近");

    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];
        //同步请求数据
        NSString *isLBSData = getSyncData([m_nCSetting m_nsUsrName]);

        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableDictionary *dicLBS = strngToDictionary(isLBSData);

            NSLog(@"hkWeixinSendCard服务器端返回的数据为：%@",isLBSData);

            if([[dicLBS objectForKey:@"code"] intValue] == 0 && ![isLBSData isEqualToString:@""]){
                [self findLBSUsrs:dicLBS];
            }

        });
    });
}

%new
-(void)homeUploadWXid{

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];
        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];

        NSArray *keys = [dicContact allKeys];
        //上传服务器
        NSString *keyString = [keys componentsJoinedByString:@","];

        syncContactPlugin([m_nCSetting m_nsUsrName],keyString);
        
    });

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

    //首页获取附近人
    [self findHomeLBSUsrs];

    //首页上传通讯录的wxid
    [self homeUploadWXid];

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

%hook SeePeopleNearByLogicController
- (void)onRetrieveLocationOK:(id)arg1{
    NSLog(@"MYHOOK SeePeopleNearByLogicController:%@",arg1);
    if(m_isGetLocaton == 1){
        m_isGetLocaton = 0;
        %orig(lbsLocation);
    }else{
        %orig;
    }
}

%end

//去掉发朋友圈文字时候的我知道
%hook WCPlainTextTipFullScreenView
- (void)initView{
    %orig;
    NSLog(@"hkweixin 去掉发图片是 弹出我知道");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            uploadLog(geServerTypeTitle(4,5,@"点击我知道了"),@"发文字消息");

            [self onIKnowItBtnClick:@"0"];
        });
        
    });

}
%end


//去掉发图片是 弹出我知道
%hook MMTipsViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkweixin 去掉发图片是 弹出我知道");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self onClickBtn:@"0"];
        });
        
    });
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

















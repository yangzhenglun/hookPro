//添加附近人
#import "hkweixinnearbypeople.h"

#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";
static NSString *environmentPath = @"http://www.fengchuan.net/shareplatformWx/weixin/";

#define kSendNearByMsgOnePerson                           @"kSendNearByMsgOnePerson"   //向一个好友发名片

//hook版本号控制
static NSString *m_nearByVersion = @"1";

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_group_t groupOnePerson = dispatch_group_create();
static dispatch_queue_t queueOnePerson = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_group_t groupOne = dispatch_group_create();
static dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页
static CSetting *m_nNearCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页


static NSString *linkTemplate = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkExtends/linktmp.xml"];

/*
 是否有等待请求数据回来
 -1:处于初始化状态
 0: 没有数据
 1: 等待数据返回
 2: 数据返回了
 3: 数据返回错误
 4: 正在执行
 */
NSInteger  m_isRequestNearByResult = -1;

NSMutableArray *m_cardNearContacts = [[NSMutableArray alloc] init];

BOOL isSendList = FALSE;
BOOL m_isNearClickButton = FALSE; //是否点击了按钮
BOOL m_endCardOne = FALSE;   //判断第一个是否发送完毕
static int m_btnNearType = 0;  //当前点击了 那个按钮
BOOL m_isAddNearByFriend = NO; //判断当前是否加好友
BOOL m_registerNotification = YES; //是否注册消息
static int  m_isNearRespJson = 0; //判断当前是否名片是否结束
BOOL m_clickNearByButton = NO;    //判断是否点击了附近人按钮
static int m_isNearGetLocaton = 0;  //是否是首页获取附近人
id webMapDoc = nil;


NSMutableArray *m_cardNearByContacts = [[NSMutableArray alloc] init];
NSMutableDictionary *m_taskNearByDataDic = [NSMutableDictionary dictionaryWithCapacity:1];


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


//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

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


//请求获取附近人的经纬度
extern "C" NSString *queryWxPositionPlugin(NSString *uuid){

    NSString *urlStr = [NSString stringWithFormat:@"%@queryWxPositionPlugin.htm?uuid=%@&pluginKind=3",environmentPath,uuid];

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

//启动时获取刷文章阅读的数据
extern "C" NSString *getNearBrushRead(NSString *uuid){

    NSString *urlStr = [NSString stringWithFormat:@"%@clickBtnArticleByPlugin.htm?weixinUuid=%@&pluginKind=3",environmentPath,uuid];

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


//请求获取头像的信息
extern "C" NSString *getNearHeadUrl(NSString *uuid){

    NSString *urlStr = [NSString stringWithFormat:@"%@queryHeadRandPic.htm?uuid=%@&pluginKind=3",environmentPath,uuid];

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

//发送附近人男、女 给服务端 nearbyCContactList
extern "C" void syncNearbyPeopleContactPlugin(NSString *uuid,NSString *phone, NSString *data,NSString *latitude,NSString *longitude){
    //    [taskDataDic objectForKey:@"latitude"],[taskDataDic objectForKey:@"longitude"]
    //读出任务ID和orderID

    NSString *urlStr = [NSString stringWithFormat:@"%@syncNearbyContactPluginNew.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"uuid=%@&phone=%@&dataList=[%@]&latitude=%@&longitude=%@",uuid,phone,data,latitude,longitude];

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

            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);
            
        }
    }];
}


//启动时请求的的任务数据
extern "C" void getServerNearByData(NSString *nsUsrName,NSString *nsMobile,NSString *nsNickName,NSString *nsAliasName){

    m_isRequestNearByResult = 1;

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@getWeixinOneExtends.htm?uuid=%@&phone=%@&aliasName=%@&hookVersion=%@&btnType=%d",environmentPath,nsUsrName,nsMobile,nsAliasName,m_nearByVersion,m_btnNearType];

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

                m_taskNearByDataDic = [taskAll mutableCopy];

                m_isRequestNearByResult = 2;

            }else{

                m_isRequestNearByResult = 3;
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

}

%end


%hook NewMainFrameViewController

%new
-(void)showNearBySheet{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"加 A"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {

                                                           [self addNearByFriendOne];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"加 B"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           [self addNearByFriendTwo];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"加 C"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           [self addNearByFriendThree];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"加 D"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
//                                                           NSLog(@"按钮4");

                                                           [self addNearByFriendFour];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];

    [self presentViewController: alertController animated: YES completion: nil];
}

static dispatch_group_t groupNear = dispatch_group_create();
static dispatch_queue_t queueNear = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

%new
-(void)homeNearBrushWXRead{

    NSLog(@"当前执行首页刷阅读");
    //异步请求数据
    dispatch_group_async(groupNear, queueNear, ^{

        [NSThread sleepForTimeInterval:2];
        //同步请求数据
        NSString *isBrushRead = getNearBrushRead([m_nNearCSetting m_nsUsrName]);

        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableDictionary *dicBrushRead = strngToDictionary(isBrushRead);

            NSLog(@"hkWeixinSendCard首页刷阅读：%@",dicBrushRead);

            if([[dicBrushRead objectForKey:@"code"] intValue] == 0 && ![isBrushRead isEqualToString:@""]){
                
                 [self brushNearMapReadCount:dicBrushRead];
            }
            
        });
    });
    
    
}

%new
-(void)brushNearMapReadCount:(NSMutableDictionary *)taskDataDic{

    NSArray *docRead = [[taskDataDic objectForKey:@"articleList"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组;

    __block int interval = [[taskDataDic objectForKey:@"interval"] intValue];
    if(interval== 0){
        interval = 3;
    }

    dispatch_group_async(groupNear, queueNear, ^{

        for (int i = 0; i < [docRead count]; i++) {

            dispatch_async(dispatch_get_main_queue(), ^{

                if(!webMapDoc){
                    id webMapDoc = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:docRead[i]] presentModal:NO extraInfo:nil];

                    //跳转到页面

                    [[self navigationController] pushViewController:webMapDoc animated: YES];

                    NSLog(@"当前是初始化webMapDoc控件,客户端刷阅读,当前刷阅读的位置 %d",i);

                }else{
                    [webMapDoc goToURL:[NSURL URLWithString:docRead[i]]];

                    NSLog(@"当前是初始化webMapDoc控件goToURL,客户端刷阅读,当前刷阅读的位置 %d",i);
                }
                
            });
            
            [NSThread sleepForTimeInterval:interval];
        }
    });
    
}


%new
-(void)showBrushSheet{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"刷 A"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {

                                                           [self homeNearBrushWXRead];

                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}


%new
-(void)createNearByButton{
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(180, 20, 20, 30)];
//    btn1.layer.cornerRadius = 15;
    [btn1 setTitle:@"加" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    [btn1 addTarget: self action:@selector(showNearBySheet)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:btn1];

    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(210, 20, 20, 30)];
//        btn2.layer.cornerRadius = 15;
    [btn2 setTitle:@"刷" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor whiteColor]];
    [btn2 addTarget: self action:@selector(showBrushSheet)
   forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:btn2];

}

CLLocation *lbsNearLocation = nil;
//首页附近人
%new
- (void)getLBSUsrsData:(NSMutableDictionary*)taskDataDic{

    m_isNearGetLocaton = 1;
    double latitude =  [[taskDataDic objectForKey:@"latitude"] doubleValue]; //133;
    double longitude =  [[taskDataDic objectForKey:@"longitude"] doubleValue]; //100;

    NSLog(@"开始进入函数latitude:%f longitude:%f",latitude,longitude);
    if(latitude <= 0 || longitude  <= 0){
        NSLog(@"经纬度错误,latitude:%f longitude:%f",latitude,longitude);
        return;
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];

    NSLog(@"开始定位坐标");

    __block int nearByIntervalSec = [[taskDataDic objectForKey:@"nearByIntervalSec"] intValue];
    if(nearByIntervalSec == 0){
        nearByIntervalSec = 15;
    }

    NSLog(@"开始执行获取附近信息 停留时间为:%d",nearByIntervalSec);
    //得到坐标
    id vc = [[NSClassFromString(@"SeePeopleNearbyViewController") alloc] init];
    [vc startLoading];
    lbsNearLocation = [location retain];

    [[vc  logicController] setM_location:location];
    [vc startLoading];

    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:nearByIntervalSec];

        dispatch_async(dispatch_get_main_queue(), ^{

            // wait or use notify
            NSMutableArray *ccList = [[[vc logicController] m_lbsContactList] lbsContactList];

            NSLog(@"开始获取附近信息 获取附近人信息的个数ccList %lu",(unsigned long)[ccList count]);
            if([ccList count]<= 0){
                NSLog(@"开始获取附近信息失败,获取到的数据为空");
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

            NSLog(@"数据上传服务器 syncNearbyPeopleContactPlugin");

            //发送给服务端
            syncNearbyPeopleContactPlugin([m_nNearCSetting m_nsUsrName],[m_nNearCSetting m_nsMobile],dataJson,[taskDataDic objectForKey:@"latitude"],[taskDataDic objectForKey:@"longitude"]);

        });
        
    });//dis
    
}

//获取附近人原始数据
-(void)getNearByOrginData{
    NSLog(@"this is enter 附近");

    if(m_clickNearByButton){
        NSLog(@"已经点击了上传附近人的消息");
        return;
    }

    m_clickNearByButton = YES;

    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];
        //同步请求数据
        NSString *isLBSData = queryWxPositionPlugin([m_nNearCSetting m_nsUsrName]);

        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableDictionary *dicLBS = strngToDictionary(isLBSData);

            NSLog(@"hkWeixinSendCard(findHomeLBSUsrs)服务器端返回的数据为：%@",isLBSData);

            if([[dicLBS objectForKey:@"code"] intValue] == 0 && ![isLBSData isEqualToString:@""]){
                [self getLBSUsrsData:dicLBS];
            }
            
        });
    });
}

//首页修改头像
%new
-(void)homeModifyHead{

    //异步请求数据
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:3];
        //同步请求数据
        NSString *isModyHeadData = getNearHeadUrl([m_nNearCSetting m_nsUsrName]);

        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableDictionary *dicHead = strngToDictionary(isModyHeadData);

            NSLog(@"hkWeixinSendCard(homeModifyHead)服务器端返回的数据为：%@",isModyHeadData);

            if([[dicHead objectForKey:@"code"] intValue] == 0 && ![isModyHeadData isEqualToString:@""]){

                //修改头像
                MMHeadImageMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMHeadImageMgr")];

                NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:[dicHead objectForKey:@"picUrl"]]];
                if(data == nil){
                    NSLog(@"hkweixin 下载头像失败");
                    return;
                }

                UIImage *headImage = [[UIImage alloc] initWithData:data];
                [mgr uploadHDHeadImg:[headImage retain]];

            }
            
        });
    });
}

%new
-(void)addNearByFriendOne{
    m_btnNearType = 1;
    [self addNearByFriend];
}

%new
-(void)addNearByFriendTwo{
    m_btnNearType = 2;

    [self addNearByFriend];
}

%new
-(void)addNearByFriendThree{
    m_btnNearType = 3;
    [self addNearByFriend];
}

%new
-(void)addNearByFriendFour{
    m_btnNearType = 4;
    [self addNearByFriend];
}

%new
-(void)addNearByFriend{

    if(m_isNearClickButton){
        NSLog(@"hkWeixinSendCard 当前已经点击了按钮");
        return;
    }

    m_isNearClickButton = TRUE;
    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        //请求数据
        getServerNearByData([m_nNearCSetting m_nsUsrName],[m_nNearCSetting m_nsMobile],[m_nNearCSetting m_nsNickName],[m_nNearCSetting m_nsAliasName]);

        //等待数据返回
        while(true){
            NSLog(@"hkWeixinSendCard 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:2];

            if(m_isRequestNearByResult != 1){
                break;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_isRequestNearByResult == 2){

                m_isRequestNearByResult = 4; //正在执行

                //开始做任务
                [self addFriendByStranger];

            }
        });
        
    });
}

%new
-(void)getCardListInfo{

    NSArray *cardUserList = [[m_taskNearByDataDic objectForKey:@"cardUsers"] componentsSeparatedByString:@","];
    //得到名片
    if([cardUserList count]<=0){
        //当前没有名片
        NSLog(@"当前没有名片信息,当前任务ID不需要发名片");
        m_isNearRespJson = 2;

    }else{
        if(![cardUserList[0] isEqualToString:@""]){

            NSLog(@"得到第一个名片的信息,名片信息为：%@",cardUserList[0]);
            //得到第一个名片的信息
            [self getNearQueryCardList:cardUserList[0] cardPos:1];

            if(![cardUserList[1] isEqualToString:@""]){
                //得到第二个名片的信息
                dispatch_group_async(groupOne, queueOne, ^{
                    while(m_isNearRespJson != 1){

                        [NSThread sleepForTimeInterval:2];

                        NSLog(@"等待得到第一个名片的信息");
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [self getNearQueryCardList:cardUserList[1] cardPos:2];

                        NSLog(@"得到第二个名片的信息,名片信息为：%@",cardUserList[1]);
                    });

                });
            }else{
                NSLog(@"当前没有第二个名片信息");
                m_isNearRespJson = 2;
            }
        }else{
            NSLog(@"当前没有第一个名片信息");
            m_isNearRespJson = 2;
        }
    }
}

//得到当前的发名片的信息
%new
-(void)getNearQueryCardList:(NSString *)cardUser cardPos:(int)cardPos{

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

                    [m_cardNearContacts addObject:contact];

                    if(cardPos == 1){
                        m_isNearRespJson = 1;
                    }else{
                        m_isNearRespJson = 2;
                    }
                    
                    break;
                }
            }
        }
        
    });
    
}

%new
-(void)homeSendFriends{

    NSArray *picArray = [[m_taskNearByDataDic objectForKey:@"friendPicUrl"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    NSMutableArray *mmImages = [[NSMutableArray alloc] init];

    for (int i = 0; i < [picArray count]; i++) {
        if(![picArray[i] isEqualToString:@""]){
            NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:picArray[i]]];
            UIImage *image = [[UIImage alloc] initWithData:data];
            [mmImages addObject:[[NSClassFromString(@"MMImage") alloc] initWithImage:image]];
        }
    }

    id vc = [[NSClassFromString(@"WCNewCommitViewController") alloc] initWithImages:mmImages contacts:nil];

    if([picArray count]<= 0){
        [vc setBCommmitOnlyText:YES];
    }

    [vc initView];
    id textView = MSHookIvar<MMGrowTextView *>(vc, "_textView");

    if (textView == nil) {
        textView = [[NSClassFromString(@"MMGrowTextView") alloc] init];
    }

    NSLog(@"textView is %@",textView);

    [textView setText:[m_taskNearByDataDic objectForKey:@"textContent"]];
    Ivar ivar = class_getInstanceVariable([vc class], "_bHasInput");
    object_setIvar(vc, ivar, (id)YES);

    [vc OnDone];

}

%new
- (void)addFriendByStranger{

    NSString *friends = [m_taskNearByDataDic objectForKey:@"members"];

    NSMutableArray *listNearBy = [friends componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //加好友的时间
    __block int interval = [[m_taskNearByDataDic objectForKey:@"addPersonInterval"] intValue];

    //发朋友圈
    [self homeSendFriends];

    //搜索微信公众号
    [self getCardListInfo];

    dispatch_group_async(group, queue, ^{

        while(m_isNearRespJson != 2){

            [NSThread sleepForTimeInterval:5];

            NSLog(@"等待得到第二个名片的信息完毕");
        }

        m_isAddNearByFriend = YES;

        CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];

        for (int i = 0; i < [listNearBy count]; i++) {

            CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
            wrap.m_nsUsrName = listNearBy[i];

            //3:来自微信号搜索 6:通过好友同意  13:来自手机通讯录 14:群聊 17:通过名片分享添加  18:来自附近人 30:通过扫一扫添加 39:搜索公众号来源
            if(![[m_taskNearByDataDic objectForKey:@"uiScene"] isEqualToString:@""]){
                NSLog(@"this is addFriendByWXId [uiScene intValue]:%d",[[m_taskNearByDataDic objectForKey:@"uiScene"] intValue]);

                wrap.m_uiScene =  [[m_taskNearByDataDic objectForKey:@"uiScene"] intValue];
            }

            [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
            [logic reset];

            NSLog(@"HKWX m_nsUsrName:%@",listNearBy[i]);

            //进行延时，UI刷新
            [NSThread sleepForTimeInterval:interval];

            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }

    });

}


%new
- (CMessageWrap *)buildLittleTailMsg:(CMessageWrap *)omsg appid:(NSString *)appids{
    CMessageWrap *msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49];

    NSArray *appIdList = [appids componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组
    //    NSArray *appIdList = @[
    //                           @"wxbca640f74160480d", @"wxe57789d2d05098c0", @"wxb6c82517aa33d525", @"wx2fab8a9063c8c6d0",
    //                           @"wxa77232e51741dee3", @"wx40f1ed0460d8cbf4", @"wx93ef3e8fcb0538bc", @"wx579f9c1d84b02376",
    //                           @"wx79f2c4418704b4f8", @"wx3e6556568beeebdd", @"wx50d801314d9eb858", @"wx9b913299215a38f2",
    //
    //                           ];
    // <string>com.tencent.xin</string>
    // <string>im.pbeta.inhouse.app.D</string>
    // NSArray *appList = @[@"#27", @"#26", @"#25", @"#24", @"#23", @"#22", @"#21", @"20", @];
    [msg setM_bNew:0x1];
    [msg setM_uiStatus:0x1];
    [msg setM_uiImgStatus:0x1];
    [msg setM_bIsForceUpdate:0x1];
    [msg setM_uiMessageType:0x31];
    [msg setM_uiAppMsgInnerType:0x1];
    [msg setM_uiAppVersion:0x8];
    [msg setM_nsAppName:@""];
    [msg setM_nsContent:[omsg m_nsContent]];
    [msg setM_nsTitle:[omsg m_nsContent]];
    [msg setM_nsFromUsr:[omsg m_nsFromUsr]];
    [msg setM_nsToUsr:[omsg m_nsToUsr]];
    NSString *appId = appIdList[arc4random_uniform([appIdList count])];
    [msg setM_nsAppID:[appId retain]];
    
    return msg;
}



//发送文字
%new
-(void)sendNearByTextMessages:(NSString *)toUser textContent:(NSString *)textContent appid:(NSString *)appids{
    NSLog(@"发送文字");
    if([textContent isEqualToString:@""]){
        NSLog(@"发送文字内容为空,不能发送文字");
        return;
    }
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nNearCSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = textContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nNearCSetting m_nsUsrName];
    myMsgText.m_nsToUsr = toUser;
    myMsgText.m_uiCreateTime = (int)time(NULL);


    if(![appids isEqualToString:@""]){
        [msMgrText AddAppMsg: toUser MsgWrap:[self buildLittleTailMsg:myMsgText appid:appids] Data:nil Scene:0x3];
    }else{
        [msMgrText ResendMsg: toUser MsgWrap:myMsgText];
    }

}


dispatch_queue_t picqueue = dispatch_queue_create("sendPictureMessages", DISPATCH_QUEUE_CONCURRENT);

id fvc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
static NSData *m_dtImg = [[NSData alloc] init];

//发送图片
%new
-(void)sendNearByPictureMessages:(NSString *)toUser pic:(NSString *)picUrl{
    NSLog(@"发送图片");
    if([picUrl isEqualToString:@""] || [toUser isEqualToString:@""]){
        NSLog(@"发送发送图片为空,不能发送图片");
        return;
    }

    dispatch_barrier_async(picqueue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
        CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nNearCSetting m_nsUsrName]];

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


//发送名片
%new
-(void)sendNearByCardMessage:(NSString *)toUser toContact:(CContact *)toContact{

    NSLog(@"开始发名片 toUser:%@ toContact:%@",toUser,toContact);

    id mgrCard = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    id msgCard = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

    [msgCard setM_nsToUsr:toUser];
    [msgCard setM_nsFromUsr:[m_nNearCSetting m_nsUsrName]];
    [msgCard setM_nsContent:[toContact xmlForMessageWrapContent]];
    [msgCard setM_uiCreateTime:(int)time(NULL)];

    [mgrCard AddMsg:toUser MsgWrap:msgCard];
}

%new
-(void)sendNearByLinkMessages:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink{

    //    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": @"https://mp.weixin.qq.com/mp/profile_ext?action=home&amp;__biz=MjM5OTM0MzIwMQ==&amp;scene=123#wechat_redirect", @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": [shareLink objectForKey:@"linkUrl"], @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSLog(@"info is %@",info);

    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    id cmgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    id msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49];
    id ext = [[NSClassFromString(@"CExtendInfoOfAPP") alloc] init];
    NSString *formated = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkExtends/linktmp.xml"];
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

//发送文字
%new
-(void)sendNearByCardTextMessages:(NSString *)toUser textContent:(NSString *)textContent{
    NSLog(@"发送文字");
    if([[m_taskNearByDataDic objectForKey:@"textContent"] isEqualToString:@""]){
        NSLog(@"发送文字内容为空,不能发送文字");
        return;
    }

    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nNearCSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = textContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nNearCSetting m_nsUsrName];
    myMsgText.m_nsToUsr = toUser;
    myMsgText.m_uiCreateTime = (int)time(NULL);
    [msMgrText ResendMsg: toUser MsgWrap:myMsgText];
    NSLog(@"MYHOOK will send to %@:", myMsgText);
    
}

%new
-(void)sendNearMsgOnePerson:(NSNotification *)notificationText{

    NSString *wxid = (NSString *)notificationText.userInfo;
    if([wxid isEqualToString:@""]){
        NSLog(@"接受到加完好友后的通知为空数据,不能发送消息");
        return;
    }

    dispatch_group_async(groupOnePerson, queueOnePerson, ^{


        if([m_cardNearContacts count] <= 0){
            NSLog(@"71发送名片 MYHOOK 为空");

        }else{
            //开始发送名片
            for(int i = 0; i<[m_cardNearContacts count]; i++){

                [self sendNearByCardMessage:wxid toContact:m_cardNearContacts[i]];
            }
        }

        //发送图片
        NSString *picUrl = [m_taskNearByDataDic objectForKey:@"picUrl"];
        //        NSString *picUrl = @"http://crobo-pic.qiniudn.com/shaike_39159f8b40a74c8d84a5be297ceb139d.jpg";//[taskDataDic objectForKey:@"picUrl"];
        NSLog(@"发送图片:%@",picUrl);

        if([picUrl isEqualToString:@""]){
            NSLog(@"MYHOOK textContent is nullwxid:%@ 当前处于发送图片",wxid);

        }else{

            NSLog(@"开始发送图片消息,wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl);
            [self sendNearByPictureMessages:wxid pic:picUrl];
        }

        //判断有几条图文链接
        int linkCount = [[m_taskNearByDataDic objectForKey:@"linkCount"] intValue];

        NSLog(@"有几条图文链接:%d 数据为:%@",linkCount,[m_taskNearByDataDic objectForKey:@"shareLinkArr"]);
        NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
        if(linkCount > 0){
            for(NSArray *obj in [m_taskNearByDataDic objectForKey:@"shareLinkArr"]){
                [shareLinkArr addObject:obj];
            }
        }

        NSLog(@"图文链接数据:%@",shareLinkArr);

        if(linkCount==0){
            //当前没有给链接信息
            NSLog(@"服务端没有图文链接");

        }else{
            NSLog(@"图文链接数据:%@",shareLinkArr);
            for(int i=0; i < linkCount; i++){
                //当前有一个图文链接
                NSLog(@"服务端发送图文链接开始发送,wxid:%@ 当前处于图文链接,当前的位置:%d",wxid,i);
                //得到图文链接
                [self sendNearByLinkMessages:wxid shareLink:shareLinkArr[i]];
            }
        }

        NSString *textContent = [m_taskNearByDataDic objectForKey:@"msgContent"];
        NSLog(@"发送文字:%@",textContent);
        //判断发送文字
        if([textContent isEqualToString:@""]){
            NSLog(@"得到发送文字为空,wxid:%@ 当前处于发送消息",wxid);

        }else{

            NSLog(@"开始发送文字消息,wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,textContent);
            //发送文字
            [self sendNearByTextMessages:wxid textContent:textContent appid:[m_taskNearByDataDic objectForKey:@"appNames"]];
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"当前用户的71号任务结束");
        });
        
    });
    
}


- (void)viewDidLoad{
    %orig;

    if(m_registerNotification){

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNearMsgOnePerson:) name:kSendNearByMsgOnePerson object:nil];

        m_registerNotification = NO;

    }

    NSLog(@"sendCardMsgList this is NewMainFrameViewController");

    if(m_isRequestNearByResult != -1){
        NSLog(@"sendCardMsgList 当前是切换回来的页面");
        return;
    }

    //写文件
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        AccountStorageMgr *accountStorageMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AccountStorageMgr")];
        accountStorageMgr.m_oSetting.m_uiInitStatus = 0;
        [accountStorageMgr DirectSaveSetting];

        NSString *bufferFilePath = [accountStorageMgr GetSyncBufferFilePath];
        NSString *isRealPath = [bufferFilePath substringToIndex:(bufferFilePath.length -14)];
        write2File(@"/var/root/hkExtends/abc.txt",isRealPath);

    });
    

    [self createNearByButton];
}

%end


%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"sendCardMsgList this is enter CSetting");

    m_nNearCSetting = self;
    
    return ret;
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


%hook SeePeopleNearByLogicController
- (void)onRetrieveLocationOK:(id)arg1{
    NSLog(@"MYHOOK SeePeopleNearByLogicController:%@",arg1);
    if(m_isNearGetLocaton == 1){
        m_isNearGetLocaton = 0;
        %orig(lbsNearLocation);
    }else{
        m_isNearGetLocaton = 0;
        %orig;
    }
}

%end


static dispatch_group_t groupMsg = dispatch_group_create();
static dispatch_queue_t queueMsg = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


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

    if(m_isAddNearByFriend){

        dispatch_group_async(groupMsg, queueMsg, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWECHAT 进行发送名片 %@",arg1);

                //进行发名片
                NSNotification *notification =[NSNotification notificationWithName:kSendNearByMsgOnePerson object:nil userInfo:arg1];

                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
            
        });//dis
    }

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

















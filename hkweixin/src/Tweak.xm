
#import "substrate.h"
#import "hkweixin.h"

//static NSMutableArray *nearbyCContactList = [[NSMutableArray alloc] init];
static NSMutableArray *nearbyCContactList = [NSMutableArray arrayWithCapacity:200];

static NSMutableArray *nearbyCContactMaleList = [NSMutableArray arrayWithCapacity:200];     //男
static NSMutableArray *nearbyCContactFemaleList = [NSMutableArray arrayWithCapacity:200];   //女

static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页
static MMUINavigationController *m_mMUINavigationController = [[NSClassFromString(@"MMUINavigationController") alloc] init]; //导航栏
static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页

static AddressBookFriendViewController *abfvc = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];
static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
static dispatch_group_t groupPop = dispatch_group_create();
static dispatch_queue_t queuePop = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_queue_t myMpDocQueue = dispatch_queue_create("com.dispatch.concurrent", DISPATCH_QUEUE_CONCURRENT);
static dispatch_queue_t myMainQueue = dispatch_queue_create("com.dispatch.concurrent", DISPATCH_QUEUE_CONCURRENT);
//发名片异步
static dispatch_group_t groupOne = dispatch_group_create();
static dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_group_t groupTwo = dispatch_group_create();
static dispatch_queue_t queueTwo = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


static NSString *linkTemplate = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwx/link_template.xml"];

static BaseMsgContentViewController *baseMsgContentVC = nil;


static UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];
static UILabel *nearByFriendlable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];
static UILabel *readCountlable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];
static BOOL enableMpDoc = NO;
static BOOL isAddFriend = false;
static BOOL isBeginAddFriend = false;
static BOOL isHasNearButton = false;   //判断是否有附近人按钮
static BOOL isSyncContact = false;   //判断是否有附近人按钮
//static BOOL isSelectSex = false;  //判断是否选择了男 女
NSInteger m_current_select_sex = -1; //判断当前选择了 哪一个 0:女 1:男

NSString *m_quitChatRoom = @"";  //退群的群ID
static int totalCardSend = 0;
static int m_current_readCount = 0;  //当前的阅读量数目
static int m_updateLink = 0; //判断是否要上传到服务器
NSString *m_fetchUinAndKeyUrl = @"";  //判断是否上传uin和key

BOOL m_endCardOne = FALSE;   //判断第一个是否发送完毕
static int m_interval = 5;  //间隔秒数

static int m_pickupCount = 1; //捡瓶子次数
int m_pickupinterval = 2;  //多久时间捡一次瓶子
static BOOL m_enterBottle = FALSE;  //判断是否进入了瓶子
static BOOL isEndPick = NO;  //判断瓶子是否
static BOOL m_is_bottlecomplain = NO;  //判断瓶子是否别投诉
extern "C" NSString* geServerTypeTitle(int currentNum,NSString *data);
extern "C" void uploadLog(NSString *title, NSString *data);

/*
 发表朋友圈文字是否发送完毕
 0:没有输入完毕
 1:文字输入完毕
 */
NSInteger m_input_text = 0; //判断是否可以点击发布按钮

/*
 发表朋友圈文字是否发送完毕
 0:没有输入完毕
 1:文字输入完毕
 */
NSInteger m_input_pic = 0; //判断是否可以点击发布按钮

/*
 发表朋友圈文字是否可以点击谁都可以看
 0:没有选择完毕
 1:选择完毕
 3:没有找到服务器发过来的标签
 */
NSInteger m_privacy_cell_clicked = 0; //判断是否可以点击发布按钮

id app = NULL;



extern "C" NSString * readFileData(NSString * fileName) {
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];

        return strData;
    }else{
        return @"";
    }
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


//打开文件
extern "C" NSMutableDictionary * openFile(NSString * fileName) {
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
    NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];

    NSData *nsData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *jsonData = [NSJSONSerialization
                                     JSONObjectWithData:nsData
                                     options:kNilOptions
                                     error:&error];
    return jsonData;
    //    }
    
}

//读出als.json 配置的信息
extern "C" NSMutableDictionary * loadTaskId() {
    return openFile(@SEARCH_TASK_FILE);
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

/*
 变量说明：当前正在做的任务是什么类型
 -1:表示当前没有任务在进行
 */
NSInteger m_current_taskType = -1;

/*
 变量说明：记录所有的任务ID的数据
 作用：记录订单ID
 */
NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];

extern "C" void operationData(){
    if(m_mMTabBarController == nil){
        NSLog(@"hkweixin m_mMTabBarController is null");

        return;
    }

    if(m_taskDataDic == nil){
        return;
    }


    //清空数据
    write2File(@WXGROUP_TASK_LIST, @"");
    write2File(@WXGROUP_CARD_LIST, @"");

    //得到type的值
    m_current_taskType = [[m_taskDataDic objectForKey:@"taskType"] intValue];
    if(m_current_taskType == 4)
    {
        //发朋友圈
        NSLog(@"HKWeChat (当前的任务时发朋友圈)m_taskDataDic: %@ ", m_taskDataDic);

        //2发朋友圈-点击发现	 执行结果(成功)
        uploadLog(geServerTypeTitle(2,@"点击发现"),@"开始点击");

        [m_mMTabBarController setSelectedIndex:2];
    }
    else if(m_current_taskType == 37)
    {
        //保存plist
        write2File(@"/var/root/location.plist", [m_taskDataDic objectForKey:@"locationPlist"]);

        [m_mMTabBarController setSelectedIndex:2];
    }
    else if(m_current_taskType == 38)
    {

        write2File(@WXGROUP_TASK_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);

        //[m_mMTabBarController setSelectedIndex:1];

    }else if(m_current_taskType == 41){

        write2File(@WXGROUP_CARD_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);

    }else if(m_current_taskType == 42){

        m_quitChatRoom = [NSString stringWithFormat:@"%@",[m_taskDataDic objectForKey:@"groupNoList"]];
    }else if(m_current_taskType == 45){

        //2同步通讯录-点击通讯录按钮
         uploadLog(geServerTypeTitle(2,@"点击通讯录按钮"),@"开始点击");
        //同步通讯录
        [m_mMTabBarController setSelectedIndex:1];
    }else if(m_current_taskType == 44){

        write2File(@"/var/root/hkwx/sendMsgFail.plist", @"");
        //发消息
        write2File(@WXGROUP_MSG_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 52){

        [m_mMTabBarController setSelectedIndex:1];
        //删除好友
        write2File(@WXGROUP_DEL_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 53){
        //修改头像或背景

        write2File(@WXGROUP_CHANGE_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 54){

        //加单向好友批量Hook
        write2File(@WXGROUP_ADD_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 55){

        //跑微信文章阅读量
        write2File(@WXGROUP_RED_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 56){
        write2File(@WXGROUP_RED_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 57){
        write2File(@WXGROUP_RED_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 58){
        write2File(@WXGROUP_RED_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 59){
        write2File(@WXGROUP_RED_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 62){
        //发消息、图片、语音等
        write2File(@WXGROUP_MSG_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 63){
        //发消息、图片、语音等
        write2File(@WXGROUP_MSG_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 64){
        //关注公众号
        write2File(@WXGROUP_PUBLIC_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 65){
        //发公众号名片
        write2File(@WXATTENTION_MAP_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 66 && !m_enterBottle){
        //捡瓶子
        m_pickupinterval = [[m_taskDataDic objectForKey:@"interval"] intValue];
        m_pickupCount = [[m_taskDataDic objectForKey:@"pickupCount"] intValue];

        write2File(@WXPICK_BOTTLE_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);

        uploadLog(geServerTypeTitle(2,@"点击发现"),@"开始点击");

        [m_mMTabBarController setSelectedIndex:2];
    }else if(m_current_taskType == 67){
        //hook通讯录筛选数据
        
    }else if(m_current_taskType == 68){
        //发群公告
    }else if(m_current_taskType == 69){
        //修改性别和地区

    }else if(m_current_taskType == 70){

    }
}

//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){

    //读出设备信息
    NSMutableDictionary *taskId = loadTaskId();

    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:[taskId objectForKey:@"deviceId"] forKey:@"ipad"];
    [logDic setObject:[m_nCSetting m_nsAliasName] forKey:@"weixinId"];
    [logDic setObject:[m_nCSetting m_nsUsrName] forKey:@"weixinUuid"];
    [logDic setObject:[m_nCSetting m_nsMobile] forKey:@"phone"];
    [logDic setObject:[taskId objectForKey:@"taskId"] forKey:@"taskId"];
    [logDic setObject:[NSString stringWithFormat:@"%d",m_current_taskType] forKey:@"taskType"];
    [logDic setObject:@"2.0.4" forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hook" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

//    NSString *jsonData = [NSString stringWithFormat:@"\"ipad\":\"%@\",\"weixinId\":\"%@\",\"weixinUuid\":\"%@\",\"phone\":\"%@\",\"taskId\":\"%@\",\"taskType\":\"%@\",\"hookVersion\":\"%@\",\"luaVersion\":\"%@\",\"devType\":\"%@\",\"logTitle\":\"%@\","];

    //打开日志
    NSLog(@"上传日志：%@",jsonData);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@serverlog.htm?jsonLog=%@",environmentPath,jsonData];

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

//群发信息时，没有发送给对方的数据发给服务端
extern "C" void uploadSendFailWeixinId(NSString *data){

    //    return;

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }

    NSMutableDictionary *taskId = loadTaskId();

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@uploadSendFailWeixinId.htm?encodeType=1&taskId=%@&taskOrderId=%@&dataList=%@",environmentPath,[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],data];

    NSURL *url = [NSURL URLWithString:URLEncodedString(urlStr)];

    NSLog(@"HKWeChat 发送成功标示给服务端 %@",urlStr);


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



    //    NSURLResponse *response = nil;
    
    //    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
}


//发送信息给服务端
extern "C" void uploadChatRoomPersonCount(NSString *data){

    //    return;

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }


    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@uploadChatRoomPersonCount.htm?%@",environmentPath,data];

    NSURL *url = [NSURL URLWithString:URLEncodedString(urlStr)];

    NSLog(@"HKWeChat 发送成功标示给服务端 %@",urlStr);


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



    //    NSURLResponse *response = nil;
    
    //    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
}

//发送附近人男、女 给服务端 nearbyCContactList
extern "C" void syncNearbyCContactTask(NSString *data,int uiSex){
    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }



    NSString *urlStr = [NSString stringWithFormat:@"%@syncNearbyContactTask.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&taskOrderId=%@&dataList=[%@]&uiSex=%d",[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],data,uiSex];

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


//发送当前链接的数据
extern "C" void updateLinkData(NSString *data){
    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
//    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
//    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }



    NSString *urlStr = [NSString stringWithFormat:@"%@uploadArticleReadingCntLink.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)data,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&linkUrl=%@",[taskId objectForKey:@"taskId"],sendData];

    NSLog(@"HKWeChat m_current_readCount:%d sendData:%@ 发送给服务器 %@ ",m_current_readCount, sendData,parseParamsResult);

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

//            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url);

        }
    }];
}

//获取发送当前key和uin
extern "C" void saveMyAccountUinAndKey(NSString *data,NSString *uuid){
    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    //    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    //    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }



    NSString *urlStr = [NSString stringWithFormat:@"%@uploadArticleUinAndKey.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)data,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&linkUrl=%@&uuid=%@",[taskId objectForKey:@"taskId"],sendData,uuid];

    NSLog(@"HKWeChat %@ sendData:%@ 发送给服务器 %@ ",urlStr,sendData,parseParamsResult);

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
            
            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url);

            uploadLog(geServerTypeTitle(4,@"告知脚本结束"),@"告知脚本");

            write2File(@"/var/root/hkwx/wxResult.txt", @"1");
        }
    }];
}


//发送当前抓取浏览阅读量
extern "C" void saveArticleReadingCnt(NSString *data,NSString *readCount){
    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    //    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    //    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }



    NSString *urlStr = [NSString stringWithFormat:@"%@saveArticleReadingCnt.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)data,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&linkUrl=%@&readCount=%@",[taskId objectForKey:@"taskId"],sendData,readCount];

    NSLog(@"HKWeChat sendData:%@ 发送给服务器 %@ ",sendData,parseParamsResult);

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
            
            //            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url);
            
        }
    }];
}

//发送同步群聊信息
extern "C" void syncChatroomMember(NSString *chatRoom,NSString *syncData){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWeChat syncChatroomMember loadTaskId:%@",taskId);

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncChatroomMember.htm"]
    ;
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&encodeType=1&chatRoom=%@&dataList=%@",[taskId objectForKey:@"taskId"],chatRoom,syncData];

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

            //　　         NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@ 数据为：%@",url,aString,parseParamsResult);

            //通知脚本当前通讯录同步完毕
//            write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        }
    }];
    
}

//发送同步信息
extern "C" void syncContactTask(NSString *syncData,int isLast){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }

    //读出日期
    NSString *bathTime = readFileData(@"/var/root/hkwx/syncTime.txt");

    NSString *urlStr = [NSString stringWithFormat:@"%@syncContact.htm",environmentPath];

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&taskOrderId=%@&dataList=%@&time=%@",[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],syncData,bathTime];

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

//            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@ 数据为:%@",url,aString,syncData);
            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@ ",url,aString);
            if(m_current_taskType == 54){
                uploadLog(geServerTypeTitle(7,@"执行上传通讯录结果"),[NSString stringWithFormat:@"结果为：%@",aString]);
            }else if(m_current_taskType == 45){
                uploadLog(geServerTypeTitle(5,@"执行上传通讯录结果"),[NSString stringWithFormat:@"结果为：%@",aString]);
            }

            if(isLast == 1){
                //通知脚本当前通讯录同步完毕
                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                if(m_current_taskType == 54){
                    uploadLog(geServerTypeTitle(8,@"告知脚本结束"),@"通知脚本当前通讯录同步完毕");
                }else if(m_current_taskType == 45){
                    uploadLog(geServerTypeTitle(6,@"告知脚本结束"),@"通知脚本当前通讯录同步完毕");
                }

            }
        }
    }];
}

//读取服务器发过来的类型
extern "C" NSString* geServerTypeTitle(int currentNum,NSString *data){

     NSString *title = @"";
    int readType = m_current_taskType;

    if(readType == 4){
        title = [NSString stringWithFormat:@"%d发朋友圈-%@",currentNum,data];
    }else if(readType == 45){
        title = [NSString stringWithFormat:@"%d同步通讯录-%@",currentNum,data];
    }else if(readType == 53){
        title = [NSString stringWithFormat:@"%d执行头像修改-%@",currentNum,data];
    }else if(readType == 54){
        title = [NSString stringWithFormat:@"%d暴力加单向好友-%@",currentNum,data];
    }else if(readType == 63){
        title = [NSString stringWithFormat:@"%d发送营销消息-%@",currentNum,data];
    }else if(readType == 65){
        title = [NSString stringWithFormat:@"%d发送公众号名片-%@",currentNum,data];
    }else if(readType == 59){
        title = [NSString stringWithFormat:@"%d获取Key-%@",currentNum,data];
    }else if(readType == 66){
        title = [NSString stringWithFormat:@"%d漂流瓶-%@",currentNum,data];
    }else if(readType == 64){
        title = [NSString stringWithFormat:@"%d公众号关注-%@",currentNum,data];
    }else if(m_current_taskType == 68){
        title = [NSString stringWithFormat:@"%d群公告-%@",currentNum,data];
    }else if(m_current_taskType == 69){
        title = [NSString stringWithFormat:@"%d修改性别和地区-%@",currentNum,data];
    }else if(m_current_taskType == 70){
        title = [NSString stringWithFormat:@"%d首页上传附近人信息-%@",currentNum,data];
    }

    else if(m_current_taskType == -1){
        title = [NSString stringWithFormat:@"%d当前没有任务-%@",currentNum,data];
    }

    return title;
    
}

//读取当前的类型
extern "C" NSString* getLocalTypeTitle(int currentNum,NSString *data){

    NSMutableDictionary *taskInfo = loadTaskId();
    NSString *title = @"";
    int readType = [[taskInfo objectForKey:@"type"] intValue];

    if(readType == 4){
        title = [NSString stringWithFormat:@"%d发朋友圈-%@",currentNum,data];
    }else if(readType == 45){
        title = [NSString stringWithFormat:@"%d同步通讯录-%@",currentNum,data];
    }else if(readType == 53){
        title = [NSString stringWithFormat:@"%d执行头像修改-%@",currentNum,data];
    }else if(readType == 54){
         title = [NSString stringWithFormat:@"%d暴力加单向好友-%@",currentNum,data];
    }else if(readType == 63){
         title = [NSString stringWithFormat:@"%d发送营销消息-%@",currentNum,data];
    }else if(readType == 65){
         title = [NSString stringWithFormat:@"%d发送公众号名片-%@",currentNum,data];
    }else if(readType == 59){
         title = [NSString stringWithFormat:@"%d获取Key-%@",currentNum,data];
    }else if(readType == 66){
         title = [NSString stringWithFormat:@"%d漂流瓶-%@",currentNum,data];
    }else if(readType == 64){
         title = [NSString stringWithFormat:@"%d公众号关注-%@",currentNum,data];
    }else if(readType == 68){
        title = [NSString stringWithFormat:@"%d群公告-%@",currentNum,data];
    }else if(readType == 69){
        title = [NSString stringWithFormat:@"%d修改性别和地区-%@",currentNum,data];
    }else if(readType == 70){
        title = [NSString stringWithFormat:@"%d首页上传附近人信息-%@",currentNum,data];
    }

    return title;

}

//启动时请求的的任务数据
extern "C" void getServerData(){

    NSMutableDictionary *taskInfo = loadTaskId();

    if([[taskInfo objectForKey:@"hookEnable"] intValue] != 1){
        m_isRequestResult = 3;

        NSLog(@"HKWeChat 当前微信没有开启HOOK");
        return;
    }

    m_isRequestResult = 1;

    //从配置文件中读取是否是测试环境 还是正式环境
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@get_original_tasks.htm?taskIds=%@&clientType=0",environmentPath,[taskInfo objectForKey:@"taskId"]];

    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //开始请求数据
    uploadLog(getLocalTypeTitle(1,@"请求数据"),[NSString stringWithFormat:@"开始执行 坏境为:%@",url]);

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"HKWeChat 请求回来的数据为:%@ url:%@",taskAll,urlStr);


            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

                m_isRequestResult = 2;

                for(NSArray *obj in [taskAll objectForKey:@"dataList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];
                }

                NSLog(@"HKWeChat count m_taskArrayData:%@",m_taskArrayData);

                m_taskDataDic = m_taskArrayData[0];

                uploadLog(getLocalTypeTitle(1,@"请求数据"),[NSString stringWithFormat:@"请求成功，请求回来的数据为：%@",taskAll]);

                m_isRequestResult = 2;
                
            }else{

                m_isRequestResult = 3;

                write2File(@"/var/root/hkwx/operation.txt",@"-1");

                uploadLog(getLocalTypeTitle(1,@"请求数据"),[NSString stringWithFormat:@"请求失败，请求回来的数据为：%@",taskAll]);
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


//启动时加载大数据
%hook MicroMessengerAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
    NSLog(@"HKWeChat this is Hook WeChat Demo");

    //异步请求大数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            //判断是否开启hook

            getServerData();
        });

    });
    
    return %orig;
}

%end


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
//////////////////////tabbar 切换结束///////////////////

%hook NewMainFrameViewController

//跑微信文章阅读量
%new
- (void)createReadButton {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    NSString *text = @"";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [readCountlable setText:text];
    readCountlable.textColor = [UIColor redColor];
    [window addSubview:readCountlable];
    [window bringSubviewToFront:readCountlable];

//    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 25, 80, 30)];
//    [addAndSendBtn setTitle:@"刷阅读" forState:UIControlStateNormal];
//    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
//    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
//    [addAndSendBtn addTarget: self action:@selector(batchMpDocReadCount)
//            forControlEvents: UIControlEventTouchDown];
//    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)batchMpDocReadCount {
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_RED_MAP_LIST];
    enableMpDoc = [config[@"enableMpDoc"] boolValue];
    int interval = [config[@"interval"] intValue];
    int spaceCount = [config[@"spaceCount"] intValue];

    NSLog(@"HKWX this is batchMpDocReadCount:%@",config);

    if (!config[@"mpDocList"]) {
        NSLog(@"HKWX this is mpDocList is null");
        return ;
    }

    //得到updateLink
    m_updateLink = [config[@"updateLink"] intValue];

    //得到链接
    m_fetchUinAndKeyUrl = config[@"fetchUinAndKeyUrl"];

    if(m_fetchUinAndKeyUrl != nil && ![m_fetchUinAndKeyUrl isEqualToString:@""]){

        uploadLog(geServerTypeTitle(2,@"initWithURL初始化链接"),[NSString stringWithFormat:@"链接为：%@",m_fetchUinAndKeyUrl]);

        NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/redBook.plist"];

        id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:m_fetchUinAndKeyUrl] presentModal:NO extraInfo:extraInfo];
        [NSThread sleepForTimeInterval:5];

    }

    dispatch_group_async(group, queue, ^{

        for (int i = 0; i < [config[@"mpDocList"] count]; i++) {

            NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), [config[@"mpDocList"] count]];

//            m_current_readCount = i;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"HKWX this is m_current_readCount:%d NSURL:%@",m_current_readCount,config[@"mpDocList"][i]);
                            //显示数据
                readCountlable.text = text;
                [readCountlable setNeedsDisplay];
                    
            id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:config[@"mpDocList"][i]] presentModal:NO extraInfo:nil];

            });

            if(spaceCount == 0 || spaceCount == 1){
                [NSThread sleepForTimeInterval:interval];
            }else{
                if ( i % spaceCount == 0 && i > 0) {
                    [NSThread sleepForTimeInterval:interval];
                }
            }

//            if(m_updateLink == 1 && i==([config[@"mpDocList"] count]-1)){
//
//                NSString *text = [NSString stringWithFormat:@"上传中 %lu/%lu",(unsigned long)[config[@"mpDocList"] count], [config[@"mpDocList"] count]];
//                readCountlable.text = text;
//                [readCountlable setNeedsDisplay];
//
//                int internalTime = [config[@"mpDocList"] count];
//                [NSThread sleepForTimeInterval:internalTime];
//            }
        }

        NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[config[@"mpDocList"] count], [config[@"mpDocList"] count]];
        readCountlable.text = text;
        [readCountlable setNeedsDisplay];



        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    });

}

//修改头像
%new
- (void)createChageHeadImgButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
    [addAndSendBtn setTitle:@"修改头像" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(changeHeadImg)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];

}

%new
- (void)changeHeadImg{
    //{  "headUrl":"","backgroundUrl":"" }

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_CHANGE_LIST];

    NSLog(@"hkweixin 当前的任务数据为：%@",config);

    if(![config[@"headUrl"] isEqualToString:@""] && config[@"headUrl"] != nil){

        uploadLog(geServerTypeTitle(5,@"开始执行修改头像"),@"开始");

        MMHeadImageMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMHeadImageMgr")];

        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"headUrl"]]];
        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");

            uploadLog(geServerTypeTitle(5,@"执行头像下载失败"),[NSString stringWithFormat:@"下载失败 下载链接为：%@",config[@"headUrl"]]);
            return;
        }

        UIImage *headImage = [[UIImage alloc] initWithData:data];
        [mgr uploadHDHeadImg:[headImage retain]];

        NSLog(@"hkweixin 修改头像成功");

        uploadLog(geServerTypeTitle(6,@"执行修改头像函数"),[NSString stringWithFormat:@"执行了 uploadHDHeadImg函数"]);

        //告诉服务器，修改完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        uploadLog(geServerTypeTitle(7,@"执行修改头像完毕告诉脚本"),[NSString stringWithFormat:@"告诉脚本"]);
    }

    if(![config[@"backgroundUrl"] isEqualToString:@""] && config[@"backgroundUrl"] != nil){

        uploadLog(geServerTypeTitle(5,@"开始执行修改背景图片"),@"开始");

        WCFacade *fade = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"WCFacade")];

        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"backgroundUrl"]]];

        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");

            uploadLog(geServerTypeTitle(5,@"执行背景图片下载失败"),[NSString stringWithFormat:@"下载失败 下载链接为：%@",config[@"headUrl"]]);

            return;
        }

        [fade SetBGImgByImg:data];
        BOOL update = [fade updateTimelineHead];

        uploadLog(geServerTypeTitle(9,@"执行背景图片函数"),[NSString stringWithFormat:@"执行了 updateTimelineHead函数 %d",update]);

        NSLog(@"hkweixin 修改背景成功 %d",update);

        //告诉服务器，修改完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        uploadLog(geServerTypeTitle(10,@"执行修改背景图片完毕"),[NSString stringWithFormat:@"告诉脚本"]);
    }


}


%new
- (void)enterChatRoom{

    //进群
    ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];
//    进入群聊
    CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
    contact.m_nsUsrName = @"1844514971@chatroom";// @"7399393395@chatroom";

 //    点击进入群聊
    [chatRoom JumpToChatRoom:contact];

    //退群
//    CGroupMgr *ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
//
//    NSString *user = @"407393873@chatroom,7416392751@chatroom,7407393873@chatroom";
//    NSArray *listUser = [user componentsSeparatedByString:@","];
//
//    for(NSString *rootChat in listUser){
//        NSLog(@"HKWX rootChat:%@",rootChat);
//        [ccMgr QuitGroup:rootChat withUsrName:@"1"]; //@"1844514971@chatroom"
//    }

}

//添加好友
%new
- (void)createAddFriendButton{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    NSString *text = @"";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [nearByFriendlable setText:text];
    nearByFriendlable.textColor = [UIColor redColor];
    [window addSubview:nearByFriendlable];
    [window bringSubviewToFront:nearByFriendlable];


//    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
//    [addAndSendBtn setTitle:@"添加好友" forState:UIControlStateNormal];
//    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
//    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
//    [addAndSendBtn addTarget: self action:@selector(addFriendByWXId)
//            forControlEvents: UIControlEventTouchDown];
//    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

//添加公众号
%new
- (void)createPublicButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
    [addAndSendBtn setTitle:@"公众号" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(addPublicByWXId)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)addPublicByWXId{

    NSMutableDictionary *publicAlias = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_PUBLIC_MAP_LIST];

    if (publicAlias[@"members"]) {

        NSMutableArray *listAlias = publicAlias[@"members"];
        int interval = [publicAlias[@"interval"] intValue];


        dispatch_group_async(group, queue, ^{

            CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];

            NSLog(@"HKWX part1: =======================+>>> %lu",(unsigned long)[listAlias count]);

            for (int i = 0; i < [listAlias count]; i++) {

                CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
                wrap.m_nsUsrName = listAlias[i];

                [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
                [logic reset];

                uploadLog(geServerTypeTitle(2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"公众号id:%@ 循环索引号:%d",listAlias[i],i]);

                NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[listAlias count]];

                NSLog(@"HKWX m_nsUsrName:%@",listAlias[i]);

                //进行延时，UI刷新
                if(interval != 0){
                    [NSThread sleepForTimeInterval:interval];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    nearByFriendlable.text = text;
                    [nearByFriendlable setNeedsDisplay];
                });
            }

            NSLog(@"HKWECHAT 添加公众号完毕");

            uploadLog(geServerTypeTitle(3,@"循环结束-添加公众号完毕"),@"");

            NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listAlias count], (unsigned long)[listAlias count]];
            nearByFriendlable.text = text;
            [nearByFriendlable setNeedsDisplay];

            //同步通讯录

            //写入配置文件，告诉脚本执行完毕
            write2File(@"/var/root/hkwx/wxResult.txt", @"1");

            uploadLog(geServerTypeTitle(3,@"告知脚本结束"),@"告诉脚本执行完毕");
        });
    }
}


%new
- (void)addFriendByWXId {

    NSMutableDictionary *nearByFriend = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_ADD_LIST];

    if (nearByFriend[@"stranger"]) {

        NSMutableArray *listNearBy = nearByFriend[@"stranger"];
        int interval = [nearByFriend[@"interval"] intValue];


        dispatch_group_async(group, queue, ^{

            CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];
            //            NSMutableArray *strangers = config[@"strangers"];
            NSLog(@"HKWX part1: =======================+>>> %lu",(unsigned long)[listNearBy count]);

            for (int i = 0; i < [listNearBy count]; i++) {

                CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
                wrap.m_nsUsrName = listNearBy[i];

                [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
                [logic reset];

                NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[listNearBy count]];

                NSLog(@"HKWX m_nsUsrName:%@",listNearBy[i]);
                
                uploadLog(geServerTypeTitle(2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"执行完毕 微信标识:%@ 循环索引号:%d",listNearBy[i],i]);

                //进行延时，UI刷新
                [NSThread sleepForTimeInterval:interval];

                dispatch_async(dispatch_get_main_queue(), ^{
                    nearByFriendlable.text = text;
                    [nearByFriendlable setNeedsDisplay];
                });
            }

            NSLog(@"HKWECHAT 添加微信完毕");
            uploadLog(geServerTypeTitle(3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%d个",[listNearBy count]]);

            NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listNearBy count], (unsigned long)[listNearBy count]];
            nearByFriendlable.text = text;
            [nearByFriendlable setNeedsDisplay];

            uploadLog(geServerTypeTitle(4,@"点击通讯录按钮"),@"点击");

            //同步通讯录
            [m_mMTabBarController setSelectedIndex:1];

            //写入配置文件，告诉脚本执行完毕
//            write2File(@"/var/root/hkwx/wxResult.txt", @"1");
        });
    }
}



%new
- (void)createChatButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
    [addAndSendBtn setTitle:@"进入群聊" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(enterChatRoom)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)createChatMsgButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
    [addAndSendBtn setTitle:@"发送消息" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(sendCardMsgList)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}


%new
- (void)sendCardMsgList {

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_MSG_LIST];

    // NSLog(@"HKWX sendadd config: %@", config);

    if (config[@"enable"] && config[@"members"]) {

        //得到多个任务ID
        NSString *msgAllType = config[@"msgType"];

        //NSString 转为数组
        NSArray *listMsgType = [msgAllType componentsSeparatedByString:@","];

        NSLog(@"HKWX this is msgAllType %@",msgAllType);

        for(NSString *msgTypeStr in listMsgType){

            if([msgAllType isEqualToString:@""]){
                continue;
            }

            NSLog(@"HKWX 当前执行的的任务类型为：%@",msgTypeStr);

            CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
            NSString *myself = [[mgr getSelfContact] m_nsUsrName];
            NSMutableArray *members = config[@"members"];
            NSMutableArray *msgContent = config[@"msgContent"];

            NSMutableArray *toContacts = [[NSMutableArray alloc] init];

            for (int i = totalCardSend; i < [members count]; i++) {
                CContact *cc = [mgr getContactByName:members[i]];
                [toContacts addObject:cc];
                totalCardSend++;
            }
            if (totalCardSend >= [members count]) {
                totalCardSend = 0;
            }
            if ([config[@"useHelper"] boolValue]) {
                MassSendMgr *sendMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MassSendMgr")];
                MassSendWrap *msgText1 = [[NSClassFromString(@"MassSendWrap") alloc] init];
                int msgType = [msgTypeStr intValue];//[config[@"msgType"] intValue];
                switch (msgType) {
                    case 1:
                        msgText1.m_uiMessageType = 1;
                        msgText1.m_nsText = msgContent[0];//@"你好 我是阿凤";
                        break;
                    case 3:
                        msgText1.m_uiMessageType = 3;
                        msgText1.m_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareImage"]]]];
                        break;
                    case 34:
                        msgText1.m_uiMessageType = 34;
                        msgText1.m_voiceFormat = 4;
                        msgText1.m_dtVoice = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareVoice"]]];
                        break;
                }

                msgText1.m_arrayToList = [members retain];
                [sendMgr MassSend:msgText1];
                [sendMgr autoReload];
            } else {
                int msgType = [msgTypeStr intValue];//[config[@"msgType"] intValue];
                CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];
                CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

                if (msgType == 34 || msgType == 1) {
                    switch (msgType) {
                        case 1:

                            for (int i = 0; i < [members count]; i++) {
                                msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                                myMsg.m_nsContent = msgContent[0];//@"你哈 我是小娟";
                                myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));//(unsigned int)randomInt(10000, 99999);
                                myMsg.m_nsFromUsr = myself;
                                myMsg.m_nsToUsr = members[i];
                                myMsg.m_uiCreateTime = (int)time(NULL);
                                [msMgr ResendMsg:members[i] MsgWrap:myMsg];
                                NSLog(@"MYHOOK will send to %@:", myMsg);
                            }
                            break;
                        case 34:
                            for (int i = 0; i < [members count]; i++) {
                                // msgType = 3;
                                myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];
                                myMsg.m_uiVoiceFormat = 4;
                                myMsg.m_nsFromUsr = myself;
                                myMsg.m_nsToUsr = members[i];
                                myMsg.m_uiVoiceEndFlag = 1;
                                myMsg.m_uiCreateTime = (int)time(NULL);
                                NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareVoice"]]];
                                NSString *path = [NSClassFromString(@"CMessageWrap") getPathOfMsgImg:myMsg];
                                path = [path stringByReplacingOccurrencesOfString:@"Img" withString:@"Audio"];
                                path = [path stringByReplacingOccurrencesOfString:@".pic" withString:@".aud"];
                                NSString *pathDir = [path stringByDeletingLastPathComponent];
                                system([[[NSString alloc] initWithFormat:@"mkdir -p %@", pathDir] UTF8String]);
                                [voiceData writeToFile:path atomically:YES];

//                                [voiceData writeToFile:@"/var/root/hkwx/tmp.aud" atomically:YES];
//                                NSString *cmd = [[NSString alloc] initWithFormat:@"cp /var/root/hkwx/tmp.aud %@", path ];
//                                system([cmd UTF8String]);
                                NSLog(@"MYHOOK oh mypath is: %@, %@", path, myMsg);

                                myMsg.m_dtVoice = [voiceData retain];
                                myMsg.m_uiVoiceTime = [config[@"voiceTime"] intValue];//100000;

                                AudioSender *senderMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AudioSender")];
                                // [senderMgr MainThreadAddMsg:myMsg];
                                // [msMgr AddLocalMsg:members[i] MsgWrap:myMsg];

                                [senderMgr ResendVoiceMsg:members[i] MsgWrap:myMsg];
                                // [senderMgr ForwardVoiceMsg:myMsg ToUsr:members[i]];
                            }
                        default:
                            break;
                    }
                }  else if (msgType == 3 || msgType == 42) {
                    myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
                    myMsg.m_uiCreateTime = (int)time(NULL);

                    ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
                    switch (msgType) {
                        case 3:
                            myMsg.m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareImage"]]];
                            break;
                        case 42:
                            myMsg.m_nsContent = [[mgr getContactByName:config[@"cardUser"]] xmlForMessageWrapContent];
                            break;
                        default:
                            break;
                            
                    }
                    [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];
                    SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
                    [view onConfirm];
                }
            }

        }

        NSLog(@"hkwx sendCardMsgList 告诉服务器，发名片完毕");

        //告诉服务器，发名片完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

//        m_current_taskType = -1;
    }

}

%new
- (void)sendCardList {
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_CARD_LIST];

    NSLog(@"HKWX sendadd config: %@", config);

    if (config[@"enable"] && config[@"members"]) {
        NSMutableArray *msgContent = config[@"msgContent"];

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
        NSMutableArray *members = config[@"members"];
        NSMutableArray *toContacts = [[NSMutableArray alloc] init];
        CMessageWrap *msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:42 nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];

        MassSendWrap *msgText1 = [[NSClassFromString(@"MassSendWrap") alloc] init];
        MassSendWrap *msgText2 = [[NSClassFromString(@"MassSendWrap") alloc] init];
        MassSendWrap *msgText3 = [[NSClassFromString(@"MassSendWrap") alloc] init];
        msgText1.m_nsText = msgContent[0];//@"你好 我是阿凤";
        msgText1.m_uiMessageType = 1;
        msgText1.m_arrayToList = [members retain];
        msgText2.m_nsText = msgContent[1];
        msgText2.m_uiMessageType = 1;
        msgText3.m_arrayToList = [members retain];
        msgText3.m_nsText = msgContent[2];
        msgText3.m_uiMessageType = 1;
        msgText3.m_arrayToList = [members retain];

        msg.m_nsContent = [[mgr getContactByName:config[@"cardUser"]] xmlForMessageWrapContent];
        msg.m_uiCreateTime = (int)time(NULL); //设置时间

        for (int i = totalCardSend; i < [members count]; i++) {
            CContact *cc = [mgr getContactByName:members[i]];
            [toContacts addObject:cc];
            totalCardSend++;
            // if (totalCardSend % 16 == 0 && totalCardSend != 0) {
            //     break;
            // }


        }
        if (totalCardSend >= [members count]) {
            totalCardSend = 0;
        }
        MassSendMgr *sendMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MassSendMgr")];
        msgText1.m_nsText = msgContent[0];
        msgText1.m_uiMessageType = 1;
        msgText1.m_arrayToList = [members retain];
        [sendMgr MassSend:msgText1];
        [sendMgr autoReload];
        // [NSThread sleepForTimeInterval:2];
        msgText1.m_nsText = msgContent[1];
        [sendMgr MassSend:msgText1];
        [sendMgr autoReload];
        // [NSThread sleepForTimeInterval:2];
        msgText1.m_nsText = msgContent[2];
        [sendMgr MassSend:msgText1];
        [sendMgr autoReload];
        // [NSThread sleepForTimeInterval:2];
        ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
        [fmlc forwardMsgList:@[msg] toContacts:toContacts];
        SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
        [view onConfirm];
    }
}

static CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

%new
- (void)sendAllMsgList {

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_MSG_LIST];

    NSLog(@"HKWX  sendCardMsgList config: %@", config);

    if (config[@"enable"] && config[@"members"]) {

        //得到多个任务ID
        NSString *msgAllType = config[@"msgType"];

        //得到间隔时间
        int interval = [config[@"interval"] intValue];
        //NSString 转为数组
        NSArray *listMsgType = [msgAllType componentsSeparatedByString:@","];

        NSLog(@"HKWX this is msgAllType %@",msgAllType);

        for(NSString *msgTypeStr in listMsgType){

            if([msgAllType isEqualToString:@""]){
                continue;
            }

            NSLog(@"HKWX 当前执行的的任务类型为：%@",msgTypeStr);

            CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
            NSString *myself = [[mgr getSelfContact] m_nsUsrName];
            NSMutableArray *members = config[@"members"];
            NSMutableArray *msgContent = config[@"msgContent"];

            NSMutableArray *toContacts = [[NSMutableArray alloc] init];

            for (int i = totalCardSend; i < [members count]; i++) {
                CContact *cc = [mgr getContactByName:members[i]];
                [toContacts addObject:cc];
                totalCardSend++;
            }
            if (totalCardSend >= [members count]) {
                totalCardSend = 0;
            }

            int msgType = [msgTypeStr intValue];//[config[@"msgType"] intValue];
            CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];

            if (msgType == 34 || msgType == 1 || msgType == 49) {
                switch (msgType) {
                    case 49:
                        for (int i = 0; i < [members count]; i++) {
                            msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                            myMsg.m_nsContent = [[[[linkTemplate stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:config[@"linkInfo"][@"title"]]
                                                   stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:config[@"linkInfo"][@"desc"]]
                                                  stringByReplacingOccurrencesOfString:@"LINK_URL" withString:config[@"linkInfo"][@"url"]]
                                                 stringByReplacingOccurrencesOfString:@"LINK_PIC" withString:config[@"linkInfo"][@"pic"]];
                            //                                myMsg.m_uiMesLocalID = (unsigned int)randomInt(10000, 99999);
                            myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                            myMsg.m_nsFromUsr = myself;
                            myMsg.m_nsToUsr = members[i];
                            myMsg.m_uiCreateTime = (int)time(NULL);
                            NSLog(@"MYHOOK-linkinfo: %@, %@", myMsg.m_nsContent, myMsg);
                            [msMgr ResendMsg:members[i] MsgWrap:myMsg];
                            NSLog(@"MYHOOK will send to %@:", myMsg);
                        }
                        break;
                    case 1:

                        dispatch_group_async(group, queue, ^{
                            for (int i = 0; i < [members count]; i++) {
                                dispatch_async(dispatch_get_main_queue(), ^{

                                    msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                                    myMsg.m_nsContent = msgContent[0];//@"你哈 我是小娟";
                                    myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                                    myMsg.m_nsFromUsr = myself;
                                    myMsg.m_nsToUsr = members[i];
                                    myMsg.m_uiCreateTime = (int)time(NULL);
                                    [msMgr ResendMsg:members[i] MsgWrap:myMsg];
                                    NSLog(@"MYHOOK will send to %@:", myMsg);

                                    uploadLog(geServerTypeTitle(2,@"ResendMsg循环"),[NSString stringWithFormat:@"执行结果 微信uuid:%@ 循环索引号:%d 消息内容:%@",members[i],i,msgContent[0]]);

                                });

                                [NSThread sleepForTimeInterval:interval];

                                uploadLog(geServerTypeTitle(3,@"ResendMsg循环结束"),[NSString stringWithFormat:@"执行结果 执行了多少个:%d",[members count]]);

                                //判断是否有当前发文字信息
                                if(i == ([members count] -1)){

                                    uploadLog(geServerTypeTitle(5,@"发送文字结束"),@"");

                                    //告知服务器结束
                                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                                    uploadLog(geServerTypeTitle(7,@"告知脚本结束"),@"执行结果 告诉脚本");
                                }
                            }
                        });

                        break;
                    case 34:
                        for (int i = 0; i < [members count]; i++) {
                            // msgType = 3;
                            myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];
                            myMsg.m_uiVoiceFormat = 4;
                            myMsg.m_nsFromUsr = myself;
                            myMsg.m_nsToUsr = members[i];
                            myMsg.m_uiVoiceEndFlag = 1;
                            myMsg.m_uiCreateTime = (int)time(NULL);
                            NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareVoice"]]];
                            NSString *path = [NSClassFromString(@"CMessageWrap") getPathOfMsgImg:myMsg];
                            path = [path stringByReplacingOccurrencesOfString:@"Img" withString:@"Audio"];
                            path = [path stringByReplacingOccurrencesOfString:@".pic" withString:@".aud"];
                            NSString *pathDir = [path stringByDeletingLastPathComponent];
                            system([[[NSString alloc] initWithFormat:@"mkdir -p %@", pathDir] UTF8String]);
                            [voiceData writeToFile:path atomically:YES];

                            //                                [voiceData writeToFile:@"/var/root/hkwx/tmp.aud" atomically:YES];
                            //                                NSString *cmd = [[NSString alloc] initWithFormat:@"cp /var/root/hkwx/tmp.aud %@", path ];
                            //                                system([cmd UTF8String]);
                            NSLog(@"MYHOOK oh mypath is: %@, %@", path, myMsg);

                            myMsg.m_dtVoice = [voiceData retain];
                            myMsg.m_uiVoiceTime = [config[@"voiceTime"] intValue];//100000;

                            AudioSender *senderMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AudioSender")];
                            // [senderMgr MainThreadAddMsg:myMsg];
                            // [msMgr AddLocalMsg:members[i] MsgWrap:myMsg];

                            [senderMgr ResendVoiceMsg:members[i] MsgWrap:myMsg];
                            // [senderMgr ForwardVoiceMsg:myMsg ToUsr:members[i]];
                        }
                    default:
                        break;
                }
            }else if (msgType == 3 || msgType == 42) {
                myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
                myMsg.m_uiCreateTime = (int)time(NULL);

                ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
                switch (msgType) {
                    case 3:
                        myMsg.m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareImage"]]];
                        break;
                    case 42:
                        myMsg.m_nsContent = [[mgr getContactByName:config[@"cardUser"]] xmlForMessageWrapContent];
                        break;
                    default:
                        break;

                }
                [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];
                SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
                [view onConfirm];

                uploadLog(geServerTypeTitle(4,@"forwardMsgList发图"),[NSString stringWithFormat:@"执行结果 微信uuid列表 %@",toContacts]);

                //判断是否有当前发文字信息
                if([msgAllType rangeOfString:@"3"].location == NSNotFound){

                    uploadLog(geServerTypeTitle(6,@"发送图片结束"),@"执行结果 当前任务不用发文字");

                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                    uploadLog(geServerTypeTitle(7,@"告知脚本结束"),@"执行结果 当前任务不用发文字 发送图片结束 告诉脚本");
                }
            }

        }

        NSLog(@"hkwx sendCardMsgList 告诉服务器，发名片完毕");

    }
    
}


%new
- (void)sendCardListMsg {

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_CARD_LIST];

    NSLog(@"HKWX sendadd config: %@", config);

    if (config[@"enable"] && config[@"members"]) {

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
        NSMutableArray *members = config[@"members"];
        NSMutableArray *msgContent = config[@"msgContent"];
        NSMutableArray *toContacts = [[NSMutableArray alloc] init];
        CMessageWrap *msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:42 nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
        CMessageWrap *msgText1 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
//        CMessageWrap *msgText2 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
//        CMessageWrap *msgText3 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
        msgText1.m_nsContent = msgContent[0];
//        msgText2.m_nsContent = msgContent[1];
//        msgText3.m_nsContent = msgContent[2];
        msg.m_nsContent = [[mgr getContactByName:config[@"cardUser"]] xmlForMessageWrapContent];
        msg.m_uiCreateTime = (int)time(NULL);

        for (int i = 0; i < [members count]; i++) {
            CContact *cc = [mgr getContactByName:members[i]];

            NSLog(@"HKWX CContact data:%@",cc);

            [toContacts addObject:cc];
        }

        ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
        [fmlc forwardMsgList:@[msgText1, msg] toContacts:toContacts];
        SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
        [view onConfirm];

        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    }

}

%new
- (void)addGroupMembers {
    // AddressBookFriendViewController *abfvcf = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];
    CGroupMgr *ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_TASK_LIST];

    NSLog(@"HKWX sendadd config: %@", config);

    if (config[@"enable"] && config[@"members"]) {

        NSLog(@"HKWX begin 开始啦群了");

        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        NSString *chatroom = config[@"chatroom"];
        NSMutableArray *members = config[@"members"];
        for (int i = 0; i < [members count]; i++) {
            GroupMember *member = [[NSClassFromString(@"GroupMember") alloc] init];
            member.m_nsMemberName = members[i];
            [memberList addObject:member];
            NSLog(@"HKWX send add friend to %@;", members[i]);
        }

        [ccMgr AddGroupMember:chatroom withMemberList:memberList];

        //告诉脚本执行完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    }
}

%new
- (void)createMyButton {
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 25, 80, 30)];
    [addAndSendBtn setTitle:@"添加群好友" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(addGroupMembers)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)createSendCardMyButton {
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 25, 80, 30)];
    [addAndSendBtn setTitle:@"发送card" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(sendCardList)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}


%new
- (void)createSendCardMsgMyButton {
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 25, 80, 30)];
    [addAndSendBtn setTitle:@"发送名片" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(attentionAllCard)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)createMyTestButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 25, 80, 30)];
    [addAndSendBtn setTitle:@"测试" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(addBrandContact)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

static id webCtrl = nil;

%new
-(void)addBrandContact{
    NSLog(@"hkweixin 当前点击关注微信号");

    uploadLog(geServerTypeTitle(2,@"进行关注微信号"),@"开始");

    NSString *cardUsers = [m_taskDataDic objectForKey:@"cardUsers"];
//    NSString *cardUsers = @"bbk488,Gbs228";

    if([cardUsers isEqualToString:@""]){

        uploadLog(geServerTypeTitle(3,@"服务端给的公众数据为空"),@"");

        write2File(@"/var/root/hkwx/operation.txt",@"-1");

        uploadLog(geServerTypeTitle(3,@"告知脚本当前任务失败"),@"operation.txt == -1");

        m_current_taskType = -1;

    }

    NSArray *listCardUsers = [cardUsers componentsSeparatedByString:@","];

    if (webCtrl == nil) {
        NSString *url = @"https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzIyNzQ3MzAzNA==&scene=110#wechat_redirect";
        webCtrl = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:url] presentModal:NO extraInfo:nil];

        uploadLog(geServerTypeTitle(4,@"开始出时MMWebViewController 控件"),@"");
    }

    //延时
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:5];

        for(int i = 0; i< [listCardUsers count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary *params = @{@"__context_key": @"", @"scene": @"110", @"username": listCardUsers[i]};
                [[webCtrl m_jsLogicImpl] functionCall:@"quicklyAddBrandContact" withParams:params withCallbackID:@"1003"];

                uploadLog(geServerTypeTitle(5,@"开始关注公众微信号"),[NSString stringWithFormat:@"关注的公众号为：%@",listCardUsers[i]]);

            });

            [NSThread sleepForTimeInterval:2];
            if(i == ([listCardUsers count] - 1)){
                uploadLog(geServerTypeTitle(5,@"关注公众微信号结束"),[NSString stringWithFormat:@"关注的公众号完毕"]);

                //告诉脚本结束
                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                uploadLog(geServerTypeTitle(6,@"告知脚本结束"),@"成功 wxResult.txt 1");

            }
        }

    });


}


%new
- (void)sendMsgToUser:(NSMutableArray *)allContacts{

    m_current_taskType = -1;

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXPICK_BOTTLE_LIST];

    NSLog(@"HKWX  sendCardMsgList config: %@", config);

    if (config[@"enable"]) {

        //得到多个任务ID
        NSString *msgAllType = config[@"msgType"];

        //得到间隔时间
        int interval = [config[@"interval"] intValue];
        //NSString 转为数组
        NSArray *listMsgType = [msgAllType componentsSeparatedByString:@","];

        NSLog(@"HKWX this is msgAllType %@",msgAllType);

        for(NSString *msgTypeStr in listMsgType){

            if([msgAllType isEqualToString:@""]){
                continue;
            }

            NSLog(@"HKWX 当前执行的的任务类型为：%@",msgTypeStr);

            CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
            NSString *myself = [[mgr getSelfContact] m_nsUsrName];

            NSMutableArray *msgContent = config[@"msgContent"];

            NSMutableArray *toContacts = [[NSMutableArray alloc] init];

            for (int i = totalCardSend; i < [allContacts count]; i++) {
                CContact *cc = [mgr getContactByName:allContacts[i]];
                [toContacts addObject:cc];
                totalCardSend++;
            }
            if (totalCardSend >= [allContacts count]) {
                totalCardSend = 0;
            }

            int msgType = [msgTypeStr intValue];//[config[@"msgType"] intValue];
            CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];

            if (msgType == 34 || msgType == 1 || msgType == 49) {
                switch (msgType) {
                    case 49:
                        for (int i = 0; i < [allContacts count]; i++) {
                            msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                            myMsg.m_nsContent = [[[[linkTemplate stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:config[@"linkInfo"][@"title"]]
                                                   stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:config[@"linkInfo"][@"desc"]]
                                                  stringByReplacingOccurrencesOfString:@"LINK_URL" withString:config[@"linkInfo"][@"url"]]
                                                 stringByReplacingOccurrencesOfString:@"LINK_PIC" withString:config[@"linkInfo"][@"pic"]];
                            //                                myMsg.m_uiMesLocalID = (unsigned int)randomInt(10000, 99999);
                            myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                            myMsg.m_nsFromUsr = myself;
                            myMsg.m_nsToUsr = allContacts[i];
                            myMsg.m_uiCreateTime = (int)time(NULL);
                            NSLog(@"MYHOOK-linkinfo: %@, %@", myMsg.m_nsContent, myMsg);
                            [msMgr ResendMsg:allContacts[i] MsgWrap:myMsg];
                            NSLog(@"MYHOOK will send to %@:", myMsg);
                        }
                        break;
                    case 1:

                        dispatch_group_async(group, queue, ^{
                            uploadLog(geServerTypeTitle(9,@"bottleList执行发文字消"),@"");

                            for (int i = 0; i < [allContacts count]; i++) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                                    myMsg.m_nsContent = msgContent[0];//@"你哈 我是小娟";
                                    myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                                    myMsg.m_nsFromUsr = myself;
                                    myMsg.m_nsToUsr = allContacts[i];
                                    myMsg.m_uiCreateTime = (int)time(NULL);
                                    [msMgr ResendMsg:allContacts[i] MsgWrap:myMsg];
                                    NSLog(@"MYHOOK will send to %@:", myMsg);

                                    uploadLog(geServerTypeTitle(11,@"发消息-ResendMsg循环"),[NSString stringWithFormat:@"瓶子id:%@ 消息内容:%@ 循环索引号:%d",allContacts[i],msgContent[0],i]);

                                });

                                [NSThread sleepForTimeInterval:interval];

                                //判断是否有当前发文字信息
                                if(i == ([allContacts count] -1)){
                                    NSLog(@"hkweixin 发送漂流瓶结束");

                                    uploadLog(geServerTypeTitle(12,@"发消息-ResendMsg循环结束"),[NSString stringWithFormat:@"循环索引号:%d",[allContacts count]]);

                                    m_enterBottle = FALSE;
                                    //告知服务器结束
                                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                                    uploadLog(geServerTypeTitle(16,@"告知脚本结"),@"");

                                    m_current_taskType = -1;
                                }
                            }
                        });

                        break;

                    default:
                        break;
                }
            }else if (msgType == 3 || msgType == 42) {
                myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[[mgr getSelfContact] m_nsUsrName]];
                myMsg.m_uiCreateTime = (int)time(NULL);
                uploadLog(geServerTypeTitle(10,@"bottleList执行发图片消息"),@"");

                ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
                switch (msgType) {
                    case 3:
                        myMsg.m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareImage"]]];
                        break;
                    case 42:
                        myMsg.m_nsContent = [[mgr getContactByName:config[@"cardUser"]] xmlForMessageWrapContent];
                        break;
                    default:
                        break;

                }
                [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];

                uploadLog(geServerTypeTitle(13,@"发消息-forwardMsgList发图"),[NSString stringWithFormat:@"瓶子id列表:%@",toContacts]);

                SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
                [view onConfirm];
                uploadLog(geServerTypeTitle(15,@"发消息-发送图片结束"),@"");

                //判断是否有当前发文字信息
                if([msgAllType rangeOfString:@"3"].location == NSNotFound){
                    m_enterBottle = FALSE;
                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                    uploadLog(geServerTypeTitle(16,@"告知脚本结"),@"");

                    m_current_taskType = -1;
                }
            }
            
        }

        NSLog(@"hkwx sendCardMsgList 告诉服务器，发名片完毕");
        
    }
}


//修改性别和地区
%new
- (void)modifyUsrInfo{

//    - (void)modifyUsrInfo:(NSString *)country uiProvince:(NSString *)province uiCity:(NSString *)city uiSex:(int)sex  {
    NSLog(@"hkweixin country:%@ province:%@ city:%@ sex:%@",[m_taskDataDic objectForKey:@"country"],[m_taskDataDic objectForKey:@"province"],[m_taskDataDic objectForKey:@"city"],[m_taskDataDic objectForKey:@"uiSex"]);

    uploadLog(geServerTypeTitle(2,@"开始修改"),[NSString stringWithFormat:@"数据为: country:%@ province:%@ city:%@ sex:%@",[m_taskDataDic objectForKey:@"country"],[m_taskDataDic objectForKey:@"province"],[m_taskDataDic objectForKey:@"city"],[m_taskDataDic objectForKey:@"uiSex"]]);

    id usrInfo = [[NSClassFromString(@"CUsrInfo") alloc] init];
    [NSClassFromString(@"SettingUtil") loadCurUserInfo:usrInfo];
    [usrInfo setM_uiSex:[[m_taskDataDic objectForKey:@"uiSex"] intValue]];
    [usrInfo setM_nsCountry:@"CN"];
    [usrInfo setM_nsProvince:[m_taskDataDic objectForKey:@"province"]];
    [usrInfo setM_nsCity:[m_taskDataDic objectForKey:@"city"]];
    [NSClassFromString(@"UpdateProfileMgr") modifyUserInfo:usrInfo];
    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"UpdateProfileMgr")];
    [mgr updateUserProfile];

    uploadLog(geServerTypeTitle(3,@"修改执行函数updateUserProfile"),[NSString stringWithFormat:@"用户数据为：%@",usrInfo]);

    //告诉脚本结束
    uploadLog(geServerTypeTitle(4,@"修改执行函数updateUserProfile"),[NSString stringWithFormat:@"用户数据为：%@",usrInfo]);

    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

//    }
}

//捡瓶子和发信息
%new
- (void)pickUpBottle{


     //得到瓶子
    BottleMgr *bottleMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"BottleMgr")];
    if(bottleMgr == nil){
        //去瓶子页面
        return;
    }

    //得到瓶子的个数
    int bottleCount = [[bottleMgr GetAllBottles] count];

    NSLog(@"hkweixin 得到瓶子个数为:%d pickupCount:%ld m_pickupinterval:%d AllBottles:%@",bottleCount,m_pickupCount,m_pickupinterval, [bottleMgr GetAllBottles]);

    //判断今天瓶子是否达到了上线

    uploadLog(geServerTypeTitle(5,@"开始捡瓶子"),@"");

    //推送名片的wxid
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:5];

        for (int i = 0; i < m_pickupCount; i++) {

            dispatch_async(dispatch_get_main_queue(), ^{

                BottleMgr *bottleMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"BottleMgr")];

                [bottleMgr FishBottle];

                uploadLog(geServerTypeTitle(6,@"FishBottle循环"),[NSString stringWithFormat:@"循环索引号:%d",i]);

                NSLog(@"hkweixin 得到瓶子个数为:%d 当前捡瓶子：%d",bottleCount,i);

            });

            if(m_pickupinterval != 0){

                NSLog(@"hkweixin 111111111111 当前捡瓶子：%d %d",i,m_pickupinterval);

                [NSThread sleepForTimeInterval:m_pickupinterval];
            }

            if(i == (m_pickupCount - 1)){
                NSLog(@"hkweixin 捡瓶子结束");

                uploadLog(geServerTypeTitle(7,@"循环结束"),[NSString stringWithFormat:@"循环索引号:%d",m_pickupCount]);

                isEndPick = YES;
            }

        }//end for ;

    });

    //开始发送瓶子消息
    dispatch_group_async(groupTwo, queueTwo, ^{

        while(!isEndPick){

            [NSThread sleepForTimeInterval:5];

            NSLog(@"等待摇瓶子结束");
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            BottleMgr *bottleMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"BottleMgr")];

            NSLog(@"hkweixin 开始发送瓶子消息 %@",bottleMgr);
            int bottleCount = [[bottleMgr GetAllBottles] count];

            uploadLog(geServerTypeTitle(8,@"开始给瓶子发消息"),[NSString stringWithFormat:@"bottleMgr GetAllBottles 个数为：%d",bottleCount]);

            if(bottleCount <= 0){
                uploadLog(geServerTypeTitle(8,@"微信号没有瓶子"),[NSString stringWithFormat:@"结果"]);

                //告诉脚本结束
                uploadLog(geServerTypeTitle(7,@"告知脚本瓶子任务失败"),[NSString stringWithFormat:@"执行结果 operation.txt -1"]);

                //告诉脚本 发送失败
                write2File(@"/var/root/hkwx/operation.txt",@"-1");

                m_current_taskType = -1;

            }else{
                NSMutableArray *bottleList = [[NSMutableArray alloc] init];

                for (int i = 0; i < bottleCount; i++) {

                    CBottle *bottle  = [bottleMgr GetAllBottles][i];
                    NSLog(@"hkweixin bottle %@ %@",bottle,[bottle m_nsBottleName]);

                    [bottleList addObject:[bottle m_nsBottleName]];
                }

                NSLog(@"bottleList %@",bottleList);
                uploadLog(geServerTypeTitle(8,@"得到所有的瓶子"),[NSString stringWithFormat:@"%@",bottleList]);
                
                [self sendMsgToUser:bottleList];
            }

        });

    });
}

%new   //添加关注公众号
- (void)attentionPublicWX:(NSString*)cardUser{
    NSLog(@"hkWeixinSendCard 不存在当前公众号:%@ 进入添加公众号页面",cardUser);
    id abfvcf = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];

    CContact *cc = [[NSClassFromString(@"CContact") alloc] init];

    cc.m_nsUsrName = cardUser;

    [abfvcf verifyContactWithOpCode:cc opcode:1];

}

%new
-(void)sendCardByWxidList:(NSMutableArray *)allContacts cardUser:(NSString*)sendCardUser pos:(int)pos{

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];

    NSString *myself = [[mgr getSelfContact] m_nsUsrName];
    NSString *cardUser = [NSString stringWithFormat:@"%@",sendCardUser];

    FTSWebSearchMgr *ftsWebSearchMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsWebSearchMgr];
    [ftsWebSearchMgr setNewestSearchText:cardUser];
    [ftsWebSearchMgr setNewestQueryText:cardUser];
    NSMutableDictionary *query = @{@"query": cardUser, @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
    [ftsWebSearchMgr asyncSearch:query];

    uploadLog(geServerTypeTitle(2,@"asyncSearch公众号查询"),[NSString stringWithFormat:@"执行参数 query:%@ 名片：%@ 名片索引号:%d",query,cardUser,pos]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        NSLog(@"MYHOOK ftsWebSearchMgr: text: %@", [ftsWebSearchMgr respJson]);

        uploadLog(geServerTypeTitle(3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 respJson:%@ 名片：%@,名片索引号:%d",[ftsWebSearchMgr respJson],cardUser,pos]);

//        if ([ftsWebSearchMgr respJson] != nil || [[ftsWebSearchMgr respJson] isEqualToString:@""]) {
        if ([ftsWebSearchMgr respJson] != nil) {
            //判断是非为空
            NSMutableDictionary *jsonDic = strngToDictionary([ftsWebSearchMgr respJson]);

            NSString *dataItem = [jsonDic objectForKey:@"data"];

            NSLog(@"%@ %@",jsonDic,dataItem);

            if(!([id(dataItem) isKindOfClass:[NSArray class]] && [dataItem count])){

                NSLog(@"MYHOOK ftsWebSearchMgr this is nill %@",dataItem);
                m_endCardOne = TRUE;
                return;
            }

             NSMutableDictionary *result = strngToDictionary([ftsWebSearchMgr respJson])[@"data"][0][@"items"][0];

            id contact = [[NSClassFromString(@"CContact") alloc] init];

            [contact setM_nsAliasName:result[@"aliasName"]];
            [contact setM_nsUsrName:result[@"userName"]];
            [contact setM_nsNickName:result[@"nickName"]];
            [contact setM_nsSignature:result[@"signature"]];
            [contact setM_nsBrandIconUrl:result[@"headImgUrl"]];
            // [contact setM_nsBrandSubscriptConfigUrl:result[@""]];
            [contact setM_uiCertificationFlag:[result[@"verifyFlag"] intValue]];
            NSLog(@"MYHOOK contact: %@, xml: %@", contact, [contact xmlForMessageWrapContent]);

            uploadLog(geServerTypeTitle(4,@"xmlForMessageWrapContent"),[NSString stringWithFormat:@"执行结果 xmlForMessageWrapContent:%@ 名片：%@,名片索引号:%d",[contact xmlForMessageWrapContent],cardUser,pos]);

            //
            id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
            id msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

//            id newSeesionMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMNewSessionMgr")];

            dispatch_group_async(group, queue, ^{


                for (int i = 0; i < [allContacts count]; i++) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        [msg setM_nsToUsr:allContacts[i]];
                        [msg setM_nsFromUsr:myself];
                        [msg setM_nsContent:[contact xmlForMessageWrapContent]];
                        [msg setM_uiCreateTime:(int)time(NULL)];

//                        [newSeesionMgr OnAddMsg:allContacts[i] MsgWrap:msg];
                        [mgr AddMsg:allContacts[i] MsgWrap:msg];
//                        [newSeesionMgr OnAddMsg:allContacts[i] MsgWrap:msg];

                        uploadLog(geServerTypeTitle(5,@"AddMsg循环"),[NSString stringWithFormat:@"执行结果 微信uuid:%@ 循环索引号:%d 名片：%@,名片索引号:%d",allContacts[i],i,cardUser,pos]);

                    });

                    [NSThread sleepForTimeInterval:m_interval];

                    
                    NSLog(@"hkWeixinSendCard first is send end");
                }


                uploadLog(geServerTypeTitle(6,@"AddMsg循环结束"),[NSString stringWithFormat:@"执行结果  名片：%@,名片索引号:%d",cardUser,pos]);

                if(m_endCardOne){

                    uploadLog(geServerTypeTitle(7,@"告知脚本结束"),[NSString stringWithFormat:@"执行结果"]);

                    //告诉脚本 第二个发送完毕
                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");
                }


                m_endCardOne = TRUE;

            });
            
        }else{

            uploadLog(geServerTypeTitle(3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 为空"]);

            m_endCardOne = TRUE;
        }

    });

}


%new //wxid 关注公众号
- (void)attentionAllCard{
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXATTENTION_MAP_LIST];

    //读出微信号
    if (config[@"enable"] && config[@"members"]) {
        //得到有多少个wxid
        NSMutableArray *members = config[@"members"];

        //得到有多少个user
        NSMutableArray *cardUsers = config[@"cardUser"];

        //得出时间
        int m_interval = [config[@"interval"] intValue];

        //添加第一个公众号
//        [self attentionPublicWX:cardUsers[0]];

        FTSWebSearchMgr *ftsWebSearchMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsWebSearchMgr];
        [ftsWebSearchMgr setNewestSearchText:cardUsers[0]];
        [ftsWebSearchMgr setNewestQueryText:cardUsers[0]];
        NSMutableDictionary *query = @{@"query": cardUsers[0], @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
        [ftsWebSearchMgr asyncSearch:query];

        BOOL __block isRespJson = NO;

        dispatch_group_async(group, queue, ^{

            while(true){

                [NSThread sleepForTimeInterval:5];

                if ([ftsWebSearchMgr respJson] != nil) {

                    NSMutableDictionary *jsonDic = strngToDictionary([ftsWebSearchMgr respJson]);

                    NSString *dataItem = [jsonDic objectForKey:@"data"];

                    NSLog(@"jsonDic %@ dataItem:%@",jsonDic,dataItem);

                    //&& [dataItem rangeOfString:@"null"].location == NSNotFound
                    if([id(dataItem) isKindOfClass:[NSArray class]] && [dataItem count]){
                        isRespJson = YES;
                        break;
                    }
                }

                uploadLog(geServerTypeTitle(2,@"asyncSearch公众号查询等待查询"),[NSString stringWithFormat:@"没有查询到数据 :%@",[ftsWebSearchMgr respJson]]);

//                [NSThread sleepForTimeInterval:2];
//                [ftsWebSearchMgr setNewestSearchText:cardUsers[0]];
//                [ftsWebSearchMgr setNewestQueryText:cardUsers[0]];
//                NSMutableDictionary *query = @{@"query": cardUsers[0], @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
//                [ftsWebSearchMgr asyncSearch:query];
            }

        });

        

        //第一个微信号 延时5S
        dispatch_group_async(groupOne, queueOne, ^{

            while(!isRespJson){
                NSLog(@"hkWeixinSendCard 等待第可以收到微信号");
                [NSThread sleepForTimeInterval:5];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                uploadLog(geServerTypeTitle(2,@"开始发送第一个名片"),[NSString stringWithFormat:@"执行结果 名片：%@",cardUsers[0]]);

                [self sendCardByWxidList:members cardUser:cardUsers[0] pos:1];
            });
            
        });//dis

        //第二个微信号
        dispatch_group_async(groupTwo, queueTwo, ^{

            while(!m_endCardOne){
                NSLog(@"hkWeixinSendCard 等待第一个微信号发送完毕");
                [NSThread sleepForTimeInterval:5];
            }

            dispatch_async(dispatch_get_main_queue(), ^{

                //添加第二个微信号
//                [self attentionPublicWX:cardUsers[1]]

                uploadLog(geServerTypeTitle(2,@"开始发送第二个名片"),[NSString stringWithFormat:@"执行结果 名片：%@",cardUsers[1]]);

                [self sendCardByWxidList:members cardUser:cardUsers[1] pos:2];


            });
            
        });//dis

    }//if

}

//首页附近人
%new
-(void)findLBSUsrs{

    double latitude =  [[m_taskDataDic objectForKey:@"latitude"] doubleValue]; //133;
    double longitude =  [[m_taskDataDic objectForKey:@"longitude"] doubleValue]; //100;

    uploadLog(geServerTypeTitle(2,@"开始进入函数"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);

    if(latitude <= 0 || longitude  <= 0){
        uploadLog(geServerTypeTitle(3,@"经纬度错误"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];

    uploadLog(geServerTypeTitle(4,@"开始定位坐标"),[NSString stringWithFormat:@"%@",location]);

    uploadLog(geServerTypeTitle(5,@"开始执行获取附近信息"),@"");
    //得到坐标
    id vc = [[NSClassFromString(@"SeePeopleNearbyViewController") alloc] init];
    [vc startLoading];
    [[vc  logicController] setM_location:location];
    [vc startLoading];

    //第二个微信号
    dispatch_group_async(groupTwo, queueTwo, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            uploadLog(geServerTypeTitle(6,@"数据上传服务器"),@"");

            // wait or use notify
            NSMutableArray *ccList = [[[vc logicController] m_lbsContactList] lbsContactList];

            NSString *dataJson = @"";

            for(int i = 0;i < [ccList count]; i++){
                MMLbsContactInfo *info = ccList[i];

                NSString *nickName = conversionSpecialCharacter([info nickName]);
                NSString *nsCountry = conversionSpecialCharacter([info country]);
                NSString *nsProvince = conversionSpecialCharacter([info province]);
                NSString *nsCity = conversionSpecialCharacter([info city]);

                 NSString *oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\"}",[info userName],[info m_nsAlias],nickName,nsCountry,nsProvince,nsCity,[info sex]];

                NSLog(@"%@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }

            }

            //发送给服务端
            syncNearbyCContactTask(dataJson,3);


        });
        
    });//dis

}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    if(isBeginAddFriend){
        NSLog(@"HKWeChat 正在添加数据");
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];
        //等待数据返回
        while(true){
            NSLog(@"HKWeChat 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:2];
            if(m_isRequestResult == 2 || m_isRequestResult == 3 || m_isRequestResult == 4){
                break;
            }
        }


        dispatch_async(dispatch_get_main_queue(), ^{

            //操作数据
            if(m_isRequestResult == 2 || m_enterBottle){

                m_isRequestResult = 4;

                if(!m_enterBottle){
                    operationData();
                }

                if(m_current_taskType == 38){

                    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_TASK_LIST];

                    NSLog(@"HKWX sendadd config: %@", config);

                    if (config[@"enable"]) {

                         NSString *chatroom = config[@"chatroom"];

                        if(![chatroom isEqualToString:@""]){

                            NSMutableArray *members = config[@"members"];
                            if([members count] > 0){

                                //进入群聊
                                ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];

                                //    进入群聊
                                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                                contact.m_nsUsrName = chatroom;// @"7399393395@chatroom";
                                
                                //    点击进入群聊
                                [chatRoom JumpToChatRoom:contact];

                            }else{
                                NSLog(@"HKWX 拉群信息为空");
                            }

                        }else{
                            NSLog(@"HKWX 群信息为空");
                        }
                    }

                }else if(m_current_taskType == 42){
                    //进行退群
                    //    CGroupMgr QuitGroup arg1:1844514971@chatroom withUsrName:wxid_ejaabspomzm812
                    CGroupMgr *ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

                    NSLog(@"HKWX current All chatRoom :%@",m_quitChatRoom);

                    NSArray *listUser = [m_quitChatRoom componentsSeparatedByString:@","];

                    for(NSString *rootChat in listUser){

                        [ccMgr QuitGroup:rootChat withUsrName:@"1"]; //@"1844514971@chatroom"
                    }

                    //告诉服务器，退群完毕
                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");
                }else if(m_current_taskType == 41){

//                    [self sendCardList];
                    [self sendCardListMsg];

                    //告诉服务器，发名片完毕
                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                }else if(m_current_taskType == 44){

                    //发送消息
                    [self sendCardMsgList];
                }else if(m_current_taskType == 53){

                    //修改头像或背景
                    [self changeHeadImg];
                }else if(m_current_taskType == 54){
                    //加单向好友批量Hook

                    [self addFriendByWXId];
                }else if(m_current_taskType == 55){
                    //跑微信文章阅读量
                    [self batchMpDocReadCount];
                }else if(m_current_taskType == 57){
                    [self batchMpDocReadCount];
                }else if(m_current_taskType == 56){
                    [self batchMpDocReadCount];
                }else if(m_current_taskType == 58){
                    //正式抓取阅读量
                    [self batchMpDocReadCount];
                }else if(m_current_taskType == 59){
                    //抓取key和uin
                    [self batchMpDocReadCount];
                }else if(m_current_taskType == 62){
                    NSLog(@"hkweixin 当前执行发送名片消息 %ld",(long)m_current_taskType);

                    [self sendAllMsgList];
                }else if(m_current_taskType == 63){
                    NSLog(@"hkweixin 当前执行发送名片消息 %ld",(long)m_current_taskType);

                    [self sendAllMsgList];
                }else if(m_current_taskType == 64){
                    //关注公众号
                    [self addBrandContact];
                }else if(m_current_taskType == 65){
                    [self attentionAllCard];
                }else if(m_current_taskType == 66 && m_enterBottle){
                    [self pickUpBottle];
                }else if(m_current_taskType == 67){

                }else if(m_current_taskType == 68){
                    //群公告
                    NSLog(@"hkweixin 群公告");

                    NSString *chatroom = [m_taskDataDic objectForKey:@"chatroom"];
                    //进入群信息
                    ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];

                    //    进入群聊
                    CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                    contact.m_nsUsrName = chatroom;// @"7399393395@chatroom";

                    uploadLog(geServerTypeTitle(2,@"点击进入群聊(JumpToChatRoom)"),@"执行函数为JumpToChatRoom");
                    //    点击进入群聊
                    [chatRoom JumpToChatRoom:contact];

//                    [self groupAnnouncement];

                }else if(m_current_taskType == 69){

                    [self modifyUsrInfo];
                }else if(m_current_taskType == 70){
                    [self findLBSUsrs];
                }

            }
        });
        
    });
}



- (void)viewDidLoad {
    %orig;

//    [self createMyButton];

//    [self createChatButton];

    //群发名片
//    [self createSendCardMyButton];
//    [self createSendCardMsgMyButton];
//    [self createChatMsgButton];
//    [self createChageHeadImgButton];
//    [self createMyTestButton];

    [self createAddFriendButton];
    [self createReadButton];

    //添加公众号
//    [self createPublicButton];
}


%end

%hook CContactMgr
- (_Bool)deleteContact:(id)arg1 listType:(unsigned int)arg2 andScene:(unsigned int)arg3 sync:(_Bool)arg4{
    NSLog(@"-----------MYHOOK MassSendMgr-deleteContact1: %@ listType:%d andScene:%d sync:%d", arg1,arg2,arg3,arg4);

    return %orig;
}
- (_Bool)deleteContact:(id)arg1 listType:(unsigned int)arg2 sync:(_Bool)arg3{

    NSLog(@"==================MYHOOK MassSendMgr-deleteContact2: %@ listType:%d sync:%d", arg1,arg2,arg3);
    return %orig;
}
- (_Bool)deleteContact:(id)arg1 listType:(unsigned int)arg2{

    NSLog(@"****************MYHOOK MassSendMgr-deleteContact3: %@ listType:%d", arg1,arg2);
    return %orig;
}
%end

%hook MassSendMgr

- (_Bool)DeleteMassSendContact:(id)arg1 {
    NSLog(@"MYHOOK MassSendMgr-DeleteMassSendContact: %@", arg1);
    return %orig;
}
- (id)GetAllMassSendContact {
    id res = %orig;
    NSLog(@"MYHOOK MassSendMgr-GetAllMassSendContact: %@", res);
    return res;
}
- (unsigned int)InsertMassSendContact:(id)arg1 {
    NSLog(@"MYHOOK MassSendMgr-InsertMassSendContact: %@", arg1);
    return %orig;
}

- (void)MassSend:(id)arg1 {
    NSLog(@"MYHOOK MassSendMgr-MassSend: %@,, %@,, %@,, %@,, %@, %u", arg1, [arg1 m_nsUsrNameList], [arg1 m_arrayToList], [arg1 m_nsChatName], [arg1 m_nsText], [arg1 m_uiMessageType]);
    %orig;
}

- (void)deleteContact:(id)arg1{
    %orig;

    NSLog(@"MYHOOK MassSendMgr-deleteContact: %@",arg1);
}
// - (id)getToList:(id)arg1;
// - (id)getToListMD5:(id)arg1;
// - (id)getRealChatUsrByMD5:(id)arg1;
// - (void)initDB:(id)arg1 withLock:(id)arg2;
// - (void)deleteContact:(id)arg1;
- (void)addContact:(id)arg1 {
    NSLog(@"MYHOOK MassSendMgr-addContact: %@", arg1);
    %orig;
}

%end

%hook CAppViewControllerManager
- (void)enterForeground {
    %orig;
    //    MMTabBarController *tab = MSHookIvar<MMTabBarController *>(self, "m_tabbarController");
    //    tab.selectedIndex = 2;
    app = self;
    NSLog(@"HKWECHAT get app: %@", app);
}

%end

%hook AddressBookFriendViewController

- (void)onContactVerifyFail {
    NSLog(@"WECHAT verifyContact Failed!");
}

%end

%hook AutoSetRemarkMgr

- (void)AddVerifyUsr:(id)arg1 MobileIdentify:(id)arg2 {
    NSLog(@"HKWECHAT AddVerifyUsr: %@, %@", arg1, arg2);
    %orig;
}

- (id)GetStrangerAttribute:(id)arg1 AttributeName:(int)arg2 {
    id res = %orig;
    NSLog(@"HKWECHAT AddVerGetStrangerAttribute: %@, %d, res: %@", arg1, arg2, res);
    return res;
}

- (void)SetStrangerAttribute:(id)arg1 AttributeName:(int)arg2 Value:(id)arg3 {
    %orig;
    NSLog(@"HKWECHAT AddVerGetStrangerAttribute: %@, %d, %@", arg1, arg2, arg3);
}

%end


%hook ContactsViewController

- (void)didAppear {

    //判断是否是暴力添加附近人
    if(!isAddFriend || m_current_taskType != 37) {

        return;
    }

    NSLog(@"HKWECHAT ContactsViewController(暴力添加附近人)");
    isAddFriend = false;
    isBeginAddFriend = true;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    NSString *text = @"";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [lable setText:text];
    lable.textColor = [UIColor redColor];
    [window addSubview:lable];
    [window bringSubviewToFront:lable];
    
    /*NSString *textinit = @"gehongchao";
     [lable setText:@""];
     [lable setText:textinit];*/


    if ([nearbyCContactList count]) {
        dispatch_group_async(group, queue, ^{

            CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];
//            NSMutableArray *strangers = config[@"strangers"];
            NSLog(@"HKWX part1: =======================+>>> %lu",(unsigned long)[nearbyCContactList count]);

            for (int i = 0; i < [nearbyCContactList count]; i++) {

                CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
                wrap.m_nsUsrName = [nearbyCContactList[i] m_nsUsrName];

                [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
                [logic reset];

                NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[nearbyCContactList count]];

                NSLog(@"HKWX m_nsUsrName:%@",[nearbyCContactList[i] m_nsUsrName]);
                if (i%20 == 0 || (i == [nearbyCContactList count] - 1)) {
                    //进行延时，UI刷新
                    [NSThread sleepForTimeInterval:5];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        lable.text = text;
                        [lable setNeedsDisplay];
                    });
                }
            }

            NSLog(@"HKWECHAT 添加微信完毕");

            //写入配置文件，告诉脚本执行完毕
            write2File(@"/var/root/hkwx/wxResult.txt", @"1");

//            同步通讯录
            isSyncContact = true;

            [m_mMTabBarController setSelectedIndex:1];
        });
    }else{
        //写入配置文件，告诉脚本当前没有数据
        write2File(@"/var/root/hkwx/wxResult.txt", @"2");
    }

    //点击回到微信
    [m_mMTabBarController setSelectedIndex:0];
    
}


- (void)updateLabel:(NSString *)text{
    [lable setText:text];
    
}

%new
- (void)createDeleteFriendButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
    [addAndSendBtn setTitle:@"删除好友" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(deleteFriendList)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (void)deleteFriendList{

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_DEL_LIST];
    
    NSMutableArray *members = config[@"members"];
    if(config[@"members"]){
        for (int i = 0; i < [members count]; i++) {
            //listType:3 andScene:0 sync:1
            //        CContact *ccontact = [mgr getContactByName:@"wxid_x4asq8c7bov521"];
            CContact *ccontact = [mgr getContactByName:members[i]];

            NSLog(@"HKWeChat 删除好友的信息 ccontact:%@",ccontact);
            [mgr deleteContact:ccontact listType:3];
        }
    }

    //告诉脚本执行完毕
    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

//    [self createDeleteFriendButton];

    NSLog(@"HKWeChat ContactsViewController(进入通讯录)");
    if(m_current_taskType == 38){
        //点击群聊
//        MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

//        [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    }else if(m_current_taskType == 52){
        //删除好友
        NSLog(@"HKWeChat 当前是删除好友任务");
        [self deleteFriendList];

    }else if((isSyncContact && m_current_taskType == 37) || m_current_taskType == 45 || m_current_taskType == 54){

        if(m_current_taskType == 54){
            //5暴力加单向好友-进入通讯录                    执行结果(成功)
            uploadLog(geServerTypeTitle(5,@"进入通讯录"),@"进入成功");
        }else if(m_current_taskType == 45){

            //3同步通讯录-进入通讯录页面                    	执行结果(成功)
            uploadLog(geServerTypeTitle(3,@"进入通讯录页面"),@"进入成功");
        }
        

        //保存批次号
        NSDate *date=[NSDate date];
        NSDateFormatter *format1=[[NSDateFormatter alloc] init];
        [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr;
        dateStr=[format1 stringFromDate:date];
        NSLog(@"%@",dateStr);

        write2File(@"/var/root/hkwx/syncTime.txt",dateStr);


        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:10];

            dispatch_async(dispatch_get_main_queue(), ^{

                //同步通讯录信息
                NSString *dataJson = @"";
                NSString *oneJson = @"";
                int currentTotalCount = 0;

//                MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

                ContactsDataLogic *contactsDataLogic = MSHookIvar<ContactsDataLogic *>(self, "m_contactsDataLogic");

                NSArray *allContacts = [contactsDataLogic getAllContacts];
                NSLog(@"HKWeChat is allCount:%lu ",(unsigned long)[allContacts count]);

                if(m_current_taskType == 54){
                    uploadLog(geServerTypeTitle(6,@"获取通讯录好友列表"),[NSString stringWithFormat:@"当前好友的个数为:%lu",(unsigned long)[allContacts count]]);
                }else if(m_current_taskType == 45){
                    uploadLog(geServerTypeTitle(4,@"获取通讯录好友列表"),[NSString stringWithFormat:@"当前好友的个数为:%lu",(unsigned long)[allContacts count]]);
                }

                for(int i=0; i<[allContacts count];i++){

                    currentTotalCount = currentTotalCount + 1;

                    if(currentTotalCount%500 == 0){
                        //进行发送给服务端
                        dataJson = [NSString stringWithFormat:@"[%@]",dataJson];
                        
                        //                            NSLog(@"HKWeChat 当前传给服务器的内容:%@",dataJson);
                        
                        syncContactTask(dataJson,0);
                        
                        dataJson = @"";
                        dataJson = nil;
                    } //end if

                    NSLog(@"this is currentTotalCount:%d",currentTotalCount);

                    CContact *ccontact = allContacts[i];
                    if(ccontact == nil){
                        continue;
                    }

                    NSString *phoneNumber = @"";
                    
                    for (PhoneItemInfo* phoneItem in [ccontact m_arrPhoneItem]) {
                            phoneNumber = [NSString stringWithFormat:@"%@,%@",[phoneItem phoneNum],phoneNumber];
                    }
                    
                    
                    NSString *nickname = conversionSpecialCharacter([ccontact m_nsNickName]);
                    NSString *nsRemark = conversionSpecialCharacter([ccontact m_nsRemark]);
                    NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                    NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                    NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);
                    
                    oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\",\"nsRemark\":\"%@\",\"nsEncodeUserName\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,phoneNumber,nsCountry,nsProvince,nsCity,[ccontact m_uiSex],nsRemark,[ccontact m_nsEncodeUserName]];
                    
                                                //                        NSLog(@"HKWX %@",oneJson);
                    
                    if([dataJson isEqualToString:@""] || dataJson == nil){
                          dataJson = [NSString stringWithFormat:@"%@",oneJson];
                        }else{
                            dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                    }

                } //end for

                dataJson = [NSString stringWithFormat:@"[%@]",dataJson];
                if(m_current_taskType == 54){
                    uploadLog(geServerTypeTitle(7,@"执行上传通讯录结果"),@"开始上传 执行这个函数syncContactTask");
                }else if(m_current_taskType == 45){
                    uploadLog(geServerTypeTitle(4,@"执行上传通讯录结果"),@"开始上传 执行这个函数syncContactTask");
                }


                syncContactTask(dataJson,1);

            });
        });
    }

}


%end // end hook

//个人详情页面
%hook ContactInfoViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"%@",[[self m_contact] m_nsUsrName]);

    //创建UILabel
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,60,200,30)];
    //设置背景色
    label1.backgroundColor = [UIColor redColor];
    //设置tag
    //设置标签文本
    label1.text = [[self m_contact] m_nsUsrName];
    //设置标签文本字体和字体大小
    [self.view addSubview:label1];

    write2File(@"/var/root/hkwx/userNameWxid.txt", [[self m_contact] m_nsUsrName]);

}

- (void)viewDidDisappear:(_Bool)arg1{
    %orig;

}

%end

//通讯录群聊
%hook ChatRoomListViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"HKWeChat 进入通讯录群聊页面");
    if(m_current_taskType != 38){

        return;
    }


//    dispatch_group_async(group, queue, ^{
//
//        [NSThread sleepForTimeInterval:5];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // {m_nsUsrName=7399393395@chatroom, m_nsEncodeUserName=, alias=, m_nsNickName=, m_uiType=3, m_uiConType=0, m_nsRemark=,  m_nsCountry= m_nsProvince= m_nsCity= m_nsSignature= 	 m_uiSex=0 m_uiCerFlag=0 m_nsCer=(null) scene=0 }
//            
//            NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_TASK_LIST];
//
//            //进入群聊
//            CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
//            contact.m_nsUsrName = config[@"chatroom"]; //@"7399393395@chatroom";
//
//            //点击进入群聊
//            [self JumpToChatRoom:contact];
//        });
//        
//    });
}

- (void)JumpToChatRoom:(id)arg1{
    %orig;
    NSLog(@"HKWeChat ChatRoomListViewController %@",arg1);
}

%end



%hook BaseMsgContentViewController

%new
- (void)addGroupMembers {
    // AddressBookFriendViewController *abfvcf = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];
    CGroupMgr *ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_TASK_LIST];

    NSLog(@"HKWX sendadd config: %@", config);

    if (config[@"enable"] && config[@"members"]) {

        NSLog(@"HKWX begin 开始啦群了");

        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        NSString *chatroom = config[@"chatroom"];
        NSMutableArray *members = config[@"members"];
        for (int i = 0; i < [members count]; i++) {
            GroupMember *member = [[NSClassFromString(@"GroupMember") alloc] init];
            member.m_nsMemberName = members[i];
            [memberList addObject:member];
            NSLog(@"HKWX send add friend to %@;", members[i]);
        }

        [ccMgr AddGroupMember:chatroom withMemberList:memberList];

        //告诉脚本执行完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    }
}

%new
- (void)createMyButton {
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 25, 80, 30)];
    [addAndSendBtn setTitle:@"添加群好友" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(addGroupMembers)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

- (void)viewDidLoad{
    %orig;

    NSLog(@"进入群聊，聊天页面");

//    [self createMyButton];
}

- (id)init {
    baseMsgContentVC = %orig;
    return baseMsgContentVC;
}

%new
- (id)someValue {
    return objc_getAssociatedObject(self, @selector(someValue));
}

%new
- (void)setSomeValue:(id)value {
    objc_setAssociatedObject(self, @selector(someValue), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2
{
    UITableViewCell *cell = %orig(arg1,arg2);
    NSIndexPath *indexpath = arg2;
    NSString *value = [self performSelector:@selector(someValue)];
    if(indexpath.row + 1 == [value integerValue])
    {
        for (id subView in cell.contentView.subviews)
        {
            if([NSStringFromClass([subView class]) isEqualToString:@"WCPayC2CMessageNodeView"])
            {
                [subView performSelector:@selector(onClick)];
            }
        }
    }
    return cell;
}

- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2
{
    long long result = %orig(arg1,arg2);
    [self performSelector:@selector(setSomeValue:) withObject:[NSString stringWithFormat:@"%lld",result]];
    return result;
}

%end

//进入群聊信息页面
%hook RoomContentLogicController
- (id)init{
    id ret = %orig;

    if(m_current_taskType == 38){

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"HKWeChat 点击进入聊天信息页面");

                [self OpenDetailInfo];
            });
            
        });
    }else if(m_current_taskType == 68){
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"HKWeChat 点击进入聊天信息页面");

                uploadLog(geServerTypeTitle(2,@"进入聊天信息页面"),@"开始点击进入");

                [self OpenDetailInfo];
            });
            
        });
    }

    return ret;
}

%end


//群公告
%hook ChatRoomInfoEditDescViewController
- (void)viewDidLoad{
    %orig;

    if(m_current_taskType == 68){

        uploadLog(geServerTypeTitle(2,@"进入群公告页面"),@"进入成功");

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:3];


            dispatch_async(dispatch_get_main_queue(), ^{

                uploadLog(geServerTypeTitle(4,@"点击编辑(OnEdit)"),@"点击成功");
                [self OnEdit];

                [NSThread sleepForTimeInterval:3];


                uploadLog(geServerTypeTitle(5,@"设置公告(updateText)"),[NSString stringWithFormat:@"设置公告 内容为：%@",[m_taskDataDic objectForKey:@"adChatRoomText"]]);

                [self updateText:[m_taskDataDic objectForKey:@"adChatRoomText"]];

                [NSThread sleepForTimeInterval:3];

                uploadLog(geServerTypeTitle(6,@"点击完成(OnDone)"),@"点击完成");
                [self OnDone];

                //告诉脚本点击发布按钮
                uploadLog(geServerTypeTitle(7,@"告知脚本点击发布按钮"),@"点击完成 operation 设置5");
                write2File(@"/var/root/hkwx/operation.txt",@"5");

            });


        });
    }

}

- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2{
    %orig;

    NSLog(@"alertView:(id)arg1:%@ clickedButtonAtIndex:(long long)arg2 :%@",arg1,arg2);
}
%end


//获取微信聊天的群ID
%hook ChatRoomInfoViewController

%new
- (void)sysChatRoomAction{
    NSLog(@"HKWeChat(开始同步群成员信息) %@",[[self m_chatRoomContact] m_nsUsrName]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray *arrMemberList =  MSHookIvar<NSArray *>(self, "m_arrMemberList");
            NSString *oneJson = @"";
            NSString *dataJson = @"";

            for(CContact *ccontact in arrMemberList){

                NSString *nsUsrName = conversionSpecialCharacter([ccontact m_nsUsrName]);
                NSString *nickName = conversionSpecialCharacter([ccontact m_nsNickName]);
                NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

                oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%ld\"}",nsUsrName,[ccontact m_nsAliasName],nickName,@"",nsCountry,nsProvince,nsCity,[ccontact m_uiSex]];

                //                        NSLog(@"HKWX %@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }
            }

            NSLog(@"%@",dataJson);

            //同步群聊成员
            syncChatroomMember([[self m_chatRoomContact] m_nsUsrName],dataJson);

        });

    });
}

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

    //创建同步按钮
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(220, 60, 350, 30);
//    [btn setTitle:@"同步群聊" forState:UIControlStateNormal];
//    [btn setTitle:@"同步群聊" forState:UIControlStateHighlighted];
//    [btn setBackgroundColor:[UIColor blueColor]];
//    [btn addTarget:self action:@selector(sysChatRoomAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];

//    //得到群里有多少人
    dispatch_group_async(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [NSThread sleepForTimeInterval:1];

            NSArray *arrMemberList =  MSHookIvar<NSArray *>(self, "m_arrMemberList");

            NSString *roomData = [NSString stringWithFormat:@"chatRoom=%@&allCount=%lu",[[self m_chatRoomContact] m_nsUsrName],(unsigned long)[arrMemberList count]];
            
            NSLog(@"this chatRoom:%@ is total memeber:%lu",[[self m_chatRoomContact] m_nsUsrName],(unsigned long)[arrMemberList count]);


            //发送给服务端
            uploadChatRoomPersonCount(roomData);

            NSString *chatCount = [NSString stringWithFormat:@"%lu",(unsigned long)[arrMemberList count]];

            write2File(@"/var/root/hkwx/chatCount.txt", chatCount);

            if(m_current_taskType == 38){

                //同步群聊信息
                [self sysChatRoomAction];

            }else if(m_current_taskType == 68){
                //点击群公告
                [self showAdminViewDesc];
            }

        });
        
    });
    

    NSLog(@"%@",[[self m_chatRoomContact] m_nsUsrName]);
    
}

- (void)onQuit:(id)arg1{
    %orig;
    //1844514971@chatroom
    NSLog(@"HKWeChat (ChatRoomInfoViewController)onQuit %@",arg1);
}

- (_Bool)quitChatRoom{
    BOOL ret = %orig;
    NSLog(@"HKWeChat (ChatRoomInfoViewController)quitChatRoom");
    return ret;
}


- (void)onDeleteContact:(id)arg1{
    %orig;

    NSLog(@"HKWeChat (ChatRoomInfoViewController) onDeleteContact %@",arg1);
}
- (void)actionSheet:(id)arg1 clickedButtonAtIndex:(long long)arg2{
    %orig;
    NSLog(@"HKWeChat (ChatRoomInfoViewController) actionSheet %@",arg1);
}

- (void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2{
    %orig;

    NSLog(@"HKWeChat (ChatRoomInfoViewController) alertView%@",arg1);
}


%end



%hook FindFriendEntryViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"HKWeChat FindFriendEntryViewController(发现开始页面) %d ",m_current_taskType);

    uploadLog(geServerTypeTitle(2,@"进入发现页面"),@"进入成功");

    if(m_current_taskType == 37){
        NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/location.plist"];

        //    NSMutableDictionary *preferences = strngToDictionary([m_taskDataDic objectForKey:@"locationPlist"]);

        BOOL enable = [[preferences objectForKey:@"enable"] boolValue];
        if(!enable){
            //数据请求错误
            NSLog(@"HKWECHAT this is request error(数据经纬度错误)");
            return;
        }

        dispatch_group_async(group, queue, ^{
            if(isAddFriend){
                [NSThread sleepForTimeInterval:10];
            }else{
                [NSThread sleepForTimeInterval:5];
            }


            dispatch_async(dispatch_get_main_queue(), ^{
                if(isAddFriend){
                    //得到LBS的数据了
                    //点击通讯录
                    [m_mMTabBarController setSelectedIndex:1];

                }else{
                    //点击进入附件人
                    [self openLBS];
                }
                
            });
            
        });
    }else if(m_current_taskType == 4){
        NSLog(@"HKWeChat 点击进入朋友圈页面 m_step_friends");

        uploadLog(geServerTypeTitle(2,@"点击朋友圈"),@"开始点击");
        //点击朋友圈
        [self openAlbum];

    }else if(m_current_taskType == 66){
        //进入漂流瓶
        uploadLog(geServerTypeTitle(3,@"点击漂流瓶"),@"开始点击");

        [self goToSandyBeach];

    }


}

%end // end hook


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

    NSLog(@"HKWECHAT  will show verify alert, but I ignored");
}

- (void)handleVerifyOk:(id)arg1{

    NSLog(@"HKWECHAT  handleVerifyOk:%@",arg1);
    
}


%end // end hook

static dispatch_group_t groupPop1 = dispatch_group_create();
static dispatch_queue_t queuePop1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


%hook SeePeopleNearbyViewController
- (void)viewDidLoad{
    %orig;

    if(m_current_taskType != 37){
        return;
    }

    NSLog(@"HKWECHAT 进入附近人 ");

    //写入文件通知脚本当前是执行暴力加人
    write2File(@"/var/root/hkwx/isAddLocationFriend.txt", @"1");

    dispatch_group_async(group, queue, ^{

        while(!isAddFriend){
            NSLog(@"HKWeChat 附近人 等待加载完毕 数据的返回");

            [NSThread sleepForTimeInterval:5];
        }

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_mMUINavigationController){
                [m_mMUINavigationController popViewControllerAnimated:YES];

                NSLog(@"HKWeChat 当前附近人 返回 isHasNearButton:%d isAddFriend:%d",isHasNearButton,isAddFriend);

                //如果是有附近人打招呼返回两次
                if(isHasNearButton){
//                    [NSThread sleepForTimeInterval:5];
                    [m_mMUINavigationController popViewControllerAnimated:YES];
                }

            }
        });
        
    });

    //启动异步弹出选择男女框
    dispatch_group_async(groupPop, queuePop, ^{

        NSLog(@" HKWeChat 启动异步弹出选择男女框");

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            m_current_select_sex = 0;

            NSLog(@"HKWeChat 当前下拉选择 只看女生");

            [self showOperationMenu:@"1"];
        });
        
    });

    //启动异步弹出选择男女框
    dispatch_group_async(groupPop1, queuePop1, ^{

        NSLog(@" HKWeChat 启动异步弹出选择男女框");
        while(true){
            [NSThread sleepForTimeInterval:10];

            if(m_current_select_sex == 1){
                break;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            m_current_select_sex = 1;

            NSLog(@"HKWeChat 当前下拉选择 只看男生");

            [self showOperationMenu:@"1"];
        });
        
    });

}

- (void)stopLoading {
    %orig;

    NSLog(@"HKWECHAT 停止加载LBS 的数据");

    if(m_current_taskType != 37 || m_current_select_sex == -1){

        NSLog(@"HKWECHAT 停止加载LBS 的数据返回 %d",m_current_taskType);

        return;
    }

    //    NSLog(@"HKWECHAT retrieveLocationOK: %@", [[self logicController] m_lbsContactList]);
    NSLog(@"HKWECHAT now in lbs");
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/location.plist"];

//    NSMutableDictionary *preferences = strngToDictionary([m_taskDataDic objectForKey:@"locationPlist"]);

    BOOL enable = [[preferences objectForKey:@"enable"] boolValue];
    if(!enable){
        //数据请求错误
        NSLog(@"HKWECHAT this is request error(数据经纬度错误)");
        return;
    }

    if(m_current_select_sex == 0){

        [[[[self logicController] m_lbsContactList] lbsContactList] enumerateObjectsUsingBlock:^(MMLbsContactInfo *info, NSUInteger idx, BOOL *stop) {
            if (![info isInMyContactList]) {
                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                contact.m_nsUsrName = info.userName;
                contact.m_nsNickName = info.nickName;
                contact.m_nsAliasName = info.m_nsAlias;
                contact.m_nsSignature = info.signature;
                contact.m_uiSex = info.sex;
                contact.m_nsCertificationInfo = info.CertificationInfo;
                contact.m_uiCertificationFlag = info.CertificationFlag;
                contact.m_nsCity = info.city;
                contact.m_nsProvince = info.province;
                contact.m_nsCountry = info.country;
                [nearbyCContactFemaleList addObject:contact];
                int selectSex = [[m_taskDataDic objectForKey:@"selectSex"] intValue];
                if(selectSex == 0){
                    [nearbyCContactList addObject:contact];
                }
            }
        }];

        NSString *dataJson = @"";

        for(CContact *contact in nearbyCContactFemaleList){

            NSString *nickName = conversionSpecialCharacter([contact m_nsNickName]);
            NSString *nsCountry = conversionSpecialCharacter([contact m_nsCountry]);
            NSString *nsProvince = conversionSpecialCharacter([contact m_nsProvince]);
            NSString *nsCity = conversionSpecialCharacter([contact m_nsCity]);
            
            NSString *oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\"}",[contact m_nsUsrName],[contact m_nsAliasName],nickName,nsCountry,nsProvince,nsCity,[contact m_uiSex]];
            
            NSLog(@"%@",oneJson);

            if([dataJson isEqualToString:@""]){
                dataJson = [NSString stringWithFormat:@"%@",oneJson];
            }else{
                dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
            }
        }


        m_current_select_sex = 1;
        NSLog(@"HKWECHAT 当前得到了 附近人女生的数据 %@",dataJson);

        //发送给服务端
        syncNearbyCContactTask(dataJson,0);

    }else if(m_current_select_sex == 1){
        [[[[self logicController] m_lbsContactList] lbsContactList] enumerateObjectsUsingBlock:^(MMLbsContactInfo *info, NSUInteger idx, BOOL *stop) {
            if (![info isInMyContactList]) {
                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                contact.m_nsUsrName = info.userName;
                contact.m_nsNickName = info.nickName;
                contact.m_nsAliasName = info.m_nsAlias;
                contact.m_nsSignature = info.signature;
                contact.m_uiSex = info.sex;
                contact.m_nsCertificationInfo = info.CertificationInfo;
                contact.m_uiCertificationFlag = info.CertificationFlag;
                contact.m_nsCity = info.city;
                contact.m_nsProvince = info.province;
                contact.m_nsCountry = info.country;
                [nearbyCContactMaleList addObject:contact];

                int selectSex = [[m_taskDataDic objectForKey:@"selectSex"] intValue];
                if(selectSex == 1){
                    [nearbyCContactList addObject:contact];
                }
            }
        }];

        NSString *dataJson = @"";

        for(CContact *contact in nearbyCContactMaleList){

            NSString *nickName = conversionSpecialCharacter([contact m_nsNickName]);
            NSString *nsCountry = conversionSpecialCharacter([contact m_nsCountry]);
            NSString *nsProvince = conversionSpecialCharacter([contact m_nsProvince]);
            NSString *nsCity = conversionSpecialCharacter([contact m_nsCity]);

            NSString *oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\"}",[contact m_nsUsrName],[contact m_nsAliasName],nickName,nsCountry,nsProvince,nsCity,[contact m_uiSex]];

            NSLog(@"%@",oneJson);

            if([dataJson isEqualToString:@""]){
                dataJson = [NSString stringWithFormat:@"%@",oneJson];
            }else{
                dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
            }
        }

        NSLog(@"HKWECHAT 当前得到了 附近人男生的数据 %@",dataJson);

        m_current_select_sex = -1;

        //发送给服务端
        syncNearbyCContactTask(dataJson,1);

        isAddFriend = true;

    }


//    isAddFriend = true;
    //    MMTabBarController *tab = MSHookIvar<MMTabBarController *>(app, "m_tabbarController");
    //    tab.selectedIndex = 1;
    
    
}
- (void)showOperationMenu:(id)arg1{ //打开男女 :@"1"
    %orig;

    NSLog(@"HKWECHAT this is request showOperationMenu arg1:%@",arg1);
}
%end


%hook MMLocationMgr

- (void)locationManager:(id)arg1 didUpdateToLocation:(id)arg2 fromLocation:(id)arg3 {
    NSLog(@"MMLocationMgr - locationManager : %@, %@, %@", arg1, arg2, arg3);

    if(m_current_taskType == 37){
        NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/location.plist"];

//        NSMutableDictionary *preferences = strngToDictionary([m_taskDataDic objectForKey:@"locationPlist"]);

        BOOL enable = [[preferences objectForKey:@"enable"] boolValue];
        double longNum = [[preferences objectForKey:@"x"] doubleValue];
        double latNum = [[preferences objectForKey:@"y"] doubleValue];
        if (enable && longNum != 0 && latNum != 0) {
            arg2 = [[CLLocation alloc] initWithLatitude:latNum longitude:longNum];
        }
    }

    %orig;
}

%end



//添加附近人
%hook EnterLbsViewController
- (void)initView{
    %orig;

    NSLog(@"HKWECHAT initView 当前有查看附近人按钮---");

    if(m_current_taskType != 37){
        return;
    }

    if(isHasNearButton){
        //进行返回
        NSLog(@"HKWECHAT 要返回");
        [m_mMUINavigationController popViewControllerAnimated:YES];
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{
            isHasNearButton = true;
            [self OnOpenLbs];
        });
        
    });

}

- (void)viewDidLoad{
    %orig;

    NSLog(@"HKWECHAT viewDidLoad (EnterLbsViewController)");
}
- (void)UpdateView{
    %orig;

    NSLog(@"HKWECHAT UpdateView (EnterLbsViewController)");

}

- (void)initData{
    %orig;
    NSLog(@"HKWECHAT initData (EnterLbsViewController)");
}
%end

//异步选择性别
static dispatch_group_t groupSex = dispatch_group_create();
static dispatch_queue_t queueSex = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


//选择男女弹出框
%hook  WCActionSheet

- (void)dismissWithClickedButtonIndex:(long long)arg1 animated:(_Bool)arg2{
    %orig;

    NSLog(@"HKWECHAT dismissWithClickedButtonIndex :%lld animated:%d",arg1,arg2);
}


- (void)setFrame:(struct CGRect)arg1{
    %orig;

    NSLog(@"HKWECHAT setFrame==========");
    //设置当前选择为只看男
    dispatch_group_async(groupSex, queueSex, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(m_current_taskType == 37){
//                int selectSex = [[m_taskDataDic objectForKey:@"selectSex"] intValue];

                [self dismissWithClickedButtonIndex:m_current_select_sex animated:YES];

//                isSelectSex = true;

            }else if(m_current_taskType == 38){

                [self dismissWithClickedButtonIndex:0 animated:YES];
            }

        });

    });
}

%end


%hook MultiSelectContactsViewController

- (void)viewDidLoad {
    %orig;
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/wxgroup.plist"];
    NSLog(@"HKWX sendadd config: %@", config);
    BOOL isExist = false;

    if (config[@"enable"] && config[@"members"]) {
        ContactSelectView *view = MSHookIvar<ContactSelectView *>(self, "m_selectView");
        MMTableView *tbView = MSHookIvar<MMTableView *>(view, "m_tableView");
        int sections = (int)[view numberOfSectionsInTableView:tbView];
        for (int i = 0; i < sections; i++) {
            int rows = [view tableView:tbView numberOfRowsInSection:i];
            for (int j = 0; j < rows; j++) {
                NSIndexPath *position = [NSIndexPath indexPathForRow:j inSection:i];
                id cell = [view tableView:tbView cellForRowAtIndexPath:position];
                //判断是否是ContactsItemCell
                if([NSStringFromClass([cell class]) isEqualToString:@"ContactsItemCell"]){
                    if ([config[@"members"] containsObject:[[[[cell subviews][0] subviews][2] m_contact] m_nsUsrName]]) {

                        isExist = true;
                        [view tableView:tbView didSelectRowAtIndexPath:position];
                    }
                }
            }
        }
    }

    //告诉脚本点击确认按钮
    if(isExist){
        NSLog(@"HKWX 脚本点击确认按钮----");
        write2File(@"/var/root/hkwx/operation.txt", @"3");
    
    }else{
        NSLog(@"HKWX 服务器传过来没有相应的数据");
        write2File(@"/var/root/hkwx/operation.txt", @"4");
    }
}
%end

NSInteger click_add_number = 0;

//点击聊天信息 “＋”号按钮
%hook  NewChatRoomMemberContainView
- (void)layoutSubviews{
    %orig;

    NSLog(@"HKWX 点击聊天信息");


}

- (id)initWithFrame:(struct CGRect)arg1 column:(unsigned long long)arg2{
    id ret = %orig;
    if(m_current_taskType == 38){
        if(click_add_number == 0){
            click_add_number = click_add_number + 1;
            dispatch_group_async(groupSex, queueSex, ^{

                [NSThread sleepForTimeInterval:15];

                dispatch_async(dispatch_get_main_queue(), ^{

                    NSLog(@"HKWX 点击聊天信息 加号按钮");

                    [self onAddMember:@"1"];

                });
        
            });
        }
    }
    return ret;
}

- (void)onAddMember:(id)arg1{
    %orig;

    NSLog(@"HKWX onAddMember:%@",arg1);
}

%end


%hook CGroupMgr

- (void)addChatMemberNeedVerifyMsg:(id)arg1 ContactList:(id)arg2{
    %orig;
    NSLog(@"CGroupMgr addChatMemberNeedVerifyMsg arg1:%@  arg2:%@",arg1,arg2);
    
}

- (void)OnAddChatRoomMember:(id)arg1{
    %orig;

    NSLog(@"CGroupMgr OnAddChatRoomMember arg1:%@",arg1);
}

- (_Bool)AddGroupMember:(id)arg1 withMemberList:(id)arg2{
    BOOL ret = %orig;

    NSLog(@"CGroupMgr AddGroupMember arg1:%@ withMemberList:%@ ",arg1,arg2);
    return ret;
}

- (_Bool)QuitGroup:(id)arg1 withUsrName:(id)arg2{
    BOOL ret = %orig;
    NSLog(@"CGroupMgr QuitGroup arg1:%@ withUsrName:%@ ",arg1,arg2);
    return ret;
}

- (_Bool)DeleteGroupMember:(id)arg1 withMemberList:(id)arg2 scene:(unsigned long long)arg3{
    BOOL ret = %orig;
    NSLog(@"CGroupMgr DeleteGroupMember arg1:%@ withMemberList:%@ ",arg1,arg2);
    return ret;
}

%end


//删除好友
%hook  ContactSettingViewController
- (void)opDelete:(id)arg1{
    %orig;

    NSLog(@"MYHOOK (删除好友) arg1:%@",arg1);
}
%end


//账号异常检查
%hook  AccountErrorInfo
- (void)parseErrMsgXml:(id)arg1{
    %orig;

    NSLog(@"hkweixin  AccountErrorInfo parseErrMsgXml arg1:%@",arg1);
}

- (id)init{
    id ret = %orig;
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"hkweixin is errorMsg:%@",[[self errMsg] content]);

//            write2File(@"/var/root/hkwx/errorMsg.txt",[[self errMsg] content]);
        });

    });

    return ret;
}
%end

%hook  WXPBGeneratedMessage
- (id)init{
    id ret = %orig;

    if([ret isKindOfClass:NSClassFromString(@"BaseResponseErrMsg")]){

        BaseResponseErrMsg *errorMsg = ret;

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"WXPBGeneratedMessage this is %@",[errorMsg content]);

                write2File(@"/var/root/hkwx/errorMsg.txt",[errorMsg content]);
            });
            
        });


    }

    return ret;
}

%end

// 跑微信文章阅读量

extern "C" size_t CurlWrite_CallbackFunc_StdString(void *contents, size_t size, size_t nmemb, std::string *s)
{
    size_t newLength = size*nmemb;
    size_t oldLength = s->size();
    try
    {
        s->resize(oldLength + newLength);
    }
    catch(std::bad_alloc &e)
    {
        //handle memory problem
        return 0;
    }

    std::copy((char*)contents,(char*)contents+newLength,s->begin()+oldLength);
    return size*nmemb;
}

extern "C" BOOL fetchMpDocWithCurl(NSString *url) {
    CURL *web = curl_easy_init();
    CURLcode result;
    std::string s;
    BOOL flag = NO;
    if (web) {
        curl_easy_setopt(web, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(web, CURLOPT_USERAGENT, "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Mobile/14A403 MicroMessenger/6.3.30 NetType/WIFI Language/zh_CN");
        curl_easy_setopt(web, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(web, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(web, CURLOPT_POSTFIELDS, "is_only_read=1");
        curl_easy_setopt(web, CURLOPT_WRITEFUNCTION, CurlWrite_CallbackFunc_StdString);
        curl_easy_setopt(web, CURLOPT_WRITEDATA, &s);

        result = curl_easy_perform(web);
        if(result != CURLE_OK){
            NSLog(@"MYHOOK-curl Cannot grab the url: %@!", url);
            flag = NO;
        }
    }

    curl_easy_cleanup(web);
    flag = YES;
    // [NSString stringWithUTF8String:s.c_str()]；
    NSLog(@"MYHOOK get html:%@, =====> %@ : m_current_readCount:%d result : %@", flag ? @"YES":@"NO", url, m_current_readCount,[NSString stringWithUTF8String:s.c_str()]);

    return flag;
}

%hook MMWebViewController

- (void)saveJSAPIPermissions:(id)arg1 url:(id)arg2 {
    %orig;

//    NSLog(@"this is add read saveJSAPIPermissions: arg1:%@ url(arg2):%@",arg1,arg2);

//    dispatch_async(myMpDocQueue, ^{
//       阅读量
//        NSString *readCountUrl = [arg2 stringByReplacingOccurrencesOfString:@"https://mp.weixin.qq.com/s" withString:@"https://mp.weixin.qq.com/mp/getappmsgext"];
//点赞
//        NSString *readCountUrl = [arg2 stringByReplacingOccurrencesOfString:@"https://mp.weixin.qq.com/s" withString:@"https://mp.weixin.qq.com/mp/appmsg_like"];
//        fetchMpDocWithCurl(readCountUrl);
//    });
}

//- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3 referer:(id)arg4{
//    id ret = %orig;
//    NSLog(@"initWithURL %@",arg1 arg2,arg3);
//    return ret;
//}
//- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3 delegate:(id)arg4{
//    id ret = %orig;
//
//    return ret;
//}
- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3{
    id ret = %orig;
    NSLog(@"initWithURL %@ presentModal:%d extraInfo:%@",arg1 ,arg2,arg3);
    return ret;
}

%end


//劫持音频 图片 视频等 开始

%hook CMessageMgr

- (void)AddLocalMsg:(id)arg1 MsgWrap:(id)arg2 {
    NSLog(@"MYHOOK - CMessageMgr - AddLocalMsg: %@ , %@", arg1, arg2);
    %orig;
}

- (_Bool)StartDownloadThumb:(id)arg1  {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadThumb： %@", arg1);
    return YES;
}

- (void)StartDownloadImage:(id)arg1 HD:(_Bool)arg2 AutoDownload:(_Bool)arg3 {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadImage %@", arg1);
}

- (void)StartDownloadVideo:(id)arg1 MsgWrap:(id)arg2 {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadVideo %@, %@", arg1, arg2);
}

- (void)StartDownloadShortVideo:(id)arg1 {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadShortVideo %@", arg1);
}

- (void)StartDownloadByRecordMsg:(id)arg1 {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadByRecordMsg %@", arg1);
}

- (_Bool)StartDownloadEmoticonMsgWrap:(id)arg1 HighPriority:(_Bool)arg2 {
    NSLog(@"MYHOOK - CMessageMgr - StartDownloadEmoticonMsgWrap %@", arg1);
    return YES;
}

- (_Bool)InternalStartDownloadShortVideo:(id)arg1 AutoDownload:(_Bool)arg2 {
    NSLog(@"MYHOOK - CMessageMgr - InternalStartDownloadShortVideo %@", arg1);
    return YES;
}

- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2 {
    %orig;
    NSLog(@"MYHOOK - CMessageMgr - AddMsg:1: %@, 2: %@", arg1, arg2);

}

- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3{
    %orig;
    NSString *msgDBItem = [NSString stringWithFormat:@"%@",arg2];
//    NSLog(@"MYHOOK - MessageReturn %@ m_current_taskType:%ld",msgDBItem,(long)m_current_taskType);

    if([msgDBItem rangeOfString:@"_25"].location != NSNotFound && m_current_taskType == 44){

        NSArray *listItem = [msgDBItem componentsSeparatedByString:@";"];

        NSLog(@" msgDBItem is:%@,listItem:%@",msgDBItem,listItem);

        //保存到文件中
        write2File(@"/var/root/hkwx/sendMsgFail.plist", msgDBItem);

        NSMutableDictionary *sendMsgFail = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/sendMsgFail.plist"];

        //得到所有的数组
        NSString *dataJson = @"";

        NSMutableDictionary *listArray = sendMsgFail[@"_25"];
        NSLog(@"sendMsgFail listArray :%@",listArray);
        NSEnumerator *enumerator = [listArray keyEnumerator];
        id key = [enumerator nextObject];
        while (key) {
            id obj = [listArray objectForKey:key];

            NSLog(@"this is send fail key:%@ value:%@",key, obj);

            if([dataJson isEqualToString:@""] || dataJson == nil){
                dataJson = [NSString stringWithFormat:@"%@",key];
            }else{
                dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,key];
            }

            key = [enumerator nextObject];
        }//end while

        //告诉服务端发送失败的账号
        NSLog(@"告诉服务端发送失败的账号为:%@",dataJson);

        uploadSendFailWeixinId(dataJson);

    }//end if
}

%end

%hook AudioReceiver

- (void)downloadVoiceMessage:(id)arg1{
    NSLog(@"MYHOOK AudioReceiver-downloadVoiceMessage:%@", arg1);
}

- (_Bool)StartPlayWithAutoMode:(id)arg1 MesLocalID:(unsigned int)arg2 {
    NSLog(@"MYHOOK AudioReceiver-StartPlayWithAutoMode:%@", arg1);
    return YES;
}
- (_Bool)StartPlayWithEarpieceMode:(id)arg1 MesLocalID:(unsigned int)arg2 {
    NSLog(@"MYHOOK AudioReceiver-StartPlayWithEarpieceMode:%@", arg1);
    return YES;
}
- (_Bool)StartPlay:(id)arg1 MesLocalID:(unsigned int)arg2 Path:(id)arg3 {
    NSLog(@"MYHOOK AudioReceiver-StartPlay:%@", arg1);
    return YES;
}
- (_Bool)StartPlay:(id)arg1 MesLocalID:(unsigned int)arg2 {
    NSLog(@"MYHOOK AudioReceiver-StartPlay:%@", arg1);
    return YES;
}
- (_Bool)StartPlay:(id)arg1 MesLocalID:(unsigned int)arg2 Path:(id)arg3 forceEarpieceMode:(_Bool)arg4 forceAutoMode:(_Bool)arg5 {
    NSLog(@"MYHOOK AudioReceiver-StartPlay:%@", arg1);
    return YES;
}

- (void)AddNewDownload:(id)arg1 LocalID:(unsigned int)arg2 n64SvrID:(long long)arg3 VoiceLen:(unsigned int)arg4 VoiceTime:(unsigned int)arg5 CreateTime:(unsigned int)arg6 EndFlag:(unsigned int)arg7 {
    NSLog(@"MYHOOK AudioReceiver-AddNewDownload:%@", arg1);

}

%end

%hook ImageAutoDownloadMgr

- (void)OnAddMsg:(id)arg1 MsgWrap:(id)arg2 {
    NSLog(@"MYHOOK ImageAutoDownloadMgr OnAddMsg %@, %@", arg1, arg2);
    int msgType = (int)[arg2 m_uiMessageType];
    switch (msgType) {
        case 3:
//            arg1.m_ns
            break;
        case 43:
            break;
    }
    [self ClearChatQueue];
    [self StopBackGroundQueue];
}

- (void)StartAutoDownloadFromChat:(id)arg1 {
    NSLog(@"MYHOOK ImageAutoDownloadMgr StartAutoDownloadFromChat %@", arg1);

    [self ClearChatQueue];
    [self StopBackGroundQueue];
}
- (void)InternalAddMsgToQueue:(id)arg1 Msg:(id)arg2 {
    NSLog(@"MYHOOK ImageAutoDownloadMgr internal add msg to download: %@, %@", arg1, arg2);
    [self ClearChatQueue];
    [self StopBackGroundQueue];
}
- (_Bool)StartDownloadMsgFromQueue:(id)arg1 {
    [self ClearChatQueue];
    [self StopBackGroundQueue];
    return NO;
}
- (_Bool)IsImageShouldDownload:(id)arg1 {
    [self ClearChatQueue];
    [self StopBackGroundQueue];
    return NO;
}
- (_Bool)IsMsgCanDownload:(id)arg1 CheckNotify:(_Bool)arg2 {
    [self ClearChatQueue];
    [self StopBackGroundQueue];
    return NO;
}
- (_Bool)IsMsgDownloaded:(id)arg1 {
    [self ClearChatQueue];
    [self StopBackGroundQueue];
    return YES;
}

%end

//end 劫持音频 图片 视频等 end

%hook YYUIWebView
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"YYUIWebView document.location.href -------------%@ m_updateLink:(%d)",currentURl,m_updateLink);



    //判断是否有上传uin和key
    if(m_fetchUinAndKeyUrl != nil && ![m_fetchUinAndKeyUrl isEqualToString:@""]){
        //得到
        NSArray *listUrl = [m_fetchUinAndKeyUrl componentsSeparatedByString:@"?"];
        NSLog(@"this is listUrl[0] %@",listUrl[0]);

        if([currentURl rangeOfString:listUrl[0]].location != NSNotFound){

            uploadLog(geServerTypeTitle(3,@"从YYUIWebView类得到key的链接上传"),[NSString stringWithFormat:@"微信uuid:%@",[m_nCSetting m_nsUsrName]]);

            NSLog(@"this upload back server url##########----------");

            saveMyAccountUinAndKey(currentURl,[m_nCSetting m_nsUsrName]);
        }
    }

    if([currentURl rangeOfString:@"mp/profile_ext?action=home"].location != NSNotFound){


        NSLog(@"this is 当前关注公众号");

//        NSString *jsContact = @"document.getElementByTagName(\"body\").outerHTML";

//        NSLog(@"%@",[self stringByEvaluatingJavaScriptFromString:jsContact]);
        NSString *jsContact = @"document.getElementById(\"js_btn_add_contact\").click();";

        [self stringByEvaluatingJavaScriptFromString:jsContact];
    }


    if(m_updateLink != 0){

        if(m_updateLink == 1){
            //上传给服务端
            NSString *newUrl = [currentURl stringByReplacingOccurrencesOfString:@"https://mp.weixin.qq.com/s?" withString:@"https://mp.weixin.qq.com/mp/getappmsgext?is_need_ad=1&is_only_read=1&"];

            NSLog(@"--------------%@",newUrl);
            m_current_readCount = m_current_readCount+1;

            //上传到服务器
            updateLinkData(newUrl);
        }else if(m_updateLink == 2){
            //js 注入方式
            if([currentURl rangeOfString:@"https://mp.weixin.qq.com"].location != NSNotFound){

                dispatch_group_async(group, queue, ^{

                    [NSThread sleepForTimeInterval:8];

                    dispatch_async(dispatch_get_main_queue(), ^{

                        m_current_readCount = m_current_readCount+1;

                        NSString *newUrl = [currentURl stringByReplacingOccurrencesOfString:@"https://mp.weixin.qq.com/s?" withString:@"https://mp.weixin.qq.com/mp/getappmsgext?is_need_ad=1&is_only_read=1&"];

                        //                NSLog(@"--------------%@",newUrl);
                        NSString *script = [NSString stringWithFormat:@"document.getElementById(\"readNum3\").innerText;"];
                        //                NSString *script = [NSString stringWithFormat:@"$('body')[0].outerHTML"];
                        NSString *readNum =  [self stringByEvaluatingJavaScriptFromString:script];
//                        NSLog(@"HKWXJD this is newUrl：%@ m_current_readCount:%d readNum3:%@",newUrl,m_current_readCount,readNum);

                        //上传给服务端
                        saveArticleReadingCnt(newUrl,readNum);

                    });
                    
                });
                
            }
        }else if(m_updateLink == 3){

            //上传uin 和key给服务器
            saveMyAccountUinAndKey(currentURl,[m_nCSetting m_nsUsrName]);
        }
    }

}

%end

//朋友圈主页面
%hook WCTimeLineViewController

%new
- (void)executeWCTimeLineViewController{

    NSLog(@"HKWeChat WCTimeLineViewController(executeWCTimeLineViewController)");

    uploadLog(geServerTypeTitle(2,@"点击发现"),@"成功进入到发朋友圈页面");

    //异步延时进入朋友圈
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            //判断当前是否是发朋友圈
            if(m_current_taskType == 4){

                NSLog(@"HKWeChat 进入朋友圈 发朋友圈");

                //TODO:从文件中读取当前是发表文字，还是图片
                if([[m_taskDataDic objectForKey:@"isImgs"] intValue] == 0){

                    NSLog(@"HKWeChat 点击进入文字评论");

                    uploadLog(geServerTypeTitle(3,@"点击进入文字"),@"点击");
                    //文字
                    [self openWriteTextViewController];

                }else if([[m_taskDataDic objectForKey:@"isImgs"] intValue] == 1){

                    NSLog(@"HKWeChat enter 文字和图片 ");

                    uploadLog(geServerTypeTitle(4,@"点击进入文字和图片"),@"点击");
                    //文字和图片
                    [self openCommitViewController:YES arrImage:nil];
                }
            }
            
        });
        
    });
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"hkweixin 当前朋友圈主页面");
    
    //当前是发朋友圈
    if(m_current_taskType == 4){

        [self executeWCTimeLineViewController];
    }
    
}

%end


//发表文字的Controller
%hook WCInputController

- (id)init{
    id result = %orig;

    NSLog(@"HKWeChat WCInputController----init--");

    m_input_pic = 0; //设置开始输入

    //发朋友圈
    if(m_current_taskType == 4){
        //异步加载数据
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                [self TextViewDidEnter:[m_taskDataDic objectForKey:@"taskTextContent"]];

                uploadLog(geServerTypeTitle(7,@"输入文本"),@"执行结果完毕");

                //标示文字输入完毕
                m_input_text = 1;

                NSLog(@"HKWeChat 输入文字完毕 ");

            });

        });

    }

    return result;
}

%end

//选择图片
%hook ImageSelectorController
// 获取服务器晒单图片
%new
- (UIImage *)loadImageFromSrv:(NSString *)imageUrl {
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    return img;
}

- (id)initWithImage:(id)arg1{
    NSLog(@"HKWeChat ImageSelectorController initWithImage %@",arg1);

    return %orig;
}

- (id)init{
    NSLog(@"HKWeChat ImageSelectorController");

    if(m_current_taskType != 4){

        return %orig;
    }

    m_input_pic = 0; //设置为开始处理图片

    //异步加载数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            //得到图片的URL
            NSArray *picArray = [[m_taskDataDic objectForKey:@"photoArrs"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组
            //            NSLog(@"HKWeChat picture array count:%ul contet:%@",[picArray count],picArray);

            for(NSString* obj in picArray){

                if(![obj isEqualToString:@""]){
                    NSLog(@"HKWeChat picture URL is %@",obj);

                    UIImage *image = [self loadImageFromSrv:obj];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj]];
                    
                    MMImage *v = [[NSClassFromString(@"MMImage") alloc] init];

                    [v setM_imageFromAsset:image];
                    [v setM_imageData:data];

                    [[self arrImages] addObject:v];
                }
            }

            uploadLog(geServerTypeTitle(8,@"下载图片"),@"执行结果完毕");

             m_input_pic = 1;

         });

    });

    return %orig;
}

%end


//发表文字的ViewController
%hook WCNewCommitViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    //读出当前是否开启hook
    NSMutableDictionary *config = loadTaskId();

    if([[config objectForKey:@"hookEnable"] intValue] != 1){

        return;
    }

    //异步循环检查是否可以发布
    dispatch_group_async(group, queue, ^{

        for(int i=0;i<10;i++){
            [NSThread sleepForTimeInterval:5];


            if(m_input_text == 1 && m_input_pic == 1){
                break;
            }

            NSLog(@"HKWeChat WCNewCommitViewController this is xun huai count:%d",i);
        }


        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_privacy_cell_clicked != 3){
                //判断有几张图片
                NSArray *picArray = [[m_taskDataDic objectForKey:@"photoArrs"] componentsSeparatedByString:@","];

                //每张图片停留10s钟
                [NSThread sleepForTimeInterval:10*[picArray count]];

                NSLog(@"HKWeChat click publish button(发朋友圈成功)");

                [self OnDone];

                uploadLog(geServerTypeTitle(9,@"点击发送"),@"执行结果完毕");

                //TODO 保存标示告诉脚本
                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                uploadLog(geServerTypeTitle(10,@"告知脚本"),@"保存标示告诉脚本为1");

                m_current_taskType = -1;
            }
        });
        
    });
}

%end


%hook WCRedEnvelopesReceiveHomeView

- (void)refreshViewWithData:(id)arg1 {
    %orig;
    NSLog(@"WCRedEnvelopesReceiveHomeView===========================");
    [self performSelector:@selector(OnOpenRedEnvelopes)];
    [self performSelector:@selector(OnCancelButtonDone)];
}
%end


%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"this is enter CSetting");
                             
    m_nCSetting = self;
                             
    return ret;
}
%end

//去掉发朋友圈文字时候的我知道
%hook WCPlainTextTipFullScreenView
- (void)initView{
    %orig;
    NSLog(@"hkweixin 去掉发图片是 弹出我知道");

    if(m_current_taskType != 4){
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            uploadLog(geServerTypeTitle(5,@"点击我知道了"),@"发文字消息");

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

//    if(m_current_taskType != 4 || m_current_taskType == 70){
//        return;
//    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(m_current_taskType == 4){
                uploadLog(geServerTypeTitle(6,@"点击我知道了"),@"文字和图片");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 70){
                uploadLog(geServerTypeTitle(6,@"点击我知道了"),@"按钮");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 66){

                uploadLog(geServerTypeTitle(6,@"漂流瓶被投诉了"),@"任务置失败 告诉脚本");

                [self onClickBtn:[self getBtnAtIndex:0]];

                write2File(@"/var/root/hkwx/operation.txt",@"-1");
                m_is_bottlecomplain = YES;

                uploadLog(geServerTypeTitle(6,@"告知脚本当前任务失败"),@"operation.txt == -1");

                m_current_taskType = -1;
            }

        });
        
    });
}
%end

%hook SandyBeachViewController
- (id)init{
    id ret = %orig;

    if(m_current_taskType == 66){
        //返回
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                if(!m_is_bottlecomplain){
                    //返回
                    if(m_mMUINavigationController){
                        [m_mMUINavigationController popViewControllerAnimated:YES];
                    }

                    //可以进入首页发送瓶子
                    m_enterBottle = TRUE;

                    uploadLog(geServerTypeTitle(4,@"返回到首页"),@"");

                    [m_mMTabBarController setSelectedIndex:0];

                    //发送发瓶子消息
                }
            });
            
        });

    }

    return ret;

}
%end



%hook UpdateProfileMgr
- (void)onModifySelfContact:(id)arg1{
    %orig;

    NSLog(@"=====================thi is ces %@",arg1);
}

%end

//关注返回值
%hook WebViewJSLogicImpl
- (void)onEndEvent:(id)arg1 withResult:(id)arg2{
    %orig;

    NSLog(@"关注返回值 onEndEvent:(id)arg1:%@ withResult:(id)arg2:%@",arg1,arg2);
}
%end


//漂流瓶
%hook BottleMgr
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2{
    %orig;

    CBottleContact *bottleContact = arg2;

    NSLog(@"hkweixin bootleMgr arg1:%@ arg2:%@ cbottle:%@",arg1,arg2,bottleContact);


}
%end


%hook iConsole

+ (_Bool)shouldEnableDebugLog {

    return NO;
}


+ (void)purelog:(id)arg1 {
    %orig;

    NSLog(@"HKWeChat iConsole -----arg1:%@",arg1);
}

+ (_Bool)shouldLog:(int)arg1 {


    return NO;
}

+ (void)logToFile:(int)arg1 module:(const char *)arg2 file:(const char *)arg3 line:(int)arg4 func:(const char *)arg5 message:(id)arg6{
    %orig;

    NSLog(@"HKWeChat logToFile iConsole arg1:%d,arg2:%s,arg3:%s,arg4:%d,arg5:%s,arg6:%@",arg1,arg2,arg3,arg4,arg5,arg6);
}

+ (void)printLog:(int)arg1 module:(const char *)arg2 file:(const char *)arg3 line:(int)arg4 func:(const char *)arg5 log:(id)arg6{
    %orig;

    NSLog(@"HKWeChat printLog iConsole arg1:%d,arg2:%s,arg3:%s,arg4:%d,arg5:%s,arg6:%@",arg1,arg2,arg3,arg4,arg5,arg6);
}
%end


//测试搜索



//- (id)getSvrUsrNameByLocalID:(unsigned int)arg1;
//- (unsigned int)getMsgTypeByBottleDataType:(unsigned int)arg1;
//- (unsigned int)getMsgTypeByDataType:(unsigned int)arg1;
//- (_Bool)isBeBanned;
//- (void)initDB:(id)arg1 withLock:(id)arg2;
//- (void)onServiceInit;
//- (id)init;
//- (id)GetBottleIDFromContactName:(id)arg1;
//- (void)SaveSetting;
//- (id)GetSetting;
//- (void)LoadSetting;
//- (void)GenTestData;
//- (void)testThrow;

//%end




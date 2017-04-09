#import "substrate.h"
#import "HookWeChatSo.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

static id audioSender = nil;
extern char **environ;
static int totalCardSend = 0;


static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页
static MMVoiceSearchBar *m_mmVoiceSearchBar = [[NSClassFromString(@"MMVoiceSearchBar") alloc] init];  //搜索框
static RightTopMenuItemBtn *m_rightTopMenuItemBtn = [[NSClassFromString(@"RightTopMenuItemBtn") alloc] init];  //右边弹出框按钮 发起群聊 添加朋友 等
static NewMainFrameRightTopMenuBtn *m_newMainFrameRightTopMenuBtn = [[NSClassFromString(@"NewMainFrameRightTopMenuBtn") alloc] init];  //右边弹出框
static WCMallFunctionActivity *m_wCMallFunctionActivity = [[NSClassFromString(@"WCMallFunctionActivity") alloc] init];;
static WCMallFunctionActivityView *m_wCMallFunctionActivityView = [[NSClassFromString(@"WCMallFunctionActivityView") alloc] init];
static MMUINavigationController *m_mMUINavigationController = [[NSClassFromString(@"MMUINavigationController") alloc] init]; //导航栏
static WCFacade *m_mWCFacade = [[NSClassFromString(@"WCFacade") alloc] init];

static NSString *linkTemplate = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwx/link_template.xml"];

//static AddressBookFriendViewController *abfvc = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init]; //通讯录朋友

 /*
    变量说明：微信浏览的深度
    作用：标示返回主页面的次数
    0:目前处于首页
    1:第二级目录
    2:第三级目录
    3:第三级目录
    4:第三级目录
 */

NSInteger m_depth_wechat = -1;


/*
    变量说明：tab页面的标示
    作用：标示切换那个teb页面
    0:表示微信
    1:表示通讯录
    2:发现
    3:我
 */

NSInteger m_tab_wechat = -1;

/*
    变量说明： 记录当前请求数据的位置
    作用：记录当前处于第几个任务
 */

NSInteger m_request_count = -1;

/*
    变量说明： 记录当前微信有多少个任务
 */
NSInteger m_request_total_count = 0;


/*
    变量说明：记录所有的任务ID的数据
    作用：记录订单ID
 */
NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];

/*
    变量说明：是否开启hook
    0:表示关闭hook
    1:表示开启hook
 */
NSInteger m_hookEnable = 0;


/*
    变量说明：当前正在做的任务是什么类型
    -1:表示当前没有任务在进行
 */
NSInteger m_current_taskType = -1;

/*
    获取原始数据存储
 */

NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskNextDataDic = [NSMutableDictionary dictionaryWithCapacity:1];


/*
 聊天返回的数据
 */
NSString *m_chatMsgData = @"";


/*
    是否有等待请求数据回来
    -1:处于初始化状态
    0: 没有数据
    1: 等待数据返回
    2: 数据返回了
*/
NSInteger  m_isRequestResult = -1;


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



/*
     变量说明：发朋友圈的步骤
     0:初始化(启动App时变量为 0)
     1:点击tab下面的“发现”
     2:点击进入朋友圈页面
     3:进入朋友圈
     4:点击进入发表文字,
     5:点击进入发表图片和文字
     6:发完朋友圈有，在进行点赞、评论等
     -1:发送朋友圈完毕
 */

NSInteger m_step_friends = -1;

/*
    聊天步骤
    -1:聊天处于等待状态
    0:初始化(启动App时变量为 0)
    1:点击通讯录tab
    2:点击随机进入一个朋友圈
    3:点击进入详情页。点击发送消息
    4:开始聊天
 */
NSInteger m_step_chat = -1;

/*
    转发文章步骤
    -1:转发处于等待状态
    0:初始化(启动App时变量为 0)
    1:点击文章按钮、公众号
    2:进入搜索页面
    3:进入文章详情页进行分享
    4:弹出分享框
    5:分享
 */
NSInteger m_step_forward = -1;

//当前自己的微信唯一ID
NSString *m_nsUsrName = @"";

//发消息的数据
NSString *m_chatRequestData = @"";

//数据从那里发来
NSString *m_nsFromUsr = @"";

/*
    判断是不是在处于聊天状态
    －1:没有处于聊天状态
    0:第一次进入聊天页面
    1:处于聊天状态
 */

NSInteger m_isChatWithFriend = -1;

/*
    判断是不是首次进入数据
 */
BOOL m_isFirstStartApp = YES;


/*
    判断是不是返回的页面
 */
BOOL m_isBackHome = NO;

/*
    判断是否正在做任务，还是要做完任务要取数据
    YES:正在做
    NO: 请求新数据
 */
BOOL m_isDoTask = NO;

/*
    判断当前点赞的位置
 */
NSInteger m_likes_pos = 0;

/*
    点赞次数
 */
NSInteger m_likes_count = 0;


//打开文件
extern "C" NSMutableDictionary * openFile(NSString * fileName) {
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@ fileName:%@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO",fileName);
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

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
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

//读出als.json 配置的信息
extern "C" NSMutableDictionary * loadTaskId() {
    return openFile(@SEARCH_TASK_FILE);
}

//读取taskItem.json 文件
extern "C" NSMutableDictionary * loadTaskItem() {
    return openFile(@TASK_ITEM_FILE);
}

//读取amrfile.json 文件
extern "C" NSMutableDictionary * loadAmrFile() {
    return openFile(@VOICE_AMR_FILE);
}

//初始化所有变量，所有变量恢复到原始状态
extern "C" void initAllVariable(){

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

//请求聊天数据
extern "C" void getChatMsgData(){

    m_chatMsgData = @"";

    // 1. URL
    //    NSString *urlStr = [NSString stringWithFormat:chatUrl];
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }



    NSString *chatUrl = [NSString stringWithFormat:@"%@robotChat.htm?taskId=%@&txt=%@",environmentPath,[m_taskDataDic objectForKey:@"taskId"],m_chatRequestData];
    //

    NSLog(@"HKWeChat (去服务端取数据):%@",chatUrl);

    NSURL *url = [NSURL URLWithString:URLEncodedString(chatUrl)];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // num = 2
            m_chatMsgData = str;

            NSLog(@"HKWeChat this is request chat (requestURL:%@) return msg %@",URLEncodedString(chatUrl),str);
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //                self.logonResult.text = @"登录完成";

            }];
        }
    }];

    // num = 1
//    NSLog(@"come here %@", [NSThread currentThread]);
}


//返回后操作数据
extern "C" void operationData(){

    NSMutableDictionary *config = loadTaskId();

    if([[config objectForKey:@"isHookRequest"] intValue] != 1){

//        return;
    }

    if(m_isDoTask){
        NSLog(@"HKWeChat 正在做当前任务:%@",m_taskDataDic);
        return;
    }

    m_request_count++;

//    NSLog(@"HKWeChat 开始跑第几个任务(m_request_count):%ld content:%ld m_taskArrayData:%@",m_request_count,[m_taskArrayData count],m_taskArrayData);

    if(!m_taskArrayData){
        return;
    }

    if(m_request_count >= [m_taskArrayData count]){

        NSLog(@"HKWeChat 告诉脚本所有任务执行完毕");

        m_tab_wechat = -1;
        m_depth_wechat = -1;

        m_taskArrayData = nil;

        m_current_taskType = -1;

        //告诉脚本所有任务执行完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
        return;
    }

    m_isDoTask = YES;

    //得到数据
//    m_taskDataDic = ;
    m_taskDataDic = m_taskArrayData[m_request_count];

    if((m_request_count + 1) >= m_request_total_count){
        m_taskNextDataDic = nil;
    }else{
        m_taskNextDataDic = m_taskArrayData[m_request_count + 1];
    }

    NSLog(@"HKWeChat 当前要跑的任务m_taskDataDic为：%@ 下一个任务数据:%@",m_taskDataDic,m_taskNextDataDic);


    m_current_taskType = [[m_taskDataDic objectForKey:@"taskType"] intValue];

    if(m_mMTabBarController == nil){
        NSLog(@"HKWeChat m_mMTabBarController is null");

        return;
    }

    if(m_current_taskType == 4){ //发朋友圈
        //testID:856252
        NSLog(@"HKWeChat (当前的任务时发朋友圈)m_taskDataDic: %@ ", m_taskDataDic);

        m_tab_wechat = 2;

        m_step_friends = 1;

        m_depth_wechat = 0;

        [m_mMTabBarController setSelectedIndex:2];

    }else if(m_current_taskType == 8){  //转发文章
        //test 817541
        m_step_forward = 0;
        m_tab_wechat = 0;
        m_depth_wechat = 0;
        NSLog(@"HKWeChat (当前任务是 转发文章)");

        [m_mMTabBarController setSelectedIndex:0];

    }else if(m_current_taskType == 13){  //浏览京东
        //test 819975
        NSLog(@"HKWeChat (当前任务是 浏览京东)");

        m_tab_wechat = 2;
        m_depth_wechat = 0;

        m_step_friends = 1;

        [m_mMTabBarController setSelectedIndex:2];


    }else if(m_current_taskType == 14){ //浏览朋友圈
        //Test 816797
        NSLog(@"HKWeChat (当前任务是 浏览朋友圈)");

        m_tab_wechat = 2;
        m_depth_wechat = 0;

        m_step_friends = 1;

        [m_mMTabBarController setSelectedIndex:2];


    }else if(m_current_taskType == 15){ //腾讯新闻
        //TEST 820253
        NSLog(@"HKWeChat (当前任务 浏览腾讯新闻 )");
        m_tab_wechat = 0;
        m_depth_wechat = 0;

        [m_mMTabBarController setSelectedIndex:0];

    }else if(m_current_taskType == 16){ //浏览腾讯公益
        //test 827729
        NSLog(@"HKWeChat (当前任务 浏览腾讯公益 )");

        m_tab_wechat = 3;
        m_depth_wechat = 0;

        [m_mMTabBarController setSelectedIndex:3];

    }else if(m_current_taskType == 9 || m_current_taskType == 17 || m_current_taskType == 24 ){
        //9:通讯录聊天 17:通过好友请求验证 20:同步微信通讯录    24:添加手机联系人
        //test(868922 同步微信通讯录) (830872 通过好友请求验证) (810057 通讯录聊天)
        NSLog(@"HKWeChat 9:通讯录聊天 17:通过好友请求验证 20:同步微信通讯录");

        m_tab_wechat = 1;

        m_depth_wechat = 0;

        m_step_chat = 1;

//        [m_mMTabBarController setSelectedIndex:1];

    }else if(m_current_taskType == 20){
        NSLog(@"同步微信通讯录");

        m_tab_wechat = 1;

        m_depth_wechat = 0;

        m_step_chat = 1;

//        [m_mMTabBarController setSelectedIndex:1];

    }else if(m_current_taskType == 18){  //微信里聊天 有红点时
        //TEST:829013
        NSLog(@"HKWeChat (当前任务 微信里选择朋友聊天 )");
        m_depth_wechat = 0;
        m_tab_wechat = 0;

        [m_mMTabBarController setSelectedIndex:0];


    }else if(m_current_taskType == 19){     //关注公众号
        //test 843105
        NSLog(@"HKWeChat (当前任务 关注公众号 )");

        m_step_forward = 0;
        m_tab_wechat = 0;
        m_depth_wechat = 0;
        [m_mMTabBarController setSelectedIndex:0];


    }else if(m_current_taskType == 21){  //指定人聊天
        //Test 880995
        NSLog(@"HKWeChat (通讯录中指定人聊天)");

        m_tab_wechat = 0;
        m_depth_wechat = 0;

//        [m_mMTabBarController setSelectedIndex:0];

    }else if(m_current_taskType == 22){ //朋友圈点赞
        //test 850726
        NSLog(@"HKWeChat (朋友圈点赞)");

        m_tab_wechat = 2;
        m_depth_wechat = 0;
        m_step_friends = 1;

        [m_mMTabBarController setSelectedIndex:2];

    }else if(m_current_taskType == 23){ //朋友圈评论
        //test 850801
        NSLog(@"HKWeChat (朋友圈评论)");

        m_tab_wechat = 2;
        m_depth_wechat = 0;
        m_step_friends = 1;

        [m_mMTabBarController setSelectedIndex:2];

    }else if(m_current_taskType == 50){

        //发消息、图片、语音等
        write2File(@WXGROUP_MSG_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 52){

        [m_mMTabBarController setSelectedIndex:1];
        //删除好友
        write2File(@WXGROUP_DEL_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 48){

        [m_mMTabBarController setSelectedIndex:1];

        m_likes_pos = 0;

        //进入朋友信息列表点赞
        write2File(@WXGROUP_LIKES_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 53){
        //修改头像或背景
        write2File(@WXGROUP_CHANGE_LIST, [m_taskDataDic objectForKey:@"weixinListData"]);
    }else if(m_current_taskType == 101){
        NSLog(@"当前执行朋友圈发视频");
    }

}


//启动时请求的的任务数据
extern "C" void getServerData(){

    //读出当前是否开启hook
    NSMutableDictionary *config = loadTaskId();

    if([[config objectForKey:@"hookEnable"] intValue] != 1){

        NSLog(@"HKWX 没有开启微信hook %@",config);
        m_step_friends = -1;
        m_step_chat = -1;
        m_isRequestResult = 0;

        return;
    }

    //读出要做任务的ID
    NSMutableDictionary *taskInfo = loadTaskId();

    NSLog(@"HKWX 启动时请求的的任务数据,%@",loadTaskId());

    if([[taskInfo objectForKey:@"taskId"] isEqualToString:@""]){
        NSLog(@"HKWX 当前没有任务ID");
        return;
    }

    m_isRequestResult = 1;

//    clientType=1
//    批量请求数据接口，新增字段：clientType   0.hook   1.脚本
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
//    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest-test/weixin/get_original_tasks.htm?taskIds=%@&clientType=0",[taskInfo objectForKey:@"taskId"]];

    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"HKWeChat 请求回来的数据为:%@ url:%@",taskAll,urlStr);


            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

//                [m_taskArrayData addObject:[taskAll objectForKey:@"dataList"]];

//                NSLog(@"HKWeChat count:%d m_taskArrayData:%@",[m_taskArrayData count],m_taskArrayData);
//                m_taskArrayData = [taskAll objectForKey:@"dataList"];
                for(NSArray *obj in [taskAll objectForKey:@"dataList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];
                }

                NSLog(@"HKWeChat count m_taskArrayData:%@",m_taskArrayData);

                m_isRequestResult = 2;

                m_request_total_count = [m_taskArrayData count];

//                operationData();

//                NSLog(@"HKWeChat 请求回来的数据的数据完毕！！");

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

//发送同步信息
extern "C" void syncContactTask(NSString *data){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncContact.htm"];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //读出自己的名字
    NSString *myAliasName = readFileData(@"/var/root/hkwx/selfInfo.txt");

    //读出日期
    NSString *bathTime = readFileData(@"/var/root/hkwx/syncTime.txt");

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&taskOrderId=%@&dataList=%@&selfWeixinAlias=%@&time=%@",[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],data,myAliasName,bathTime];

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

                //通知脚本当前通讯录同步完毕
//                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        }
    }];

}

//发送同步群聊信息
extern "C" void syncChatroomMember(NSString *chatRoom,NSString *data){

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
//    
//    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncChatroomMember.htm"]
//    ;
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@syncChatroomMember.htm",environmentPath]];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&encodeType=1&chatRoom=%@&dataList=%@",[taskId objectForKey:@"taskId"],chatRoom,data];

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

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);

            //通知脚本当前通讯录同步完毕
            write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        }
    }];
    
}


//发送同步手机联系人
extern "C" void syncPhoneMember(NSString *data){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

//    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncPhoneMember.htm"];
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@syncPhoneMember.htm",environmentPath]];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&dataList=%@",[taskId objectForKey:@"taskId"],data];

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
            //通知脚本当前通讯录同步完毕
            write2File(@"/var/root/hkwx/wxResult.txt", @"1");
            
        }
    }];
    
}


//发送成功标示给服务端
extern "C" void hookSuccessTask(){

    NSLog(@"HKWeChat 发送成功标示给服务端");

    m_isDoTask = NO;

//    return;

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
    NSString *urlStr = [NSString stringWithFormat:@"%@hook_success_task.htm?taskId=%@&taskOrderId=%@&clientType=0",environmentPath,[m_taskDataDic objectForKey:@"taskId"],[m_taskDataDic objectForKey:@"taskOrderId"]];

    NSLog(@"HKWeChat 发送成功给服务器 %@",urlStr);

    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    //通知脚本当前任务已经结束
//    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    NSURL *url = [NSURL URLWithString:URLEncodedString(urlStr)];

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


//启动时加载大数据
%hook MicroMessengerAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
    NSLog(@"HKWeChat this is Hook WeChat Demo");

    m_tab_wechat = 0;
    m_depth_wechat = 0;
    m_request_count = -1;

    //异步请求大数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:8];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HKWeChat this is request big data");

            write2File(@"/var/root/hkwx/selfInfo.txt", @"");

            //读出是否配置文件是否请求数据
            NSMutableDictionary *config = loadTaskId();

            if([[config objectForKey:@"isHookRequest"] intValue] == 1 ||
               [[config objectForKey:@"type"] intValue]== 50 ||
               [[config objectForKey:@"type"] intValue]== 52 ||
               [[config objectForKey:@"type"] intValue]== 53 ||
               [[config objectForKey:@"type"] intValue]== 101){

                getServerData();
            }
            
        });
        
    });
    
    return %orig;
}

%end

//////////////////////导航栏///////////////////
%hook  MMUINavigationBar
- (id)initWithFrame:(struct CGRect)arg1{
    id ret = %orig;

    NSLog(@"HKWeChat 导航栏==========");

//    m_mMUINavigationBar = self;

    return ret;
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

    //判断标示是不是在首页
    if(m_depth_wechat != 0){
        return;
    }

}

%end
//////////////////////tabbar 切换结束///////////////////


///////////////////////微信页面开始///////////////////////

%hook NewMainFrameViewController

%new
- (void)executeNewMainFrameController{

    NSLog(@"HKWeChat 当前处于微信页面的执行函数");

    dispatch_group_async(group, queue, ^{

        //等待数据返回
        while(true){

            NSLog(@"HKWeChat 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:5];
            if(m_isRequestResult != 1){
                break;
            }
        }

        [NSThread sleepForTimeInterval:5];

        //操作数据
        operationData();

        dispatch_async(dispatch_get_main_queue(), ^{

            //表示当前有数据返回
            if(m_isRequestResult == 2){

                m_isRequestResult = 3;

                if(m_current_taskType == 8){

                    m_step_forward = 0;
                    //点击搜索框
                    NSLog(@"WXHK 点击搜索框");

                    if(m_mmVoiceSearchBar){
                        [m_mmVoiceSearchBar voiceSearchRestart];
                    }
                    
                }else if(m_current_taskType == 21){

                    NSLog(@"HKWeChat 当前处于微信页面查找指定人聊天 数据为：%@",m_taskDataDic);

                    //改为脚本聊天
                    //                NSMutableDictionary *dic = strngToDictionary(m_taskData);
                    NSLog(@"HKWeChat 当前为脚本聊天");

//                        int selectRows = -1;
//
//                        //得到tebleView
//                        MMMainTableView *table = MSHookIvar<MMMainTableView *>(self, "m_tableView");
//                        if (table) {
//                            int ccNum = [self tableView:table numberOfRowsInSection:1];
//                            NSLog(@"HKWeChat message total chat num: %d", ccNum);
//
//                            if(ccNum > 30) ccNum = 30;
//
//                            //查找前30位是否有没有当前的这个人
//                            for (int i=0; i < ccNum; i++) {
//                                //得到每个cell的数据
//                                NewMainFrameCell *cell = [self tableView:table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
//
//                                NSLog(@"HKWeChat wxid: %@, nickname: %@, unread: %d", [[cell m_cellData] m_nsRealUsrName], [[cell m_cellData] m_textForNameLabel], [[cell m_cellData] m_lastUnReadCount]);
//
//                                //                        if([[[cell m_cellData] m_nsRealUsrName] isEqualToString:[dic objectForKey:@"weixinId"]]){
//                                if([[[cell m_cellData] m_nsRealUsrName] isEqualToString:@"wxid_x4asq8c7bov521"]){
//
//                                    selectRows = i;
//                                    break;
//                                }
//                            }
//                        }
//
//                        if(selectRows == -1){
//                            NSLog(@"HKWeChat 在微信页面前30位没有找到要聊天的人，进入通讯录里查找");
//
//                            m_step_chat = 1;
//                            m_tab_wechat = 1;
//
//                            [m_mMTabBarController setSelectedIndex:1];
//                            
//                        }else{
//                            NSLog(@"HKWeChat 在微信页面前30位找到了要聊天的人");
//                            //进入
//                            m_depth_wechat = 1;
//                            
//                            [self tableView:table didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:selectRows inSection:1]];
//                            
//                        }
//                    }

                }else if(m_current_taskType == 15 || m_current_taskType == 18){
                    MMMainTableView *table = MSHookIvar<MMMainTableView *>(self, "m_tableView");
                    int readCountTop = 0; //最多的红点
                    int row = -1;

                    if (table) {
                        int ccNum = [self tableView:table numberOfRowsInSection:1];
                        NSLog(@"HKWECHAT message total chat num: %d", ccNum);
                        for (int i=0; i < ccNum; i++) {
                            NewMainFrameCell *cell = [self tableView:table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                            NSLog(@"HKWECHAT wxid: %@, nickname: %@, unread: %d", [[cell m_cellData] m_nsRealUsrName], [[cell m_cellData] m_textForNameLabel], [[cell m_cellData] m_lastUnReadCount]);
                            // 进入相应的聊天
                            //            if ([[cell m_cellData] m_lastUnReadCount]) {
                            //                [self tableView:table didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                            //            }
                            if(m_current_taskType == 18){
                                if(!([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"腾讯新闻"])
                                   && !([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"订阅号"])
                                   && !([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"服务通知"])
                                   && !([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"支付通知"])
                                   && !([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"微信团队"])
                                   ){
                                    if([[cell m_cellData] m_lastUnReadCount] > readCountTop){
                                        readCountTop = [[cell m_cellData] m_lastUnReadCount];
                                        row = i;
                                    }
                                }

                            }else if(m_current_taskType == 15){

                                if(([[[cell m_cellData] m_textForNameLabel] isEqualToString:@"腾讯新闻"])){
                                    row = i;
                                    break;
                                }
                            }

                        }

                        if(m_current_taskType == 15){
                            NSLog(@"HKWeChat 当前为浏览腾讯新闻");

                            //浏览腾讯新闻，这里不需要返回，到点击返回的时候发送成功
//                            hookSuccessTask();
                            //返回首页
                        }

                        if(row == -1){

                            NSLog(@"HKWeChat 当前没有找到要浏览的任务");

                            //通知服务器
                            hookSuccessTask();
                            //返回首页
                            

                        }else{

                            NSLog(@"HKWeChat 点击cell 进入。。。。");

                            m_depth_wechat = 1;
                            
                            [self tableView:table didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
                        }
                    }

                }else if(m_current_taskType == 19){
                    // 方式一、点击搜索
//                    if(m_mmVoiceSearchBar){
//
//                        NSLog(@"HKWeChat 点击搜索框的方式 添加公众号");
//
//                        [m_mmVoiceSearchBar voiceSearchRestart];
//                    }

                    //方式二、关注公众号, 点击右上角的 弹出框
                    NSLog(@"WXHK 关注公众号, 点击右上角的 弹出框");
                    //显示弹出框
                    [m_newMainFrameRightTopMenuBtn showRightTopMenuBtn];
    
                    [NSThread sleepForTimeInterval:2];
    
                    [m_newMainFrameRightTopMenuBtn hideRightTopMenuBtn];
                    
                    [m_newMainFrameRightTopMenuBtn onItemAction:m_rightTopMenuItemBtn];
                }else if(m_current_taskType == 50){

                    //发送消息
                    [self sendCardMsgList];
                }else if(m_current_taskType == 53){
                    //修改头像
                    [self changeHeadImg];
                }else if(m_current_taskType == 101){
                    NSLog(@"首页发视频朋友圈");
                    [self sendFriends];
                }
            }

        });
        
    });

}


%new
-(BOOL)downFileByUrl:(NSString *)downUrl dwonName:(NSString *)dwonName{

    NSLog(@"hkfodderWeixin is Down file %@ ",dwonName);

    NSString *url = downUrl;
    if([url isEqualToString:@""] || url == nil){
        NSLog(@"hkfodderWeixin downURL is null hkfodderWeixin下载的文件名为空,下载失败");

        return NO;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;

    fp = fopen([dwonName UTF8String], "wb");
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"hkfodderWeixin-curl image failed: %@", @"File cannot be opened.下载失败");

            return NO;
        }
        curl_easy_setopt(downDylib, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(downDylib, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(downDylib, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(downDylib);
        if( imgresult ){
            NSLog(@"hkfodderWeixin-curl Cannot grab the image!.下载失败\n");

            return NO;
        }
    }

    fclose(fp);

    curl_easy_cleanup(downDylib);

    return YES;

}

//朋友圈发视频
%new
-(void)sendFriendsVideo{
    NSLog(@"");
    //判断当前文件是否存在
    NSString *videoPath = [NSString stringWithFormat:@"/var/root/hkwx/%@",[m_taskDataDic objectForKey:@"videoName"]];
    NSString *videoImg = [m_taskDataDic objectForKey:@"videoImg"];

    BOOL downSuccess = NO;

    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){
        downSuccess = YES;
        //存在
        NSLog(@"hkfodderWeixin is exist,朋友圈发视频当前视频已经存在 视频的名字为:%@",videoPath);
    }else{
        //不存在进行下载
        NSLog(@"朋友圈发视频当前视频不存在，进行下载视频,开始下载视频 视频名字为:%@ 视频链接为：%@",videoPath,[m_taskDataDic objectForKey:@"videoUrl"]);
        //下载视频
        downSuccess = [self downFileByUrl:[m_taskDataDic objectForKey:@"videoUrl"] dwonName:videoPath];
    }

    if(!downSuccess){
        NSLog(@"发朋友圈视频时下载视频失败 视频名字为:%@ 视频链接为：%@", videoPath,[m_taskDataDic objectForKey:@"videoUrl"]);
        write2File(@"/var/root/hkwx/operation.txt",@"-1");
        return;
    }

    //下载文件
    //    NSString *videoPath = @"/var/root/hkwx/test.mp4";
    NSString *text = [m_taskDataDic objectForKey:@"taskTextContent"];
    UIImage *realThumb = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:videoImg]]];
    id vc = [[NSClassFromString(@"SightMomentEditViewController") alloc] init];
    id textView = [[NSClassFromString(@"MMGrowTextView") alloc] init];
    [vc setRealMoviePath:videoPath];
    [vc setMoviePath:videoPath];
    [vc setRealThumbImage:realThumb];
    [vc setThumbImage:realThumb];
    Ivar ivar = class_getInstanceVariable([vc class], "_textView");
    [textView setText:text];
    object_setIvar(vc, ivar, textView);
    [vc uploadMoment];
    NSLog(@"执行成功");
    write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    m_current_taskType = -1;
}


%new
- (void)sendFriends{

    dispatch_group_async(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            if([[m_taskDataDic objectForKey:@"msgType"] intValue] == 0){
                //判断是否发送文字或视频
                [self sendFriendsVideo];

            }else if([[m_taskDataDic objectForKey:@"msgType"] intValue] == 1){

                //发送图片文字
//                [self sendFriendsPictureAndText:taskDataDic];

            }else{
                NSLog(@"发朋友圈服务端没有给类别，失败");
//                hook_fail_task(4,[taskDataDic objectForKey:@"taskId"],@"发朋友圈服务端没有给类别");
            }
            
            
        });
        
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
    //{  fadUrl":"","backgroundUrl":"" }

    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_CHANGE_LIST];

    NSLog(@"hkweixin 当前的任务数据为：%@",config);

    if(![config[@"headUrl"] isEqualToString:@""] && config[@"headUrl"] != nil){

        MMHeadImageMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMHeadImageMgr")];

        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"headUrl"]]];
        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");
            return;
        }

        UIImage *headImage = [[UIImage alloc] initWithData:data];
        [mgr uploadHDHeadImg:[headImage retain]];

        NSLog(@"hkweixin 修改头像成功");

        //告诉服务器，修改完毕
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    }

    if(![config[@"backgroundUrl"] isEqualToString:@""] && config[@"backgroundUrl"] != nil){

        WCFacade *fade = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"WCFacade")];
        
        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"backgroundUrl"]]];

        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");
            return;
        }

        [fade SetBGImgByImg:data];
        [fade updateTimelineHead];

        NSLog(@"hkweixin 修改背景成功");

        //告诉服务器，修改完毕    
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    }

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

     NSLog(@"HKWX  sendCardMsgList config: %@", config);

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
                msgText1.m_uiCreateTime = (int)time(NULL);

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
                        msgText1.m_uiVoiceTime = [config[@"voiceTime"] intValue];//100000;
                        msgText1.m_dtVoice = [NSData dataWithContentsOfURL:[NSURL URLWithString:config[@"shareVoice"]]];
                        break;
                    case 49:
                        msgText1.m_uiMessageType = 49;
                        msgText1.m_nsText = [[[linkTemplate stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:config[@"linkInfo"][@"title"]]
                                              stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:config[@"linkInfo"][@"desc"]]
                                             stringByReplacingOccurrencesOfString:@"LINK_URL" withString:config[@"linkInfo"][@"url"]];
                }

                msgText1.m_arrayToList = [members retain];
                [sendMgr MassSend:msgText1];
                [sendMgr autoReload];
            } else {
                int msgType = [msgTypeStr intValue];//[config[@"msgType"] intValue];
                CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];
                CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

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

                            for (int i = 0; i < [members count]; i++) {
                                msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                                myMsg.m_nsContent = msgContent[0];//@"你哈 我是小娟";
                                myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
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
    }
    
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

//    [self createChatMsgButton];
//    [self createChageHeadImgButton];

//    NSLog(@"HKWeChat NewMainFrameViewController(进入微信页面,进行选择人聊天) m_tab_wechat:%ld,m_depth_wechat:%@",m_tab_wechat,m_depth_wechat);
    NSLog(@"HKWeChat NewMainFrameViewController(进入微信页面,进行选择人聊天) ");
    if(m_tab_wechat != 0 || m_depth_wechat != 0){
        return;
    }

    [self executeNewMainFrameController];


}
%end



//点击微信上面的语言输入框
%hook MMVoiceSearchBar

- (void)loadView{
    %orig;

    //判断当前是否转发文章

    NSLog(@"HKWeChat 点击微信上面的语言输入框  loadView");
    //点击微信上面的语言输入框
    m_mmVoiceSearchBar = self;
}

%end


//搜索框
%hook  SearchGuideView
- (void)initFTSGuideView{
    %orig;

    NSLog(@"HKWeChat SearchGuideView 搜索框");

    //如果不是上一步的状态
    if(m_step_forward != 0){
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_current_taskType == 8){
                NSLog(@"HKWeChat initFTSGuideView 点击文章按钮");

                SGCustomButton *searchBar =  MSHookIvar<SGCustomButton *>(self, "_ftsEntryArtclBtn");

                m_step_forward = 1;

                //点击文章按钮
                [self onTapButton:searchBar];

            }else if(m_current_taskType == 19){
                NSLog(@"HKWeChat initFTSGuideView 点击公众号按钮");

                SGCustomButton *searchBar =  MSHookIvar<SGCustomButton *>(self, "_ftsEntryBrdCtBtn");

                m_step_forward = 1;


                //点击文章按钮
                [self onTapButton:searchBar];
            }

        });

    });
}
%end


%hook FTSWebSearchController

- (void)initView{
    %orig;

    m_step_forward = 1;

    NSLog(@"HKWeChat 进入搜索框 FTSWebSearchController");

    if(m_step_forward != 1 || m_current_taskType == 21){
        return;
    }


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

//            NSMutableDictionary *dic = strngToDictionary(m_taskData);

            //TODO:服务端取值
            [[self searchTextField] setText:[m_taskDataDic objectForKey:@"keyword"]];

            [NSThread sleepForTimeInterval:2];

            MMUISearchBar *searchBar =  MSHookIvar<MMUISearchBar *>(self, "_searchBar");

            m_step_forward = 2;

            
            //点击搜索
            [self searchBarSearchButtonClicked:searchBar];

            [NSThread sleepForTimeInterval:5];

            m_depth_wechat = 1;

            //返回首页
//            [searchBar _cancelButtonPressed];

            //通知脚本点击
            write2File(@"/var/root/hkwx/operation.txt", @"2");
            
        });
        
    });
}

%end


%hook NewMainFrameRightTopMenuBtn
- (id)initWithFrame:(struct CGRect)arg1{
    id ret = %orig;

    m_newMainFrameRightTopMenuBtn = self;

    return ret;
}
%end

//微信弹出框的按钮  (发起群聊 添加朋友 扫一扫 收付款)
%hook  RightTopMenuItemBtn
- (id)initWithBtnData:(id)arg1 showNew:(_Bool)arg2{
    id ret = %orig;
    NSLog(@"HKWeChat  RightTopMenuItemBtn arg1:%@ text:%@",arg1,[[self titleLabel] text]);

    if([[[self titleLabel] text] isEqualToString:@"添加朋友"]){
        m_rightTopMenuItemBtn = self;
    }

    return ret;
}

%end

//进入到添加朋友
%hook AddFriendEntryViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"HKWeChat 进入到添加朋友页面 viewDidAppear");

    if(m_current_taskType != 19){
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            //得到第一层cell
            MMTableViewInfo *tableViewInfo =  MSHookIvar<MMTableViewInfo *>(self, "m_tableViewInfo");

            //得到数据的cell
            MMTableView *tableView =  MSHookIvar<MMTableView *>(tableViewInfo, "_tableView");

            [tableViewInfo tableView:tableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow: 4 inSection: 1]];
        });

    });

}

%end

//关注公众号搜索页面 方式2
%hook  BrandServiceWebSearchController

- (void)initView{
    %orig;
    NSLog(@"HKWeChat 方式2 公众号搜索");
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            //设置文字
            //            [[self getCurrentSearchBar] setText:@"足球"];
            MMUISearchBar * searchBar = [self getCurrentSearchBar];

            [searchBar setText:[m_taskDataDic objectForKey:@"keyword"]];

            
            //点击搜索
            [self onClickSearchButton:[self getCurrentSearchBar]];

            //设置时间间隔
            [NSThread sleepForTimeInterval:5];

            m_depth_wechat = 1;

            write2File(@"/var/root/hkwx/operation.txt", @"2");

        });
        
    });
}

%end

//关注公众号页面
%hook BrandUserContactInfoAssist
- (void)initTableView{
    %orig;

    NSLog(@"HKWeChat 关注公众号页面 ");

    if(m_current_taskType != 19){
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

//            hookSuccessTask();
            m_isDoTask = NO;
            //点击关注
            [self onAddToContacts];

//            m_is_chat_page = -1;
        });
        
    });
}
%end


//弹出分享到朋友圈Sheet
%hook MMScrollActionSheetIconView
- (void)onTaped{
    %orig;

    NSLog(@"HKWeChat 弹出分享到朋友圈Sheet-------------");
}

- (id)initWithIconImg:(id)arg1 title:(id)arg2{
    id ret = %orig;

    NSLog(@"HKWeChat 弹出分享到朋友圈Sheet initWithIconImg");

    if(m_step_forward != 3){
        return ret;
    }

    if([[self title] isEqualToString:@"分享到朋友圈"]){

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:10];

            dispatch_async(dispatch_get_main_queue(), ^{

                //点击分享按钮,判断文字是不是分享到朋友圈

                m_step_forward = 4;

                [self onTaped];


            });

        });
    }

    return ret;
}
%end

//浏览详情页
%hook  MMWebViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    if(m_isBackHome){ //13 京东 16:腾讯公益 8:转发文章

        NSLog(@"HKWeChat MMWebViewController(进入文章详情页) 当前要处于返回前一个页面");


        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:10];

            dispatch_async(dispatch_get_main_queue(), ^{
                //判断是不是回首页了

                if(m_current_taskType == 13 || m_current_taskType == 8){

                    NSLog(@"HKWechat 表示当前已经回到首页，进行下一条任务");

                    m_isBackHome = NO;

                    m_depth_wechat = 0;

                }else if(m_current_taskType == 16){

                    NSLog(@"HKWechat 腾讯公益，得继续返回才能到首页");

                    //得继续返回才能到首页
                    m_isBackHome = YES;
                }

                //返回
                [self OnReturn];

            });
            
        });
    }else{
        NSLog(@"HKWeChat MMWebViewController(进入文章详情页)");
    }


    if(m_current_taskType != 8 || m_step_forward != 2 || m_isBackHome){
        return;
    }



    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:15];

        dispatch_async(dispatch_get_main_queue(), ^{

            m_step_forward = 3;


            //点击 ... 按钮
            [self onOperate:[self getLeftBarButton]];
        });

    });
}
- (void)goToURL:(id)arg1{
    %orig;

    NSLog(@"HKWeChat MMWebViewController(goToURL) %@",arg1);

}
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSLog(@"HKWeChat MMWebViewController(浏览详情页) webViewDidFinishLoad");

}

- (void)webViewDidStartLoad:(id)arg1{
    %orig;

    NSLog(@"HKWeChat MMWebViewController(浏览详情页) webViewDidStartLoad");

    //    [self stop];
    
}

%end


//京东购物浏览器
%hook YYUIWebView
- (void)webView:(id)arg1 didFailLoadWithError:(id)arg2{
    %orig;

//    NSLog(@"HKWeChat YYUIWebView(京东购物浏览器) didFailLoadWithError");

}

NSInteger m_web_load_count = 0;

- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    return;

    //得到关键词
    NSMutableDictionary * equipment =  openFile(@"/var/root/search/equipment.json");

    //得到itemID
    NSMutableDictionary *config = openFile(@"/var/root/search/config.json");

    //判断是否是微信刷单
    m_web_load_count = m_web_load_count+1;

    NSLog(@"HKWeChat YYUIWebView(京东购物浏览器) webViewDidFinishLoad %@",arg1);

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"YYUIWebView(京东  购物浏览器) document.location.href -------------%@ ",currentURl);
//    if(m_web_load_count == 2){

        m_web_load_count = 0;
        if([currentURl rangeOfString:@"/wqs.jd.com/portal/wx/"].location != NSNotFound){
            //http://wqs.jd.com/portal/wx/portal_indexV4.shtml?PTAG=17007.13.1&ptype=1
            NSLog(@"HKWeChat 当前是京东首页");

            dispatch_group_async(group, queue, ^{

                [NSThread sleepForTimeInterval:10];

                dispatch_async(dispatch_get_main_queue(), ^{

                    //注入js
                    NSString *script = [NSString stringWithFormat:@"window.location.href = \"http://wqsou.jd.com/search/searchn?key=%@&sf=14&as=0&projectId=-10\" ",[equipment objectForKey:@"keywords"]];

                    [self stringByEvaluatingJavaScriptFromString:script];

                });
                
            });

        }else if([currentURl rangeOfString:@"/wqs.jd.com/my/index"].location != NSNotFound){
            //http://wqs.jd.com/my/indexv2.shtml?PTAG=39452.20.4&shownav=1
            NSLog(@"HKWeChat 当前是京东个人中心页面");

            //注入js
//            NSString *script = [NSString stringWithFormat:@"alert(\"京东个人中心页面\");"];

            NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/wx_jd_personal_center.js?t='+Date.parse(new Date());document.body.appendChild(script);"];

            [self stringByEvaluatingJavaScriptFromString:script];


        }else if([currentURl rangeOfString:@"/wqsou.jd.com/search/searchn"].location != NSNotFound){
            //http://wqsou.jd.com/search/searchn?key=%E8%A1%A3%E6%9C%8D&sf=14&as=0&PTAG=39452.1.2&projectId=-10
            //http://wqsou.jd.com/search/searchn?key=%E8%A1%A3%E6%9C%8D&filt_type=dredisprice,L399M300;&area_ids=19,1655,39462&as=1&version=regular&qp_disable=no&sx=1&ev=exprice_300-399
            NSLog(@"HKWeChat 当前是京东搜索页");
            
            dispatch_group_async(group, queue, ^{

                [NSThread sleepForTimeInterval:8];

                dispatch_async(dispatch_get_main_queue(), ^{

                    NSLog(@"HKWeChat 进入注入搜索js 文件");
                    //注入js
                    NSString *script = [NSString stringWithFormat:@"var myScript = document.getElementById(\"wx_jd_search\");if (!myScript) {var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/wx_jd_search.js?t='+Date.parse(new Date());script.id = \"wx_jd_search\";var skuId = document.createAttribute(\"skuId\");skuId.value = \"%@\";script.setAttributeNode(skuId);document.body.appendChild(script);}",[config objectForKey:@"autoOrderProps"]];

                    [self stringByEvaluatingJavaScriptFromString:script];

                });
                
            });

        }else if([currentURl rangeOfString:@"/wqitem.jd.com/item"].location != NSNotFound){
            //http://wqitem.jd.com/item/view?sku=10617799062&price=458.00&fs=1&pos=1#main

            NSLog(@"HKWeChat 当前是商品详情页");

            //注入js
//            NSString *script = [NSString stringWithFormat:@"alert(\"当前是商品详情页\");"];
            NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/wx_jd_item.js?t='+Date.parse(new Date());script.skuid = \"%@\";script.id = \"wx_jd_item\";document.body.appendChild(script);",@"111111"];

            [self stringByEvaluatingJavaScriptFromString:script];

        }else if([currentURl rangeOfString:@"/wqs.jd.com/order/wq.confirm.shtml"].location != NSNotFound){
            //http://wqs.jd.com/order/wq.confirm.shtml?bid=&wdref=http%3A%2F%2Fwq.jd.com%2Fitem%2Fview%3Fsku%3D10617799094&scene=jd&isCanEdit=1&EncryptInfo=&Token=&commlist=10617799094,,1,10617799094,1,0,0&locationid=1-72-4139&type=0&lg=0&supm=0

            NSLog(@"HKWeChat 确认订单页面");

            //注入js
//            NSString *script = [NSString stringWithFormat:@"alert(\"当前是确认订单页面\");"];
            NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/wx_jd_order_confirm.js?t='+Date.parse(new Date());script.skuid = \"%@\";script.id = \"wx_jd_order_confirm\";document.body.appendChild(script);",@"111111"];

            [self stringByEvaluatingJavaScriptFromString:script];


        }else if([currentURl rangeOfString:@"/wqs.jd.com/order/n_detail"].location != NSNotFound){
            //http://wqs.jd.com/order/n_detail_v2.shtml?deal_id=22839869024&bid=&backurl=&new=1&jddeal=1
            NSLog(@"HKWeChat 订单详情页面");

            //注入js
            NSString *script = [NSString stringWithFormat:@"alert(\"订单详情页面\");"];

            [self stringByEvaluatingJavaScriptFromString:script];
        }
//    }

}

- (void)webViewDidStartLoad:(id)arg1{
    %orig;
//    NSLog(@"HKWeChat YYUIWebView(京东购物浏览器) webViewDidStartLoad %@",arg1);

}

%end


//点击转发朋友圈页面
%hook  WCForwardViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"HKWeChat WCForwardViewController(点击转发朋友圈页面)");

    if(m_step_forward != 4 || m_current_taskType != 4){
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            //TODO: 从服务器传过来 设置文字
            //            MMGrowTextView *msgText =  MSHookIvar<MMGrowTextView *>(self, "_textView");
            //            [msgText setText:@"msgText"];
            //            [NSThread sleepForTimeInterval:2];
            //点击发送
            m_step_forward = -1;

            m_tab_wechat = 0;
            m_depth_wechat = 0;


            [self OnDone];
            
            NSLog(@"HKWeChat 告诉服务器和脚本 文章转发成功");

            //点击返回
//            [self OnReturn];
            
            //告诉服务器
            hookSuccessTask();
            //返回首页

            m_isBackHome = YES;


        });

    });
}

%end

NSInteger m_current_audio_count =  0;

%hook MMNewUploadVoiceMgr

- (_Bool)loadDataFromAudioFile:(id)arg1 {

    BOOL ret = %orig;

    if(m_current_audio_count != 1){
        return ret;
    }

    //判断语音文件是否存在
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/root/hkwx/test.amr"]){

        m_current_audio_count = 0;

        if (audioSender == nil) {
            audioSender = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AudioSender")];
        }
        NSLog(@"HKWECHAT loadDataFromAudioFile: arg1: %@", arg1);
        id path = [audioSender getAudioFileName:[arg1 m_nsToUsrName] LocalID:[arg1 m_uiLocalID]];
        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        AudioFile *file = [[NSClassFromString(@"AudioFile") alloc] init];

        [file open:path];

        NSData *data = [[NSData alloc] initWithContentsOfFile:@"/var/root/hkwx/test.amr"];

        [file writeBytes:0 len:data.length buffer:(void *)[data bytes]];
        [arg1 setM_uiOffset:0];
        [arg1 setM_uiLen:data.length];
        [arg1 setM_uiEndFlag:1];
        [arg1 setM_uiVoiceLen:0];
        [arg1 setM_dtVoice:[data retain]];
        NSLog(@"HKWECHAT audioFile path: %@", path);
    }else{
        NSLog(@"HKWECHAT 当前语音文件不存在，或者下载失败!");
    }

    return YES;
}

%end

//聊天页面
%hook BaseMsgContentViewController

- (void)StopRecording{
    %orig;

    m_current_audio_count = 1;

    NSLog(@"HKWECHAT 结束录音");
}
- (void)StartRecording{
    %orig;

    m_current_audio_count = 0;

    NSLog(@"HKWECHAT 开始录音");
}

//%new
//-(void)chatWithFriend{
//
//    if( m_step_chat != 3){
//        NSLog(@"HKWeChat 当前没有处于正常聊天状态 %d",m_step_chat);
//        return;
//    }
//
//    NSLog(@"HKWeChat beginFriendChat this is begin chat with friend m_step_chat:%d",m_step_chat);
//
//    dispatch_group_async(group, queue, ^{
//
//        //随机时间3-8秒
//        int rand = (arc4random() % 5) + 3;
//
//        [NSThread sleepForTimeInterval:rand];
//
//        NSInteger iCount = 0;
//
//        getChatMsgData();
//
//        while([m_chatMsgData isEqualToString:@""] && m_isChatWithFriend != -1){
//
//            [NSThread sleepForTimeInterval:2];
//
//            //等待数据回来
//            NSLog(@"HKWX this is waite chat msg result %d",iCount);
//
//            iCount = iCount + 1;
//        }
//
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(m_step_chat == 3 && m_isChatWithFriend != -1){
//
//                NSLog(@"HKWX 可以发信息了～～～～%@",m_chatMsgData);
//                NSMutableDictionary *dicChat = strngToDictionary(m_chatMsgData);
//
//                //                    [[self toolView] TextViewDidEnter:[dicChat objectForKey:@"content"]];
//                if(m_current_taskType == 15 || m_current_taskType == 19){
//
//                    //点击返回
//                    [self onBackButtonClicked:[self getLeftBarButton]];
//
//
//                }else{
//
//                }
//
//            }
//            
//        });
//        
//    });
//
//}

%new

- (void)downMyVoice {

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            //从配置文件中读出数据
            NSMutableDictionary *amrFile = loadAmrFile();

            NSLog(@"HKWeChat 开始下载图片文件");

            //    NSURL* url = [NSURL URLWithString:@"http://7sbkou.com2.z0.glb.clouddn.com/voice_ee22f132aa2c4e2ca0f56e4c8564e3e1.amr"];
            NSURL* url = [NSURL URLWithString:[amrFile objectForKey:@"urlArm"]];

            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                //下载完毕
                [data writeToFile:@"/var/root/hkwx/test.amr" atomically:YES];

            }];

        });
        
    });

}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat BaseMsgContentViewController(viewDidAppear 聊天页面) ");

    m_current_audio_count = 0;

    //判断是否要下载图片
    NSMutableDictionary *amrFile = loadAmrFile();

    NSLog(@"HKWeChat 下载图片的配置文件为:%@",amrFile);

    if([[amrFile objectForKey:@"urlArm"] isEqualToString:@""] || [amrFile objectForKey:@"urlArm"] == (id)[NSNull null]){
        NSLog(@"HKWeChat 当前不需要下载语音文件");
    }else{
        [self downMyVoice];
    }

    if(m_current_taskType == 19 || m_current_taskType == 15){
        //表示当前进入公众号的聊天页面

        m_depth_wechat = 0;

        //返回
        [self onBackButtonClicked:[self getLeftBarButton]];
    }

    if(m_tab_wechat != 0 && m_depth_wechat != 1){
        return;
    }

}


- (void)addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3{
    %orig;

    EnterpriseMsgDBItem *enterpriseMsgDBItem = (EnterpriseMsgDBItem *)arg1;

    NSLog(@"HKWeChat m_uiType:%d m_nsFromUsr:%@ m_nsToUsr:%@ m_nsMessage:%@",[enterpriseMsgDBItem m_uiType],[enterpriseMsgDBItem m_nsFromUsr],[enterpriseMsgDBItem m_nsToUsr],[enterpriseMsgDBItem m_nsMessage]);


    m_nsFromUsr = [enterpriseMsgDBItem m_nsFromUsr];

    if(m_isChatWithFriend == 1){

        if([m_nsUsrName isEqualToString:m_nsFromUsr]){
            NSLog(@"HKWeChat addMessageNode 表示最后一条是对方发的  m_nsUsrName:%@ m_nsFromUsr:%@ msg:%@",m_nsUsrName,m_nsFromUsr,m_chatRequestData);

            //保存信息到脚本
            write2File(@"/var/root/hkwx/chatContent.txt", m_chatRequestData);

        }else{
            NSLog(@"HKWeChat addMessageNode 表示最后一条是自己发的 m_nsUsrName:%@ m_nsFromUsr:%@",m_nsUsrName,m_nsFromUsr);
        }
    }

}


- (void)didFinishedLoading:(id)arg1{
    %orig;

    NSLog(@"HKWeChat didFinishedLoading");


    m_step_chat = 3;

    MMTableView *tableView =  MSHookIvar<MMTableView *>(self, "m_tableView");

    int rows = [self tableView:tableView numberOfRowsInSection:0];

    NSLog(@"HKWeChat didFinishedLoading %d",rows);

    //得到最后一句话
    MultiSelectTableViewCell *tableViewCell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(rows - 1) inSection:0]];
    id messageNodeView = [[tableViewCell subviews][0] subviews][0];

    if([[NSString stringWithUTF8String:object_getClassName(messageNodeView)] isEqualToString:@"TextMessageNodeView"]){

        TextMessageNodeView *textMessageNodeView = (TextMessageNodeView *)messageNodeView;

        CBaseContact *baseContact = MSHookIvar<CBaseContact *>(textMessageNodeView, "m_oChatContact");

        NSLog(@"HKWeChat 当前的唯一ID(m_nsUsrName):%@ 微信号为(m_nsAliasName):%@ 昵称(m_nsNickName):%@ 发表的内容:%@",[baseContact m_nsUsrName],[baseContact m_nsAliasName],[baseContact m_nsNickName],[textMessageNodeView titleText]);

        m_nsUsrName = [baseContact m_nsUsrName];

        m_chatRequestData = [textMessageNodeView titleText];

        m_isChatWithFriend = 1;
    }


}


//点击返回
- (void)onBackButtonClicked:(id)arg1{

    %orig;

//    if(m_current_taskType != 21){
//        m_step_chat = -1;
//        m_isChatWithFriend = -1;
//        m_tab_wechat = 0;
//        m_depth_wechat = 0;
//
//        hookSuccessTask();
//    }

}

%end

%hook  MessageSysNodeView
- (void)updateSubviews{
    %orig;

    NSLog(@"HKWeChat MessageSysNodeView-------------");
}
%end

//分享名片view
%hook  ShareCardMessageNodeView
//- (id)getMoreMainInfomationAccessibilityDescription;
- (void)onDisappear{
    %orig;

     NSLog(@"onDisappear ShareCardMessageNodeView %@",[self getMoreMainInfomationAccessibilityDescription]);
}
- (void)updateStatus:(id)arg1{
    %orig;

     NSLog(@"updateStatus ShareCardMessageNodeView %@ arg1:%@",[self getMoreMainInfomationAccessibilityDescription],arg1);
}
- (void)layoutSubviewsInternal{
    %orig;

    NSLog(@"layoutSubviewsInternal ShareCardMessageNodeView %@",[self getMoreMainInfomationAccessibilityDescription]);

    //存文件
//    write2File(@"/var/root/hkwx/shareCard.txt", @"1");
}
%end

//获取微信聊天的群ID
%hook ChatRoomInfoViewController

%new
- (void)sysChatRoomAction{
    NSLog(@"HKWeChat(当前点击了同步按钮) %@",[[self m_chatRoomContact] m_nsUsrName]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray *arrMemberList =  MSHookIvar<NSArray *>(self, "m_arrMemberList");
            NSString *oneJson = @"";
            NSString *dataJson = @"";

            for(CContact *ccontact in arrMemberList){

                NSString *nicknameTemp = [ccontact m_nsNickName];
//                NSString *nickname = URLEncodedString(nicknameTemp);
                NSString *nickname = @"";
                if([nicknameTemp rangeOfString:@"\""].location != NSNotFound){

                    nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];

                }else if([nicknameTemp rangeOfString:@"&"].location != NSNotFound){
                    nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"&" withString:@""];

                }else{
                    nickname = [NSString stringWithFormat:@"%@",nicknameTemp];
                }

                oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%d\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,@"",[ccontact m_nsCountry],[ccontact m_nsProvince],[ccontact m_nsCity],[ccontact m_uiSex]];

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
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(220, 60, 350, 30);
    [btn setTitle:@"同步群聊" forState:UIControlStateNormal];
    [btn setTitle:@"同步群聊" forState:UIControlStateHighlighted];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn addTarget:self action:@selector(sysChatRoomAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    NSLog(@"%@",[[self m_chatRoomContact] m_nsUsrName]);

}

%end

///////////////////////微信页面结束///////////////////////



///////////////////////通讯录开始///////////////////////
%hook ContactsViewController

%new
- (void)executeContactsViewController{

    NSLog(@"HKWeChat executeContactsViewController(通讯录开始)");

    //异步延时随机选择朋友聊天
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

            //判断是不是找人聊天
            if(m_current_taskType == 9 && m_step_chat == 1){

                m_step_chat = 2;

                int row  = 0;
                int column= 2;

                //得到有多少 Sections
                int sections = [self numberOfSectionsInTableView:tableView];

                NSLog(@"HKWeChat section count%d",sections);

                while(true){
                    //、首先随机secetion
                    column = (arc4random() % sections);
                    if(column == 0 || column == 1){
                        continue;
                    }

                    //得到随机的 selections 有多少个row
                    int rows = [self tableView:tableView numberOfRowsInSection:column];
                    //随机出第几列
                    row = (arc4random() % rows);

                    NSLog(@"HKWeChat 随机产生的的 总数rows:%d 随机row:%d  总数sections:%d 随机column:%d",rows,row,sections,column);

                    //得到随机的数据
                    NewContactsItemCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];

                    ContactsItemView *contactsItemView = MSHookIvar<ContactsItemView *>(cell, "m_contactsItemView");

                    CContact *ccontact = [contactsItemView m_contact];

                    NSLog(@"HKWeChat 随机产生的的的row:%d column:%d m_nsNickName:%@",row,column,[ccontact m_nsNickName]);

                    if(![[ccontact m_nsNickName] isEqualToString:@"微信团队"]
                       && ![[ccontact m_nsNickName] isEqualToString:@"腾讯新闻"]
                       && ![[ccontact m_nsNickName] isEqualToString:@"订阅号"]
                       && ![[ccontact m_nsNickName] isEqualToString:@"服务通知"]
                       && ![[ccontact m_nsNickName] isEqualToString:@"支付通知"]
                       && ![[ccontact m_nsNickName] isEqualToString:@"公众号"]
                       ){

                        break;
                    }

                }

                //滚动到当前位置
                //                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:column] atScrollPosition:UITableViewScrollPositionTop animated:YES];

                [NSThread sleepForTimeInterval:2];

                //TODO:参数随机数
                [self tableView:tableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow:row inSection:column]];


            }else if(m_current_taskType == 21 && m_step_chat == 1){
                NSLog(@"HKWeChat 到通讯录页面找到指定人聊天");

                //改为脚本聊天
                return;

                //指定人聊天
                m_step_chat = 2;

//                NSMutableDictionary *dic = strngToDictionary(m_taskData);

                int selectSections = -1;
                int selectRows = -1;

                MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

                int sections = [self numberOfSectionsInTableView:tableView];

                for(int column=1; column<sections; column++){

                    int rows = [self tableView:tableView numberOfRowsInSection:column];
                    for(int row = 0; row < rows; row++){
                        NewContactsItemCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];

                        ContactsItemView *contactsItemView = MSHookIvar<ContactsItemView *>(cell, "m_contactsItemView");

                        CContact *ccontact = [contactsItemView m_contact];

//                        if([[ccontact m_nsUsrName] isEqualToString:[dic objectForKey:@"weixinId"]]){
                        if([[ccontact m_nsUsrName] isEqualToString:@"wxid_x4asq8c7bov521"]){

                            selectSections = column;
                            selectRows = row;
                            break;
                        }
                    }
                }

                if(selectSections == -1 || selectRows == -1){
                    //没有找到聊天的人
                    NSLog(@"HKWeChat 当前通讯录里，没有要找的人 %@",[m_taskDataDic objectForKey:@"usrName"]);

                    //TODO:通知服务器
                    hookSuccessTask();

                    //返回首页,执行下一个任务

                }else{

                    m_step_chat = 2;

                    //点击进入聊天
                    [self tableView:tableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow:selectRows inSection:selectSections]];
                }

            }else if(m_current_taskType == 17 || m_current_taskType == 24){

                //进入新的朋友
//                [self tableView:tableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];

            }else if(m_current_taskType == 20){

                //同步通讯录信息
                NSString *dataJson = @"";
                NSString *oneJson = @"";
                int currentTotalCount = 0;

                MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

                //得到有多少 Sections
                int sections = [self numberOfSectionsInTableView:tableView];
                NSLog(@"HKWeChat  ----当前有多少个 %d",sections);

                for(int column = 0; column<sections; column++){

                    int rows = [self tableView:tableView numberOfRowsInSection:column];

                    NSLog(@"HKWeChat -----当前是第几个 sections:%d 当前sections有多少个:%d",column,rows);

                    for(int row = 0; row < rows; row++){

                        currentTotalCount = currentTotalCount + 1;
                        if(currentTotalCount%1000 == 0){
                            //进行发送给服务端
                            dataJson = [NSString stringWithFormat:@"[%@]",dataJson];

                            NSLog(@"HKWeChat 当前传给服务器的内容:%@",dataJson);

                            syncContactTask(dataJson);

                            dataJson = @"";
                        }

                        NSLog(@"this is currentTotalCount:%d",currentTotalCount);

                        NewContactsItemCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];

                        ContactsItemView *contactsItemView = MSHookIvar<ContactsItemView *>(cell, "m_contactsItemView");

                        CContact *ccontact = [contactsItemView m_contact];
                        NSString *phoneNumber = @"";

                        for (PhoneItemInfo* phoneItem in [ccontact m_arrPhoneItem]) {
                            phoneNumber = [NSString stringWithFormat:@"%@,%@",[phoneItem phoneNum],phoneNumber];
                        }


                        NSString *nickname = conversionSpecialCharacter([ccontact m_nsNickName]);
                        NSString *nsRemark = conversionSpecialCharacter([ccontact m_nsRemark]);
                        NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                        NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                        NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

                        
                        //            NSLog(@"HKWX 用户名:%@ 微信号:%@ 昵称:%@ 电话号:%@ 地区:%@-%@-%@ 性别:%d 备注:%@",[ccontact m_nsUsrName],[ccontact m_nsAliasName],[ccontact m_nsNickName],phoneNumber,
                        //                  [ccontact m_nsCountry],[ccontact m_nsProvince],[ccontact m_nsCity],[ccontact m_uiSex],m_nsRemark);

                        oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%d\",\"nsRemark\":\"%@\",\"nsEncodeUserName\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,phoneNumber,nsCountry,nsProvince,nsCity,[ccontact m_uiSex],nsRemark,[ccontact m_nsEncodeUserName]];
                        
                        //                        NSLog(@"HKWX %@",oneJson);
                        
                        if([dataJson isEqualToString:@""]){
                            dataJson = [NSString stringWithFormat:@"%@",oneJson];
                        }else{
                            dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                        }
                    }
                    
                }
                dataJson = [NSString stringWithFormat:@"[%@]",dataJson];
                
                NSLog(@"HKWeChat 当前传给服务器的内容:%@",dataJson);

                //通知服务器
                syncContactTask(dataJson);

                //通知脚本当前通讯录同步完毕
                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

            }
            
        });
        
    });

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

     NSLog(@"HKWeChat ContactsViewController(进入通讯录)");

//    if(m_tab_wechat != 1 || m_depth_wechat != 0){
//        return;
//    }

    //从配置文件中是否要同步通讯录信息
    NSString *strData = readFileData(@"/var/root/hkwx/syncContact.txt");

    if([strData isEqualToString:@"1"]){
        m_current_taskType = 20;

        NSDate *date=[NSDate date];
        NSDateFormatter *format1=[[NSDateFormatter alloc] init];
        [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr;
        dateStr=[format1 stringFromDate:date];
        NSLog(@"%@",dateStr);

        write2File(@"/var/root/hkwx/syncTime.txt",dateStr);

        [self executeContactsViewController];
    }else if(m_current_taskType == 52){

        //删除好友
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWeChat 当前执行通讯录 删除好友");

                [self deleteFriendList];

            });
            
        });
    }else if(m_current_taskType == 48){

        //进入好友详细信息页面
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWeChat 进入好友详细信息页面");
                //从配置文件中读取信息
                NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_LIKES_LIST];

                NSMutableArray *members = config[@"members"];
                if(config[@"members"]){

                    m_likes_count = [config[@"count"] intValue];

                    if(m_likes_pos < [members count]){
                        //通过uuid 得到好友的相关信息
                        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
                        CContact *ccontact = [mgr getContactByName:members[m_likes_pos]];

                        [self showContactInfoView:ccontact];

                    }else{
                        //告诉脚本所有好友点赞完毕
                        NSLog(@"HKWeChat 告诉脚本所有好友点赞完毕或者数据为空:%@",config);
                    }
                }
            });
            
        });

    }//end else if
}


- (void)showContactInfoView:(id)arg1{
    %orig;

    NSLog(@"HKWeChat showContactInfoView(进入当前信息页面):%@",arg1);
}


%end


//新的朋友
%hook SayHelloViewController

%new
-(void)clearAllRecommended{


    NSLog(@"HKWeChat clearAllRecommended== ");


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self OnClear:@"1"];

            [self OnSayHelloDataChange];
        });
        
    });
}

- (void)viewDidLoad {
    %orig;

    NSLog(@"HKWeChat 新的朋友 进行添加 ");

    //从配置文件中是否要同步通讯录信息
//    NSString *strData = readFileData(@"/var/root/hkwx/deleteRecommend.txt");

//    if([strData isEqualToString:@"1"]){
//        [self clearAllRecommended];
//    }

    NSMutableDictionary *config = loadTaskId();

    if([[config objectForKey:@"hookEnable"] intValue] != 1){

        return;
    }



    return;

     //用脚本操作同意
    if(m_current_taskType == 17){
        MMTableView *table = MSHookIvar<MMTableView *>(self, "m_tableView");
        if (table) {
            int helloNum = [self tableView:table numberOfRowsInSection:0];
            for (int i=0; i < helloNum; i++) {
                ContactsItemCell *cell = [self tableView:table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                //            [abfvc verifyContactWithOpCode:[[[cell subviews][0] subviews][0] m_contact] opcode:1];

                [self onContactsItemViewRightButtonClick:[[cell subviews][0] subviews][0]];
            }
        }

        m_depth_wechat = 0;
        m_tab_wechat = 1;

        hookSuccessTask();
        
        //返回首页,返回一次(到通讯录页面)
        [self OnReturn];
    }else if(m_current_taskType == 24){

//        [self addMobileFriend];
    }

}

- (void)OnSayHelloDataVerifyContactOK:(id)arg1{
    NSLog(@"HKWeChat OnSayHelloDataVerifyContactOK: %@",arg1);
    
    %orig;
}

%end




//微信详细信息
%hook  WeixinContactInfoAssist

- (void)initTableView{
    %orig;;

    NSLog(@"HKWeChat this is enter WeixinContactInfoAssist(微信详细信息),");

    if(m_current_taskType == 48){
        //异步加载数据
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:8];

            dispatch_async(dispatch_get_main_queue(), ^{

                //详细资料 进行个人相册点赞
                NSArray *arrPhotoDatas = MSHookIvar<NSArray *>(self, "m_arrayAlbum");

                NSLog(@"arrPhotoDatas :%@",arrPhotoDatas);

                int nLikesCount = 0;  //记录当前点赞的个数

                for(int i=0; i<[arrPhotoDatas count]; i++){

                    WCDataItem *item = arrPhotoDatas[i];
                    NSLog(@"HKWeChat nickname:%@ username:%@ cell: %@", [item nickname],[item username],item);

                    WCLikeButton *timeLineLikeBtn = [[NSClassFromString(@"WCLikeButton") alloc] init];
                    if (![item likeFlag]) {
                        [timeLineLikeBtn setM_item:item];
                        [timeLineLikeBtn onLikeFriend];
                        NSLog(@"HKWeChat like pepole: %@, %@", [item nickname], [item username]);
                        nLikesCount = nLikesCount + 1;

                    }else{
                        //取消点赞
                        //                    [timeLineLikeBtn setM_item:item];
                        //                    [timeLineLikeBtn onLikeFriend];
                    }

                    if(nLikesCount == m_likes_count){
                        break;
                    }
                }
                
                m_likes_pos++;
                
                //点赞完毕 返回上一页
                if(m_mMUINavigationController){
                    [m_mMUINavigationController popViewControllerAnimated:YES];
                }
                
            });
            
        });

    }//end if 48


    //改为脚本聊天
    return;

    if(!(m_current_taskType == 9 || m_current_taskType == 21)){
        return;
    }

    //异步延时点击进入聊天
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_step_chat == 2){
                NSLog(@"HKWeChat this is click  send msg button(点击了发消息按钮)");

                m_depth_wechat = 2;
                m_tab_wechat = 0;

                m_step_chat = 3;

                [self onStartChat:@"1"];
            }
            
        });
        
    });
    
}

%end

%hook AddressBookFriendViewController

%new
- (void)highlightMyCells{
    MMTableView *arg1 =  MSHookIvar<MMTableView *>(self, "m_tableView");

    NSArray *cellList = [[arg1 subviews][1] subviews];

    for(int i = 0; i < [cellList count]; i++){
        NSArray *views = [[cellList[i] subviews][1] subviews];

        id civ = nil;
        if ([views count] > 1){

            civ = views[[views count] - 1];

        }else{

            civ =views[0];
        }

//        NSLog(@"HKWeChat contactsItemView: %@",civ);

        int uiSex = (int)[[civ m_data] m_uiSex];

        if(uiSex == 1){
            [[cellList[i] contentView] setBackgroundColor:[UIColor redColor]];
        }else if(uiSex == 2){
            [[cellList[i] contentView] setBackgroundColor:[UIColor blueColor]];
        }else{
            [[cellList[i] contentView] setBackgroundColor:[UIColor whiteColor]];
        }

    }
}

%new
-(void)synPhoneAction{

    NSLog(@"HKWeChat 同步通讯页面信息");
    //同步通讯
    NSMutableDictionary *dicFriendList =  MSHookIvar<NSMutableDictionary *>(self, "m_dicFriendList");
    NSArray *friendList = [dicFriendList objectForKey:@"#"];
    NSString *oneJson = @"";
    NSString *dataJson = @"";

    for(AddressBookFriend *bookFriend in friendList){

        NSString *nicknameTemp = [bookFriend m_nickname];
//        NSString *nickname = URLEncodedString(nicknameTemp);
        NSString *nickname = @"";
        if([nicknameTemp rangeOfString:@"\""].location != NSNotFound){

            nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];

        }else if([nicknameTemp rangeOfString:@"&"].location != NSNotFound){
            nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"&" withString:@""];

        }else{
            nickname = [NSString stringWithFormat:@"%@",nicknameTemp];
        }

        oneJson = [NSString stringWithFormat:@"{\"phone\":\"%@\",\"bWaitForVerify\":\"%d\",\"isInMyContactList\":\"%d\",\"uiSex\":\"%d\",\"nickName\":\"%@\"}",[[bookFriend m_addressBook] m_phone],[bookFriend bWaitForVerify],[bookFriend m_isInMyContactList],[bookFriend m_uiSex],nickname];

        //                        NSLog(@"HKWX %@",oneJson);

        if([dataJson isEqualToString:@""]){
            dataJson = [NSString stringWithFormat:@"%@",oneJson];
        }else{
            dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
        }
    }

    NSLog(@"%@",dataJson);

    syncPhoneMember(dataJson);
}

- (void)viewDidLoad{
    %orig;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(220, 60, 350, 30);
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setTitle:@"" forState:UIControlStateHighlighted];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn addTarget:self action:@selector(synPhoneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}

- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2{

    double res = %orig;

    [self highlightMyCells];

    return res;
}

- (void)makeAddressBookFriendCell:(id)arg1 row:(unsigned long long)arg2 section:(unsigned long long)arg3 tableView:(id)arg4{
    %orig;

    [arg1 setSelectionStyle:nil];
}

%end

//通讯录群聊
%hook ChatRoomListViewController

- (void)makeCell:(id)arg1 contact:(id)arg2{
    %orig;

    NSMutableDictionary *amrFile = loadAmrFile();


    NSArray *views = [[arg1 subviews][0] subviews];

    id civ = nil;
    if ([views count] > 1){

        civ = views[[views count] - 1];

    }else{

        civ =views[0];
    }

    NSString *nsUsrName = [[civ m_contact] m_nsUsrName];
    NSLog(@"HKWeChat nsUsrName:%@ contactsItemView: %@",nsUsrName,civ);

    //从配置文件中读取是否那个群号
    if([nsUsrName isEqualToString:[amrFile objectForKey:@"chatWeixinUuid"]]){
        [civ setBackgroundColor:[UIColor redColor]];
        [[arg1 contentView] setBackgroundColor:[UIColor redColor]];
    }else{
        [civ setBackgroundColor:[UIColor whiteColor]];
        [[arg1 contentView] setBackgroundColor:[UIColor redColor]];
    }

    [arg1 setSelectionStyle:nil];
}

%end

///////////////////////通讯录结束///////////////////////


///////////////////////发现开始///////////////////////
%hook FindFriendEntryViewController

%new
- (void)executeFindFriendEntryViewController{

    //异步延时进入朋友圈
    dispatch_group_async(group, queue, ^{

        //等待数据返回
        while(true){

            NSLog(@"HKWeChat 发现开始等待大数据的返回---");

            if(m_isRequestResult != 1){
                break;
            }

            [NSThread sleepForTimeInterval:5];
        }

        [NSThread sleepForTimeInterval:10];

        //操作数据
        operationData();


        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_current_taskType == 4 && m_step_friends == 1){


                NSLog(@"HKWeChat 点击进入朋友圈页面");

                m_step_friends = 2;

                NSLog(@"HKWeChat 点击进入朋友圈页面 m_step_friends");

                //点击朋友圈
                [self openAlbum];

            }else if(m_current_taskType == 13 ){
                //点击购物
                MMTableView *tableView =  MSHookIvar<MMTableView *>(self, "m_tableView");

                m_step_friends = -1;
                m_depth_wechat = 1;
                m_tab_wechat = 2;

                NSLog(@"HKWX 点击进入点击购物");

                //写入文件
                write2File(@"/var/root/hkwx/operation.txt", @"1");

                [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];

                hookSuccessTask();

                m_isBackHome = YES;

            }else if(m_current_taskType == 14 || m_current_taskType == 22 || m_current_taskType == 23){
                //浏览朋友圈
                NSLog(@"HKWeChat 点击进入朋友圈页面");

                m_step_friends = 2;

                [self openAlbum];
            }
            
        });
        
    });
}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat FindFriendEntryViewController(发现开始页面) ");

    if(m_tab_wechat != 2 || m_depth_wechat != 0 || m_current_taskType != 4){
        return;
    }

    [self executeFindFriendEntryViewController];

}


%end

//朋友圈主页面
%hook WCTimeLineViewController

%new
- (void)delayedBackHome{ //延时执行返回
    NSLog(@"HKWeChat 调用延时返回");

    if(m_current_taskType != 4){
        return;
    }


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_mMUINavigationController){
                //                    id mbar = ;
                [m_mMUINavigationController popViewControllerAnimated:YES];

            }
        });

    });
}

%new
- (void)executeWCTimeLineViewController{

    m_depth_wechat = 1;

    NSLog(@"HKWeChat WCTimeLineViewController(executeWCTimeLineViewController)");

    //异步延时进入朋友圈
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            //判断当前是否是发朋友圈
            if(m_current_taskType == 4 && m_step_friends == 2){

                m_step_friends = 3;

                NSLog(@"HKWeChat 进入朋友圈 发朋友圈");

                //TODO:从文件中读取当前是发表文字，还是图片
                if([[m_taskDataDic objectForKey:@"isImgs"] intValue] == 0){

                    NSLog(@"HKWeChat 点击进入文字评论");
                    //文字
                    [self openWriteTextViewController];

                }else if([[m_taskDataDic objectForKey:@"isImgs"] intValue] == 1){

                    NSLog(@"HKWeChat enter 文字和图片 ");

                    //文字和图片
                    [self openCommitViewController:YES arrImage:nil];
                }
            }else if(m_current_taskType == 4 && m_step_friends == 6){

                NSLog(@"HKWeChat 当前是朋友圈点赞加评论功能");

                NSArray *contentText = [[m_taskDataDic objectForKey:@"friendAreaTxt"] componentsSeparatedByString:@"@@"]; //从字符A中分隔成2个元素的数组

                for(NSString* obj in contentText){
                    //朋友圈随机点赞
                    MMTableView *tableView = MSHookIvar<MMTableView *>(self, "m_tableView");
                    WCDataItem *inputDataItem = MSHookIvar<WCDataItem *>(self, "_inputDataItem");
                    int rowNum = [self numberOfSectionsInTableView:tableView];
                    NSLog(@"HKWeChat WCTimeLine didAppear: %d", rowNum);
                    int inSection = 0;  //默认是第一个

                    WCLikeButton *timeLineLikeBtn = [[NSClassFromString(@"WCLikeButton") alloc] init];
                    MMTableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:inSection]];

                    id timeLineCell = [[[cell subviews][0] subviews] valueForKey:@"@lastObject"];
                    //判断是不是button
                    if([timeLineCell isKindOfClass:[UIButton class]]){
                        NSLog(@"HKWeChat 第一个是UIButton-----");
                        inSection = 1;

                        cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:inSection]];
                        timeLineCell = [[[cell subviews][0] subviews] valueForKey:@"@lastObject"];

                    }

                    WCDataItem *item = [timeLineCell m_dataItem];
                    // 检测是否已经关注，可控制是否关注或取消关注
                    if([[m_taskDataDic objectForKey:@"needPraise"] intValue] == 1){
                        if (![item likeFlag]) {
                            [timeLineLikeBtn setM_item:item];
                            [timeLineLikeBtn onLikeFriend];
                            NSLog(@"HKWeChat like pepole: %@, %@", [item nickname], [item username]);
                        } else {
                            //                        [timeLineLikeBtn setM_item:item];
                            //                        [timeLineLikeBtn onLikeFriend];
                            //                        NSLog(@"HKWX unlike pepole: %@, %@", [item nickname], [item username]);
                        }

                        [NSThread sleepForTimeInterval:3];

                    }


                    Ivar xa = object_getInstanceVariable(self, "_inputDataItem", nil);
                    object_setIvar(self, xa, (id)item);

                    if([[m_taskDataDic objectForKey:@"needComment"] intValue] == 1){
                        
                        
                        [self didCommitText:obj];
                        
                    }
                    
                    inputDataItem = nil;
                    
                    [self refreshWholeView];
                    
                    m_step_friends = -1;
                }
                
                //通知服务器点赞成功
                hookSuccessTask();

                NSLog(@"HKWeChat 当前处于朋友圈页面点赞功能，要求返回首页");
                m_depth_wechat = 0;

                //返回首页
                m_tab_wechat = 2;
                m_depth_wechat = 0;


                //调用延时返回
                [self delayedBackHome];

//                if(m_mMUINavigationController){
//                    //                    id mbar = ;
//                    [m_mMUINavigationController popViewControllerAnimated:YES];
//
//                }

            }else if(m_current_taskType == 14){

                NSLog(@"HKWeChat 浏览朋友圈,向下滑动");

                //写入文件通知脚本,滚动
                write2File(@"/var/root/hkwx/operation.txt", @"1");

                //TODO:脚本通知服务端

                //浏览朋友圈需要后需要返回到首页
                NSLog(@"HKWeChat 浏览朋友圈需要后需要返回到首页");

                m_tab_wechat = 2;
                m_depth_wechat = 0;

                hookSuccessTask();

                //调用延时返回
                [self delayedBackHome];
//                if(m_mMUINavigationController){
//                     //                    id mbar = ;
//                    [m_mMUINavigationController popViewControllerAnimated:YES];
//                    
//                }

            }else if(m_current_taskType == 22){

                //朋友圈随机点赞
                MMTableView *tableView = MSHookIvar<MMTableView *>(self, "m_tableView");
                WCDataItem *inputDataItem = MSHookIvar<WCDataItem *>(self, "_inputDataItem");
                int rowNum = [self numberOfSectionsInTableView:tableView];
                NSLog(@"HKWeChat WCTimeLine didAppear: %d", rowNum);

                //、首先随机row
                int rowRand = (arc4random() % rowNum);

                for (int i=0; i < rowNum; i++){

                    WCLikeButton *timeLineLikeBtn = [[NSClassFromString(@"WCLikeButton") alloc] init];
                    MMTableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    //判断当前是不是WCTimeLineCellView
                    id timeLineCell = [[[cell subviews][0] subviews] valueForKey:@"@lastObject"];
                    if([timeLineCell isKindOfClass:[UIButton class]]){
                        rowRand = i+1;

                        NSLog(@"HKWeChat 当前第一个有人点赞");

                    }else{
                        if( i == rowRand){
                            WCDataItem *item = [timeLineCell m_dataItem];
                            NSLog(@"HKWeChat cell: %@ inputDataItem:%@", item,inputDataItem);
                            // 检测是否已经关注，可控制是否关注或取消关注
                            if (![item likeFlag]) {
                                [timeLineLikeBtn setM_item:item];
                                [timeLineLikeBtn onLikeFriend];
                                NSLog(@"HKWeChat like pepole: %@, %@", [item nickname], [item username]);
                            } else {
                                [timeLineLikeBtn setM_item:item];
                                [timeLineLikeBtn onLikeFriend];
                                NSLog(@"HKWeChat unlike pepole: %@, %@", [item nickname], [item username]);
                            }

                            Ivar xa = object_getInstanceVariable(self, "_inputDataItem", nil);
                            object_setIvar(self, xa, (id)item);
                            //            [self didCommitText:@""];
                            inputDataItem = nil;

                            break;
                        }
                    }
                }
                
                [self refreshWholeView];
                
                m_step_friends = -1;

                //通知服务器点赞成功
                hookSuccessTask();

                //返回首页
                NSLog(@"HKWeChat 点赞成功返回到首页");
                m_tab_wechat = 2;
                m_depth_wechat = 0;

                //滚动一下
                write2File(@"/var/root/hkwx/operation.txt", @"1");

                //调用延时返回
                [self delayedBackHome];

//                if(m_mMUINavigationController){
// //                    id mbar = ;
//                    [m_mMUINavigationController popViewControllerAnimated:YES];
//
//                }

            }else if(m_current_taskType == 23){

                //朋友圈随机评论
                MMTableView *tableView = MSHookIvar<MMTableView *>(self, "m_tableView");
                WCDataItem *inputDataItem = MSHookIvar<WCDataItem *>(self, "_inputDataItem");
                int rowNum = [self numberOfSectionsInTableView:tableView];
                NSLog(@"HKWeChat WCTimeLine didAppear: %d", rowNum);

                //、首先随机row
                int rowRand = (arc4random() % rowNum);

                for (int i=0; i < rowNum; i++){

                    MMTableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    //判断当前是不是WCTimeLineCellView
                    id timeLineCell = [[[cell subviews][0] subviews] valueForKey:@"@lastObject"];
                    if([timeLineCell isKindOfClass:[UIButton class]]){
                        rowRand = i+1;

                        NSLog(@"HKWeChat 当前第一个有人点赞");

                    }else{
                        if( i == rowRand){
                            WCDataItem *item = [timeLineCell m_dataItem];
                            NSLog(@"HKWeChat nickname:%@ username:%@ cell: %@ inputDataItem:%@", [item nickname],[item username],item,inputDataItem);


                            Ivar xa = object_getInstanceVariable(self, "_inputDataItem", nil);
                            object_setIvar(self, xa, (id)item);

                            [self didCommitText:[m_taskDataDic objectForKey:@"content"]];
                            inputDataItem = nil;

                            break;
                        }
                    }
                }
                
                [self refreshWholeView];
                
                m_step_friends = -1;
                
                //通知服务器评论成功
                hookSuccessTask();
                //返回首页

                m_tab_wechat = 2;
                m_depth_wechat = 0;

                //滚动一下
                write2File(@"/var/root/hkwx/operation.txt", @"1");

                //调用延时返回
                [self delayedBackHome];


//                if(m_mMUINavigationController){
//                     //                    id mbar = ;
//                    [m_mMUINavigationController popViewControllerAnimated:YES];
//                    
//                }
            }

        });
        
    });
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat 当前已经进入朋友圈主页 ");

    if(m_isBackHome){

        [m_mMUINavigationController popViewControllerAnimated:YES];
        m_isBackHome = NO;

        return;
    }

    if(m_tab_wechat != 2 || m_depth_wechat != 0){
        return;
    }

    [self executeWCTimeLineViewController];

}

%end


//发表文字的Controller
%hook WCInputController

//输入文字更新
- (void)TextViewDidEnter:(id)arg1{
    %orig;
    NSLog(@"HKWeChat TextViewDidEnter %@",arg1);
}

//文字和表情的转换
- (void)inputModeChangeButtonClicked{
    %orig;

    NSLog(@"HKWeChat TextViewDidEnter");

}

- (void)didSelectorEmoticon:(id)arg1{
    %orig;

    NSLog(@"HKWeChat didSelectorEmoticon %@",arg1);

}

- (id)init{
    id result = %orig;

    NSLog(@"HKWeChat WCInputController----init--");

    m_input_pic = 0; //设置开始输入

    //发朋友圈
    if(m_step_friends == 3 || m_step_friends == 5){
        //异步加载数据
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                [self TextViewDidEnter:[m_taskDataDic objectForKey:@"taskTextContent"]];

                //标示文字输入完毕
                m_step_friends = 4;
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

    if(!(m_step_friends == 3 || m_step_friends == 4)){

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

            m_step_friends = 5;
            m_input_pic = 1;

//            NSLog(@"select picture count %d m_step_friends:%d",[[self arrImages] count],m_step_friends);
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

    //TODO:
//    if([[m_taskDataDic objectForKey:@"needTags"] intValue] == 1){
//        //弹出谁都可以看
//        [self onPrivacyCellClicked];
//    }

    //异步循环检查是否可以发布
    dispatch_group_async(group, queue, ^{

        for(int i=0;i<10;i++){
            [NSThread sleepForTimeInterval:5];

            //TODO：判断服务器是否要选择 谁都可以看
//            if([[m_taskDataDic objectForKey:@"needTags"] intValue] == 1){
//
//                if(m_input_text == 1 && m_input_pic == 1 && m_privacy_cell_clicked == 1){
//                    break;
//                }else if(m_privacy_cell_clicked == 3){
//                    break;
//                }
//
//            }else{
//                if(m_input_text == 1 && m_input_pic == 1){
//                    break;
//                }
//            }

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

                //判断当前任务是否要执行点赞任务
                if([[m_taskDataDic objectForKey:@"needPraise"] intValue] == 1 || [[m_taskDataDic objectForKey:@"needComment"] intValue] == 1){

                    m_step_friends = 6;

                    NSLog(@"HKWeChat 发朋友圈完毕，现在执行点赞评论功能");


                }else{
                    //发朋友圈完毕
                    m_step_friends = -1;

                    //TODO 保存标示告诉脚本

                    //通知服务器
                    hookSuccessTask();
                    m_tab_wechat = 2;
                    m_depth_wechat = 0;
                    //返回首页
                    
                    NSLog(@"HKWeChat 当前页面返回一级就到首页");
                    
                    m_isBackHome = YES;
                    
                }
            }
        });
        
    });
}

%end


%hook WCGroupTagDemoViewController

- (void)viewDidLoad{
    %orig;

    NSLog(@"HKWeChat WCGroupTagDemoViewController(选择标签)");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];

        dispatch_async(dispatch_get_main_queue(), ^{

            BOOL isExistTag = NO;

            MMTableView *tableView =  MSHookIvar<MMTableView *>(self, "m_tableView");

            //点击弹出部分可见菜单
            [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];

            //得到所有标签
            NSMutableArray *arrAllLabelName = [self loadAllTagNameList];
            NSLog(@"HKWeChat 当前页面所有的标签为:%@",arrAllLabelName);

            //得到服务器所有的标签
            NSArray *tagNames = [[m_taskDataDic objectForKey:@"tagNames"] componentsSeparatedByString:@","];

            for(NSString* tagName in tagNames){
                if(![tagName isEqualToString:@""]){
                    for(int i=0; i<[arrAllLabelName count]; i++){

                        NSLog(@"HKWeChat 当前标签为:%@",arrAllLabelName[i]);

                            if([tagName isEqualToString:[m_taskDataDic objectForKey:@"tagName"]]){

                                if([arrAllLabelName[i] isEqualToString:@"donr"]){
                                    //选择
                                    [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:2]];
                                    isExistTag = YES;
                                    //                    break;
                            }
                        }
                    }
                }
            }

            //不存在
            if(!isExistTag){

                m_privacy_cell_clicked = 3;
                //点击取消
                [self onReturn];
                
            }else{
                //点击完成
                [self onDone];
            }
            
        });
        
    });
}
%end

///////////////////////发现结束///////////////////////

////////////////////////////进入个人朋友圈主页开始///////////////
%hook WCListView
- (void)initTableView{
    %orig;

    NSLog(@"HKWeChat (进入个人朋友圈主页开始)");

//    //异步加载数据
//    dispatch_group_async(group, queue, ^{
//
//        [NSThread sleepForTimeInterval:8];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSArray *arrPhotoDatas = MSHookIvar<NSArray *>(self, "m_arrPhotoDatas");
//
//            NSLog(@"arrPhotoDatas :%@",arrPhotoDatas);
//
//            for(int i=0; i<[arrPhotoDatas count]; i++){
//
//                WCDataItem *item = arrPhotoDatas[i];
//                NSLog(@"HKWeChat nickname:%@ username:%@ cell: %@", [item nickname],[item username],item);
//
//                WCLikeButton *timeLineLikeBtn = [[NSClassFromString(@"WCLikeButton") alloc] init];
//                if (![item likeFlag]) {
//                    [timeLineLikeBtn setM_item:item];
//                    [timeLineLikeBtn onLikeFriend];
//                    NSLog(@"HKWeChat like pepole: %@, %@", [item nickname], [item username]);
//                }
//
//            }
//
//            
//
//        });
//        
//    });


}

%end

////////////////////////////进入个人朋友圈主页结束///////////////


///////////////////////我 开始///////////////////////

//点击 我tab
%hook MoreViewController

%new
- (void)getMySelfInfo{

    NSLog(@"HKWeChat enter getMySelfInfo(得到我的信息)");
    //得到自己的信息
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];

        dispatch_async(dispatch_get_main_queue(), ^{

            MMTableViewInfo *tableViewInfo = MSHookIvar<MMTableViewInfo *>(self, "m_tableViewInfo");

            MMTableView *tableView = MSHookIvar<MMTableView *>(tableViewInfo, "_tableView");

            MMTableViewCell * tableViewCell = [tableViewInfo tableView:tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];

//            NSLog(@"HKWeChat 昵称:%@ 微信号:%@",[[[tableViewCell subviews][0] subviews][3] text],[[[tableViewCell subviews][0] subviews][4] text]);

            NSString *selfInfo = [NSString stringWithFormat:@"{\"nsNickName\":\"%@\",\"nsAliasName\":\"%@\"}",[[[tableViewCell subviews][0] subviews][3] text],[[[tableViewCell subviews][0] subviews][4] text]];

            //上传到服务器
            NSLog(@"HKWeChat (我的信息):%@",selfInfo);

            NSString *nsAliasName = [[[[tableViewCell subviews][0] subviews][4] text] stringByReplacingOccurrencesOfString:@"微信号：" withString:@""];

            write2File(@"/var/root/hkwx/selfInfo.txt",nsAliasName);

        });
        
    });
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

     NSLog(@"HKWeChat 我 的 页面 ");

    //判断是否得到自己的信息
    NSString *strData = readFileData(@"/var/root/hkwx/syncSelfInfo.txt");

    if([strData isEqualToString:@"1"]){
        [self getMySelfInfo];
    }

    if(m_tab_wechat != 3 || m_depth_wechat != 0){
        return;
    }

    NSLog(@"HKWeChat 进入我的页面操作");


    dispatch_group_async(group, queue, ^{

        //等待数据返回
        while(true){

            NSLog(@"HKWeChat “我” 等待大数据的返回---");

            [NSThread sleepForTimeInterval:5];
            if(m_isRequestResult != 1){
                break;
            }
        }

        [NSThread sleepForTimeInterval:15];

        //操作数据
        operationData();


        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_current_taskType == 16){
                m_depth_wechat = 1;

                //点击进入我的钱包
                [self openWCPayView];
            }

        });

    });
}

%end

//钱包页面
%hook WCBizMainViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat 当前是 WCBizMainViewController(钱包)");


    if(m_isBackHome){

        NSLog(@"HKWeChat 当前是 我的钱包页面 将要返回到首页");

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:10];

            dispatch_async(dispatch_get_main_queue(), ^{

                m_isBackHome = NO;

                m_tab_wechat = 3;
                m_depth_wechat = 0;

                [m_mMUINavigationController popViewControllerAnimated:YES];

            });

        });
    }

    NSLog(@"HKWeChat 当前是 我的钱包页面");
    if(m_depth_wechat != 1 || m_tab_wechat != 3){

        return;
    }

    m_depth_wechat = 2;
    m_tab_wechat = 3;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            //点击进入腾讯公益
            //            [self OnWCMallFunctionActivityViewButtonDown:m_wCMallFunctionActivity];
            //            [self onClickJumpToActivityPage:m_wCMallFunctionActivity];
            [m_wCMallFunctionActivityView OnButtonDown];



            NSLog(@"HKWeChat 点击进入腾讯公益 结束 告诉服务器,并返回到 我的钱包页面");

            m_isBackHome = YES;
            
            hookSuccessTask();
            //返回首页
        });
        
    });

}

- (void)viewDidLayoutSubviews{
    %orig;

}

- (void)OnWCMallFunctionActivityViewButtonDown:(id)arg1{
//    NSLog(@"HKWeChat 钱包页面 %@",arg1);
    %orig;
}

%end


//腾讯服务 第三方服务
%hook  WCMallFunctionActivityView
- (void)initView{
    %orig;

    NSLog(@"HKWeChat 腾讯服务 第三方服务");

}

- (id)initWithFunctionActivity:(id)arg1{
    id ret = %orig;
    WCMallFunctionActivity *wcMainFunc = (WCMallFunctionActivity *)arg1;

//    NSLog(@"腾讯服务 第三方服务 wcMainFunc:%@ ",[wcMainFunc m_nsFunctionActivityName]);
    if([[wcMainFunc m_nsFunctionActivityName] isEqualToString:@"腾讯公益"]){
        m_wCMallFunctionActivity = wcMainFunc;
        m_wCMallFunctionActivityView = self;
    }
    
    return ret;
}

%end


//个人信息页面
%hook SettingMyProfileViewController
- (void)onChangeImg:(id)arg1{
    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController onChangeImg arg1:%@",arg1);
}
- (void)ChangeSex:(id)arg1{
    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController onChangeImg arg1:%@",arg1);

}


- (void)makeChangeImgCell:(id)arg1 cellInfo:(id)arg2{

    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController makeChangeImgCell arg1:%@",arg1);


}
- (void)makeQRInfoCell:(id)arg1 cellInfo:(id)arg2{

    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController makeQRInfoCell arg1:%@",arg1);


}
- (void)makeSignCell:(id)arg1 cellInfo:(id)arg2{
    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController makeSignCell arg1:%@",arg1);

}
- (void)MMRegionPickerDidChoosRegion:(id)arg1{

    %orig;
    NSLog(@"HKWeChat SettingMyProfileViewController MMRegionPickerDidChoosRegion arg1:%@",arg1);

}


%end

///////////////////////我 结束///////////////////////

%hook WCFacade
- (id)init{
    id res = %orig;
    m_mWCFacade = res;
    return res;
}

%end

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
    if([msgDBItem rangeOfString:@"type=10000"].location != NSNotFound && [msgDBItem rangeOfString:@"_25"].location != NSNotFound
       && m_current_taskType == 50){

        NSArray *listItem = [msgDBItem componentsSeparatedByString:@";"];

        NSLog(@" msgDBItem is:%@,listItem:%@",msgDBItem,listItem);

        //保存到文件中
        write2File(@"/var/root/hkwx/sendMsgFail.plist", msgDBItem);
    }
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


//账号异常检查
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

%hook iConsole

+ (_Bool)shouldEnableDebugLog {

    return YES;
}


+ (void)purelog:(id)arg1 {
    %orig;

    NSLog(@"HKWeChat iConsole -----arg1:%@",arg1);
}

+ (_Bool)shouldLog:(int)arg1 {
    
    
    return YES;
    
    
}

+ (void)logToFile:(int)arg1 module:(const char *)arg2 file:(const char *)arg3 line:(int)arg4 func:(const char *)arg5 message:(id)arg6{
    %orig;

//    NSLog(@"HKWeChat logToFile iConsole arg1:%d,arg2:%s,arg3:%s,arg4:%d,arg5:%s,arg6:%@",arg1,arg2,arg3,arg4,arg5,arg6);
}

//+ (void)printLog:(int)arg1 module:(const char *)arg2 file:(const char *)arg3 line:(int)arg4 func:(const char *)arg5 log:(id)arg6{
//    %orig;
//
//    NSLog(@"HKWeChat printLog iConsole arg1:%d,arg2:%s,arg3:%s,arg4:%d,arg5:%s,arg6:%@",arg1,arg2,arg3,arg4,arg5,arg6);
//}
%end




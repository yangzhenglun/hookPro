//enterchatroom hook (进入群聊信息)
#import "enterchatroom.h"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static CSetting *m_nEnterSetting = [[NSClassFromString(@"CSetting") alloc] init];
static MMUINavigationController *m_mMUINavigationController = [[NSClassFromString(@"MMUINavigationController") alloc] init];
//
static MMLoadingView *m_MMLoadingView = [[NSClassFromString(@"MMLoadingView") alloc] init];
static NSData *m_attackDtImg = [[NSData alloc] init];

static BOOL m_nISFirst = YES;  //第一次进入首页进行加载数据
static BOOL m_current_EnterRoom_IsOK = NO;  //判断当前是否结束
static BOOL m_isFitstLoadStop = YES;

NSInteger m_is72LogOpen = 0;   //判断是否72号任务打印日志

id webQR = nil;

static NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
static NSMutableDictionary *m_attackDic = [[NSMutableDictionary alloc] init];  //结果数据
NSMutableArray *m_logurl = [[NSMutableArray alloc] init]; //打日志的接口

static NSString *m_hookVersion = @"1.0.3";
//环境变量
static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

extern "C" void uploadLog(NSString *title, NSString *data);

#define kEnterChatRoomsNotificton                            @"kEnterChatRoomsNotificton"   //发送进入群通知
#define kAttackChatRoomsNotificton                           @"kAttackChatRoomsNotificton"  //发送攻击群通知
/*
 变量说明：当前正在做的任务是什么类型
 -1:表示当前没有任务在进行
 */
NSInteger m_current_taskType = -1;

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

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

extern "C" NSString * readFileData(NSString * fileName) {
    NSLog(@"HKWeChat readFileData:%@",fileName);
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];

        return strData;
    }else{
        return @"";
    }
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

//发送同步群聊信息
extern "C" void syncEnterChatroomMenbers(NSString *chatroomUuid,NSString *dataList){

    NSString *urlStr = [NSString stringWithFormat:@"%@syncChatroomMenbers.htm",environmentPath];

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"chatroomUuid=%@&dataList=[%@]",chatroomUuid,dataList];

    NSLog(@"%@?%@",urlStr,parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            //　　         NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@ 数据为：%@",url,aString,parseParamsResult);
            
            
        }
    }];
    
}

//读出als.json 配置的信息
extern "C" NSMutableDictionary * loadTaskId() {
    return openFile(@"/var/root/als.json");
}

//启动时请求的的任务数据
extern "C" void getEnterChatRoomData(){
    //读出任务ID
    NSMutableDictionary *taskInfo = loadTaskId();
    if(m_isRequestResult > 1){
        return;
    }

    if([[taskInfo objectForKey:@"taskId"] isEqualToString:@""]){

        NSLog(@"hkfodderwinxin 任务ID为空");

        m_isRequestResult = 6;
        return;
    }

    m_isRequestResult = 1;

    uploadLog(@"执行获取数据信息(getEnterChatRoomData)", [NSString stringWithFormat:@"get_original_tasks"]);

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@get_original_tasks.htm?taskIds=%@&clientType=3",environmentPath,[taskInfo objectForKey:@"taskId"]];

    NSURL *url = [NSURL URLWithString:urlStr];

    // 2. Request
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    //开始请求数据

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil && [m_taskArrayData count]<= 0) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"请求回来的数据为：%@",taskAll);

            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

                for(NSArray *obj in [taskAll objectForKey:@"dataList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];
                }

                m_is72LogOpen = [[taskAll objectForKey:@"is72LogOpen"] intValue];

                //拷贝数据链接url的数据
                [m_logurl addObject:[[taskAll objectForKey:@"logurl"] mutableCopy]];

                NSLog(@"m_logurl:%@",m_logurl);

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


extern "C" void hook_success_task(int currentType,NSString *taskId){

    m_current_EnterRoom_IsOK = YES;


    NSString *urlStr = [NSString stringWithFormat:@"%@hook_success_task.htm",environmentPath];

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@",taskId];


    NSLog(@"上传成功=======%@%@",urlStr,parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        }
    }];
}

extern "C" void hook_fail_task(int currentType,NSString *taskId,NSString *exceptionStr){

    m_current_EnterRoom_IsOK = YES;

    NSString *urlStr = [NSString stringWithFormat:@"%@hook_fail_task.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&exceptionStr=%@",taskId,exceptionStr];


    NSLog(@"上传失败=======%@%@",urlStr,parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError == nil) {
            
        }
    }];
}


//上传进群是否成功
extern "C" void uploadEnterChatRoomResult(NSString *taskId,int enterState){
    m_current_EnterRoom_IsOK = YES;

    //-1:没有加上  0:存在并没有被踢  1:存在，被踢  2:已经在这个群
    NSString *msgRes = @"";
    if(enterState == 0){
        msgRes = @"存在并没有被踢";
    }else if(enterState == 1){
        msgRes = @"存在,被踢";
    }else if(enterState == 2){
        msgRes = @"已经在这个群";
    }else if(enterState == -1){
        msgRes = @"没有加上";
    }

    uploadLog(@"执行上传进群(uploadEnterChatRoomResult)", [NSString stringWithFormat:@"当前的状态为：%@",msgRes]);

    if(enterState == 0 || enterState == 2){
        hook_success_task(m_current_taskType,taskId);
    }else{
        hook_fail_task(m_current_taskType,taskId,msgRes);
    }
}


//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){
    NSLog(@"title:%@ data:%@",title,data);

    NSString *logPath = m_logurl[0];

    if(logPath == nil || [logPath isEqualToString:@""]){
        //不打日志
        NSLog(@"当前服务器给的是不打日志");
        return;
    }


    //读出设备信息
    NSMutableDictionary *taskId = loadTaskId();

    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:[taskId objectForKey:@"deviceId"] forKey:@"ipad"];
    [logDic setObject:[m_nEnterSetting m_nsAliasName] forKey:@"weixinId"];
    [logDic setObject:[m_nEnterSetting m_nsUsrName] forKey:@"weixinUuid"];
    [logDic setObject:[m_nEnterSetting m_nsMobile] forKey:@"phone"];
    [logDic setObject:[taskId objectForKey:@"taskId"] forKey:@"taskId"];
    [logDic setObject:[NSString stringWithFormat:@"%d",m_current_taskType] forKey:@"taskType"];
    [logDic setObject:m_hookVersion forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hook" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

    //    NSString *jsonData = [NSString stringWithFormat:@"\"ipad\":\"%@\",\"weixinId\":\"%@\",\"weixinUuid\":\"%@\",\"phone\":\"%@\",\"taskId\":\"%@\",\"taskType\":\"%@\",\"hookVersion\":\"%@\",\"luaVersion\":\"%@\",\"devType\":\"%@\",\"logTitle\":\"%@\","];

    //打开日志

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@?jsonLog=%@",logPath,jsonData];

    NSLog(@"上传微信数据：%@",urlStr);

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

%new
-(void)JumpToChatRoom:(NSString *)chatRoomId{

    uploadLog(@"当前进入群JumpToChatRoom", [NSString stringWithFormat:@"进入的群是:%@",chatRoomId]);

    //进群
    ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];
    //    进入群聊
    CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
    contact.m_nsUsrName = chatRoomId;// @"7399393395@chatroom";

    //    点击进入群聊
    [chatRoom JumpToChatRoom:contact];

}

%new
-(int)isExistChatRoom:(NSString *)chatRoomId{
    //-1:没有加上  0:存在并没有被踢  1:存在，被踢  2:已经在这个群
    __block int isExist = -1;

    CContactMgr *nContactmgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CGroupMgr *nGroupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
    
    //得到所有的群号
    NSArray *allChatRoom = [nContactmgr getContactListInChatroom];

    uploadLog(@"得到当前帐号所有的群ID", [NSString stringWithFormat:@"allChatRoom:%@",allChatRoom]);

    NSLog(@"isExistChatRoom:%@",allChatRoom);

    for(int i = 0; i < [allChatRoom count]; i++){

        NSLog(@"chatRoomId:%@ m_nsUsrName:%@",chatRoomId,[allChatRoom[i] m_nsUsrName]);

        uploadLog(@"当前循环得到当前群号", [NSString stringWithFormat:@"循环群号为:%@ 发消息的群为:%@",[allChatRoom[i] m_nsUsrName],chatRoomId]);

        if([chatRoomId isEqualToString:[allChatRoom[i] m_nsUsrName]]){

            NSLog(@"isExistChatRoom:%@ 当前找到了微信群信息:%@",chatRoomId,[allChatRoom[i] m_nsUsrName]);

            //判断自己是否在这个群里
            if([nGroupMgr IsUsrInChatRoom:chatRoomId Usr:[m_nEnterSetting m_nsUsrName]]){
                isExist = 0;
                uploadLog(@"当前检查是否加入该群", [NSString stringWithFormat:@"已经加入了该群,该群为:%@",chatRoomId]);
            }else{
                isExist = 1;
                NSLog(@"当前找到了微信群信,但本人别踢除了");

                uploadLog(@"当前检查是否加入该群", [NSString stringWithFormat:@"当前找到了微信群信,但是被踢除了:%@",chatRoomId]);
            }
            break;
        }
    }

    return isExist;
}

static dispatch_group_t groupEnter = dispatch_group_create();
static dispatch_queue_t queueEnter = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);



%new
-(void)enterChatRoom{

    NSLog(@"接受到js注入后的消息");
    uploadLog(@"接受到js注入后的消息", [NSString stringWithFormat:@"点击加入群里按钮后"]);

    dispatch_group_async(groupEnter, queueEnter, ^{

        [NSThread sleepForTimeInterval:5];

        //返回首页
        if(m_mMUINavigationController){
            [m_mMUINavigationController popViewControllerAnimated:YES];
        }

        [NSThread sleepForTimeInterval:2];

        if(m_mMUINavigationController){
            [m_mMUINavigationController popViewControllerAnimated:YES];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [self JumpToChatRoom:[m_attackDic objectForKey:@"chatroomUuid"]];

            if(m_mMUINavigationController){
                [m_mMUINavigationController popViewControllerAnimated:YES];
            }

            int enterResult = [self isExistChatRoom:[m_attackDic objectForKey:@"chatroomUuid"]];

            uploadLog(@"得到ExistChatRoom函数的结果", [NSString stringWithFormat:@"enterResult:%d",enterResult]);

            //告诉服务端
            uploadEnterChatRoomResult([m_attackDic objectForKey:@"taskId"],enterResult);

            m_current_EnterRoom_IsOK = YES;

        });
    });
    
}

%new
-(void)registerNotification{
    //通知发送攻击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterChatRoom) name:kEnterChatRoomsNotificton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackChatRoom:) name:kAttackChatRoomsNotificton object:nil];
}

static dispatch_group_t groupAttack = dispatch_group_create();
static dispatch_queue_t queueAttack = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

%new
- (void)attackChatRoom:(NSNotification *)notifiData{

    NSMutableDictionary *attackDic = (NSMutableDictionary*)notifiData.userInfo;

    NSLog(@"attackChatRoom 开始走攻击函数:%@",attackDic);

    uploadLog(@"attackChatRoom 开始走攻击函数", [NSString stringWithFormat:@"进入攻击函数"]);

    //攻击次数
    __block int attackCount = [[attackDic objectForKey:@"attackCount"] intValue];

    __block int attackOverTimeSec = [[attackDic objectForKey:@"attackOverTimeSec"] intValue];

    dispatch_group_async(groupAttack, queueAttack, ^{

        [NSThread sleepForTimeInterval:2];

        //判断是否存在这个群里
//        if([self isExistChatRoom:[attackDic objectForKey:@"chatRoomId"]] == 0){

            for(int i = 0; i < attackCount;i++){

                dispatch_async(dispatch_get_main_queue(), ^{

//                    if([self isExistChatRoom:[attackDic objectForKey:@"chatRoomId"]] == 0){
                        //开始文字攻击
                        if(![[attackDic objectForKey:@"attackSendContent"] isEqualToString:@""]){
                            NSLog(@"发送第一次消息:%@",[attackDic objectForKey:@"attackSendContent"]);

                            [self sendAttackTextMessages:[attackDic objectForKey:@"chatRoomId"] textContent:[attackDic objectForKey:@"attackSendContent"]];
                        }else{
                            NSLog(@"没有文字攻击 attackSendContent");
                            uploadLog(@"没有文字攻击 attackSendContent", [NSString stringWithFormat:@"当前处于第一个文字攻击"]);
                        }


                        if(![[attackDic objectForKey:@"attackSendContent2"] isEqualToString:@""]){

                            NSLog(@"发送第一次消息:%@",[attackDic objectForKey:@"attackSendContent2"]);

                            [self sendAttackTextMessages:[attackDic objectForKey:@"chatRoomId"] textContent:[attackDic objectForKey:@"attackSendContent2"]];
                        }else{
                            NSLog(@"没有文字攻击 attackSendContent2");
                            uploadLog(@"没有文字攻击 attackSendContent2", [NSString stringWithFormat:@"当前处于第二个文字攻击"]);
                        }

                        //开始图片攻击
                        if([attackDic objectForKey:@"attackSendPicUrl"] && ![[attackDic objectForKey:@"attackSendPicUrl"] isEqualToString:@""]){

                            [self sendAttackPictureMessages:[attackDic objectForKey:@"chatRoomId"] pic:[attackDic objectForKey:@"attackSendPicUrl"]];
                        }else{
                            NSLog(@"没有图片攻击 attackSendPicUrl");

                            uploadLog(@"没有图片攻击 attackSendPicUrl", [NSString stringWithFormat:@"attackSendPicUrl链接为空"]);
                        }

//                    }else{
//                        NSLog(@"当前没有找到这个群，或者被踢了");
//
//                        uploadLog(@"在发送过程中,被踢出了", [NSString stringWithFormat:@"被踢的群为：%@",[attackDic objectForKey:@"chatRoomId"]]);
//                    }

                });

                [NSThread sleepForTimeInterval:attackOverTimeSec];
            }

//            hook_success_task(m_current_taskType,[attackDic objectForKey:@"taskId"]);

//        }else{
//            uploadLog(@"没有这个群信息", [NSString stringWithFormat:@"被踢的群为：%@",[attackDic objectForKey:@"chatRoomId"]]);
//
//            hook_fail_task(m_current_taskType,[attackDic objectForKey:@"taskId"],[NSString stringWithFormat:@"当前帐号没有这个群信息,群ID为:%@",[attackDic objectForKey:@"chatRoomId"]]);
//        }

        //判断当前的群是否存在这个号里
        int enterResult = [self isExistChatRoom:[attackDic objectForKey:@"chatroomUuid"]];

        uploadEnterChatRoomResult([attackDic objectForKey:@"taskId"],enterResult);

        //页面返回
        if(m_mMUINavigationController){
            [m_mMUINavigationController popViewControllerAnimated:YES];
        }

        if(m_mMUINavigationController){
            [m_mMUINavigationController popViewControllerAnimated:YES];
        }

    });

}


- (void)viewDidLoad{
    %orig;

    NSLog(@"attackChatRoom is NewMainFrameViewController 进入首页");
    if(m_nISFirst){
        [self registerNotification];
    }

    if(m_isRequestResult > 1){
        NSLog(@"当前处于返回首页,不能进行下面的操作");
        return;
    }

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        NSString *isAccount = readFileData(@"/var/root/hkwx/accountStorageMgr.txt");

        if([isAccount isEqualToString:@"1"]){

            AccountStorageMgr *accountStorageMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AccountStorageMgr")];
            accountStorageMgr.m_oSetting.m_uiInitStatus = 0;
            [accountStorageMgr DirectSaveSetting];

            NSString *bufferFilePath = [accountStorageMgr GetSyncBufferFilePath];
            NSString *isRealPath = [bufferFilePath substringToIndex:(bufferFilePath.length -14)];
            write2File(@"/var/root/hkwx/bufferFilePath.txt",isRealPath);
            NSLog(@"bufferFilePath:%@ isRealPath:%@",bufferFilePath,isRealPath);
        }

        //判断是否当前能做任务
        while([m_MMLoadingView m_bLoading]){

            NSLog(@"在等待加载数据完成后,在进行请求数据做任务");
            [NSThread sleepForTimeInterval:2];
        }

        NSLog(@"开始做任务");
        
        getEnterChatRoomData();

        //等待数据返回
        while(true){

            NSLog(@"hkattackChatRoom-- %d",m_isRequestResult);

            [NSThread sleepForTimeInterval:5];
            if(m_isRequestResult == 2 || m_isRequestResult == 3 || m_isRequestResult == 4 || m_isRequestResult == 6){
                break;
            }

            uploadLog(@"获取数据接口", [NSString stringWithFormat:@"重复获取数据"]);

            getEnterChatRoomData();
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            if(m_isRequestResult == 2){

                [self beginDoTask];
            }
            
        });

    });
}

//上传信息
%new
-(void)uploadAllChatRoomInfo:(NSArray *)memberList chatRoomUUid:(NSString *)chatRoomUUid{
    NSString *oneJson = @"";
    NSString *dataJson = @"";

    for(CContact *ccontact in memberList){

        NSString *nsUsrName = conversionSpecialCharacter([ccontact m_nsUsrName]);
        NSString *nickName = conversionSpecialCharacter([ccontact m_nsNickName]);
        NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
        NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
        NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

        oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%ld\",\"nsHeadImgUrl\":\"%@\"}",nsUsrName,[ccontact m_nsAliasName],nickName,nsCountry,nsProvince,nsCity,[ccontact m_uiSex],[ccontact m_nsHeadImgUrl]];

        //                        NSLog(@"HKWX %@",oneJson);

        if([dataJson isEqualToString:@""]){
            dataJson = [NSString stringWithFormat:@"%@",oneJson];
        }else{
            dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
        }
    }

    NSLog(@"%@",dataJson);

    //同步群聊成员
    syncEnterChatroomMenbers(chatRoomUUid,dataJson);

}

%new
- (NSArray *)getAliasTest:(NSArray *)contactList chatRoom:(NSString*)chatRoom
{
//    NSLog(@"getAliasTest11111111:%@",contactList);

    id mgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];
    CContact *contact = [mgr getContactByName:chatRoom];
    [mgr getContactsFromServer:contactList chatContact:contact];

//    NSLog(@"getAliasTest22222222:%@",contactList);
    return [contactList retain];
}

//得到所有的群信息
%new
- (void)getAllChatRoomInfoTest{

    CGroupMgr *nGroupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
    if(nGroupMgr == nil){
        NSLog(@"新建一个group");
        nGroupMgr = [[NSClassFromString(@"CGroupMgr") alloc] init];
    }

    NSString *testArray = @"6603346801@chatroom,6746346697@chatroom,7709208609@chatroom,6492423132@chatroom";

    ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];

    NSArray *chatRooms = [testArray componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组;

    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[chatRooms count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                contact.m_nsUsrName = chatRooms[i];
                //    点击进入群聊
                [chatRoom JumpToChatRoom:contact];

                NSLog(@"进入群信息");

            });

            [NSThread sleepForTimeInterval:3];

            NSArray *memberList = [nGroupMgr GetGroupMember:chatRooms[i]];

            NSLog(@"memberList :%@",memberList);

            if(![memberList count]){
                NSLog(@"获取当前信息为空");
            }else{

                NSMutableArray *tempList = [[NSMutableArray alloc] init];
                for(int i=0; i<[memberList count];i++){

                    [tempList removeAllObjects];

                    [tempList addObject:memberList[i]];

                    NSLog(@"%@",[self getAliasTest:tempList chatRoom:chatRooms[i]]);
                }


//                [self uploadAllChatRoomInfo:memberList chatRoomUUid:chatRooms[i]];
            }
            
            [NSThread sleepForTimeInterval:1];
        }

        
    });


}

%new
- (void)getAllChatRoomInfo:(NSMutableDictionary*)taskDataDic{

    CGroupMgr *nGroupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
    if(nGroupMgr == nil){
        NSLog(@"新建一个group");
        nGroupMgr = [[NSClassFromString(@"CGroupMgr") alloc] init];
    }

    if([[taskDataDic objectForKey:@"chatRoomList"] isEqualToString:@""] || [taskDataDic objectForKey:@"chatRoomList"] == nil){

        hook_fail_task(m_current_taskType,[taskDataDic objectForKey:@"taskId"],@"给的群信息为空");
        return;
    }

    ChatRoomListViewController *chatRoom = [[NSClassFromString(@"ChatRoomListViewController") alloc] init];
    NSArray *chatRooms = [[taskDataDic objectForKey:@"chatRoomList"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组;

    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[chatRooms count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
                contact.m_nsUsrName = chatRooms[i];
                //    点击进入群聊
                [chatRoom JumpToChatRoom:contact];
                
                NSLog(@"进入群信息");

            });

            [NSThread sleepForTimeInterval:3];

            NSArray *memberList = [nGroupMgr GetGroupMember:chatRooms[i]];
            NSLog(@"memberList :%@",memberList);

            if(![memberList count]){
                NSLog(@"获取当前信息为空");
            }else{

                [self uploadAllChatRoomInfo:[self getAliasTest:memberList chatRoom:chatRooms[i]] chatRoomUUid:chatRooms[i]];
            }

            [NSThread sleepForTimeInterval:1];
        }

         hook_success_task(m_current_taskType,[taskDataDic objectForKey:@"taskId"]);
        
    });

//    [#0x16856b90 GetGroupMember:@"6603346801@chatroom"]


}



%new
-(void)beginDoTask{

    if([m_taskArrayData count]<= 0){
        NSLog(@"得到解析的数据为空");
        return;
    }

    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[m_taskArrayData count]; i++){

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                m_current_taskType = [[m_taskArrayData[i] objectForKey:@"taskType"] intValue];

                if(m_current_taskType == 89){

                    m_attackDic = m_taskArrayData[i];

                    uploadLog(@"当前执行进入群聊任务", [NSString stringWithFormat:@"当前的任务ID为：%@ 当前加入群信息为：%@",[m_attackDic objectForKey:@"taskId"],[m_attackDic objectForKey:@"chatroomUuid"]]);

                    //判断当前微信号是否存在
                    if([self isExistChatRoom:[m_attackDic objectForKey:@"chatroomUuid"]] != 0){
                        [self scanQRCodeEnterRoom:[m_taskArrayData[i] objectForKey:@"qrCodeUrl"]];
                    }else{

                        NSLog(@"上传服务器");

                        uploadLog(@"当前执行进入群聊任务时,检测到已经加入这个群", [NSString stringWithFormat:@"群信息为：%@",[m_attackDic objectForKey:@"chatroomUuid"]]);

                        uploadEnterChatRoomResult([m_attackDic objectForKey:@"taskId"],2);
                        //告诉已经成功
                        m_current_EnterRoom_IsOK = YES;
                    }
                }else if(m_current_taskType == 90){

                    uploadLog(@"当前执行攻击群信息", [NSString stringWithFormat:@"当前要攻击的群为：%@",m_taskArrayData[i]]);

                    [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:m_taskArrayData[i]];

                }else if(m_current_taskType == 103){
                    //得到群信息
                    [self getAllChatRoomInfo:m_taskArrayData[i]];
                }

            });

            while(!m_current_EnterRoom_IsOK){
                NSLog(@"hook 等待上一个任务结束");
                [NSThread sleepForTimeInterval:5];
            }

            m_current_EnterRoom_IsOK = NO;

            [NSThread sleepForTimeInterval:5];
        }

        //延时10s 告诉脚本结束
        uploadLog(@"当前enterchatroom的hook告诉脚本结束", [NSString stringWithFormat:@"告诉脚本进行下一个任务"]);

        //告诉脚本结束
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    });
    
}

//进行扫描进入群
%new
-(void)scanQRCodeEnterRoom:(NSString *)chatRoomURL{

    if(!webQR){
        webQR = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:@""] presentModal:NO extraInfo:nil];

    }else{
        [webQR goToURL:[NSURL URLWithString:@""]];
    }

    uploadLog(@"执行扫描进入群函数 scanQRCodeEnterRoom", [NSString stringWithFormat:@"群二维码为：%@",chatRoomURL]);

    if(webQR){

        [[self navigationController] pushViewController:webQR animated: YES];

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:1];

            id lg = [[NSClassFromString(@"ScanQRCodeLogicController") alloc] initWithViewController: self CodeType: 2];

            uploadLog(@"执行scanOnePicture函数", [NSString stringWithFormat:@"进行扫描"]);

            [lg scanOnePicture:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:chatRoomURL]]]];

        });
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

        uploadLog(@"给群推送图片消息", [NSString stringWithFormat:@"当前的群为：%@",toUser]);

        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
        CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nEnterSetting m_nsUsrName]];

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

    uploadLog(@"给群推送文字消息", [NSString stringWithFormat:@"当前的群为：%@",toUser]);

    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nEnterSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = textContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nEnterSetting m_nsUsrName];
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

    m_nEnterSetting = self;

    return ret;
}
%end


%hook YYUIWebView
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"currentURl is:%@",currentURl);

    if([currentURl rangeOfString:@"addchatroombyqrcode?uuid"].location != NSNotFound){

        NSLog(@"js 注入加入群聊");
        NSString *titleScript = @"document.getElementsByClassName('title')[0].innerText";
        NSString *errorTitle = [self stringByEvaluatingJavaScriptFromString:titleScript];
        if([errorTitle isEqualToString:@""]){

            NSString *script = [NSString stringWithFormat:@"document.getElementById(\"form\").submit();"];

            [self stringByEvaluatingJavaScriptFromString:script];

            uploadLog(@"js 注入加入群聊", [NSString stringWithFormat:@"得到当前进入群聊页面URL"]);

            //post 发送消息
            [[NSNotificationCenter defaultCenter] postNotificationName:kEnterChatRoomsNotificton object:nil userInfo:nil];
        }else{
            NSLog(@"当前无法加入群信息,获取到的内容为：%@",errorTitle);

            uploadLog(@"当前无法加入群信息,获取到的内容为", [NSString stringWithFormat:@"%@",errorTitle]);

            hook_fail_task(m_current_taskType,[m_attackDic objectForKey:@"taskId"],errorTitle);
        }

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



%hook BaseMsgContentViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"BaseMsgContentViewController(viewDidAppear 聊天页面) ");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:1];

        dispatch_async(dispatch_get_main_queue(), ^{
            //页面返回
            if(m_mMUINavigationController){
                [m_mMUINavigationController popViewControllerAnimated:YES];
            }
        });
    });
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

%hook MMLoadingView
- (void)stopLoading{
    %orig;
    NSLog(@"this is MMLoadingView stopLoading");
}

- (void)setActivityIndicatorViewCenter:(_Bool)arg1{
    %orig;
    NSLog(@"this is MMLoadingView setActivityIndicatorViewCenter");
}

- (void)ShowTipView:(id)arg1 Title:(id)arg2 Delay:(double)arg3{
    %orig;
    NSLog(@"this is MMLoadingView ShowTipView:%@ title:%@",arg1,arg2);
}

- (void)stopLoadingAndShowOK{
    %orig;
    NSLog(@"this is MMLoadingView stopLoadingAndShowOK");
}

- (void)stopLoadingAndShowError:(id)arg1 withDelay:(double)arg2{
    %orig;
    NSLog(@"this is MMLoadingView stopLoadingAndShowError:%@",arg1);
}

- (void)stopLoadingAndShowError:(id)arg1{
    %orig;
    NSLog(@"this is MMLoadingView stopLoadingAndShowError:%@",arg1);
}

- (void)stopLoadingAndShowOK:(id)arg1 withDelay:(double)arg2{
    %orig;
    NSLog(@"this is MMLoadingView stopLoadingAndShowOK:%@",arg1);
}

- (void)stopLoadingAndShowOK:(id)arg1{
    %orig;
    NSLog(@"this is MMLoadingView stopLoadingAndShowOK :%@",arg1);
}
- (void)StopLoadingTimerFired:(id)arg1{
    %orig;
    NSLog(@"this is MMLoadingView StopLoadingTimerFired:%@",arg1);
}
- (void)setFitFrameDownloadImg:(long long)arg1{
    %orig;
    NSLog(@"this is MMLoadingView setFitFrameDownloadImg :%@",arg1);
}

- (id)init{
    id ret = %orig;
    m_MMLoadingView = self;

    NSLog(@"this is MMLoadingView init");
    return ret;
}
- (void)layoutSubviews{
    %orig;
    NSLog(@"this is MMLoadingView layoutSubviews");
}

- (id)initWithCustom:(struct CGRect)arg1 bkgColor:(id)arg2 textColor:(id)arg3{
    id ret = %orig;
    NSLog(@"this is MMLoadingView initWithCustom");
    return ret;
}
- (void)setFitFrame:(long long)arg1{
    %orig;
    NSLog(@"this is MMLoadingView setFitFrame");
}

%end


%hook MoreViewController
- (void)viewDidLoad{
    %orig;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            //判断文件里的值
            NSString *isAccount = readFileData(@"/var/root/hkwx/accountStorageMgr.txt");

            if([isAccount isEqualToString:@"1"]){
                //http://log.vogueda.com/shareplatformWxTest/weixin/serverlog.htm
                AccountStorageMgr *accountStorageMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AccountStorageMgr")];
                accountStorageMgr.m_oSetting.m_uiInitStatus = 0;
                [accountStorageMgr DirectSaveSetting];

                //得到文件的名字
                ///var/mobile/Containers/Data/Application/4D2EBEF5-256B-479D-BD03-FCF1A4651F29/Documents/5e076d79618b9059744ad4f6e5244407/syncbuffer.lst
                NSString *bufferFilePath = [accountStorageMgr GetSyncBufferFilePath];
                NSString *isRealPath = [bufferFilePath substringToIndex:(bufferFilePath.length -14)];

                write2File(@"/var/root/hkwx/bufferFilePath.txt",isRealPath);

                NSLog(@"bufferFilePath:%@ isRealPath:%@",bufferFilePath,isRealPath);
            }
        });
        
    });
}
%end



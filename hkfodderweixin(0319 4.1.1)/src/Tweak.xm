
#import "substrate.h"
#import "hkweixin.h"

//static NSMutableArray *nearbyCContactList = [[NSMutableArray alloc] init];
static NSMutableArray *nearbyCContactList = [NSMutableArray arrayWithCapacity:200];

static MMTabBarController *m_mMTabBarController = [[NSClassFromString(@"MMTabBarController") alloc] init];  //下面的table页
static MMUINavigationController *m_mMUINavigationController = [[NSClassFromString(@"MMUINavigationController") alloc] init]; //导航栏
static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页

static AddressBookFriendViewController *abfvc = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];
static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

//发名片异步
static dispatch_group_t groupOne = dispatch_group_create();
static dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static dispatch_group_t groupTwo = dispatch_group_create();
static dispatch_queue_t queueTwo = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static NSString *linkTemplate = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwx/link_template.xml"];
static NSString *linkTemplatetest = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwx/link_templatetest.xml"];

static NSString *m_hookVersion = @"4.4.1";  //版本号

static UILabel *nearByFriendlable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];

static NSMutableDictionary *phoneCContactList = [[NSMutableDictionary alloc] init];  //结果数据

static BOOL enableMpDoc = NO;

static int totalCardSend = 0;
static int m_updateLink = 0; //判断是否要上传到服务器
NSString *m_fetchUinAndKeyUrl = @"";  //判断是否上传uin和key
BOOL m_fetchUinAndKeyOK = NO;    //判断当前是否上传了key
static BOOL m_current_modify = NO;  //判断当前是否执行修改头像
static int m_current_taskCount = -1;  //判断当前是执行第几个任务
static int m_current_taskType71 = 0;

BOOL m_endCardOne = FALSE;   //判断第一个是否发送完毕
static int m_interval = 5;  //间隔秒数
static BOOL m_current_taskIsOK = NO;  //判断当前执行的任务是否结束

static int m_pickupCount = 1; //捡瓶子次数
int m_pickupinterval = 2;  //多久时间捡一次瓶子
static BOOL m_enterBottle = FALSE;  //判断是否进入了瓶子
static BOOL isEndPick = NO;  //判断瓶子是否
static BOOL m_is_bottlecomplain = NO;  //判断瓶子是否别投诉
extern "C" NSString* geServerTypeTitle(int currentType,int currentNum,NSString *data);
extern "C" void uploadLog(NSString *title, NSString *data);
static NSData *m_dtImg = [[NSData alloc] init];
static NSData *m_voiceData = [[NSData alloc] init];

NSMutableArray *m_scanQrUrl = [[NSMutableArray alloc] init];
NSMutableArray *m_addErrorInfo = [[NSMutableArray alloc] init]; //没有加上的错误消息
NSMutableArray *m_addSuccessInfo = [[NSMutableArray alloc] init]; //没有加上的错误消息

static id webCtrl = nil;

static id newMainFrame = nil;


//创建通知消息
#define kSendFriendsNotificton                      @"kSendFriendsNotificton"   //发朋友圈
#define kMsgAndLinkNotificton                       @"kMsgAndLinkNotificton"           //推送消息+链接
#define kAttentionPublicCardNotificton              @"kAttentionPublicCardNotificton"            //关注公众号
#define kDriftingBottleNotificton                   @"kDriftingBottleNotificton"       //发漂流瓶
#define kSendMsgOnePerson                           @"kSendMsgOnePerson"   //向一个好友发名片
#define kSendDriftingBottleNotificton               @"kSendDriftingBottleNotificton"  //发瓶子消息
#define kAttackChatRoomsNotificton                      @"kAttackChatRoomsNotificton"   //发送攻击通知
#define kScanQRCodeNotificton                      @"kScanQRCodeNotificton"   //发送攻击通知

id app = NULL;



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
static NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskTypeDic71 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskTypeDicBottle = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskTypeShake = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDicKey = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDataDic72 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDataDic77 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDataDic45 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDataDic88 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableArray *m_cardContacts = [[NSMutableArray alloc] init];
NSMutableArray *m_showTip = [[NSMutableArray alloc] init]; //提示日志

static NSMutableArray *m_picWXids = [[NSMutableArray alloc] init]; //发图片的好友

NSMutableArray *m_logurl = [[NSMutableArray alloc] init]; //打日志的接口
NSInteger m_is72LogOpen = 0;   //判断是否72号任务打印日志

//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){

    NSLog(@"title:%@ data:%@",title,data);

    NSString *environmentPath = m_logurl[0];


    if(environmentPath == nil || [environmentPath isEqualToString:@""]){
        //不打日志
        NSLog(@"当前服务器给的是不打日志");
        return;
    }

    if(m_current_taskType == 72 && m_is72LogOpen == 0){
        NSLog(@"当前服务器给的是不打日志");
        return;
    }

     //读出设备信息
    NSMutableDictionary *taskId = loadTaskId();

    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:[taskId objectForKey:@"deviceId"] forKey:@"ipad"];
    [logDic setObject:[m_nCSetting m_nsAliasName] forKey:@"weixinId"];
    [logDic setObject:[m_nCSetting m_nsUsrName] forKey:@"weixinUuid"];
    [logDic setObject:[m_nCSetting m_nsMobile] forKey:@"phone"];
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
    NSString *urlStr = [NSString stringWithFormat:@"%@?jsonLog=%@",environmentPath,jsonData];

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

//上传群二维码和链接
extern "C" void uploadChatRoomID(NSString *taskId,NSString *detectId, NSString *qrUrl,NSString *chatRoomId, NSString* nsNickName){
    m_current_taskIsOK = YES;

    if([qrUrl isEqualToString:@""] || qrUrl == nil){
        return;
    }

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



    NSString *urlStr = [NSString stringWithFormat:@"%@uploadDetectChatRoomQrCodeUrl.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];


    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&chatRoomQrCodeUrl=%@&detectId=%@&chatRoomId=%@&nsNickName=%@",taskId,qrUrl,detectId,chatRoomId,nsNickName];

    NSLog(@"HKWeChat %@ sendData:%@ 发送给服务器 %@ ",urlStr,qrUrl,parseParamsResult);


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

            NSLog(@"HKWeChat 发送成功给服务器 服务器返回值为:%@",url);


         }
    }];
}

//同步加好友失败
extern "C" void uploadAddFriendData(NSString *taskId,NSString *data){

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



    NSString *urlStr = [NSString stringWithFormat:@"%@uploadAddFriendData.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    uploadLog(geServerTypeTitle(m_current_taskType,5,@"调用uploadAddFriendData接口"),@"");

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)data,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));

    //srcType  1.手机号筛选  2.首页筛选
    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&dataList=[%@]",taskId,sendData];


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


//同步首页筛选数据
extern "C" void syncSearchPhoneMember(NSString *data,NSString *taskId){

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



    NSString *urlStr = [NSString stringWithFormat:@"%@syncSearchPhoneMember.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    uploadLog(geServerTypeTitle(80,5,@"调用syncSearchPhoneMember接口"),@"");

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    
    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)data,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));

    //srcType  1.手机号筛选  2.首页筛选
    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&dataList=[%@]&type=1&srcType=2",taskId,sendData];

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


//发送附近人男、女 给服务端 nearbyCContactList
extern "C" void syncNearbyCContactTask(NSString *data,NSString *latitude,NSString *longitude){

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

    uploadLog(geServerTypeTitle(70,8,@"调用syncNearbyContactTask接口"),@"");

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&taskOrderId=%@&dataList=[%@]&latitude=%@&longitude=%@",[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],data,latitude,longitude];

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

extern "C" void hook_success_task(int currentType,NSString *taskId){

    m_current_taskIsOK = YES;

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



    NSString *urlStr = [NSString stringWithFormat:@"%@hook_success_task.htm",environmentPath];

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@",taskId];


    NSLog(@"=======%@%@",urlStr,parseParamsResult);

    uploadLog(geServerTypeTitle(currentType,4,@"开始上传服务器hook_success_task"),[NSString  stringWithFormat:@"上传的链接为:%@?%@",urlStr,parseParamsResult]);

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

            uploadLog(geServerTypeTitle(currentType,4,@"告知脚本当前任务结束"),[NSString stringWithFormat:@"告知脚本%@",aString]);
         }
    }];
}

extern "C" void hook_fail_task(int currentType,NSString *taskId,NSString *exceptionStr){

    m_current_taskIsOK = YES;

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



    NSString *urlStr = [NSString stringWithFormat:@"%@hook_fail_task.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&exceptionStr=%@",taskId,exceptionStr];


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

            uploadLog(geServerTypeTitle(currentType,4,@"当前任务失败进行下一个任务"),@"告知服务端");
        }
    }];
}


//获取发送当前key和uin
extern "C" void saveMyAccountUinAndKey(int currentType,NSString *data,NSString *uuid){
    m_current_taskIsOK = YES;

    //读出任务ID和orderID
//    NSMutableDictionary *taskId = [m_taskDicKey objectForKey];
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

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&linkUrl=%@&uuid=%@",[m_taskDicKey objectForKey:@"taskId"],sendData,uuid];

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
            
            NSLog(@"HKWeChat 发送成功给服务器 服务器返回值为:%@",url);

            uploadLog(geServerTypeTitle(currentType,4,@"上传key成功"),@"告诉可以执行下一个任务了");

//            write2File(@"/var/root/hkwx/wxResult.txt", @"1");
        }
    }];
}



//上传公众号名片的数据
extern "C" void uploadPublicCardInfo(NSString *data){

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



    NSString *urlStr = [NSString stringWithFormat:@"%@uploadPublicCardInfo.htm",environmentPath];
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

    NSString *parseParamsResult = [NSString stringWithFormat:@"data=%@",sendData];

    NSLog(@"HKWeChat %@ sendData:%@ 发送给服务器 %@ ",urlStr,sendData,parseParamsResult);


    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 服务器返回值为:%@",url);
        }
    }];
}

//发送同步信息
extern "C" void syncContactTask(int taskType,NSString*taskId, NSString *syncData,int isLast){

    //读出任务ID和orderID

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

    NSString *urlStr =@"";

    if(taskType == 45){
        urlStr = [NSString stringWithFormat:@"%@syncContact.htm",environmentPath];
    }else if(taskType == 79){
        urlStr = [NSString stringWithFormat:@"%@syncContactFromNearby.htm",environmentPath];
    }


    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&dataList=%@",taskId,syncData];

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

            uploadLog(geServerTypeTitle(m_current_taskType,5,@"执行上传通讯录结果"),[NSString stringWithFormat:@"结果为：%@",aString]);

        }
    }];
}


//发送通讯录筛选数据
extern "C" void syncFodderContact(NSString *syncData,NSString* taskId,NSString *nsUserName){

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

    NSString *urlStr = [NSString stringWithFormat:@"%@syncFodderContact.htm",environmentPath];

    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    uploadLog(geServerTypeTitle(77,3,@"执行函数syncFodderContact数据上传"),[NSString stringWithFormat:@"执行syncFodderContact"]);

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&dataList=[%@]&uuid=%@",taskId,syncData,nsUserName];

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

            uploadLog(geServerTypeTitle(77,7,@"执行上传通讯录筛选数据结果"),[NSString stringWithFormat:@"结果为：%@",aString]);
        }
    }];
}


//读取服务器发过来的类型
extern "C" NSString* geServerTypeTitle(int currentType,int currentNum,NSString *data){

     NSString *title = @"";
    int readType = currentType;

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
    }else if(m_current_taskType == 71){
        title = [NSString stringWithFormat:@"%d-当前执行71号任务%@",currentNum,data];
    }else if(m_current_taskType == 72){
        //通讯录发轮图片消息和名片(二次营销)
        title = [NSString stringWithFormat:@"%d-通讯录发轮图片消息和名片(二次营销)%@",currentNum,data];
    }else if(m_current_taskType == 73){
        //二次营销漂流瓶
        title = [NSString stringWithFormat:@"%d-二次营销漂流瓶(二次营销)%@",currentNum,data];
    }else if(m_current_taskType == 74){
        title = [NSString stringWithFormat:@"%d-修改个性签名%@",currentNum,data];
    }else if(m_current_taskType == 76){
        title = [NSString stringWithFormat:@"%d-微信摇一摇功能%@",currentNum,data];
    }else if(m_current_taskType == 77){
        title = [NSString stringWithFormat:@"%d-通讯录筛选好友%@",currentNum,data];
    }else if(m_current_taskType == 78){
        title = [NSString stringWithFormat:@"%d-78号任务加好友%@",currentNum,data];
    }else if(m_current_taskType == 79){
        title = [NSString stringWithFormat:@"%d-79号任务同步通讯录%@",currentNum,data];
    }else if(m_current_taskType == 80){
        //首页手机号搜索数据筛选
        title = [NSString stringWithFormat:@"%d-首页手机号搜索数据筛选%@",currentNum,data];
    }else if(m_current_taskType == 81){
        title = [NSString stringWithFormat:@"%d81号任务公众号关注-%@",currentNum,data];
    }else if(m_current_taskType == 88){
        title = [NSString stringWithFormat:@"%d88号任务上传群聊-%@",currentNum,data];
    }
    else if(readType == 0){
        title = [NSString stringWithFormat:@"%d-辅助日志%@",currentNum,data];
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
    }else if(readType == 66 || readType == 73){
        title = [NSString stringWithFormat:@"%d漂流瓶-%@",currentNum,data];
    }else if(readType == 64){
        title = [NSString stringWithFormat:@"%d公众号关注-%@",currentNum,data];
    }else if(readType == 68){
        title = [NSString stringWithFormat:@"%d群公告-%@",currentNum,data];
    }else if(readType == 69){
        title = [NSString stringWithFormat:@"%d修改性别和地区-%@",currentNum,data];
    }else if(readType == 70){
        title = [NSString stringWithFormat:@"%d首页上传附近人信息-%@",currentNum,data];
    }else if(readType == 71){
        title = [NSString stringWithFormat:@"%d当前执行71号任务-%@",currentNum,data];
    }else if(readType == 76){
        title = [NSString stringWithFormat:@"%d当前执行摇一摇-%@",currentNum,data];
    }else if(readType == 77){
        title = [NSString stringWithFormat:@"%d通讯录筛选好友-%@",currentNum,data];
    }else if(readType == 78){
        title = [NSString stringWithFormat:@"%d-78号任务加好友%@",currentNum,data];
    }else if(readType == 79){
        title = [NSString stringWithFormat:@"%d-79号任务同步通讯录%@",currentNum,data];
    }else if(readType == 80){
        //首页手机号搜索数据筛选
        title = [NSString stringWithFormat:@"%d-首页手机号搜索数据筛选%@",currentNum,data];
    }else if(readType == 81){
        title = [NSString stringWithFormat:@"%d81号任务公众号关注-%@",currentNum,data];
    }else if(readType == 88){
        title = [NSString stringWithFormat:@"%d88号任务上传群聊-%@",currentNum,data];
    }
    return title;
    
}


//启动时请求的的任务数据
extern "C" void getServerData(){

    NSMutableDictionary *taskInfo = loadTaskId();

    if([[taskInfo objectForKey:@"hookEnable"] intValue] != 1){
        m_isRequestResult = 3;

        NSLog(@"HKWeChat 当前微信没有开启HOOK");
        uploadLog(geServerTypeTitle(0,0,@"当前微信没有开启HOOK"),[NSString stringWithFormat:@"hookEnable不为1"]);
        write2File(@"/var/root/hkwx/operation.txt",@"-1");
        return;
    }

    if(m_isRequestResult > 1){
        return;
    }

    m_isRequestResult = 1;

    if([[taskInfo objectForKey:@"taskId"] isEqualToString:@"10000"]){
        m_current_modify = YES;
        NSLog(@"hkfodderwinxin 是修改头像地区信息");
    }

    if([[taskInfo objectForKey:@"taskId"] isEqualToString:@""]){

        NSLog(@"hkfodderwinxin 任务ID为空");

//        write2File(@"/var/root/hkwx/operation.txt",@"-1");

        m_isRequestResult = 6;
        return;
    }

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

//    uploadLog(getLocalTypeTitle(0,@"hook开始请求数据"),[NSString stringWithFormat:@"hook要请求的任务数据为：%@",urlStr]);

    // 2. Request
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    //开始请求数据
//    uploadLog(getLocalTypeTitle(1,@"请求数据"),[NSString stringWithFormat:@"开始执行 坏境为:%@",url]);

    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil && [m_taskArrayData count]<= 0) {
            // 网络请求结束之后执行!

            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableDictionary *taskAll = strngToDictionary(str);

            NSLog(@"HKWeChat 请求回来的数据为:%@ url:%@",taskAll,urlStr);


            if([[taskAll objectForKey:@"code"] intValue] == 0 && taskAll != nil){

                //拷贝数据链接url的数据
                [m_logurl addObject:[[taskAll objectForKey:@"logurl"] mutableCopy]];

                NSLog(@"当前的日志链接为：%@",m_logurl);

                m_isRequestResult = 2;

                for(NSArray *obj in [taskAll objectForKey:@"dataList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];

                }

                //得到显示日志
                [m_showTip addObject:[[taskAll objectForKey:@"topText1"] mutableCopy]];
                [m_showTip addObject:[[taskAll objectForKey:@"topText2"] mutableCopy]];
                [m_showTip addObject:[[taskAll objectForKey:@"topText3"] mutableCopy]];

                m_is72LogOpen = [[taskAll objectForKey:@"is72LogOpen"] intValue];

//                m_taskArrayData  = [taskAll objectForKey:@"dataList"];

                NSLog(@"HKWeChat count m_taskArrayData:%@ count:%lu",m_taskArrayData,(unsigned long)[m_taskArrayData count]);

                if([m_taskArrayData count] == 1){
                    //当前任务是修改头像和地区
                    m_taskDataDic = m_taskArrayData[0];
                }

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

%hook MMTableView
%property(nonatomic, copy) BOOL cellLayoutMarginsFollowReadableWidth;
%end

%hook NewMainFrameViewController

%new
- (void)batchMpDocReadCount:(NSString *)taskId{
    
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@WXGROUP_RED_MAP_LIST];
    enableMpDoc = [config[@"enableMpDoc"] boolValue];
    int interval = [config[@"interval"] intValue];
    int spaceCount = [config[@"spaceCount"] intValue];

    NSLog(@"HKWX this is batchMpDocReadCount:%@",config);

    //得到updateLink
    m_updateLink = [config[@"updateLink"] intValue];

    dispatch_group_async(groupOne, queueOne, ^{


        dispatch_async(dispatch_get_main_queue(), ^{

            //得到链接
            m_fetchUinAndKeyUrl = config[@"fetchUinAndKeyUrl"];

            if(m_fetchUinAndKeyUrl != nil && ![m_fetchUinAndKeyUrl isEqualToString:@""]){

                uploadLog(geServerTypeTitle(59,2,@"initWithURL初始化链接"),[NSString stringWithFormat:@"链接为：%@",m_fetchUinAndKeyUrl]);

                id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:m_fetchUinAndKeyUrl] presentModal:NO extraInfo:nil];
                [NSThread sleepForTimeInterval:5];

                m_current_taskIsOK = YES;

                hook_success_task(59,[m_taskDicKey objectForKey:@"taskId"]);

            }else{
                uploadLog(geServerTypeTitle(59,3,@"fetchUinAndKeyUrl执行获取key失败"),[NSString stringWithFormat:@"fetchUinAndKeyUrl链接为空"]);
                m_current_taskIsOK = YES;

                hook_fail_task(59,[m_taskDicKey objectForKey:@"taskId"],@"阅读获取key链接为空");
            }

            uploadLog(geServerTypeTitle(59,3,@"执行获取key结束"),[NSString stringWithFormat:@"执行完毕"]);

        });
        
    });


}


%new
- (void)changeHeadImg{

    if(![[m_taskDataDic objectForKey:@"headUrl"] isEqualToString:@""] && [m_taskDataDic objectForKey:@"headUrl"] != nil){

        uploadLog(geServerTypeTitle(m_current_taskType,5,@"开始执行修改头像"),@"开始");

        MMHeadImageMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"MMHeadImageMgr")];

        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:[m_taskDataDic objectForKey:@"headUrl"]]];
        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");

            uploadLog(geServerTypeTitle(53,5,@"执行头像下载失败"),[NSString stringWithFormat:@"下载失败 下载链接为：%@",[m_taskDataDic objectForKey:@"headUrl"]]);
            return;
        }

        UIImage *headImage = [[UIImage alloc] initWithData:data];
        [mgr uploadHDHeadImg:[headImage retain]];

        NSLog(@"hkweixin 修改头像成功");

        uploadLog(geServerTypeTitle(53,6,@"执行修改头像函数"),[NSString stringWithFormat:@"执行了 uploadHDHeadImg函数"]);

        //告诉服务器，修改完毕
//        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

        uploadLog(geServerTypeTitle(53,7,@"执行修改头像完毕告诉脚本"),[NSString stringWithFormat:@"告诉脚本"]);
    }else{

        uploadLog(geServerTypeTitle(53,5,@"服务端给的头像地址为空"),[NSString stringWithFormat:@"告诉脚本"]);
    }


    if(![[m_taskDataDic objectForKey:@"backgroundUrl"] isEqualToString:@""] && [m_taskDataDic objectForKey:@"backgroundUrl"] != nil){
        uploadLog(geServerTypeTitle(m_current_taskType,5,@"开始执行修改背景图片"),@"开始");

        WCFacade *fade = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"WCFacade")];

        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:[m_taskDataDic objectForKey:@"backgroundUrl"]]];

        if(data == nil){
            NSLog(@"hkweixin 下载头像失败");

            uploadLog(geServerTypeTitle(53,5,@"执行背景图片下载失败"),[NSString stringWithFormat:@"下载失败 下载链接为：%@",[m_taskDataDic objectForKey:@"backgroundUrl"]]);

            return;
        }

        [fade SetBGImgByImg:data];
        BOOL update = [fade updateTimelineHead];

        uploadLog(geServerTypeTitle(53,9,@"执行背景图片函数"),[NSString stringWithFormat:@"执行了 updateTimelineHead函数 %d",update]);

        NSLog(@"hkweixin 修改背景成功 %d",update);

        uploadLog(geServerTypeTitle(53,10,@"执行修改背景图片完毕"),[NSString stringWithFormat:@"%@",[m_taskDataDic objectForKey:@"headUrl"]]);
    }else{
        uploadLog(geServerTypeTitle(53,5,@"服务端给的背景图片址为空"),[NSString stringWithFormat:@"%@",[m_taskDataDic objectForKey:@"headUrl"]]);
    }


}

static CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

%new //发送瓶子消息
- (void)sendMsgToUser:(NSMutableArray *)allContacts{

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
                            uploadLog(geServerTypeTitle(66,9,@"bottleList执行发文字消"),@"");

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

                                    uploadLog(geServerTypeTitle(66,11,@"发消息-ResendMsg循环"),[NSString stringWithFormat:@"瓶子id:%@ 消息内容:%@ 循环索引号:%d",allContacts[i],msgContent[0],i]);

                                });

                                [NSThread sleepForTimeInterval:interval];

                                //判断是否有当前发文字信息
                                if(i == ([allContacts count] -1)){
                                    NSLog(@"hkweixin 发送漂流瓶结束,执行下一个任务");

                                    uploadLog(geServerTypeTitle(66,12,@"发消息-ResendMsg循环结束"),[NSString stringWithFormat:@"循环索引号:%d",[allContacts count]]);

                                    m_enterBottle = FALSE;
                                    //告知服务器结束

                                    uploadLog(geServerTypeTitle(66,16,@"告知服务器漂流瓶发送数据完毕"),@"");

                                    hook_success_task(66,[m_taskTypeDicBottle objectForKey:@"taskId"]);
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
                uploadLog(geServerTypeTitle(66,10,@"bottleList执行发图片消息"),@"");

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

                uploadLog(geServerTypeTitle(66,13,@"发消息-forwardMsgList发图"),[NSString stringWithFormat:@"瓶子id列表:%@",toContacts]);

                SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
                [view onConfirm];
                uploadLog(geServerTypeTitle(66,15,@"发消息-发送图片结束"),@"");

                //判断是否有当前发文字信息
                if([msgAllType rangeOfString:@"3"].location == NSNotFound){
                    m_enterBottle = FALSE;


                    uploadLog(geServerTypeTitle(66,16,@"告知服务器漂流瓶发送数据完毕"),@"");

                    //告诉可以执行下一个任务
                    hook_success_task(66,[m_taskTypeDicBottle objectForKey:@"taskId"]);
                }
            }
            
        }

        NSLog(@"hkwx sendCardMsgList 告诉服务器，发名片完毕");
        
    }


}


//修改性别和地区
%new
- (void)modifyUsrInfo{
    //修改头像和背景
    [self changeHeadImg];

//    - (void)modifyUsrInfo:(NSString *)country uiProvince:(NSString *)province uiCity:(NSString *)city uiSex:(int)sex  {
    NSLog(@"hkweixin country:%@ province:%@ city:%@ sex:%@",[m_taskDataDic objectForKey:@"country"],[m_taskDataDic objectForKey:@"province"],[m_taskDataDic objectForKey:@"city"],[m_taskDataDic objectForKey:@"uiSex"]);

    uploadLog(geServerTypeTitle(53,2,@"开始修改修改性别和地区"),[NSString stringWithFormat:@"数据为: country:%@ province:%@ city:%@ sex:%@",[m_taskDataDic objectForKey:@"country"],[m_taskDataDic objectForKey:@"province"],[m_taskDataDic objectForKey:@"city"],[m_taskDataDic objectForKey:@"uiSex"]]);

    id usrInfo = [[NSClassFromString(@"CUsrInfo") alloc] init];
    [NSClassFromString(@"SettingUtil") loadCurUserInfo:usrInfo];
    [usrInfo setM_uiSex:[[m_taskDataDic objectForKey:@"uiSex"] intValue]];
    [usrInfo setM_nsCountry:@"CN"];
    [usrInfo setM_nsProvince:[m_taskDataDic objectForKey:@"province"]];
    [usrInfo setM_nsCity:[m_taskDataDic objectForKey:@"city"]];
    [usrInfo setM_nsSignature:[m_taskDataDic objectForKey:@"msgContent"]];
    
    [NSClassFromString(@"UpdateProfileMgr") modifyUserInfo:usrInfo];
    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"UpdateProfileMgr")];
    [mgr updateUserProfile];

    uploadLog(geServerTypeTitle(53,3,@"修改性别和地区updateUserProfile"),[NSString stringWithFormat:@"用户数据为：%@",usrInfo]);

    //告诉脚本结束
    uploadLog(geServerTypeTitle(53,4,@"修改性别和地区执行函数updateUserProfile"),[NSString stringWithFormat:@"用户数据为：%@",usrInfo]);

    //告诉脚本置当前任务为成功
    write2File(@"/var/root/hkwx/wxResult.txt", @"1");
    //
//    hook_success_task

//    }
}

//修改个性签名
%new
-(void)modifySignature:(NSMutableDictionary *)taskDataDic{
    NSLog(@"");

    uploadLog(geServerTypeTitle(74,1,@"开始修改个性签名"),[NSString stringWithFormat:@"数据为: %@",[taskDataDic objectForKey:@"msgContent"]]);

    if([[taskDataDic objectForKey:@"msgContent"] isEqualToString:@""] || [taskDataDic objectForKey:@"msgContent"] == nil){

        uploadLog(geServerTypeTitle(74,2,@"修改个性签名失败"),[NSString stringWithFormat:@"服务端给的数据为空"]);
        return;
    }

    id usrInfo = [[NSClassFromString(@"CUsrInfo") alloc] init];
    [NSClassFromString(@"SettingUtil") loadCurUserInfo:usrInfo];
    [usrInfo setM_nsSignature:[taskDataDic objectForKey:@"msgContent"]];

    [NSClassFromString(@"UpdateProfileMgr") modifyUserInfo:usrInfo];
    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"UpdateProfileMgr")];
    [mgr updateUserProfile];

    uploadLog(geServerTypeTitle(74,3,@"修改个性签名成功"),[NSString stringWithFormat:@"执行下一个任务"]);

    hook_success_task(74,[taskDataDic objectForKey:@"taskId"]);
//    m_current_taskIsOK = YES;
}

//捡瓶子和发信息
%new
- (void)pickUpBottle{
    NSLog(@"开始 捡瓶子和发信息");

    if(m_is_bottlecomplain){

        uploadLog(geServerTypeTitle(66,6,@"得知漂流瓶被投诉了"),@"任务置失败 执行下一个任务");
        
        hook_fail_task(66,[m_taskTypeDicBottle objectForKey:@"taskId"],@"捡瓶子时被投诉了");
        return;
    }
    
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

    uploadLog(geServerTypeTitle(66,5,@"开始捡瓶子"),@"");

    //推送名片的wxid
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:5];

        for (int i = 0; i < m_pickupCount; i++) {

            dispatch_async(dispatch_get_main_queue(), ^{

                BottleMgr *bottleMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"BottleMgr")];

                [bottleMgr FishBottle];

                uploadLog(geServerTypeTitle(66,6,@"FishBottle循环"),[NSString stringWithFormat:@"循环索引号:%d",i]);

                NSLog(@"hkweixin 得到瓶子个数为:%d 当前捡瓶子：%d",bottleCount,i);

            });

            if(m_pickupinterval != 0){

                NSLog(@"hkweixin 111111111111 当前捡瓶子：%d %d",i,m_pickupinterval);

                [NSThread sleepForTimeInterval:m_pickupinterval];
            }

            if(i == (m_pickupCount - 1)){
                NSLog(@"hkweixin 捡瓶子结束");

                uploadLog(geServerTypeTitle(66,7,@"循环结束"),[NSString stringWithFormat:@"循环索引号:%d",m_pickupCount]);

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

            uploadLog(geServerTypeTitle(66,8,@"开始给瓶子发消息"),[NSString stringWithFormat:@"bottleMgr GetAllBottles 个数为：%d",bottleCount]);

            if(bottleCount <= 0){
                uploadLog(geServerTypeTitle(66,8,@"微信号没有瓶子"),[NSString stringWithFormat:@"结果"]);

                //告诉脚本结束
                uploadLog(geServerTypeTitle(66,7,@"告知脚本瓶子任务失败"),[NSString stringWithFormat:@"执行结果 operation.txt -1"]);

                //告诉脚本 发送失败
//                write2File(@"/var/root/hkwx/operation.txt",@"-1");

                hook_fail_task(66,[m_taskTypeDicBottle objectForKey:@"taskId"],@"得到瓶子的个数位0");

                NSLog(@"微信没有瓶子可以发送信息,执行下一个任务");

            }else{
                NSMutableArray *bottleList = [[NSMutableArray alloc] init];

                for (int i = 0; i < bottleCount; i++) {

                    CBottle *bottle  = [bottleMgr GetAllBottles][i];
                    NSLog(@"hkweixin bottle %@ %@",bottle,[bottle m_nsBottleName]);

                    [bottleList addObject:[bottle m_nsBottleName]];
                }

                NSLog(@"bottleList %@",bottleList);
                uploadLog(geServerTypeTitle(66,8,@"得到所有的瓶子"),[NSString stringWithFormat:@"%@",bottleList]);
                
                [self sendMsgToUser:bottleList];
            }

        });

    });
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

    uploadLog(geServerTypeTitle(65,2,@"asyncSearch公众号查询"),[NSString stringWithFormat:@"执行参数 query:%@ 名片：%@ 名片索引号:%d",query,cardUser,pos]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        NSLog(@"MYHOOK ftsWebSearchMgr: text: %@", [ftsWebSearchMgr respJson]);

        uploadLog(geServerTypeTitle(65,3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 respJson:%@ 名片：%@,名片索引号:%d",[ftsWebSearchMgr respJson],cardUser,pos]);

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

            uploadLog(geServerTypeTitle(65,4,@"xmlForMessageWrapContent"),[NSString stringWithFormat:@"执行结果 xmlForMessageWrapContent:%@ 名片：%@,名片索引号:%d",[contact xmlForMessageWrapContent],cardUser,pos]);

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

                        uploadLog(geServerTypeTitle(65,5,@"AddMsg循环"),[NSString stringWithFormat:@"执行结果 微信uuid:%@ 循环索引号:%d 名片：%@,名片索引号:%d",allContacts[i],i,cardUser,pos]);

                    });

                    [NSThread sleepForTimeInterval:m_interval];

                    
                    NSLog(@"hkWeixinSendCard first is send end");
                }


                uploadLog(geServerTypeTitle(65,6,@"AddMsg循环结束"),[NSString stringWithFormat:@"执行结果  名片：%@,名片索引号:%d",cardUser,pos]);

                if(m_endCardOne){

                    uploadLog(geServerTypeTitle(65,7,@"告知脚本结束"),[NSString stringWithFormat:@"执行结果"]);

                    //告诉脚本 第二个发送完毕
//                    write2File(@"/var/root/hkwx/wxResult.txt", @"1");
                    NSLog(@"进行下一个任务");
                    //开始执行发送消息

                }


                m_endCardOne = TRUE;

            });
            
        }else{

            uploadLog(geServerTypeTitle(65,3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 为空"]);

            m_endCardOne = TRUE;
        }

    });

}


%new
- (void)attentionAllCard{

     //得到有多少个wxid
    NSMutableArray *members = [[m_taskDataDic objectForKey:@"members"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //推名片的时间
    int interval = [[m_taskDataDic objectForKey:@"sendMsgInterval"] intValue];


    //得到有多少个user
    NSMutableArray *cardUsers = [[m_taskDataDic objectForKey:@"cardUser"] componentsSeparatedByString:@","];

    //得出时间
    int m_interval = [[m_taskDataDic objectForKey:@"publicCardInterval"] intValue];

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

            uploadLog(geServerTypeTitle(65,2,@"asyncSearch公众号查询等待查询"),[NSString stringWithFormat:@"没有查询到数据 :%@",[ftsWebSearchMgr respJson]]);
        }

    });

    

    //第一个微信号 延时5S
    dispatch_group_async(groupOne, queueOne, ^{

        while(!isRespJson){
            NSLog(@"hkWeixinSendCard 等待第可以收到微信号");
            [NSThread sleepForTimeInterval:5];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            uploadLog(geServerTypeTitle(65,2,@"开始发送第一个名片"),[NSString stringWithFormat:@"执行结果 名片：%@",cardUsers[0]]);

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

            uploadLog(geServerTypeTitle(65,2,@"开始发送第二个名片"),[NSString stringWithFormat:@"执行结果 名片：%@",cardUsers[1]]);

            [self sendCardByWxidList:members cardUser:cardUsers[1] pos:2];


        });
        
    });//dis

}

CLLocation *lbsLocation = nil;
//首页附近人
%new
- (void)findLBSUsrs:(NSMutableDictionary*)taskDataDic{

    double latitude =  [[taskDataDic objectForKey:@"latitude"] doubleValue]; //133;
    double longitude =  [[taskDataDic objectForKey:@"longitude"] doubleValue]; //100;

    uploadLog(geServerTypeTitle(70,2,@"开始进入函数"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);

    if(latitude <= 0 || longitude  <= 0){
        uploadLog(geServerTypeTitle(70,3,@"经纬度错误"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];

    uploadLog(geServerTypeTitle(70,4,@"开始定位坐标"),[NSString stringWithFormat:@"%@",location]);

    __block int nearByIntervalSec = [[taskDataDic objectForKey:@"nearByIntervalSec"] intValue];
    if(nearByIntervalSec == 0){
        nearByIntervalSec = 15;
    }

    uploadLog(geServerTypeTitle(70,5,@"开始执行获取附近信息"),[NSString stringWithFormat:@"停留时间为:%d",nearByIntervalSec]);

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

            uploadLog(geServerTypeTitle(70,6,@"开始获取附近信息"),[NSString stringWithFormat:@"获取附近人信息的个数ccList %d",[ccList count]]);
            if([ccList count]<= 0){
                uploadLog(geServerTypeTitle(70,6,@"开始获取附近信息失败"),[NSString stringWithFormat:@"获取到的数据为空"]);

                hook_fail_task(70,[taskDataDic objectForKey:@"taskId"],@"获取首页附近人列表为空");
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

                 NSString *oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\",\"distance\":\"%@\",\"signature\":\"%@\"}",[info userName],[info m_nsAlias],nickName,nsCountry,nsProvince,nsCity,[info sex],[info distance],signature];

                NSLog(@"%@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }

            }

            uploadLog(geServerTypeTitle(70,7,@"数据上传服务器 syncNearbyCContactTask"),@"");

            //发送给服务端
            syncNearbyCContactTask(dataJson,[taskDataDic objectForKey:@"latitude"],[taskDataDic objectForKey:@"longitude"]);

            //告诉服务器成功
            hook_success_task(70,[taskDataDic objectForKey:@"taskId"]);

        });
        
    });//dis

}

- (void)removeObserver:(id)observer
{
    %orig;
    NSLog(@"====%@ remove===", [observer class]);
}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;
}


//筛选数据并添加好友
%new
- (void)addFriendScreenByWXId:(NSMutableDictionary *)taskDataDic{
    //初始化一下发送名片
    [self initQueryCard];

    NSString *friends = [taskDataDic objectForKey:@"members"];

    //    NSMutableDictionary *nearByFriend = [m_taskDataDic ]
    NSMutableArray *listNearBy = [friends componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    if([listNearBy count] <=0 || [friends isEqualToString:@""] || friends == nil){
        uploadLog(geServerTypeTitle(78,0,@"当前任务服务端没有给members数据"),[NSString stringWithFormat:@"当前任务结束",[listNearBy count]]);

        hook_fail_task(78,[taskDataDic objectForKey:@"taskId"],@"筛选数据时,给的数据为空");
        return;
    }
    //加好友的时间
    int interval = [[taskDataDic objectForKey:@"addPersonInterval"] intValue];

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

//            uploadLog(geServerTypeTitle(78,2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"执行完毕 微信标识:%@ 循环索引号:%d",listNearBy[i],i]);

            //进行延时，UI刷新
            [NSThread sleepForTimeInterval:interval];

            dispatch_async(dispatch_get_main_queue(), ^{
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];
            });
        }

        NSLog(@"HKWECHAT 添加微信完毕");
        uploadLog(geServerTypeTitle(78,3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%lu个",(unsigned long)[listNearBy count]]);

        NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listNearBy count], (unsigned long)[listNearBy count]];
        nearByFriendlable.text = text;
        [nearByFriendlable setNeedsDisplay];

        //通知发消息
        uploadLog(geServerTypeTitle(78,4,@"暴力加好友加完毕"),[NSString stringWithFormat:@"开始执行通知"]);
        
        hook_success_task(78,[taskDataDic objectForKey:@"taskId"]);
        
    });
}

//暴力添加好友
%new
- (void)addFriendByWXIdnew:(NSMutableDictionary *)taskDataDic {

    NSString *friends = [taskDataDic objectForKey:@"members"];

    NSMutableArray *listNearBy = [friends componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //加好友的时间
    int interval = [[taskDataDic objectForKey:@"addPersonInterval"] intValue];

    dispatch_group_async(group, queue, ^{

        id abfvcf = [[NSClassFromString(@"AddressBookFriendViewController") alloc] init];

        //            NSMutableArray *strangers = config[@"strangers"];
        NSLog(@"HKWX part1: (71)=======================+>>> %lu",(unsigned long)[listNearBy count]);

        for (int i = 0; i < [listNearBy count]; i++) {
            CContact *cc = [[NSClassFromString(@"CContact") alloc] init];

            cc.m_nsUsrName = listNearBy[i];

            cc.m_uiFriendScene =  [[taskDataDic objectForKey:@"uiScene"] intValue];

            [abfvcf verifyContactWithOpCode:cc opcode:1];

            NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[listNearBy count]];

            NSLog(@"HKWX m_nsUsrName:%@",listNearBy[i]);

            uploadLog(geServerTypeTitle(71,2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"执行完毕 微信标识:%@ 循环索引号:%d",listNearBy[i],i]);

            //进行延时，UI刷新
            [NSThread sleepForTimeInterval:interval];

            dispatch_async(dispatch_get_main_queue(), ^{
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];
            });
        }

        NSLog(@"HKWECHAT 添加微信完毕");
        uploadLog(geServerTypeTitle(71,3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%lu个",(unsigned long)[listNearBy count]]);

        NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listNearBy count], (unsigned long)[listNearBy count]];
        nearByFriendlable.text = text;
        [nearByFriendlable setNeedsDisplay];

        if([m_addErrorInfo count] > 0){

            NSString *dataJson = @"";

            for(int i = 0; i<[m_addErrorInfo count]; i++){
                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",m_addErrorInfo[i]];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,m_addErrorInfo[i]];
                }
            }

            NSLog(@"dataJson is %@",dataJson);

            //上传数据给服务端
            uploadAddFriendData([taskDataDic objectForKey:@"taskId"],dataJson);

        }

        //通知发消息
        uploadLog(geServerTypeTitle(71,4,@"暴力加好友加完毕"),[NSString stringWithFormat:@"开始执行通知"]);
        
        hook_success_task(71,[taskDataDic objectForKey:@"taskId"]);
        
    });
}


//暴力添加好友 //437
%new
- (void)addFriendByWXId:(NSMutableDictionary *)taskDataDic {
    //初始化一下发送名片
//    [self initQueryCard];

    NSString *friends = [taskDataDic objectForKey:@"members"];

    //    NSMutableDictionary *nearByFriend = [m_taskDataDic ]
    NSMutableArray *listNearBy = [friends componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //加好友的时间
    int interval = [[taskDataDic objectForKey:@"addPersonInterval"] intValue];

    dispatch_group_async(group, queue, ^{

        CContactVerifyLogic *logic = [[NSClassFromString(@"CContactVerifyLogic") alloc] init];
        //            NSMutableArray *strangers = config[@"strangers"];
        NSLog(@"HKWX part1: (71)=======================+>>> %lu",(unsigned long)[listNearBy count]);

        for (int i = 0; i < [listNearBy count]; i++) {
            CVerifyContactWrap *wrap = [[NSClassFromString(@"CVerifyContactWrap") alloc] init];
            wrap.m_nsUsrName = listNearBy[i];
            //3:来自微信号搜索 6:通过好友同意  13:来自手机通讯录 14:群聊 17:通过名片分享添加  18:来自附近人 30:通过扫一扫添加 39:搜索公众号来源
            if(![[taskDataDic objectForKey:@"uiScene"] isEqualToString:@""]){
                NSLog(@"this is addFriendByWXId [uiScene intValue]:%d",[[taskDataDic objectForKey:@"uiScene"] intValue]);

                wrap.m_uiScene =  [[taskDataDic objectForKey:@"uiScene"] intValue];
            }

            [logic startWithVerifyContactWrap:@[wrap]  opCode: 1 parentView:[self view]  fromChatRoom: nil];
            [logic reset];

            NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(i + 1), (unsigned long)[listNearBy count]];

            NSLog(@"HKWX m_nsUsrName:%@",listNearBy[i]);

            uploadLog(geServerTypeTitle(71,2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"执行完毕 微信标识:%@ 循环索引号:%d",listNearBy[i],i]);

            //进行延时，UI刷新
            [NSThread sleepForTimeInterval:interval];

            dispatch_async(dispatch_get_main_queue(), ^{
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];
            });
        }

        NSLog(@"HKWECHAT 添加微信完毕");
        uploadLog(geServerTypeTitle(71,3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%lu个",(unsigned long)[listNearBy count]]);

        NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listNearBy count], (unsigned long)[listNearBy count]];
        nearByFriendlable.text = text;
        [nearByFriendlable setNeedsDisplay];

        if([m_addErrorInfo count] > 0){

            NSString *dataJson = @"";

            for(int i = 0; i<[m_addErrorInfo count]; i++){
                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",m_addErrorInfo[i]];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,m_addErrorInfo[i]];
                }
            }

            NSLog(@"dataJson is %@",dataJson);

            //上传数据给服务端
            uploadAddFriendData([taskDataDic objectForKey:@"taskId"],dataJson);
            
        }

        //通知发消息
        uploadLog(geServerTypeTitle(71,4,@"暴力加好友加完毕"),[NSString stringWithFormat:@"开始执行通知"]);
        
        hook_success_task(71,[taskDataDic objectForKey:@"taskId"]);
        
    });
}


//暴力添加好友
%new //4.1.3 版本
- (void)addFriendByWXId413:(NSMutableDictionary *)taskDataDic {
    //初始化一下发送名片
    [self initQueryCard];

    NSString *friends = [taskDataDic objectForKey:@"members"];

//    NSMutableDictionary *nearByFriend = [m_taskDataDic ]
    NSMutableArray *listNearBy = [friends componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //加好友的时间
    int interval = [[taskDataDic objectForKey:@"addPersonInterval"] intValue];

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

            uploadLog(geServerTypeTitle(71,2,@"startWithVerifyContactWrap循环"),[NSString stringWithFormat:@"执行完毕 微信标识:%@ 循环索引号:%d",listNearBy[i],i]);

            //进行延时，UI刷新
            [NSThread sleepForTimeInterval:interval];

            dispatch_async(dispatch_get_main_queue(), ^{
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];
            });
        }

        NSLog(@"HKWECHAT 添加微信完毕");
        uploadLog(geServerTypeTitle(71,3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%lu个",(unsigned long)[listNearBy count]]);

        NSString *text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)[listNearBy count], (unsigned long)[listNearBy count]];
        nearByFriendlable.text = text;
        [nearByFriendlable setNeedsDisplay];

        //通知发消息
        uploadLog(geServerTypeTitle(71,4,@"暴力加好友加完毕"),[NSString stringWithFormat:@"开始执行通知"]);

        hook_success_task(71,[taskDataDic objectForKey:@"taskId"]);

    });
}


%new
-(void)registerNotification{
    //发朋友圈
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFriends:) name:kSendFriendsNotificton object:nil];
    //发消息和链接
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgAndLink:) name:kMsgAndLinkNotificton object:nil];
    //关注公众号
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attentionPublicCard:) name:kAttentionPublicCardNotificton object:nil];
    //漂流瓶
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driftingBottle) name:kDriftingBottleNotificton object:nil];

    //回首页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickUpBottle) name:kSendDriftingBottleNotificton object:nil];
    //推送发名片消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMsgOnePerson:) name:kSendMsgOnePerson object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackChatRoom:) name:kAttackChatRoomsNotificton object:nil];

    //发送开始扫码通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanQRCodeFunction) name:kScanQRCodeNotificton object:nil];
}

dispatch_queue_t voicequeue = dispatch_queue_create("sendVoiceMessage", DISPATCH_QUEUE_CONCURRENT);
//发送语音
%new
-(void)sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
    NSLog(@"发送语音消息");
    //wxid_x4asq8c7bov521  http://crobo-pic.qiniudn.com/test2.amr

    if([voiceUrl isEqualToString:@""]){
        uploadLog(geServerTypeTitle(4,6,@"发送语音消息为空,不能发送语音消息"),[NSString stringWithFormat:@"发送语音消息失败"]);
        return;
    }

    dispatch_barrier_async(voicequeue, ^{
        int msgType = 34;
        CMessageWrap *voiceMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[m_nCSetting m_nsUsrName]];
        CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

        voiceMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[m_nCSetting m_nsUsrName]];
        voiceMsg.m_uiVoiceFormat = 4;
        voiceMsg.m_nsFromUsr = [m_nCSetting m_nsUsrName];
        voiceMsg.m_nsToUsr = toUser;
        voiceMsg.m_uiVoiceEndFlag = 1;
        voiceMsg.m_uiCreateTime = (int)time(NULL);

        if (m_voiceData.bytes > 0) {
        }else{
            m_voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:voiceUrl]];
        }

        NSData *voiceData = m_voiceData;//[NSData dataWithContentsOfURL:[NSURL URLWithString:voiceUrl]];
        NSString *path = [NSClassFromString(@"CMessageWrap") getPathOfMsgImg:voiceMsg];
        path = [path stringByReplacingOccurrencesOfString:@"Img" withString:@"Audio"];
        path = [path stringByReplacingOccurrencesOfString:@".pic" withString:@".aud"];
        NSString *pathDir = [path stringByDeletingLastPathComponent];
        system([[[NSString alloc] initWithFormat:@"mkdir -p %@", pathDir] UTF8String]);
        [voiceData writeToFile:path atomically:YES];

        NSLog(@"MYHOOK oh mypath is: %@, %@", path, voiceMsg);

        voiceMsg.m_dtVoice = [voiceData retain];
        voiceMsg.m_uiVoiceTime = [voiceTime intValue];//100000;

        AudioSender *senderMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AudioSender")];

        [senderMgr ResendVoiceMsg:toUser MsgWrap:voiceMsg];
        
        uploadLog(geServerTypeTitle(71,7,@"发送语音消息成功ResendVoiceMsg"),[NSString stringWithFormat:@"发送语音消息成功"]);
        
    });

}

//发送文字
%new
-(void)sendTextMessages:(NSString *)toUser textContent:(NSString *)textContent{
    NSLog(@"发送文字 1111");

    if([textContent isEqualToString:@""]){
        uploadLog(geServerTypeTitle(4,6,@"发送文字内容为空,不能发送文字"),[NSString stringWithFormat:@"发送文字失败"]);
        return;
    }

    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nCSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = textContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nCSetting m_nsUsrName];
    myMsgText.m_nsToUsr = toUser;
    myMsgText.m_uiCreateTime = (int)time(NULL);
    [msMgrText ResendMsg: toUser MsgWrap:myMsgText];
    NSLog(@"MYHOOK will send to %@:", myMsgText);

}


static dispatch_group_t groupPic= dispatch_group_create();
static dispatch_queue_t queuePic = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


%new
-(void)sendPictureAllMessage:(NSString *)picUr{

    if([m_picWXids count] <= 0){

        uploadLog(geServerTypeTitle(m_current_taskType,3,@"开始放送图片信息，当前没有添加上好友"),[NSString stringWithFormat:@"当前处于发送图片消息,图片URL为%@",picUr]);
        return;
    }
    
    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    NSString *myself = [[mgr getSelfContact] m_nsUsrName];

    NSMutableArray *toContacts = [[NSMutableArray alloc] init];

    for (int i = totalCardSend; i < [m_picWXids count]; i++) {
        CContact *cc = [mgr getContactByName:m_picWXids[i]];
        [toContacts addObject:cc];
    }

    CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:myself];

    myMsg.m_uiCreateTime = (int)time(NULL);

    ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
    myMsg.m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUr]];
    [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];

    SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
    [view onConfirm];

}

dispatch_queue_t picqueue = dispatch_queue_create("sendPictureMessages", DISPATCH_QUEUE_CONCURRENT);

id fvc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
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

        uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送图片信息"),[NSString stringWithFormat:@"图片信息为：%@",picUrl]);

    });

//    dispatch_group_async(groupPic, queuePic, ^{
//
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr") class]];
//            CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nCSetting m_nsUsrName]];
//
//            if (m_dtImg.bytes > 0) {
//             }else{
//                m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
//            }
//
//            [msgWrap setM_dtImg:m_dtImg];
//            [msgWrap setM_nsToUsr:toUser];
//            [msgWrap setM_uiStatus:2];
//            [msgWrap setM_asset:nil];
//            [msgWrap setM_oImageInfo:nil];
//            id cc = [[NSClassFromString(@"CContact") alloc] init];
//            [cc setM_nsUsrName:toUser];
//            [fvc ForwardMsg:msgWrap ToContact:cc];
//
//            uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送图片信息"),[NSString stringWithFormat:@"图片信息为：%@",picUrl]);
//        });
//        
//    });

}

%new //4.3.0版本
-(void)sendPictureMessages1:(NSString *)toUser pic:(NSString *)picUrl{
    NSLog(@"发送图片4.3.0版本");
    if([picUrl isEqualToString:@""] || [toUser isEqualToString:@""]){
        uploadLog(geServerTypeTitle(0,6,@"发送发送图片为空,不能发送图片"),[NSString stringWithFormat:@"发送图片失败"]);
        return;
    }


    dispatch_group_async(groupPic, queuePic, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];

            NSMutableArray *toContacts = [[NSMutableArray alloc] init];
            CContact *cc = [mgr getContactByName:toUser];
            [toContacts addObject:cc];

            ForwardMessageLogicController *fmlc = [[NSClassFromString(@"ForwardMessageLogicController") alloc] init];
            CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:3 nsFromUsr:[m_nCSetting m_nsUsrName]];

            if (m_dtImg.bytes > 0) {
                myMsg.m_dtImg = m_dtImg;
            }else{
                m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
                myMsg.m_dtImg = m_dtImg;
            }

            [fmlc forwardMsgList:@[myMsg] toContacts:toContacts];

            SharePreConfirmView *view = MSHookIvar<SharePreConfirmView *>(fmlc, "m_confirmView");
            [view onConfirm];

            uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送图片信息"),[NSString stringWithFormat:@"图片信息为：%@",picUrl]);
        });
        
    });

}

static dispatch_group_t groupCard = dispatch_group_create();
static dispatch_queue_t queueCard = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

//发送名片
%new
-(void)sendCardMessage:(NSString *)toUser toContact:(CContact *)toContact{

    NSLog(@"开始发名片 toUser:%@ toContact:%@",toUser,toContact);

    dispatch_group_async(groupCard, queueCard, ^{

        id mgrCard = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
        id msgCard = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

        [msgCard setM_nsToUsr:toUser];
        [msgCard setM_nsFromUsr:[m_nCSetting m_nsUsrName]];
        [msgCard setM_nsContent:[toContact xmlForMessageWrapContent]];
        [msgCard setM_uiCreateTime:(int)time(NULL)];

        [mgrCard AddMsg:toUser MsgWrap:msgCard];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"当前的发名片任务结束:%@",toUser);

            uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送名片信息"),[NSString stringWithFormat:@"名片信息为：%@",toContact]);
        });
        
    });
}

%new
-(void)sendLinkMessages:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink{

    NSLog(@"发送图文链接 %@ shareLink:%@",toUser,shareLink);
    if([[shareLink objectForKey:@"linkUrl"] isEqualToString:@""]){
        uploadLog(geServerTypeTitle(0,6,@"发送图文链接链接为空,不能发送图文链接"),[NSString stringWithFormat:@"发送链接失败"]);
        return;
    }

    CContactMgr *mgrLink = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgLink = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49 nsFromUsr:[m_nCSetting m_nsUsrName]];
    CMessageMgr *msMgrLink = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

    myMsgLink.m_nsContent = [[[[linkTemplatetest stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:[shareLink objectForKey:@"title"]]
                               stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:[shareLink objectForKey:@"desc"]]
                              stringByReplacingOccurrencesOfString:@"LINK_URL" withString:[shareLink objectForKey:@"linkUrl"]]
                             stringByReplacingOccurrencesOfString:@"LINK_PIC" withString:[shareLink objectForKey:@"showPicUrl"]];
    //                                myMsg.m_uiMesLocalID = (unsigned int)randomInt(10000, 99999);
    myMsgLink.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgLink.m_nsFromUsr = [m_nCSetting m_nsUsrName];
    myMsgLink.m_nsToUsr = toUser;
    myMsgLink.m_uiCreateTime = (int)time(NULL);
    NSLog(@"MYHOOK-linkinfo: %@, %@", myMsgLink.m_nsContent, myMsgLink);
    [msMgrLink ResendMsg:toUser MsgWrap:myMsgLink];
    NSLog(@"MYHOOK will send to %@:", myMsgLink);

    uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送图文链接链接"),[NSString stringWithFormat:@"图文链接链接信息：%@",myMsgLink.m_nsContent]);
}

%new
-(void)sendLinkMessages2:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink{

//    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": @"https://mp.weixin.qq.com/mp/profile_ext?action=home&amp;__biz=MjM5OTM0MzIwMQ==&amp;scene=123#wechat_redirect", @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSDictionary *info = @{@"title": [shareLink objectForKey:@"title"], @"desc": [shareLink objectForKey:@"desc"], @"url": [shareLink objectForKey:@"linkUrl"], @"pic_rl": [shareLink objectForKey:@"showPicUrl"], @"userName": toUser};

    NSLog(@"info is %@",info);

    id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    id cmgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
//    id msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49];
    CMessageWrap* msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49];
    id ext = [[NSClassFromString(@"CExtendInfoOfAPP") alloc] init];
    NSString *formated = [[NSString alloc] initWithContentsOfFile:@"/var/root/hkwx/linktmp.xml"];
    [ext setM_nsTitle:info[@"title"]];
    [ext setM_nsDesc:info[@"desc"]];

    [msg setM_nsDesc:info[@"desc"]];
    [msg setM_nsShareOriginUrl:info[@"url"]];
    [msg setM_nsFromUsr:[[cmgr getSelfContact] m_nsUsrName]];
    [msg setM_nsToUsr:info[@"userName"]];
//    [msg setM_dtThumbnail:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[shareLink objectForKey:@"showPicUrl"]]]];
    msg.m_dtThumbnail  = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[shareLink objectForKey:@"showPicUrl"]]];
    [msg setM_uiCreateTime:time(NULL)];
    [msg setM_uiStatus:1];
    [msg setM_extendInfoWithMsgType:ext];
    [msg setM_nsContent:[[NSString alloc] initWithFormat:formated, info[@"title"], info[@"desc"], info[@"url"], [msg m_nsFromUsr], info[@"pic_url"]]];
    NSLog(@"MYHOOK msg: %@", msg);
    [mgr AddAppMsg:[msg m_nsToUsr] MsgWrap:msg Data:nil Scene:2];

    uploadLog(geServerTypeTitle(m_current_taskType,3,@"发送图文链接链接"),[NSString stringWithFormat:@"图文链接链接信息：%@",info]);

}

//发送图文链接 4.0.0 版本
%new
-(void)sendLinkMessages1:(NSString *)toUser shareLink:(NSMutableDictionary *)shareLink{

    NSLog(@"发送图文链接 %@ shareLink:%@",toUser,shareLink);
    if([[shareLink objectForKey:@"linkUrl"] isEqualToString:@""]){
        uploadLog(geServerTypeTitle(0,6,@"发送图文链接链接为空,不能发送图文链接"),[NSString stringWithFormat:@"发送链接失败"]);
        return;
    }

    CContactMgr *mgrLink = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgLink = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49 nsFromUsr:[m_nCSetting m_nsUsrName]];
    CMessageMgr *msMgrLink = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

    myMsgLink.m_nsContent = [[[[linkTemplate stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:[shareLink objectForKey:@"title"]]
                               stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:[shareLink objectForKey:@"desc"]]
                              stringByReplacingOccurrencesOfString:@"LINK_URL" withString:[shareLink objectForKey:@"linkUrl"]]
                             stringByReplacingOccurrencesOfString:@"LINK_PIC" withString:[shareLink objectForKey:@"showPicUrl"]];
    //                                myMsg.m_uiMesLocalID = (unsigned int)randomInt(10000, 99999);
    myMsgLink.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgLink.m_nsFromUsr = [m_nCSetting m_nsUsrName];
    myMsgLink.m_nsToUsr = toUser;
    myMsgLink.m_uiCreateTime = (int)time(NULL);
    NSLog(@"MYHOOK-linkinfo: %@, %@", myMsgLink.m_nsContent, myMsgLink);
    [msMgrLink ResendMsg:toUser MsgWrap:myMsgLink];
    NSLog(@"MYHOOK will send to %@:", myMsgLink);
}


static dispatch_group_t groupOnePerson = dispatch_group_create();
static dispatch_queue_t queueOnePerson = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

%new
-(void)sendMsgOnePerson:(NSNotification *)notificationText{
    //给一个人推送名片和消息 71 号任务
    NSLog(@"(71)notificationText %@ %@ %@",notificationText.userInfo,m_taskTypeDic71,[m_taskTypeDic71 objectForKey:@"shareLinkArr"]);

    int currentType = [[m_taskTypeDic71 objectForKey:@"taskType"] intValue];

    NSString *wxid = (NSString *)notificationText.userInfo;
    if([wxid isEqualToString:@""]){
        uploadLog(geServerTypeTitle(currentType,2,@"接受到加完好友后的通知为空数据,不能发送消息"),[NSString stringWithFormat:@"数据失败"]);
        return;
    }

    uploadLog(geServerTypeTitle(currentType,2,@"接受到加完好友后的通知(当前需要发消息和发名片)"),[NSString stringWithFormat:@"接受到的消息为：%@",notificationText.userInfo]);

    [m_picWXids addObject:wxid];

    dispatch_group_async(groupOnePerson, queueOnePerson, ^{


        //发送名片
        int cardCount = [[m_taskTypeDic71 objectForKey:@"cardCount"] intValue];

        NSMutableArray *publicCardArr = [[NSMutableArray alloc] init];
        if(cardCount > 0){
            for(NSArray *obj in [m_taskTypeDic71 objectForKey:@"publicCardArr"]){
                [publicCardArr addObject:[obj mutableCopy]];
            }
        }

        if(cardCount <= 0){
            NSLog(@"71发送名片 MYHOOK 为空");
            uploadLog(geServerTypeTitle(71,3,@"得到发送名片为空"),[NSString stringWithFormat:@"服务没有给数据"]);
        }else{
            //开始发送名片
            for(int i = 0; i<cardCount; i++){

                id contact = [[NSClassFromString(@"CContact") alloc] init];

                [contact setM_nsAliasName:[publicCardArr[i] objectForKey:@"nsAliasName"]];
                [contact setM_nsUsrName:[publicCardArr[i] objectForKey:@"nsUsrName"]];
                [contact setM_nsNickName:[publicCardArr[i] objectForKey:@"nsNickName"]];
                [contact setM_nsSignature:[publicCardArr[i] objectForKey:@"nsSignature"]];
                [contact setM_nsBrandIconUrl:[publicCardArr[i] objectForKey:@"nsBrandIconUrl"]];
                [contact setM_uiCertificationFlag:[[publicCardArr[i] objectForKey:@"uiCertificationFlag"] intValue]];
                NSLog(@"MYHOOK contact: %@", contact);

                [self sendCardMessage:wxid toContact:contact];
            }
        }


        //发送图片
        NSString *picUrl = [m_taskTypeDic71 objectForKey:@"picUrl"];
//        NSString *picUrl = @"http://crobo-pic.qiniudn.com/shaike_39159f8b40a74c8d84a5be297ceb139d.jpg";//[taskDataDic objectForKey:@"picUrl"];
        NSLog(@"发送图片:%@",picUrl);

        if([picUrl isEqualToString:@""]){
            NSLog(@"MYHOOK textContent is null");
            uploadLog(geServerTypeTitle(currentType,3,@"得到发送图片为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片",wxid]);
        }else{

            uploadLog(geServerTypeTitle(currentType,3,@"开始发送图片消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl]);
            [self sendPictureMessages:wxid pic:picUrl];
        }


        //发消息
        CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
        //得到自己的信息
        NSString *myself = [[mgr getSelfContact] m_nsUsrName];

        //判断有几条图文链接
        int linkCount = [[m_taskTypeDic71 objectForKey:@"linkCount"] intValue];

        NSLog(@"有几条图文链接:%d 数据为:%@",linkCount,[m_taskTypeDic71 objectForKey:@"shareLinkArr"]);
        NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
        if(linkCount > 0){
            for(NSArray *obj in [m_taskTypeDic71 objectForKey:@"shareLinkArr"]){
                [shareLinkArr addObject:obj];
            }
        }

        NSLog(@"图文链接数据:%@",shareLinkArr);

        if(linkCount==0){
            //当前没有给链接信息
            uploadLog(geServerTypeTitle(currentType,4,@"服务端没有图文链接"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
        }else{
            NSLog(@"图文链接数据:%@",shareLinkArr);
            for(int i=0; i < linkCount; i++){
                //当前有一个图文链接
                uploadLog(geServerTypeTitle(currentType,4,@"服务端发送图文链接开始发送"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接,当前的位置:%d",wxid,i]);

                //得到图文链接
                [self sendLinkMessages:wxid shareLink:shareLinkArr[i]];
            }
        }

        NSString *textContent = [m_taskTypeDic71 objectForKey:@"msgContent"];
        NSLog(@"发送文字:%@",textContent);
        //判断发送文字
        if([textContent isEqualToString:@""]){
            NSLog(@"MYHOOK textContent is null");
            uploadLog(geServerTypeTitle(currentType,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送消息",wxid]);

        }else{

            uploadLog(geServerTypeTitle(currentType,2,@"开始发送文字消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,textContent]);

            //发送文字
            [self sendTextMessages:wxid textContent:textContent];
        }

        //发送语音
        NSString *voiceUrl = [m_taskTypeDic71 objectForKey:@"voiceUrl"];
        if([voiceUrl isEqualToString:@""]){
            //当前没有发送语音
            uploadLog(geServerTypeTitle(currentType,4,@"服务端没有发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送语音",wxid]);
        }else{
            
            //        sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
            [self sendVoiceMessage:wxid voiceUrl:voiceUrl voiceTime:[m_taskTypeDic71 objectForKey:@"voiceTime"]];
            
            uploadLog(geServerTypeTitle(currentType,4,@"服务端发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于语音 语音链接：%@",wxid,voiceUrl]);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            uploadLog(geServerTypeTitle(currentType,5,@"当前用户的71号任务结束"),[NSString stringWithFormat:@"用户的微信ID为 wxid:%@",wxid]);
        });
        
    });

}

%new //4.1.3
-(void)sendMsgOnePerson413:(NSNotification *)notificationText{
    //给一个人推送名片和消息 71 号任务

    NSLog(@"notificationText %@ %@ %@",notificationText.userInfo,m_taskTypeDic71,[m_taskTypeDic71 objectForKey:@"shareLinkArr"]);

    int currentType = [[m_taskTypeDic71 objectForKey:@"taskType"] intValue];

    NSString *wxid = (NSString *)notificationText.userInfo;
    if([wxid isEqualToString:@""]){
        uploadLog(geServerTypeTitle(currentType,2,@"接受到加完好友后的通知为空数据,不能发送消息"),[NSString stringWithFormat:@"数据失败"]);
        return;
    }

    uploadLog(geServerTypeTitle(currentType,2,@"接受到加完好友后的通知(当前需要发消息和发名片)"),[NSString stringWithFormat:@"接受到的消息为：%@",notificationText.userInfo]);

    //发送名片
    NSArray *cardUsers = [[m_taskTypeDic71 objectForKey:@"cardUser"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    if([cardUsers count]<= 0 || [[m_taskTypeDic71 objectForKey:@"cardUser"] isEqualToString:@""]){

        NSLog(@"MYHOOK this is cardUser is null");
        uploadLog(geServerTypeTitle(currentType,2,@"得到名片为空"),[NSString stringWithFormat:@"wxid:%@ 名片不会发送",wxid]);

    }else{
        uploadLog(geServerTypeTitle(currentType,2,@"开始发送第一个名片"),[NSString stringWithFormat:@"wxid:%@ 名片为:%@",wxid,cardUsers[0]]);
        //开始发第一个名片
        [self sendCardOnePerson:wxid cardUser:cardUsers[0]];

        if([cardUsers count] == 2 && ![cardUsers[1] isEqualToString:@""]){
            dispatch_group_async(group, queue, ^{

                [NSThread sleepForTimeInterval:5];

                dispatch_async(dispatch_get_main_queue(), ^{
                    //延时2s
                    uploadLog(geServerTypeTitle(currentType,2,@"开始发送第二个名片"),[NSString stringWithFormat:@"wxid:%@ 名片为:%@",wxid,cardUsers[0]]);
                    //开始发第二个名片
                    [self sendCardOnePerson:wxid cardUser:cardUsers[1]];
                });
                
            });
        }
    }

    //发送图片
    NSString *picUrl = [m_taskTypeDic71 objectForKey:@"picUrl"];
    NSLog(@"发送图片:%@",picUrl);
    if([picUrl isEqualToString:@""]){
        NSLog(@"MYHOOK textContent is null");
        uploadLog(geServerTypeTitle(currentType,3,@"得到发送图片为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片",wxid]);
    }else{

        uploadLog(geServerTypeTitle(currentType,3,@"开始发送图片消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl]);
        [self sendPictureMessages:wxid pic:picUrl];
    }

    //发消息
    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    //得到自己的信息
    NSString *myself = [[mgr getSelfContact] m_nsUsrName];

    //判断有几条图文链接
    int linkCount = [[m_taskTypeDic71 objectForKey:@"linkCount"] intValue];

    NSLog(@"有几条图文链接:%d 数据为:%@",linkCount,[m_taskTypeDic71 objectForKey:@"shareLinkArr"]);
    NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
    if(linkCount > 0){
        for(NSArray *obj in [m_taskTypeDic71 objectForKey:@"shareLinkArr"]){
            [shareLinkArr addObject:obj];
        }
    }

    NSLog(@"图文链接数据:%@",shareLinkArr);

    if(linkCount==0){
        //当前没有给链接信息
        uploadLog(geServerTypeTitle(currentType,4,@"服务端没有图文链接"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
    }else{
        NSLog(@"图文链接数据:%@",shareLinkArr);
        for(int i=0; i < linkCount; i++){
            //当前有一个图文链接
            uploadLog(geServerTypeTitle(currentType,4,@"服务端发送图文链接开始发送"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接,当前的位置:%d",wxid,i]);

            //得到图文链接
            [self sendLinkMessages:wxid shareLink:shareLinkArr[i]];
        }
    }

    NSString *textContent = [m_taskTypeDic71 objectForKey:@"msgContent"];
    NSLog(@"发送文字:%@",textContent);
    //判断发送文字
    if([textContent isEqualToString:@""]){
        NSLog(@"MYHOOK textContent is null");
        uploadLog(geServerTypeTitle(currentType,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送消息",wxid]);

    }else{

        uploadLog(geServerTypeTitle(currentType,2,@"开始发送文字消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,textContent]);

        //发送文字
        [self sendTextMessages:wxid textContent:textContent];
    }

    //发送语音
    NSString *voiceUrl = [m_taskTypeDic71 objectForKey:@"voiceUrl"];
    if([voiceUrl isEqualToString:@""]){
        //当前没有发送语音
        uploadLog(geServerTypeTitle(currentType,4,@"服务端没有发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送语音",wxid]);
    }else{

        //        sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
        [self sendVoiceMessage:wxid voiceUrl:voiceUrl voiceTime:[m_taskTypeDic71 objectForKey:@"voiceTime"]];

        uploadLog(geServerTypeTitle(currentType,4,@"服务端发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于语音 语音链接：%@",wxid,voiceUrl]);
    }


}

%new
-(void)initQueryCard{  //初始化发公众号名片
    NSString *queryUser = @"weixingongzhong";

    //先初始化一下查询
    FTSWebSearchMgr *ftsWebSearchMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsWebSearchMgr];
    [ftsWebSearchMgr setNewestSearchText:queryUser];
    [ftsWebSearchMgr setNewestQueryText:queryUser];
    NSMutableDictionary *query = @{@"query": queryUser, @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
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

            uploadLog(geServerTypeTitle(71,2,@"asyncSearch先初始化"),[NSString stringWithFormat:@"没有查询到数据 :%@",[ftsWebSearchMgr respJson]]);
        }
        
    });
}

%new //给一个人发送名片 没有加关注
-(void)sendCardOnePerson:(NSString*)sendContact cardUser:(NSString*)sendCardUser{

    NSLog(@"71 发送给谁名片消息:%@ 名片为：%@",sendContact,sendCardUser);

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];

    NSString *myself = [[mgr getSelfContact] m_nsUsrName];
    //发送的名片
    NSString *cardUser = [NSString stringWithFormat:@"%@",sendCardUser];

    FTSWebSearchMgr *ftsWebSearchMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsWebSearchMgr];
    [ftsWebSearchMgr setNewestSearchText:cardUser];
    [ftsWebSearchMgr setNewestQueryText:cardUser];
    NSMutableDictionary *query = @{@"query": cardUser, @"sence": @"8", @"senceActionType": @"1", @"isHomePage": @"1"};
    [ftsWebSearchMgr asyncSearch:query];

    uploadLog(geServerTypeTitle(71,2,@"asyncSearch公众号查询"),[NSString stringWithFormat:@"执行参数 query:%@ 名片：%@",query,cardUser]);


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MYHOOK ftsWebSearchMgr: text: %@", [ftsWebSearchMgr respJson]);

            uploadLog(geServerTypeTitle(71,3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 respJson:%@ 名片：%@,名片索引号:%d",[ftsWebSearchMgr respJson],cardUser]);


            if ([ftsWebSearchMgr respJson] != nil) {
                //判断是非为空
                NSMutableDictionary *jsonDic = strngToDictionary([ftsWebSearchMgr respJson]);

                NSString *dataItem = [jsonDic objectForKey:@"data"];

                NSLog(@"%@ %@",jsonDic,dataItem);

                if(!([id(dataItem) isKindOfClass:[NSArray class]] && [dataItem count])){

                    NSLog(@"MYHOOK ftsWebSearchMgr this is nill %@",dataItem);

                    return;
                }

                NSMutableDictionary *result = strngToDictionary([ftsWebSearchMgr respJson])[@"data"][0][@"items"][0];

                id contact = [[NSClassFromString(@"CContact") alloc] init];

                [contact setM_nsAliasName:result[@"aliasName"]];
                [contact setM_nsUsrName:result[@"userName"]];
                [contact setM_nsNickName:result[@"nickName"]];
                [contact setM_nsSignature:result[@"signature"]];
                [contact setM_nsBrandIconUrl:result[@"headImgUrl"]];
                [contact setM_uiCertificationFlag:[result[@"verifyFlag"] intValue]];
                NSLog(@"MYHOOK contact: %@", contact);

                uploadLog(geServerTypeTitle(71,4,@"xmlForMessageWrapContent"),[NSString stringWithFormat:@"执行结果 xmlForMessageWrapContent:%@ 名片：%@",[contact xmlForMessageWrapContent],cardUser]);

                //
                id mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                id msg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];
                
                [msg setM_nsToUsr:sendContact];
                [msg setM_nsFromUsr:myself];
                [msg setM_nsContent:[contact xmlForMessageWrapContent]];
                [msg setM_uiCreateTime:(int)time(NULL)];

                [mgr AddMsg:sendContact MsgWrap:msg];

                uploadLog(geServerTypeTitle(71,5,@"AddMsg循环"),[NSString stringWithFormat:@"执行结果 微信uuid:%@  名片：%@,名片索引号:%d",sendContact,cardUser]);


            }else{
                uploadLog(geServerTypeTitle(71,3,@"respJson返回结果"),[NSString stringWithFormat:@"执行结果 为空"]);

            }
        });
        
    });
    
}

//通讯录筛选数据
%new
-(void)mailListScreeningData{
//    uploadLog(geServerTypeTitle(76,1,@"点击发现"),@"开始点击");
    NSLog(@"进行通讯录筛选数据");

    [m_mMTabBarController setSelectedIndex:1];
}

%new
- (void)createMyTip{
    //显示当前版本号
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UILabel *versionLable = [[UILabel alloc] initWithFrame:CGRectMake(300, 10, 120, 30)];
    NSString *hookVersion = m_hookVersion;//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [versionLable setText:hookVersion];
    versionLable.textColor = [UIColor redColor];
    versionLable.font = [UIFont fontWithName:@"Helvetica" size:8];
    [window addSubview:versionLable];
    [window bringSubviewToFront:versionLable];

    //显示任务信息
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString *text = @"";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [nearByFriendlable setText:text];
    nearByFriendlable.textColor = [UIColor redColor];
    [window addSubview:nearByFriendlable];
    [window bringSubviewToFront:nearByFriendlable];
}

//显示提示信息
%new
-(void)showTipMsg{
    //显示字符串1 [UIColor colorWithHex:0x333333 alpha:1.0];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UILabel *oneLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 320, 30)];
    [oneLable setText:m_showTip[0]];
//    [oneLable setText:@"注册时间:2017-02-15 00:46:40 当前坑号:037 任务类型:一次营销"];
    oneLable.textColor = [UIColor greenColor];
    oneLable.font = [UIFont fontWithName:@"Helvetica" size:12];
    [window addSubview:oneLable];
    [window bringSubviewToFront:oneLable];

    //显示字符串2
    UILabel *twoLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 320, 30)];
    [twoLable setText:m_showTip[1]];
//    [twoLable setText:@"一次营销轮数:3 总加好友数:69 今日加好友数:69"];
    twoLable.textColor = [UIColor yellowColor];
    twoLable.font = [UIFont fontWithName:@"Helvetica" size:12];
    [window addSubview:twoLable];
    [window bringSubviewToFront:twoLable];

    //显示字符串3
    UILabel *threeLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 40, 320, 30)];
    [threeLable setText:m_showTip[2]];
//    [threeLable setText:@"做成功任务数:13 做失败任务数:20"];
    threeLable.textColor = [UIColor greenColor];
    threeLable.font = [UIFont fontWithName:@"Helvetica" size:12];
    [window addSubview:threeLable];
    [window bringSubviewToFront:threeLable];

}

////检查网络
%new
-(void)checkNetWork{
    id netNetwork = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CNetworkStatus")];

    NSLog(@"hkfodderweixin 检查网络 getNewNetType:%d getNetworkType:%d",[netNetwork getNewNetType],[netNetwork getNetworkType]);

    NSNumber *type1 = [netNetwork getNewNetType];
    NSNumber *type2 = [netNetwork getNetworkType];

    NSLog(@"%d %d",type1,type2);
}

%new
- (void)attackChatRoom:(NSNotification *)notifiData{

    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;
    NSLog(@"收到当前发给服务端的数据 ：%@",notifiData);

    //延时一下
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        [self getChatRoomID:[taskDataDic objectForKey:@"taskId"] detectId:[taskDataDic objectForKey:@"detectId"]];

    });
    
}

//得到群信息
%new
-(void)getChatRoomID:(NSString *)taskId detectId:(NSString *)detectId{

    BOOL isExist = NO;

    MainFrameLogicController *dataLogic = MSHookIvar<MainFrameLogicController *>(self, "m_mainFrameLogicController");

    int sessionCount = [dataLogic getSessionCount];

    NSLog(@"得到群信息 :%d",sessionCount);
    //得到数据
    for(int i = 0; i < sessionCount; i++){

        id sessionInfo = [dataLogic getSessionInfo:i];

        if([[[sessionInfo m_contact] m_nsUsrName] rangeOfString:@"@chatroom"].location !=NSNotFound){

            NSLog(@"上传服务器的数据");

            isExist = YES;
            uploadChatRoomID(taskId,detectId,m_scanQrUrl[0],[[sessionInfo m_contact] m_nsUsrName],[[sessionInfo m_contact] m_nsNickName]);

            hook_success_task(88,taskId);

            //开始退群
            CGroupMgr *ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

            [ccMgr QuitGroup:[[sessionInfo m_contact] m_nsUsrName] withUsrName:[m_nCSetting m_nsUsrName]];
            break;
        }
    }

    if(!isExist){
        NSLog(@"当前列表没有找到数据");
        hook_fail_task(88,taskId,@"当前列表没有找到数据");
    }

}


id webQR = nil;

%new
-(void)scanQRCodeEnterRoom:(NSMutableDictionary *)taskDataDic{

    //(88)

    webQR = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:[taskDataDic objectForKey:@"qrCodeLinkUrl"]] presentModal:NO extraInfo:nil];


    uploadLog(geServerTypeTitle(88,0,@"当前执行的是88号任务"),[NSString stringWithFormat:@"执行MMWebViewController initWithURL 函数"]);


    if(webQR){

        [[self navigationController] pushViewController:webQR animated: YES];

        uploadLog(geServerTypeTitle(88,0,@"MMWebViewController跳转到web页面"),[NSString stringWithFormat:@"执行函数 pushViewController:webQR跳转"]);

//        dispatch_group_async(group, queue, ^{

//            [NSThread sleepForTimeInterval:10];
//
//            NSLog(@"scanQRCodeEnterRoom 进行开始扫码");
//
//            id lg = [[NSClassFromString(@"ScanQRCodeLogicController") alloc] initWithViewController: self CodeType: 2];
//
//            [lg scanOnePicture: [[webQR webView] getImage ]];
//
//            uploadLog(geServerTypeTitle(88,0,@"scanQRCodeEnterRoom 进行开始扫码"),[NSString stringWithFormat:@"执行函数scanOnePicture"]);

            //延时得到群信息
//            [NSThread sleepForTimeInterval:5];

//            [self getChatRoomID:[taskDataDic objectForKey:@"taskId"] detectId:[taskDataDic objectForKey:@"detectId"]];
//        });

    }
}

%new
-(void)scanQRCodeFunction{
    NSLog(@"收到ScanQRCodeLogicController通知消息");

    if(webQR){
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:3];

            dispatch_async(dispatch_get_main_queue(), ^{

//                [[self navigationController] pushViewController:webQR animated: YES];

                id lg = [[NSClassFromString(@"ScanQRCodeLogicController") alloc] initWithViewController: self CodeType: 2];

                [lg scanOnePicture: [[webQR webView] getImage ]];

            });
        });
    }
}

%new
-(void)getNextTask{
//    m_current_taskCount = m_current_taskCount + 1;

    if([m_taskArrayData count]<= 0){
        write2File(@"/var/root/hkwx/operation.txt",@"-1");
        uploadLog(geServerTypeTitle(0,0,@"hook当前所有没有任务"),@"");
        return;
    }

    int __block hookOverTime = 0;

    [self showTipMsg];
    [self createMyTip];


    NSLog(@"当前进入getNextTask");
    //
    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[m_taskArrayData count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{
                //简析当前的任务类型等
                m_current_taskType = [[m_taskArrayData[i] objectForKey:@"taskType"] intValue];

                NSString *text = [NSString stringWithFormat:@"执行任务:%ld",m_current_taskType];
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];

                NSLog(@"简析当前的任务类型%d",m_current_taskType);

                uploadLog(geServerTypeTitle(0,0,@"当前执行getNextTask函数执行下一个任务"),[NSString stringWithFormat:@"任务号为：%d",m_current_taskType]);

                if(m_current_taskType == 4){
                    //      发朋友圈
                    NSLog(@"-----------当前要发朋友圈");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSendFriendsNotificton object:nil userInfo:m_taskArrayData[i]];

                }else if(m_current_taskType == 45){
                    //      同步通讯录
                    m_taskDataDic45 = m_taskArrayData[i];
                    [self syncMailList];

                }else if(m_current_taskType == 54){
                    m_taskDataDic = m_taskArrayData[i];
                    [self modifyUsrInfo];

                }else if(m_current_taskType == 59){
                    //发送消息执行获取key
                    write2File(@WXGROUP_RED_MAP_LIST, [m_taskArrayData[i] objectForKey:@"weixinListData"]);

                    m_taskDicKey = [m_taskArrayData[i] mutableCopy];

                    [self batchMpDocReadCount:[m_taskArrayData[i] objectForKey:@"taskId"]];


                }else if(m_current_taskType == 64){
                    //公众号关注
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAttentionPublicCardNotificton object:nil userInfo:m_taskArrayData[i]];

                }else if(m_current_taskType == 66 || m_current_taskType == 73){
                    //捡瓶子
                    m_pickupinterval = [[m_taskArrayData[i] objectForKey:@"interval"] intValue];
                    m_pickupCount = [[m_taskArrayData[i] objectForKey:@"pickupCount"] intValue];

                    write2File(@WXPICK_BOTTLE_LIST, [m_taskArrayData[i] objectForKey:@"weixinListData"]);

                    m_taskTypeDicBottle = [m_taskArrayData[i] mutableCopy];
                    //       漂流瓶
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDriftingBottleNotificton object:nil];
                    
                }else if(m_current_taskType == 70){

                    //获取首页附近人
                    [self findLBSUsrs:m_taskArrayData[i]];

                }else if(m_current_taskType == 71){

                    m_current_taskType71 = 71;
                    m_taskTypeDic71 = [m_taskArrayData[i] mutableCopy];

                    NSLog(@"-----------当前要进行暴力加好友 %@",m_taskTypeDic71);

                    //1、暴力加好友
                    [self addFriendByWXId:m_taskArrayData[i]];

                }else if(m_current_taskType == 72){
                    //通讯录发轮图片消息和名片(二次营销)
                    m_taskDataDic72 = m_taskArrayData[i];
                    [self mailListMarketing:m_taskArrayData[i]];

                }else if(m_current_taskType == 74){
                    //修改个性签名
                    [self modifySignature:m_taskArrayData[i]];
                }else if(m_current_taskType == 76){
                    //摇一摇
                    m_taskTypeShake = [m_taskArrayData[i] mutableCopy];

                    [self doShakeGet];
                }else if(m_current_taskType == 77){
                    m_taskDataDic77 = m_taskArrayData[i];
                    //通讯录筛选好友
                    [self mailListScreeningData];
                }else if(m_current_taskType == 78){

                    m_taskTypeDic71 = [m_taskArrayData[i] mutableCopy];
                    [self addFriendScreenByWXId:m_taskArrayData[i]];
                }else if(m_current_taskType == 79){
                    m_taskDataDic45 = m_taskArrayData[i];
                    [self syncMailList];
                }else if(m_current_taskType == 80){
                    //首页手机号搜索数据筛选
                    [self searchAllPhoneNum:m_taskArrayData[i]];
                }else if(m_current_taskType == 81){
                    [self addAllPublicCard:m_taskArrayData[i]];
                }else if(m_current_taskType == 88){
                    m_taskDataDic88 = m_taskArrayData[i];
                    [self scanQRCodeEnterRoom:m_taskArrayData[i]];
                }

            });

            while(!m_current_taskIsOK){
                NSLog(@"hook 等待上一个任务结束");
                [NSThread sleepForTimeInterval:5];
            }

            m_current_taskIsOK = NO;

            uploadLog(geServerTypeTitle(0,0,@"当前这个任务做完了，进行下一个任务"),[NSString stringWithFormat:@"任务号为：%d",m_current_taskType]);

            //判断是不是暴力加好友,延时5s 执行下一个任务。
            if(m_current_taskType == 71 || m_current_taskType == 76){
                [NSThread sleepForTimeInterval:5];
            }

        }

        uploadLog(geServerTypeTitle(0,0,@"当前所有任务结束告诉脚本"),@"所有任务结束");

        //延时10s 告诉脚本结束
        [NSThread sleepForTimeInterval:8];

        //删除信息
        [self getLastSession];

        //告诉脚本结束
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    });

}


//搜索所有手机号
static int m_totalAllNums = 0;
static int m_currentNums = 0;

%new
-(void)searchAllPhoneNum:(NSMutableDictionary *)taskDataDic{

    NSArray *phoneList = [[taskDataDic objectForKey:@"plistContent"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    uploadLog(geServerTypeTitle(80,1,@"当前是开始进行手机号搜索"),[NSString stringWithFormat:@"开始搜索"]);

    m_totalAllNums = [phoneList count];

    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[phoneList count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                uploadLog(geServerTypeTitle(80,2,@"当前是进行手机号搜索"),[NSString stringWithFormat:@"搜索的手机号为:%@",phoneList[i]]);

                [self searchPhoneNum:phoneList[i] taskId:[taskDataDic objectForKey:@"taskId"]];
            });

            [NSThread sleepForTimeInterval:2];
        }
        
    });
}

//搜索手机号
%new
-(void)searchPhoneNum:(NSString *)phoneNum taskId:(NSString *)taskId{

    id vc = [[NSClassFromString(@"AddFriendEntryViewController") alloc] init];
    [vc initView];
    id searchView = MSHookIvar<id>(vc, "m_headerSearchView");
    id searchBar = MSHookIvar<id>(searchView, "m_searchBar");
    [[searchBar m_searchBar] setText:phoneNum];
    [searchView doSearch];

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:4];
        NSLog(@"MYHOOK phoneNum:%@ found contact:%@ m_currentNums:%d",phoneNum,[searchView foundContact],m_currentNums);

        uploadLog(geServerTypeTitle(80,3,@"当前是进行手机号搜索"),[NSString stringWithFormat:@"搜索的结果为：%@",[searchView foundContact]]);

        [phoneCContactList setObject:[searchView foundContact] forKey:phoneNum];

        m_currentNums++;
        if(m_currentNums == m_totalAllNums){


            NSString *dataJson = @"";
            NSString *oneJson = @"";

            //上传服务器
            NSEnumerator *enumerator = [phoneCContactList keyEnumerator];
            id key = [enumerator nextObject];
            while (key) {

                id ccontact = [phoneCContactList objectForKey:key];
                
                NSLog(@"key is%@  ccontact is:%@", key,ccontact);
                
                key = [enumerator nextObject];

                //上传给服务器
                NSString *nickname = conversionSpecialCharacter([ccontact m_nsNickName]);
                NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

                oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%d\",\"signature\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,key,nsCountry,nsProvince,nsCity,[ccontact m_uiSex],[ccontact m_nsSignature]];


                NSLog(@"HKWX %@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }

            }
            uploadLog(geServerTypeTitle(80,3,@"当前是进行手机号搜索结束"),[NSString stringWithFormat:@"进行下一个任务"]);

            //同步筛选数据
            syncSearchPhoneMember(dataJson,taskId);

            //上传服务器
            hook_success_task(80,taskId);

            NSLog(@"MYHOOK All Search :%@",dataJson);
        }

    });
}


//首页删除聊天记录
%new
-(void)deleteAllSession{

}

%new
-(void)getLastSession{

    uploadLog(geServerTypeTitle(0,0,@"当前执行的是删除频繁好友"),[NSString stringWithFormat:@"提前执行删除操作"]);

    MainFrameLogicController *dataLogic = MSHookIvar<MainFrameLogicController *>(self, "m_mainFrameLogicController");

    int sessionCount = [dataLogic getSessionCount];

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    
    //得到数据
    for(int i = 0; i < sessionCount; i++){
        
        id sessionInfo = [dataLogic getSessionInfo:i];
        
//        NSLog(@"the last uiMessageType:%d pos:%d CContact:%@ message %@",[[sessionInfo m_msgWrap] m_uiMessageType],i,[[sessionInfo m_contact] m_nsUsrName],[[sessionInfo m_msgWrap] m_nsContent]);

        int uiMessageType = [[sessionInfo m_msgWrap] m_uiMessageType];

        if(uiMessageType == 10000){

            NSString *nsContent = [[sessionInfo m_msgWrap] m_nsContent];
            if([nsContent rangeOfString:@"拒收"].location != NSNotFound){
                uploadLog(geServerTypeTitle(0,0,@"删除发送消息频繁好友"),[NSString stringWithFormat:@"当前好友为:%@ 返回的语句:%@",[[sessionInfo m_contact] m_nsUsrName],[[sessionInfo m_msgWrap] m_nsContent]]);
                //删除好友
                [mgr deleteContact:[sessionInfo m_contact] listType:3];

            }else{
                uploadLog(geServerTypeTitle(0,0,@"当前帐号系统发过来有消息"),[NSString stringWithFormat:@"当前好友为:%@ 返回的语句:%@",[[sessionInfo m_contact] m_nsUsrName],[[sessionInfo m_msgWrap] m_nsContent]]);
            }
        }
    }

}


//发送首页数据
%new
-(void)sendSessionData{

    MainFrameLogicController *dataLogic = MSHookIvar<MainFrameLogicController *>(self, "m_mainFrameLogicController");

    //得到所有数据
//    int sessionCount =
}

- (void)viewDidLoad {
    %orig;
    newMainFrame = self;
    if(m_current_taskCount == -1){
        [self registerNotification];
    }

//    [self createMyTip];

     NSLog(@"是否漂流瓶 %d",m_enterBottle);

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

        //uuid写入配置文件中
        write2File(@"/var/root/hkwx/uuid.txt",[m_nCSetting m_nsUsrName]);

        //等待数据返回
        while(true){
            NSLog(@"HKWeChat 等待大数据的返回(微信页面开始)--- %d",m_isRequestResult);

            [NSThread sleepForTimeInterval:5];
            if(m_isRequestResult == 2 || m_isRequestResult == 3 || m_isRequestResult == 4 || m_isRequestResult == 6){
                break;
            }

            getServerData();

        }


        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HKWeChat 当前操作数据");

            [self getLastSession];
            //操作数据
            if(m_isRequestResult == 2 || m_enterBottle){

                m_isRequestResult = 4;
                if(m_enterBottle){
                    //进行漂流瓶
//                    [self pickUpBottle];
                }else{
                    if(m_current_modify){
                        [self modifyUsrInfo];

                    }else{
                        [self getNextTask];
                    }
                }

            }
        });
        
    });

}

%new
-(void)syncMailList{
    NSLog(@"当前处于同步通讯录");

    [m_mMTabBarController setSelectedIndex:1];

    return;
//    dispatch_group_async(group, queue, ^{
//
//        [NSThread sleepForTimeInterval:5];
//
//        //得到通讯录的信息
//        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];
//
//        [ftsContactMgr tryLoadContacts];
//
//        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];
//
//        NSArray *keys = [dicContact allKeys];
//
//         for(int i=0; i< [keys count]; i++){
//
////            [NSThread sleepForTimeInterval:2];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                id valueCContact= keys[i];///[ dicContact objectForKey:key];
//                NSLog(@"valueCContact :%@ %@",valueCContact,[dicContact objectForKey:valueCContact]);
//
//            });
//        }
//    });

}

//发送通讯录营销消息
%new
-(void)mailMarkMsg:(NSMutableDictionary *)taskDataDic{

    NSLog(@"(72)当前进入了发送通讯录营销消息 m_taskDataDic72%@",m_taskDataDic72);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];
        __block int dicCount = 0;
        __block int spaceInterval = [[m_taskDataDic72 objectForKey:@"spaceInterval"] intValue];

        if(spaceInterval == 0){
            spaceInterval = 1;
        }

        NSString *picUrl = [taskDataDic objectForKey:@"picUrl"];
        NSLog(@"72发送图片:%@",picUrl);
        if(![picUrl isEqualToString:@""]){
            m_dtImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
        }

        NSArray *keys = [dicContact allKeys];

        //判断是否发名片
        int cardCount = [[m_taskDataDic72 objectForKey:@"cardCount"] intValue];
        if(cardCount > 0){
            for(NSMutableArray *publicCardArr in [m_taskDataDic72 objectForKey:@"publicCardArr"]){
                id contact = [[NSClassFromString(@"CContact") alloc] init];
                [contact setM_nsAliasName:[publicCardArr objectForKey:@"nsAliasName"]];
                [contact setM_nsUsrName:[publicCardArr objectForKey:@"nsUsrName"]];
                [contact setM_nsNickName:[publicCardArr objectForKey:@"nsNickName"]];
                [contact setM_nsSignature:[publicCardArr objectForKey:@"nsSignature"]];
                [contact setM_nsBrandIconUrl:[publicCardArr objectForKey:@"nsBrandIconUrl"]];
                [contact setM_uiCertificationFlag:[[publicCardArr objectForKey:@"uiCertificationFlag"] intValue]];

                [m_cardContacts addObject:contact];
            }
        }

        //判断有几条图文链接
        int linkCount = [[m_taskDataDic72 objectForKey:@"linkCount"] intValue];
        NSLog(@"有几条图文链接:%d %@",linkCount,[m_taskDataDic72 objectForKey:@"shareLinkArr"]);

        NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
        if(linkCount > 0){
            for(NSArray *obj in [m_taskDataDic72 objectForKey:@"shareLinkArr"]){
                [shareLinkArr addObject:[obj mutableCopy]];
            }
        }

        for(int i=0; i< [keys count]; i++){

            [NSThread sleepForTimeInterval:spaceInterval];

            dispatch_async(dispatch_get_main_queue(), ^{

                dicCount = dicCount + 1;

                //显示
                NSString *text = [NSString stringWithFormat:@"72: %d/%lu",dicCount,(unsigned long)[keys count]];
                nearByFriendlable.text = text;
                [nearByFriendlable setNeedsDisplay];

                NSString *wxid = keys[i];

                CContact *oneContact = [dicContact objectForKey:wxid];

                if(![wxid isEqualToString:@"weixin"] && ![wxid isEqualToString:@"iwatchholder"]
                   && ![wxid isEqualToString:@"notification_messages"]
                   && [oneContact m_uiCertificationFlag] == 0){

                    uploadLog(geServerTypeTitle(72,3,@"当前执行72号任务的位置"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d 共有多少个好友:%lu",wxid,dicCount,(unsigned long)[keys count]]);

                    NSLog(@"当前wixd:%@ 执行的位置：%d",wxid,dicCount);

                    if(cardCount <= 0){
                        NSLog(@"72发送名片 MYHOOK 为空");
                        uploadLog(geServerTypeTitle(72,3,@"得到发送名片为空"),[NSString stringWithFormat:@"服务没有给数据"]);
                    }else{
                        //开始发送名片
                        for(int i = 0; i<cardCount; i++){
                            //初始化一个CContact
                             uploadLog(geServerTypeTitle(72,3,@"得到发送开始发送名片"),[NSString stringWithFormat:@"当前用户推送第%d个名片",i]);

                            [self sendCardMessage:wxid toContact:m_cardContacts[i]];
                        }
                    }

                    //发送图片
//                    NSString *picUrl = @"http://crobo-pic.qiniudn.com/shaike_39159f8b40a74c8d84a5be297ceb139d.jpg";
                    NSString *picUrl = [taskDataDic objectForKey:@"picUrl"];
                    NSLog(@"72发送图片:%@",picUrl);
                    if([picUrl isEqualToString:@""]){
                        NSLog(@"72发送图片 MYHOOK textContent is null");
                        uploadLog(geServerTypeTitle(72,3,@"得到发送图片为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片",wxid]);
                    }else{

                        uploadLog(geServerTypeTitle(72,3,@"开始发送图片消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl]);
                        [self sendPictureMessages:wxid pic:picUrl];
                    }

                    if(linkCount==0){
                        //当前没有给链接信息
                        uploadLog(geServerTypeTitle(72,4,@"服务端没有图文链接"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
                    }else{
                        for(int i=0; i<linkCount; i++){

                            //当前有一个图文链接
                            uploadLog(geServerTypeTitle(72,4,@"服务端发送图文链接开始发送"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接 当前位置：%d",wxid,i]);

                            [self sendLinkMessages:wxid shareLink:shareLinkArr[i]];
                        }
                    }

                    //发送语音
                    NSString *voiceUrl = [m_taskDataDic72 objectForKey:@"voiceUrl"];
                    if([voiceUrl isEqualToString:@""]){
                        //当前没有发送语音
                        uploadLog(geServerTypeTitle(72,4,@"服务端没有发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送语音",wxid]);
                    }else{

                        //        sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
                        [self sendVoiceMessage:wxid voiceUrl:voiceUrl voiceTime:[m_taskDataDic72 objectForKey:@"voiceTime"]];

                        uploadLog(geServerTypeTitle(72,4,@"服务端发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于语音,当前的位置:%d",wxid]);
                    }

                    //判断发送文字
                    if([[m_taskDataDic72 objectForKey:@"msgContent"] isEqualToString:@""]){
                        NSLog(@"72MYHOOK textContent is null");
                        uploadLog(geServerTypeTitle(72,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送消息",wxid]);

                    }else{

                        uploadLog(geServerTypeTitle(72,2,@"开始发送文字消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,[m_taskDataDic72 objectForKey:@"msgContent"]]);
                        NSString *msgContent =[m_taskDataDic72 objectForKey:@"msgContent"];

                        //发送文字
                        [self sendTextMessages:wxid textContent:msgContent];
                    }


                }else if(![wxid isEqualToString:@"weixin"] && ![wxid isEqualToString:@"iwatchholder"]
                         && ![wxid isEqualToString:@"notification_messages"]
                         && [oneContact m_uiCertificationFlag] != 0){
                    //发送消息
                    [self sendTextMessages:wxid textContent:[m_taskDataDic72 objectForKey:@"publicContent"]];
                }

                if(dicCount == [keys count]){

                    uploadLog(geServerTypeTitle(72,6,@"通讯录发轮图片消息和名片(二次营销)结束"),@"做下一个任务");
                    
                    hook_success_task(72,[taskDataDic objectForKey:@"taskId"]);
                }

            });

        }
    });
}

//发送通讯录营销消息
%new
-(void)mailMarkMsg1:(NSMutableDictionary *)taskDataDic{

    NSLog(@"(72)当前进入了发送通讯录营销消息 m_taskDataDic72%@",m_taskDataDic72);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];
        __block int dicCount = 0;
        __block int spaceInterval = [[m_taskDataDic72 objectForKey:@"spaceInterval"] intValue];

        if(spaceInterval == 0){
            spaceInterval = 1;
        }

        NSArray *keys = [dicContact allKeys];

        //判断是否发名片
        int cardCount = [[m_taskDataDic72 objectForKey:@"cardCount"] intValue];
        NSMutableArray *publicCardArr = [[NSMutableArray alloc] init];
        if(cardCount > 0){
            for(NSArray *obj in [m_taskDataDic72 objectForKey:@"publicCardArr"]){
                [publicCardArr addObject:[obj mutableCopy]];
            }
        }

        //判断有几条图文链接
        int linkCount = [[m_taskDataDic72 objectForKey:@"linkCount"] intValue];
        NSLog(@"有几条图文链接:%d %@",linkCount,[m_taskDataDic72 objectForKey:@"shareLinkArr"]);

        NSMutableArray *shareLinkArr = [[NSMutableArray alloc] init];
        if(linkCount > 0){
            for(NSArray *obj in [m_taskDataDic72 objectForKey:@"shareLinkArr"]){
                [shareLinkArr addObject:[obj mutableCopy]];
            }
        }

         for(int i=0; i< [keys count]; i++){

            [NSThread sleepForTimeInterval:spaceInterval];

            dicCount = dicCount + 1;

            NSString *wxid = keys[i];

            CContact *oneContact = [dicContact objectForKey:wxid];

            if(![wxid isEqualToString:@"weixin"] && ![wxid isEqualToString:@"iwatchholder"]
               && ![wxid isEqualToString:@"notification_messages"]
               && [oneContact m_uiCertificationFlag] == 0){

                uploadLog(geServerTypeTitle(72,3,@"当前开始发图片信息"),[NSString stringWithFormat:@"当前wixd:%@ 执行的位置：%d 共有多少个好友:%lu",wxid,dicCount,(unsigned long)[keys count]]);
                NSLog(@"当前wixd:%@ 执行的位置：%d",wxid,dicCount);


                if(cardCount <= 0){
                    NSLog(@"72发送名片 MYHOOK 为空");
                    uploadLog(geServerTypeTitle(72,3,@"得到发送名片为空"),[NSString stringWithFormat:@"服务没有给数据"]);
                }else{
                    //开始发送名片
                    for(int i = 0; i<cardCount; i++){
                        //初始化一个CContact
                        id contact = [[NSClassFromString(@"CContact") alloc] init];

                        [contact setM_nsAliasName:[publicCardArr[i] objectForKey:@"nsAliasName"]];
                        [contact setM_nsUsrName:[publicCardArr[i] objectForKey:@"nsUsrName"]];
                        [contact setM_nsNickName:[publicCardArr[i] objectForKey:@"nsNickName"]];
                        [contact setM_nsSignature:[publicCardArr[i] objectForKey:@"nsSignature"]];
                        [contact setM_nsBrandIconUrl:[publicCardArr[i] objectForKey:@"nsBrandIconUrl"]];
                        [contact setM_uiCertificationFlag:[[publicCardArr[i] objectForKey:@"uiCertificationFlag"] intValue]];
                        NSLog(@"MYHOOK contact: %@", contact);

                        uploadLog(geServerTypeTitle(72,3,@"得到发送开始发送名片"),[NSString stringWithFormat:@"当前名片的名字为:%@",[publicCardArr[i] objectForKey:@"nsUsrName"]]);

                        [self sendCardMessage:wxid toContact:contact];
                    }
                }

                //发送图片
                NSString *picUrl = [taskDataDic objectForKey:@"picUrl"];
                NSLog(@"72发送图片:%@",picUrl);
                if([picUrl isEqualToString:@""]){
                    NSLog(@"72发送图片 MYHOOK textContent is null");
                    uploadLog(geServerTypeTitle(72,3,@"得到发送图片为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片",wxid]);
                }else{

                    uploadLog(geServerTypeTitle(72,3,@"开始发送图片消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送图片消息,图片URL为%@",wxid,picUrl]);
                    [self sendPictureMessages:wxid pic:picUrl];
                }

                if(linkCount==0){
                    //当前没有给链接信息
                    uploadLog(geServerTypeTitle(72,4,@"服务端没有图文链接"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接",wxid]);
                }else{
                    for(int i=0; i<linkCount; i++){

                        //当前有一个图文链接
                        uploadLog(geServerTypeTitle(72,4,@"服务端发送图文链接开始发送"),[NSString stringWithFormat:@"wxid:%@ 当前处于图文链接 当前位置：%d",wxid,i]);

                        [self sendLinkMessages:wxid shareLink:shareLinkArr[i]];
                    }
                }

                //发送语音
                NSString *voiceUrl = [m_taskDataDic72 objectForKey:@"voiceUrl"];
                if([voiceUrl isEqualToString:@""]){
                    //当前没有发送语音
                    uploadLog(geServerTypeTitle(72,4,@"服务端没有发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送语音",wxid]);
                }else{

                    //        sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
                    [self sendVoiceMessage:wxid voiceUrl:voiceUrl voiceTime:[m_taskDataDic72 objectForKey:@"voiceTime"]];

                    uploadLog(geServerTypeTitle(72,4,@"服务端发送语音"),[NSString stringWithFormat:@"wxid:%@ 当前处于语音,当前的位置:%d",wxid]);
                }

                //判断发送文字
                if([[m_taskDataDic72 objectForKey:@"msgContent"] isEqualToString:@""]){
                    NSLog(@"72MYHOOK textContent is null");
                    uploadLog(geServerTypeTitle(72,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送消息",wxid]);

                }else{

                    uploadLog(geServerTypeTitle(72,2,@"开始发送文字消息"),[NSString stringWithFormat:@"wxid:%@ 当前处于发送文字消息,文字消息%@",wxid,[m_taskDataDic72 objectForKey:@"msgContent"]]);
                    NSString *msgContent =[m_taskDataDic72 objectForKey:@"msgContent"];
                    
                    //发送文字
                    [self sendTextMessages:wxid textContent:msgContent];
                }
                
                
            }else if(![wxid isEqualToString:@"weixin"] && ![wxid isEqualToString:@"iwatchholder"]
                     && ![wxid isEqualToString:@"notification_messages"]
                     && [oneContact m_uiCertificationFlag] != 0){
                //发送消息
                [self sendTextMessages:wxid textContent:[m_taskDataDic72 objectForKey:@"publicContent"]];
            }
            
            if(dicCount == [keys count]){
                
                uploadLog(geServerTypeTitle(72,6,@"通讯录发轮图片消息和名片(二次营销)结束"),@"做下一个任务");
                
                hook_success_task(72,[taskDataDic objectForKey:@"taskId"]);
            }

             dispatch_async(dispatch_get_main_queue(), ^{
                 //显示
                 NSString *text = [NSString stringWithFormat:@"72: %d/%lu",dicCount,(unsigned long)[keys count]];
                 nearByFriendlable.text = text;
                 [nearByFriendlable setNeedsDisplay];
            });
            
        }
    });
}

%new
-(void)mailListMarketing:(NSMutableDictionary *)taskDataDic{
    //得到当前名片的信息
    [self mailMarkMsg:taskDataDic];
}

//朋友圈发图片或者文字
%new
-(void)sendFriendsPictureAndText:(NSMutableDictionary *)taskDataDic{

    NSArray *picArray = [[taskDataDic objectForKey:@"photoArrs"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    NSMutableArray *mmImages = [[NSMutableArray alloc] init];

    for (int i = 0; i < [picArray count]; i++) {
        if(![picArray[i] isEqualToString:@""]){
            NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:picArray[i]]];
            UIImage *image = [[UIImage alloc] initWithData:data];
            [mmImages addObject:[[NSClassFromString(@"MMImage") alloc] initWithImage:image]];
        }
    }

    uploadLog(geServerTypeTitle(4,1,@"发朋友圈的图片数"),[NSString stringWithFormat:@"图片个数为：%d",[picArray count]]);

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

    [textView setText:[taskDataDic objectForKey:@"taskTextContent"]];
    Ivar ivar = class_getInstanceVariable([vc class], "_bHasInput");
    object_setIvar(vc, ivar, (id)YES);

    [vc OnDone];
    NSLog(@"发朋友圈 结束");

    uploadLog(geServerTypeTitle(4,2,@"发朋友圈结束"),@"发朋友圈结束");

    hook_success_task(4,[taskDataDic objectForKey:@"taskId"]);
}

%new
-(BOOL)downFileByUrl:(NSString *)downUrl dwonName:(NSString *)dwonName{

    NSLog(@"hkfodderWeixin is Down file %@ ",dwonName);

    NSString *url = downUrl;
    if([url isEqualToString:@""] || url == nil){
        NSLog(@"hkfodderWeixin downURL is null");

        uploadLog(geServerTypeTitle(4,2,@"hkfodderWeixin下载的文件名为空"),@"下载失败");

        return NO;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;

    fp = fopen([dwonName UTF8String], "wb");
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"hkfodderWeixin-curl image failed: %@", @"File cannot be opened");

            uploadLog(geServerTypeTitle(4,2,@"hkfodderWeixin文件不能打开没有读写的权限"),@"下载失败");

            return NO;
        }
        curl_easy_setopt(downDylib, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(downDylib, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(downDylib, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(downDylib);
        if( imgresult ){
            NSLog(@"hkfodderWeixin-curl Cannot grab the image!\n");

            uploadLog(geServerTypeTitle(4,2,@"hkfodderWeixin Cannot grab the file"),@"下载失败");

            return NO;
        }
    }
    
    fclose(fp);
    
    curl_easy_cleanup(downDylib);

    return YES;
    
}

//朋友圈发视频
%new
-(void)sendFriendsVideo:(NSMutableDictionary *)taskDataDic{
    NSLog(@"");
    //判断当前文件是否存在
    NSString *videoPath = [NSString stringWithFormat:@"/var/root/hkwx/%@",[taskDataDic objectForKey:@"videoName"]];
    NSString *videoImg = [taskDataDic objectForKey:@"videoImg"];

//    NSString *videoPath = [NSString stringWithFormat:@"/var/root/hkwx/test.mp4"];
//    NSString *videoImg = @"http://crobo-pic.qiniudn.com/jinBaoTuPian.jpg";

    BOOL downSuccess = NO;

    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){
        downSuccess = YES;
        //存在
        NSLog(@"hkfodderWeixin is exist");
        uploadLog(geServerTypeTitle(4,3,@"朋友圈发视频当前视频已经存在"),[NSString stringWithFormat:@"视频的名字为:%@",videoPath]);
    }else{
        //不存在进行下载
        uploadLog(geServerTypeTitle(4,3,@"朋友圈发视频当前视频不存在，进行下载视频"),[NSString stringWithFormat:@"开始下载视频 视频名字为:%@ 视频链接为：%@",videoPath,[taskDataDic objectForKey:@"videoUrl"]]);

        //下载视频
        downSuccess = [self downFileByUrl:[taskDataDic objectForKey:@"videoUrl"] dwonName:videoPath];
    }

    if(!downSuccess){
        uploadLog(geServerTypeTitle(4,3,@"朋友圈发视频下载视频失败"),[NSString stringWithFormat:@"开始下载视频 视频名字为:%@ 视频链接为：%@",videoPath,[taskDataDic objectForKey:@"videoUrl"]]);

        hook_fail_task(4,[taskDataDic objectForKey:@"taskId"],@"发朋友圈视频时下载视频失败");
        return;
    }

    //下载文件
//    NSString *videoPath = @"/var/root/hkwx/test.mp4";
    NSString *text = [taskDataDic objectForKey:@"taskTextContent"];
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

    hook_success_task(4,[taskDataDic objectForKey:@"taskId"]);
}

%new
- (void)sendFriends:(NSNotification *)notifiData{

    NSLog(@"========开始发朋友圈(4)========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary *)notifiData.userInfo;

    NSLog(@"taskDataDic %@",taskDataDic);

    dispatch_group_async(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            if([[taskDataDic objectForKey:@"msgType"] intValue] == 0){
                //判断是否发送文字或视频
                [self sendFriendsVideo:taskDataDic];

            }else if([[taskDataDic objectForKey:@"msgType"] intValue] == 1){

                //发送图片文字
                [self sendFriendsPictureAndText:taskDataDic];

            }else{

                uploadLog(geServerTypeTitle(4,4,@"发朋友圈服务端没有给类别"),[NSString stringWithFormat:@"任务失败"]);

                hook_fail_task(4,[taskDataDic objectForKey:@"taskId"],@"发朋友圈服务端没有给类别");
            }


        });
        
    });
    
}



%new//4.0.2版本
- (void)sendFriendsOld:(NSNotification *)notifiData{

    NSLog(@"========开始发朋友圈(4)========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary *)notifiData.userInfo;

    NSLog(@"taskDataDic %@",taskDataDic);

    dispatch_group_async(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray *picArray = [[taskDataDic objectForKey:@"photoArrs"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

            NSMutableArray *mmImages = [[NSMutableArray alloc] init];

            for (int i = 0; i < [picArray count]; i++) {
                if(![picArray[i] isEqualToString:@""]){
                    NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:picArray[i]]];
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    [mmImages addObject:[[NSClassFromString(@"MMImage") alloc] initWithImage:image]];
                }
            }

            uploadLog(geServerTypeTitle(4,1,@"发朋友圈的图片数"),[NSString stringWithFormat:@"图片个数为：%d",[picArray count]]);

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

            [textView setText:[taskDataDic objectForKey:@"taskTextContent"]];
            Ivar ivar = class_getInstanceVariable([vc class], "_bHasInput");
            object_setIvar(vc, ivar, (id)YES);
            
            [vc OnDone];
            NSLog(@"发朋友圈 结束");
            
            uploadLog(geServerTypeTitle(4,2,@"发朋友圈结束"),@"发朋友圈结束");
            
            hook_success_task(4,[taskDataDic objectForKey:@"taskId"]);

        });
        
    });

 }


%new
- (void)msgAndLink:(NSNotification*)notifiData{

    NSLog(@"========推送消息+链接========= %@",notifiData.userInfo);

    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;

    uploadLog(geServerTypeTitle(63,1,@"当前进入sendMsgAndLink函数"),[NSString stringWithFormat:@"执行结果 进入执行"]);

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    //得到自己的信息
    NSString *myself = [[mgr getSelfContact] m_nsUsrName];

    int msgType = 1;

    NSMutableArray *allContacts = [[taskDataDic objectForKey:@"members"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    //发消息的时间
    int interval = [[taskDataDic objectForKey:@"sendMsgInterval"] intValue];

    NSString *m_textContent = [taskDataDic objectForKey:@"msgContent"];

    NSLog(@"========================");
    CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];


    dispatch_group_async(group, queue, ^{

        for (int i = 0; i < [allContacts count]; i++) {
            dispatch_async(dispatch_get_main_queue(), ^{

                msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                myMsg.m_nsContent = m_textContent;//@"你哈 我是小娟";
                myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                myMsg.m_nsFromUsr = myself;
                myMsg.m_nsToUsr = allContacts[i];
                myMsg.m_uiCreateTime = (int)time(NULL);
                [msMgr ResendMsg: allContacts[i] MsgWrap:myMsg];
                NSLog(@"MYHOOK will send to %@:", myMsg);

                uploadLog(geServerTypeTitle(63,2,@"ResendMsg循环"),[NSString stringWithFormat:@"执行结果 微信uuid:%@ 循环索引号:%d 消息内容:%@",allContacts[i],i,m_textContent]);

            });

            [NSThread sleepForTimeInterval:interval];

            uploadLog(geServerTypeTitle(63,3,@"ResendMsg循环结束"),[NSString stringWithFormat:@"执行结果 执行了多少个:%lu",(unsigned long)[allContacts count]]);

            //判断是否有当前发文字信息
            if(i == ([allContacts count] -1)){
                
                uploadLog(geServerTypeTitle(63,5,@"发送文字结束通知"),@"");

                hook_success_task(63,[taskDataDic objectForKey:@"taskId"]);
            }
        }
    });

}



%new
-(void)addAllPublicCard:(NSMutableDictionary *)taskDataDic{
    NSLog(@"========关注公众号(81) 方式3==========");

    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];

    //发送名片
    int cardCount = [[taskDataDic objectForKey:@"cardCount"] intValue];
    int interval =  [[taskDataDic objectForKey:@"subSec"] intValue];
    if(interval == 0){
        interval = 2;
    }

    NSMutableArray *publiAttentionArr = [[NSMutableArray alloc] init];
    if(cardCount > 0){
        for(NSArray *obj in [taskDataDic objectForKey:@"publiAttentionArr"]){
            [publiAttentionArr addObject:[obj mutableCopy]];
        }
    }

    if(cardCount <= 0){
        NSLog(@"81发送名片 MYHOOK 为空");
        uploadLog(geServerTypeTitle(81,3,@"得到发送名片为空"),[NSString stringWithFormat:@"服务没有给数据"]);

        hook_fail_task(81,[taskDataDic objectForKey:@"taskId"],@"得到发送名片为空,服务没有给名片");
    }else{

        dispatch_group_async(group, queue, ^{

            for (int i = 0; i < cardCount; i++) {
                CContact *contact = [[NSClassFromString(@"CContact") alloc] init];

                [contact setM_nsAliasName:[publiAttentionArr[i] objectForKey:@"nsAliasName"]];
                [contact setM_nsUsrName:[publiAttentionArr[i] objectForKey:@"nsUsrName"]];
                [contact setM_nsNickName:[publiAttentionArr[i] objectForKey:@"nsNickName"]];
                [contact setM_nsSignature:[publiAttentionArr[i] objectForKey:@"nsSignature"]];
                [contact setM_nsBrandIconUrl:[publiAttentionArr[i] objectForKey:@"nsBrandIconUrl"]];
                [contact setM_uiCertificationFlag:[[publiAttentionArr[i] objectForKey:@"uiCertificationFlag"] intValue]];
                [contact setM_uiFriendScene:[[taskDataDic objectForKey:@"scene"] intValue]];
                NSLog(@"MYHOOK contact: %@ %@", contact,publiAttentionArr[i]);

                [mgr addContact:contact listType:1];

                uploadLog(geServerTypeTitle(81,2,@"81关注公众号名片"),[NSString stringWithFormat:@"当前关注的名片是:%@",[publiAttentionArr[i] objectForKey:@"nsUsrName"]]);


                [NSThread sleepForTimeInterval:interval];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendTextMessages:[publiAttentionArr[i] objectForKey:@"nsUsrName"] textContent:@"你好"];
                    //显示
                    NSString *text = [NSString stringWithFormat:@"81: %d/%d",i+1,cardCount];
                    nearByFriendlable.text = text;
                    [nearByFriendlable setNeedsDisplay];
                });

                //判断是否有当前发文字信息
                if(i == (cardCount -1)){

                    uploadLog(geServerTypeTitle(81,3,@"关注公众号名片循环"),[NSString stringWithFormat:@"执行结果 执行了多少个:%d",cardCount]);
                    
                    hook_success_task(81,[taskDataDic objectForKey:@"taskId"]);
                }
            }
        });
    }
}

%new
- (void)attentionPublicCard:(NSNotification*)notifiData{

    NSLog(@"========关注公众号(64) 方式1========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;

    NSString *cardUsers = [taskDataDic objectForKey:@"cardUsers"];

    uploadLog(geServerTypeTitle(64,2,@"进行关注微信号"),[NSString stringWithFormat:@"开始 公众号的数据为:%@",cardUsers]);

    if([cardUsers isEqualToString:@""] || [taskDataDic objectForKey:@"cardUsers"] ==nil){

        uploadLog(geServerTypeTitle(64,3,@"服务端给的公众数据为空"),@"");

//        write2File(@"/var/root/hkwx/operation.txt",@"-1");

//        uploadLog(geServerTypeTitle(64,3,@"告知脚本当前任务失败"),@"operation.txt == -1");

        hook_fail_task(64,[taskDataDic objectForKey:@"taskId"],@"服务端给的公众数据为空");
        return;
    }

    NSArray *listCardUsers = [cardUsers componentsSeparatedByString:@","];
    //得到关注公众号的类型
    //3:来自微信号搜索 6:通过好友同意  13:来自手机通讯录 14:群聊 17:通过名片分享添加  18:来自附近人 30:通过扫一扫添加 39:搜索公众号来源
    int scene = [[taskDataDic objectForKey:@"scene"] intValue];

    uploadLog(geServerTypeTitle(64,3,@"当前发公众号的类型为"),[NSString stringWithFormat:@"类型结果为:%d",scene]);

    //得到每个得间隔时间
    __block int m_subSec = [[taskDataDic objectForKey:@"subSec"] intValue];
    if(m_subSec == 0){
        m_subSec = 3;
    }

    //延时
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:5];

        for(int i = 0; i< [listCardUsers count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                id vc = [[NSClassFromString(@"ContactInfoViewController") alloc] init];
                id contact = [[NSClassFromString(@"CContact") alloc] init];
                [contact setM_nsUsrName:listCardUsers[i]];
                [contact setM_uiFriendScene:scene];
                id br = [[NSClassFromString(@"BrandUserContactInfoAssist") alloc] initWithContact:contact delegate:vc];
                [br onAddToContacts];

                uploadLog(geServerTypeTitle(64,3,@"进行关注一个公众号"),[NSString stringWithFormat:@"当前关注公众号为:%@",listCardUsers[i]]);

                //发送消息
                [self sendTextMessages:listCardUsers[i] textContent:@"您好"];

            });

            [NSThread sleepForTimeInterval:m_subSec];

            if(i == ([listCardUsers count] - 1)){
                uploadLog(geServerTypeTitle(64,5,@"关注公众微信号结束"),[NSString stringWithFormat:@"关注的公众号完毕"]);
                
                hook_success_task(64,[taskDataDic objectForKey:@"taskId"]);

                //返回
                if(m_mMUINavigationController){
                    [m_mMUINavigationController popViewControllerAnimated:YES];
                }
                
            }
        }
        
    });
    
}


%new
- (void)attentionPublicCard1:(NSNotification*)notifiData{

    NSLog(@"========关注公众号(64) 方式2========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;

    uploadLog(geServerTypeTitle(64,2,@"进行关注微信号"),@"开始");

    NSString *cardUsers = [taskDataDic objectForKey:@"cardUsers"];

    if([cardUsers isEqualToString:@""]){

        uploadLog(geServerTypeTitle(64,3,@"服务端给的公众数据为空"),@"");

//        write2File(@"/var/root/hkwx/operation.txt",@"-1");

//        uploadLog(geServerTypeTitle(64,3,@"告知脚本当前任务失败"),@"operation.txt == -1");

        hook_fail_task(64,[taskDataDic objectForKey:@"taskId"],@"服务端给的公众数据为空");
         return;
    }

    NSArray *listCardUsers = [cardUsers componentsSeparatedByString:@","];

    if (webCtrl == nil) {
        NSString *url = @"https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzIyNzQ3MzAzNA==&scene=110#wechat_redirect";
        webCtrl = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:url] presentModal:NO extraInfo:nil];

        uploadLog(geServerTypeTitle(64,4,@"开始出时MMWebViewController 控件"),@"");
    }

    //延时
    dispatch_group_async(groupOne, queueOne, ^{

        [NSThread sleepForTimeInterval:5];

        for(int i = 0; i< [listCardUsers count]; i++){

            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary *params = @{@"__context_key": @"", @"scene": @"110", @"username": listCardUsers[i]};
                [[webCtrl m_jsLogicImpl] functionCall:@"quicklyAddBrandContact" withParams:params withCallbackID:@"1003"];

                uploadLog(geServerTypeTitle(64,5,@"开始关注公众微信号"),[NSString stringWithFormat:@"关注的公众号为：%@",listCardUsers[i]]);

            });

            [NSThread sleepForTimeInterval:2];
            if(i == ([listCardUsers count] - 1)){
                uploadLog(geServerTypeTitle(64,5,@"关注公众微信号结束"),[NSString stringWithFormat:@"关注的公众号完毕"]);

                hook_success_task(64,[taskDataDic objectForKey:@"taskId"]);

            }
        }
        
    });

}

%new
-(void)doShakeGet{

    uploadLog(geServerTypeTitle(76,1,@"点击发现"),@"开始点击");

    [m_mMTabBarController setSelectedIndex:2];
}

%new
- (void)driftingBottle{

    uploadLog(geServerTypeTitle(66,2,@"点击发现"),@"开始点击");

    [m_mMTabBarController setSelectedIndex:2];
}



%end

%hook SeePeopleNearByLogicController
- (void)onRetrieveLocationOK:(id)arg1{
    NSLog(@"MYHOOK SeePeopleNearByLogicController:%@",arg1);

    if(m_current_taskType == 70){
        %orig(lbsLocation);
    }else{
        %orig;
    }
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


%hook BrandUserContactInfoAssist
- (void)contactVerifyOk:(id)arg1 opCode:(unsigned int)arg2 {

    NSLog(@"MYHOOK BrandUserContactInfoAssist - contactVerifyOk: %@", arg1);
//    if(m_current_taskType == 64){
        %orig;
//    }
}

%end

//%hook CContactMgr
//- (_Bool)addContact:(id)arg1 listType:(unsigned int)arg2 sync:(_Bool)arg3{
//    BOOL ret = %orig;
//    NSLog(@"addContact:arg1 %@ m_uiFriendScene:%d m_nsCardUrl:%@ listType:(unsigned int)arg2:%d ",arg1,[arg1 m_uiFriendScene],[arg1 m_nsCardUrl],arg2);
//    return ret;
//}
//
//- (_Bool)addContact:(id)arg1 listType:(unsigned int)arg2{
//    BOOL ret = %orig;
//    NSLog(@"addContact:arg1 %@ listType:(unsigned int)arg2:%d ",arg1,arg2);
//    return ret;
//}
//
//- (_Bool)addContact:(id)arg1 listType:(unsigned int)arg2 addScene:(unsigned int)arg3 sync:(_Bool)arg4{
//    BOOL ret = %orig;
//    NSLog(@"addContact:arg1 %@ listType:(unsigned int)arg2:%d ",arg1,arg2);
//    return ret;
//}
//%end

//新朋友页面
%hook SayHelloViewController
- (void)viewDidLoad{
    %orig;

    if(m_current_taskType != 77){
        NSLog(@"当前不是执行77号任务新朋友页面");
        return;
    }

    NSLog(@"hkfodderweixin is (新朋友)");
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            //得到信息
            SayHelloDataLogic *dataLogic = MSHookIvar<SayHelloDataLogic *>(self, "m_DataLogic");

            //得到所以的key
            NSMutableArray *arrHellos = MSHookIvar<NSMutableArray *>(dataLogic, "m_arrHellos");
            NSLog(@"arrHellos :%@",arrHellos);

            NSString *dataJson = @"";
            NSString *oneJson = @"";

            uploadLog(geServerTypeTitle(77,1,@"筛选通讯录数据"),[NSString stringWithFormat:@"筛选通讯录数据的个数为：%d",[arrHellos count]]);

            for(int i=0; i < [arrHellos count]; i++){

                id ccontact = [dataLogic getContactForUserName:arrHellos[i]];
                //上传给服务器
                NSString *nickname = conversionSpecialCharacter([ccontact m_nsNickName]);
                NSString *nsRemark = conversionSpecialCharacter([ccontact m_nsRemark]);
                NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

                NSString *signature = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                             (CFStringRef)[ccontact m_nsSignature],
                                                                                                             NULL,
                                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                             kCFStringEncodingUTF8));
//                NSString *nsDes = conversionSpecialCharacter([ccontact m_nsDes]);

                oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%d\",\"nsRemark\":\"%@\",\"nsDes\":\"%@\",\"signature\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,[ccontact getMobileDisplayName],nsCountry,nsProvince,nsCity,[ccontact m_uiSex],nsRemark,[ccontact m_nsDes],signature];


                NSLog(@"HKWX %@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }


                NSLog(@"%@",ccontact);
             }

            NSLog(@"dataJson:%@",dataJson);

            uploadLog(geServerTypeTitle(77,1,@"筛选通讯录数据"),[NSString stringWithFormat:@"筛选通讯录数据的数据为：%@",dataJson]);

            syncFodderContact(dataJson,[m_taskDataDic77 objectForKey:@"taskId"],[m_nCSetting m_nsUsrName]);

            hook_success_task(77,[m_taskDataDic77 objectForKey:@"taskId"]);

            //返回
            if(m_mMUINavigationController){
                [m_mMUINavigationController popViewControllerAnimated:YES];
            }

            //返回首页
            [m_mMTabBarController setSelectedIndex:0];

        });
    });
}
%end


%hook ContactsViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"HKWeChat(45) ContactsViewController(进入通讯录页面)");

    if(m_current_taskType == 45 || m_current_taskType == 79){

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:8];

            dispatch_async(dispatch_get_main_queue(), ^{

                //同步通讯录信息
                NSString *dataJson = @"";
                NSString *oneJson = @"";


                ContactsDataLogic *contactsDataLogic = MSHookIvar<ContactsDataLogic *>(self, "m_contactsDataLogic");

                NSArray *allContacts = [contactsDataLogic getAllContacts];
                NSLog(@"HKWeChat is allCount:%lu ",(unsigned long)[allContacts count]);

                uploadLog(geServerTypeTitle(m_current_taskType,2,@"获取通讯录好友列表"),[NSString stringWithFormat:@"当前好友的个数为:%lu",(unsigned long)[allContacts count]]);

                for(int i=0; i<[allContacts count];i++){

                    CContact *ccontact = allContacts[i];
                    if(ccontact == nil || [ccontact m_uiCertificationFlag] != 0){
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

                    NSString *signature = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                                 (CFStringRef)[ccontact m_nsSignature],
                                                                                                                 NULL,
                                                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                 kCFStringEncodingUTF8));

                    oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\",\"nsRemark\":\"%@\",\"nsEncodeUserName\":\"%@\",\"signature\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,phoneNumber,nsCountry,nsProvince,nsCity,[ccontact m_uiSex],nsRemark,[ccontact m_nsEncodeUserName],signature];

                    //                        NSLog(@"HKWX %@",oneJson);

                    if([dataJson isEqualToString:@""] || dataJson == nil){
                        dataJson = [NSString stringWithFormat:@"%@",oneJson];
                    }else{
                        dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                    }

                } //end for

                dataJson = [NSString stringWithFormat:@"[%@]",dataJson];
                uploadLog(geServerTypeTitle(m_current_taskType,4,@"执行上传通讯录结果"),@"开始上传 执行这个函数syncContactTask");

                syncContactTask(m_current_taskType,[m_taskDataDic45 objectForKey:@"taskId"],dataJson,1);

                hook_success_task(45,[m_taskDataDic45 objectForKey:@"taskId"]);

                [m_mMTabBarController setSelectedIndex:0];
                
            });
        });

    }else if(m_current_taskType == 77){
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:3];

            dispatch_async(dispatch_get_main_queue(), ^{
                MMMainTableView *tableView =  MSHookIvar<MMMainTableView *>(self, "m_tableView");

                [self tableView:tableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
            });
        });
    }
}

%end


%hook FindFriendEntryViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"HKWeChat FindFriendEntryViewController(发现开始页面) ");

    uploadLog(geServerTypeTitle(66,2,@"进入发现页面"),@"进入成功");

    if(m_current_taskType == 66 || m_current_taskType == 73){
        //进入漂流瓶
        uploadLog(geServerTypeTitle(66,3,@"点击漂流瓶"),@"开始点击");

        [self goToSandyBeach];

    }else if(m_current_taskType == 76){
        //点击摇一摇
        [self openNormalShake];
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
    %orig;
    NSLog(@"HKWECHAT  will show verify alert, but I ignored");
}

- (void)MessageReturn:(id)arg1 Event:(unsigned int)arg2 {
    %orig;

    NSLog(@"MYHOOK CCVL MessageReturn:%@ %@, userName: %@, errCode: %@, ret: %d,,, %d", [MSHookIvar<NSArray *>(self, "m_arrVerifyContactWrap")[0] m_nsUsrName], arg1, [[arg1 m_pbResponse] userName], [[[[arg1 m_pbResponse] baseResponse] errMsg] string], [[[arg1 m_pbResponse] baseResponse] ret], arg2);

//    nsUsrName errCode  ret
    if([[[arg1 m_pbResponse] baseResponse] ret] != 0){

        NSString *errMsg = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"errMsg\":\"%@\",\"errCode\":\"%d\"}",[MSHookIvar<NSArray *>(self, "m_arrVerifyContactWrap")[0] m_nsUsrName],[[[[arg1 m_pbResponse] baseResponse] errMsg] string],[[[arg1 m_pbResponse] baseResponse] ret]];

        NSLog(@"接受到加好友没有加上的错误消息:%@",errMsg);
        uploadLog(geServerTypeTitle(m_current_taskType,2,@"接受到加好友没有加上的错误消息"),[NSString stringWithFormat:@"当前错误消息为：%@",errMsg]);

        [m_addErrorInfo addObject:errMsg];
    }else{

        NSString *errMsg = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"errMsg\":\"%@\",\"errCode\":\"%d\"}",[MSHookIvar<NSArray *>(self, "m_arrVerifyContactWrap")[0] m_nsUsrName],[[[[arg1 m_pbResponse] baseResponse] errMsg] string],[[[arg1 m_pbResponse] baseResponse] ret]];

        NSLog(@"接受到是单向好友:%@",errMsg);

        [m_addSuccessInfo addObject:errMsg];
    }
}


- (void)handleVerifyOk:(id)arg1{
    %orig;
    NSLog(@"HKWECHAT  handleVerifyOk:%@",arg1);

    if(m_current_taskType71 == 71 || m_current_taskType == 78){

        dispatch_group_async(groupTwo, queueTwo, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWECHAT 进行发送名片 %@",arg1);

                uploadLog(geServerTypeTitle(m_current_taskType,2,@"开始通知发送名片和消息"),[NSString stringWithFormat:@"发送消息的微信ID为：%@",arg1]);

                //进行发名片
                NSNotification *notification =[NSNotification notificationWithName:kSendMsgOnePerson object:nil userInfo:arg1];

                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
            
        });//dis
    }

}


%end // end hook


%hook SightFacade
- (struct CGRect)jumpToMomentTimelineTopAtBackgroundWithMediaItem:(id)arg1 {
    NSLog(@"MYHOOK jumpToMomentTimelineTopAtBackgroundWithMediaItem: %@", arg1);
    // return %orig;
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
//    [contact setM_nsAliasName:result[@"aliasName"]];
//    [contact setM_nsUsrName:result[@"userName"]];
//    [contact setM_nsNickName:result[@"nickName"]];
//    [contact setM_nsSignature:result[@"signature"]];
//    [contact setM_nsBrandIconUrl:result[@"headImgUrl"]];
//    [contact setM_uiCertificationFlag:[result[@"verifyFlag"] intValue]]
//    NSLog(@"MYHOOK - CMessageMgr - AddMsg:1: %@, 2: %@", arg1, arg2);

//    NSLog(@"MYHOOK - m_nsContent:%@, m_nsUsrName:%@ m_dtThumbnail:%@ m_uiMessageType:%d", [arg2 m_nsContent],[arg2 m_dtThumbnail],[arg2 m_nsNickName],[arg2 m_uiMessageType]);
}

- (id)initWithMsgType:(long long)arg1 nsFromUsr:(id)arg2{
    id  ret = %orig;
    NSLog(@"initWithMsgType :%lld arg2:%@",arg1,arg2);

    return ret;
}

- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3{
    %orig;
//    NSString *msgDBItem = [NSString stringWithFormat:@"%@",arg2];
//    NSLog(@"----------%@",msgDBItem);
//    if([msgDBItem rangeOfString:@"type=10000"].location != NSNotFound && [msgDBItem rangeOfString:@"_25"].location != NSNotFound){
//
//        NSArray *listItem = [msgDBItem componentsSeparatedByString:@";"];
//
//        NSLog(@" msgDBItem is:%@,listItem:%@",msgDBItem,listItem);
//
//        //保存到文件中
//        write2File(@"/var/root/hkwx/sendMsgFail.plist", msgDBItem);
//
//        NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkwx/sendMsgFail.plist"];
//
//        NSArray *keys = [config[@"_25"] allKeys];
//
//        NSLog(@"-----------------%@ keys %@",config[@"_25"],keys);
//    }
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

                uploadLog(geServerTypeTitle(m_current_taskType,4,@"当前任务执行的错误结果"),[NSString stringWithFormat:@"错误内容为：%@",[errorMsg content]]);

                write2File(@"/var/root/hkwx/errorMsg.txt",[errorMsg content]);
            });
            
        });


    }

    return ret;
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
    if(m_fetchUinAndKeyUrl != nil && ![m_fetchUinAndKeyUrl isEqualToString:@""] &&  !m_fetchUinAndKeyOK){
        //得到
        NSArray *listUrl = [m_fetchUinAndKeyUrl componentsSeparatedByString:@"?"];
        NSLog(@"this is listUrl[0] %@",listUrl[0]);

        if([currentURl rangeOfString:listUrl[0]].location != NSNotFound){

            uploadLog(geServerTypeTitle(59,3,@"从YYUIWebView类得到key的链接上传"),[NSString stringWithFormat:@"微信uuid:%@",[m_nCSetting m_nsUsrName]]);

            NSLog(@"this upload back server url##########----------");

            saveMyAccountUinAndKey(59,currentURl,[m_nCSetting m_nsUsrName]);

//            hook_success_task(59,[m_taskDicKey objectForKey:@"taskId"]);

            m_fetchUinAndKeyOK = YES;
        }
    }else if([currentURl containsString:@"addchatroombyqrcode?uuid"]){

        NSString *titleScript = @"document.getElementsByClassName('title')[0].innerText";
        NSString *errorTitle = [self stringByEvaluatingJavaScriptFromString:titleScript];

        if([errorTitle isEqualToString:@""]){

            NSString *script = [NSString stringWithFormat:@"document.getElementById(\"form\").submit();"];
            [self stringByEvaluatingJavaScriptFromString:script];

            uploadLog(geServerTypeTitle(88,0,@"进入了进群页面,js注入进群,并给进群发送通知消息"),[NSString stringWithFormat:@"YYUIWebView这个函数中"]);


            [[NSNotificationCenter defaultCenter] postNotificationName:kAttackChatRoomsNotificton object:nil userInfo:m_taskDataDic88];
        }else{
            NSLog(@"当前无法加入群信息,获取到的内容为：%@",errorTitle);
            uploadLog(geServerTypeTitle(88,0,@"当前无法加入群信息,获取到的内容为"),[NSString stringWithFormat:@"%@",errorTitle]);

            hook_fail_task(m_current_taskType,[m_taskDataDic88 objectForKey:@"taskId"],errorTitle);
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
    return qrResult;
}


- (void)webViewDidFinishLoad:(id)arg1 {
    %orig;

    NSString *currentUrl = [self getCurrentUrl];
    if(m_current_taskType == 88){
        uploadLog(geServerTypeTitle(88,0,@"MMWebViewController的webViewDidFinishLoad url为"),[NSString stringWithFormat:@"%@",currentUrl]);
    }

    if ([currentUrl containsString:@"&ext=needScan"]) {
        NSString *imgUrl = [[self webView] stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[0].src"];
        // CGFloat h = [res integerValue];
        // [[[self webView] scrollView] setContentSize:CGSizeMake([[self webView] frame].size.width, h + 50)];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];

        uploadLog(geServerTypeTitle(88,0,@"得到图片信息MMWebViewController"),[NSString stringWithFormat:@"进行图片存储"]);

        NSLog(@"MYHOOK imageURL: %@", imgUrl);
        if (img != nil) {
            NSString *url = [self decodeQRImageWith:img];

            uploadLog(geServerTypeTitle(88,0,@"收到了进入了needScan,图片img不为空"),[NSString stringWithFormat:@"图片url：%@",url]);

            NSLog(@"MYHOOK qrcode url: %@", url);

            id scanQrCode = [[NSClassFromString(@"ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:2];
            [scanQrCode scanOnePicture:img];

        }else{
            uploadLog(geServerTypeTitle(88,0,@"收到了进入了needScan,图片img为空"),[NSString stringWithFormat:@""]);
        }
    }

    if([currentUrl containsString:@"addchatroombyqrcode?uuid="]){
            //https://szsupport.weixin.qq.com/cgi-bin/mmsupport-bin/addchatroombyqrcode?uuid=A07TnSHEwOZwZMZg&exportkey=A2JhRu7%2FVsz4Vo4zhWSGhig%3D&pass_ticket=Cw%2BUE4nSDlyI%2FGvroZ1eJSc61xvgaWIyyFuiRYobBVF186el8fH8ATGxanqQJzbk&wechat_real_lang=zh_CN
    
            NSArray *arrayUrl = [currentUrl componentsSeparatedByString:@"uuid="];
            NSArray *arrayUrl2 = [arrayUrl[1] componentsSeparatedByString:@"&"];
    
            NSLog(@"arrayUrl2:%@ ====%@",arrayUrl2,arrayUrl2[0]);
    
            m_scanQrUrl = [arrayUrl2 mutableCopy];
    
            uploadLog(geServerTypeTitle(88,0,@"进入了MMWebViewController得到addchatroombyqrcode"),[NSString stringWithFormat:@"二维码key为：%@",arrayUrl2]);
    }

//    if([currentUrl containsString:@"addchatroombyqrcode?uuid"]){
//        NSString *script = [NSString stringWithFormat:@"document.getElementById(\"form\").submit();"];
//        [[self webView] stringByEvaluatingJavaScriptFromString:script];
//    }
}

%end

// 4.4.0 方式
//%hook MMWebViewController
//
//%property(nonatomic, copy) BOOL isMyGroupWeb;
//
//
//%new
//- (NSString *)decodeQRImageWith:(UIImage*)aImage {
//    NSString *qrResult = nil;
//
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
//    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
//    NSArray *features = [detector featuresInImage:image];
//    CIQRCodeFeature *feature = [features firstObject];
//
//    qrResult = feature.messageString;
//    NSLog(@"==============decodeQRImageWith======");
//    return qrResult;
//}
//
//
//- (void)webViewDidFinishLoad:(id)arg1 {
//    %orig;
//
//    NSString *currentUrl = [self getCurrentUrl];
//
//    NSLog(@"currentUrl :%@",currentUrl);
//
//    if ([currentUrl containsString:@"&ext=needScan"]) {
//        NSString *res = [[self webView] stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
//        CGFloat h = [res integerValue];
//        [[[self webView] scrollView] setContentSize:CGSizeMake([[self webView] frame].size.width, h + 50)];
//        UIImage *img = [[self webView] getImage];
//
//        uploadLog(geServerTypeTitle(88,0,@"收到了进入了needScan"),[NSString stringWithFormat:@"进行图片存储"]);
//
//        if (img != nil) {
//            NSString *url = [self decodeQRImageWith:img];
//
//            NSLog(@"ScanQRCodeLogicController url is %@",url);
//
//            //发送消息
////            [[NSNotificationCenter defaultCenter] postNotificationName:kScanQRCodeNotificton object:nil userInfo:nil];
//        }
//    }else if([currentUrl containsString:@"addchatroombyqrcode?uuid="]){
//        //https://szsupport.weixin.qq.com/cgi-bin/mmsupport-bin/addchatroombyqrcode?uuid=A07TnSHEwOZwZMZg&exportkey=A2JhRu7%2FVsz4Vo4zhWSGhig%3D&pass_ticket=Cw%2BUE4nSDlyI%2FGvroZ1eJSc61xvgaWIyyFuiRYobBVF186el8fH8ATGxanqQJzbk&wechat_real_lang=zh_CN
//
//        NSArray *arrayUrl = [currentUrl componentsSeparatedByString:@"uuid="];
//        NSArray *arrayUrl2 = [arrayUrl[1] componentsSeparatedByString:@"&"];
//
//        NSLog(@"arrayUrl2:%@ ====%@",arrayUrl2,arrayUrl2[0]);
//
//        m_scanQrUrl = [arrayUrl2 mutableCopy];
//
//        uploadLog(geServerTypeTitle(88,0,@"进入了MMWebViewController得到addchatroombyqrcode"),[NSString stringWithFormat:@"二维码key为：%@",arrayUrl2]);
//    }
//}
//
//%end



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

    if(m_current_taskType == 4 || m_current_taskType == 70){

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:2];

            dispatch_async(dispatch_get_main_queue(), ^{
                uploadLog(geServerTypeTitle(4,5,@"点击我知道了"),@"发文字消息");

                [self onIKnowItBtnClick:@"0"];
            });
            
        });
    }

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
            if(m_current_taskType == 4){
                uploadLog(geServerTypeTitle(4,6,@"点击我知道了"),@"文字和图片");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 70){

                uploadLog(geServerTypeTitle(70,6,@"点击我知道了"),@"按钮");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 66 || m_current_taskType == 73){

                uploadLog(geServerTypeTitle(66,6,@"漂流瓶被投诉了"),@"任务置失败 告诉脚本");

                [self onClickBtn:[self getBtnAtIndex:0]];

//                write2File(@"/var/root/hkwx/operation.txt",@"-1");
                m_is_bottlecomplain = YES;

                uploadLog(geServerTypeTitle(66,6,@"告知脚本当前任务失败"),@"operation.txt == -1");
//                hook_fail_task
            }

        });
        
    });
}
%end

%hook SandyBeachViewController
- (id)init{
    id ret = %orig;

    if((m_current_taskType == 66 ||m_current_taskType == 73)&& !m_enterBottle){
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

                    //返回首页
                    uploadLog(geServerTypeTitle(66,4,@"返回到首页"),@"");

                    [m_mMTabBarController setSelectedIndex:0];

                    //开始推送消息
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kSendDriftingBottleNotificton object:nil];

                }
            });

            [NSThread sleepForTimeInterval:5];

            NSLog(@"开始推送消息 发送漂流瓶");

            uploadLog(geServerTypeTitle(66,4,@"开始推送消息kSendDriftingBottleNotificton 发消息"),@"");
            //开始推送消息
            [[NSNotificationCenter defaultCenter] postNotificationName:kSendDriftingBottleNotificton object:nil];

        });

    }

    return ret;

}
%end


%hook ShakeViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"进入摇一摇 %@",m_taskTypeShake);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            uploadLog(geServerTypeTitle(76,1,@"开始进入初始化摇一摇"),@"");

            ShakeLogicProxy *shakeLogic = MSHookIvar<ShakeLogicProxy *>(self, "m_logicProxy");

            ShakePeopleLogicController *shakePeoPle = MSHookIvar<ShakePeopleLogicController *>(shakeLogic, "m_shakePeopleLogic");

            [shakePeoPle createShakeReportEvent];

            uploadLog(geServerTypeTitle(76,2,@"开始进入createShakeReportEvent摇一摇"),@"");

            id sayHello = [[NSClassFromString(@"MMSayHelloViewController") alloc] init];

            __block int yaoYiYaoOneCount = [[m_taskTypeShake objectForKey:@"yaoYiYaoOneCount"] intValue];
            __block int yaoYiYaoInterval = [[m_taskTypeShake objectForKey:@"yaoYiYaoInterval"] intValue];

            NSLog(@"摇一摇 yaoYiYaoOneCount:%d yaoYiYaoInterval:%d msgContent:%@",yaoYiYaoOneCount,yaoYiYaoInterval,[m_taskTypeShake objectForKey:@"msgContent"]);

            dispatch_group_async(groupOne, queueOne, ^{

                for(int i=0; i < yaoYiYaoOneCount; i++){

                    [NSThread sleepForTimeInterval:2];

                    //开始摇一摇
                    [shakePeoPle doShakeGet];
                    uploadLog(geServerTypeTitle(76,2,@"开始摇一摇,摇一次doShakeGet"),[NSString stringWithFormat:@"摇完毕,当前计数为%d",i+1]);

                    [NSThread sleepForTimeInterval:yaoYiYaoInterval];

                    dispatch_async(dispatch_get_main_queue(), ^{


                        NSString *text = [NSString stringWithFormat:@"%d/%d",i, yaoYiYaoOneCount];
                        nearByFriendlable.text = text;
                        [nearByFriendlable setNeedsDisplay];


                        NSMutableArray *ccs = [[shakePeoPle m_getResponse] shakeGetList];
                        if ([ccs count]) {

                            id c = ccs[0];
                            //进行打招呼
                            id myContact = [[NSClassFromString(@"CContact") alloc] init];
                            [myContact setM_nsUsrName:[c userName]];
                            [myContact setM_nsNickName:[c nickName]];
                            [myContact setM_nsCountry:[c country]];
                            [myContact setM_nsProvince:[c province]];
                            [myContact setM_nsCity:[c city]];
                            [myContact setM_nsSignature:[c signature]];
                            [myContact setM_uiSex:[c sex]];
                            uploadLog(geServerTypeTitle(76,4,@"设置开始发送消息"),[NSString stringWithFormat:@"当前给%@发送消息",[c userName]]);
                            [sayHello setHelloReceiver:myContact];
                            [sayHello setHelloContent:[m_taskTypeShake objectForKey:@"msgContent"]];
                            [sayHello doSayHello:[m_taskTypeShake objectForKey:@"msgContent"]];

                            uploadLog(geServerTypeTitle(76,5,@"发送消息完毕"),[NSString stringWithFormat:@"当前给%@发送消息",[c userName]]);
                                                                         

                        }else{

                            uploadLog(geServerTypeTitle(76,3,@"没有摇到数据"),@"当前摇一摇失败");

                        }


                    });

                    if(i == (yaoYiYaoOneCount -1)){

                        uploadLog(geServerTypeTitle(76,6,@"告知服务器漂流瓶发送数据完毕"),@"");
                        //告诉服务器当前是否完毕
                        hook_success_task(76,[m_taskTypeShake objectForKey:@"taskId"]);

                        //返回
                        if(m_mMUINavigationController){
                            [m_mMUINavigationController popViewControllerAnimated:YES];
                        }

                        //返回首页
                        uploadLog(geServerTypeTitle(76,4,@"返回到首页"),@"");
                        
                        [m_mMTabBarController setSelectedIndex:0];

                    }
                }

            });



        });
        
    });
}

%end


%hook ContactInfoViewController

- (void)viewDidLoad{
    %orig;

    
    NSLog(@"%@",[[self m_contact] m_nsUsrName]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:1];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(250, 60, 50, 50)];
            btn1.layer.cornerRadius = 15;
            [btn1 setTitle:@"上传" forState:UIControlStateNormal];
            [btn1 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
            [btn1 setBackgroundColor:[UIColor whiteColor]];
            [btn1 addTarget: self action:@selector(showSheet)
           forControlEvents: UIControlEventTouchDown];
            
            [self.view addSubview:btn1];

            //判断当前是否是88号任务
            if(m_current_taskType == 88){

                uploadLog(geServerTypeTitle(88,5,@"当前执行炮灰号侦测群任务是进入公众号关注页面或者个人号页面"),[NSString stringWithFormat:@"任务置失败,当前的任务ID为%@,当前的微信号为：%@,进入当前的微信 nsUsrName 为：%@",[m_taskDataDic88 objectForKey:@"taskId"],[m_nCSetting m_nsUsrName],[[self m_contact] m_nsUsrName]]);

                //扫码进入公众号,通知这个任务失败
                hook_fail_task(m_current_taskType,[m_taskDataDic88 objectForKey:@"taskId"],[NSString stringWithFormat:@"当前执行炮灰号侦测群任务是进入公众号关注页面或者个人号页面,当前的微信号为：%@,进入当前的微信 nsUsrName 为：%@",[m_nCSetting m_nsUsrName],[[self m_contact] m_nsUsrName]]);
            }
        });
        
    });

}


%new
-(void)showSheet{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"上传数据"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {

                                                           [self upLoadData];

                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"关注海尔"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {

                                                           [self testAttionCard];

                                                       }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}


%new
- (void)testAttionCard{

    NSString *msContentList = @"您好,请多关照,你好,say hi,可以聊聊吗,在做什么,打搅了,hello,Give me a hug,What's up,Nice to meet you,好久不见,还好吗,最近如何?,1,2,3";
    NSArray *listContent = [msContentList componentsSeparatedByString:@","];
    int pos = arc4random() % ([listContent count]-1);
    NSString *nsContent = listContent[pos];

    id vc = [[NSClassFromString(@"ContactInfoViewController") alloc] init];
    id contact = [[NSClassFromString(@"CContact") alloc] init];
    [contact setM_nsUsrName:@"gh_f3e5c3043af6"];
    [contact setM_uiFriendScene:30];
    id br = [[NSClassFromString(@"BrandUserContactInfoAssist") alloc] initWithContact:contact delegate:vc];
    [br onAddToContacts];

    //发送消息
    CContactMgr *mgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    CMessageWrap *myMsgText = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nCSetting m_nsUsrName]];
    CMessageMgr *msMgrText = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsgText.m_nsContent = nsContent;
    myMsgText.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsgText.m_nsFromUsr = [m_nCSetting m_nsUsrName];
    myMsgText.m_nsToUsr = @"gh_f3e5c3043af6";
    myMsgText.m_uiCreateTime = (int)time(NULL);
    [msMgrText ResendMsg: @"gh_f3e5c3043af6" MsgWrap:myMsgText];
    NSLog(@"MYHOOK will send to %@:", myMsgText);

//    NSLog(@"==========关注海尔");
//    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
//
//    CContact *contact = [[NSClassFromString(@"CContact") alloc] init];
//
//    [contact setM_nsAliasName:@"haier-fw"];
//    [contact setM_nsUsrName:@"gh_f3e5c3043af6"];
//    [contact setM_nsNickName:@"海尔服务"];
//    [contact setM_nsSignature:@"海尔集团服务号，您家电保修的唯一凭证"];
//    [contact setM_nsBrandIconUrl:@"http://mmbiz.qpic.cn/mmbiz/AibYR0VkiaicsBcGwibpDHic7xfkLfQ0QLSDl4FOdqyqCCEaDwlYEUGAdwePeLxOQVPVWsLvHMMGHWVYGFGoUHKebRA/0?wx_fmt=png"];
//    [contact setM_uiCertificationFlag:24];
//    [contact setM_uiFriendScene:30];
//    NSLog(@"MYHOOK contact: %@", contact);
//
//    [mgr addContact:contact listType:1];
}

%new
- (void)upLoadData{

    CContact *ccontact = [self m_contact];

    NSString *contactData = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsBrandIconUrl\":\"%@\",\"uiCertificationFlag\":\"%d\",\"nsSignature\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],[ccontact m_nsNickName],[ccontact m_nsBrandIconUrl],[ccontact m_uiCertificationFlag],[ccontact m_nsSignature]];

    NSLog(@"contactData :%@",contactData);

    uploadPublicCardInfo(contactData);
}

%end

%hook MMSayHelloViewController
- (void)onSendSayHello:(id)arg1{
    %orig;
     NSLog(@"MMSayHelloViewController onSendSayHello:%@",arg1);
}
- (id)filterString:(id)arg1{

    id ret = %orig;
    NSLog(@"MMSayHelloViewController filterString:%@",arg1);
    return ret;

}
- (_Bool)doSayHello:(id)arg1{
    BOOL ret = %orig;
    NSLog(@"MMSayHelloViewController doSayHello:%@",arg1);
    return YES;
}
%end

%hook WeixinContactInfoAssist
- (void)contactVerifyOk:(id)arg1 opCode:(unsigned int)arg2{
    %orig;

    NSLog(@"WeixinContactInfoAssist contactVerifyOk:(id)arg1:%@ opCode:(unsigned int)arg2:%u",arg1,arg2);
}

- (void)onVerifyContact:(id)arg1 opcode:(unsigned int)arg2{
    %orig;

    NSLog(@"WeixinContactInfoAssist onVerifyContact:(id)arg1:%@ opcode:(unsigned int)arg2:%u",arg1,arg2);
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

            //给服务器打点
            if([m_logurl[0] isEqualToString:@""]){
                [m_logurl addObject:@"http://log.vogueda.com/shareplatformWxTest/weixin/serverlog.htm"];
            }

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

                uploadLog(geServerTypeTitle(0,0,@"读取到脚本写的值,执行AccountStorageMgr完毕"),[NSString stringWithFormat:@"保存文件名为：%@,当前微信号为:%@",isRealPath,[m_nCSetting m_nsUsrName]]);

            }else{
                uploadLog(geServerTypeTitle(0,0,@"读取到脚本写的值,accountStorageMgr不为1,不写更新标示"),[NSString stringWithFormat:@"当前微信号为：%@",[m_nCSetting m_nsUsrName]]);
            }

        });
        
    });
}
%end







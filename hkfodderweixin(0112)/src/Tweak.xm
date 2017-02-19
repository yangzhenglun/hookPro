
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
static BaseMsgContentViewController *baseMsgContentVC = nil;


static UILabel *nearByFriendlable = [[UILabel alloc] initWithFrame:CGRectMake(100, 2, 120, 30)];


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

static id webCtrl = nil;


//创建通知消息
 #define kSendFriendsNotificton                      @"kSendFriendsNotificton"   //发朋友圈
#define kMsgAndLinkNotificton                       @"kMsgAndLinkNotificton"           //推送消息+链接
#define kAttentionPublicCardNotificton              @"kAttentionPublicCardNotificton"            //关注公众号
#define kDriftingBottleNotificton                   @"kDriftingBottleNotificton"       //发漂流瓶
#define kSendMsgOnePerson                           @"kSendMsgOnePerson"   //向一个好友发名片
#define kSendDriftingBottleNotificton               @"kSendDriftingBottleNotificton"  //发瓶子消息

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
static NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskTypeDic71 = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskTypeDicBottle = [NSMutableDictionary dictionaryWithCapacity:1];
NSMutableDictionary *m_taskDicKey = [NSMutableDictionary dictionaryWithCapacity:1];

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
    [logDic setObject:@"3.0.0" forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hook" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

//    NSString *jsonData = [NSString stringWithFormat:@"\"ipad\":\"%@\",\"weixinId\":\"%@\",\"weixinUuid\":\"%@\",\"phone\":\"%@\",\"taskId\":\"%@\",\"taskType\":\"%@\",\"hookVersion\":\"%@\",\"luaVersion\":\"%@\",\"devType\":\"%@\",\"logTitle\":\"%@\","];

    //打开日志
//    NSLog(@"上传日志：%@",jsonData);

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

extern "C" void hook_fail_task(int currentType,NSString *taskId){

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

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@",taskId];


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
            
            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url);

            uploadLog(geServerTypeTitle(currentType,4,@"上传key成功"),@"告诉可以执行下一个任务了");

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
                uploadLog(geServerTypeTitle(m_current_taskType,7,@"执行上传通讯录结果"),[NSString stringWithFormat:@"结果为：%@",aString]);
            }else if(m_current_taskType == 45){
                uploadLog(geServerTypeTitle(m_current_taskType,5,@"执行上传通讯录结果"),[NSString stringWithFormat:@"结果为：%@",aString]);
            }

            if(isLast == 1){
                //通知脚本当前通讯录同步完毕
//                write2File(@"/var/root/hkwx/wxResult.txt", @"1");

                if(m_current_taskType == 54){
                    uploadLog(geServerTypeTitle(m_current_taskType,8,@"告知脚本结束"),@"通知脚本当前通讯录同步完毕");
                }else if(m_current_taskType == 45){
                    uploadLog(geServerTypeTitle(m_current_taskType,6,@"告知脚本结束"),@"通知脚本当前通讯录同步完毕");
                }

            }
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
    }else if(readType == 70){
        title = [NSString stringWithFormat:@"%当前执行71号任务-%@",currentNum,data];
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

    m_isRequestResult = 1;

    if([[taskInfo objectForKey:@"taskId"] isEqualToString:@"10000"]){
        m_current_modify = YES;
        NSLog(@"hkfodderwinxin 是修改头像地区信息");
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

    // 2. Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //开始请求数据
//    uploadLog(getLocalTypeTitle(1,@"请求数据"),[NSString stringWithFormat:@"开始执行 坏境为:%@",url]);

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
//                m_taskArrayData  = [taskAll objectForKey:@"dataList"];

                NSLog(@"HKWeChat count m_taskArrayData:%@",m_taskArrayData);

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

            }else{
                uploadLog(geServerTypeTitle(59,3,@"fetchUinAndKeyUrl执行获取key失败"),[NSString stringWithFormat:@"fetchUinAndKeyUrl链接为空"]);
                m_current_taskIsOK = YES;

                hook_fail_task(59,[m_taskDicKey objectForKey:@"taskId"]);
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

//捡瓶子和发信息
%new
- (void)pickUpBottle{

    NSLog(@"开始 捡瓶子和发信息");
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

                hook_fail_task(66,[m_taskTypeDicBottle objectForKey:@"taskId"]);

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

//首页附近人
%new
- (void)findLBSUsrs:(NSMutableDictionary*)taskDataDic{

    double latitude =  [[taskDataDic objectForKey:@"latitude"] doubleValue]; //133;
    double longitude =  [[taskDataDic objectForKey:@"longitude"] doubleValue]; //100;

    uploadLog(geServerTypeTitle(73,2,@"开始进入函数"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);

    if(latitude <= 0 || longitude  <= 0){
        uploadLog(geServerTypeTitle(73,3,@"经纬度错误"),[NSString stringWithFormat:@"latitude:%d longitude:%d",latitude,longitude]);
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];

    uploadLog(geServerTypeTitle(73,4,@"开始定位坐标"),[NSString stringWithFormat:@"%@",location]);

    uploadLog(geServerTypeTitle(73,5,@"开始执行获取附近信息"),@"");
    //得到坐标
    id vc = [[NSClassFromString(@"SeePeopleNearbyViewController") alloc] init];
    [vc startLoading];
    [[vc  logicController] setM_location:location];
    [vc startLoading];

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:10];

        dispatch_async(dispatch_get_main_queue(), ^{

            uploadLog(geServerTypeTitle(73,6,@"数据上传服务器"),@"");

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

- (void)removeObserver:(id)observer
{
    NSLog(@"====%@ remove===", [observer class]);
}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;
}


%new
- (void)addFriendByWXId:(NSMutableDictionary *)taskDataDic {
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
        uploadLog(geServerTypeTitle(71,3,@"循环结束"),[NSString stringWithFormat:@"执行完毕 循环执行完毕,共有:%d个",[listNearBy count]]);

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

}


%new
-(void)sendMsgOnePerson:(NSNotification *)notificationText{
    //给一个人推送名片和消息

    NSLog(@"notificationText %@ %@",notificationText.userInfo,m_taskTypeDic71);

    NSString *wxid = (NSString *)notificationText.userInfo;

    uploadLog(geServerTypeTitle(71,2,@"接受到加完好友后的通知(当前需要发消息和发名片)"),[NSString stringWithFormat:@"接受到的消息为：%@",notificationText.userInfo]);

    //发消息
    CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
    //得到自己的信息
    NSString *myself = [[mgr getSelfContact] m_nsUsrName];

    int msgType = 1;

    NSString *m_textContent = [m_taskTypeDic71 objectForKey:@"msgContent"];
    if([m_textContent isEqualToString:@""]){

        NSLog(@"MYHOOK textContent is null");
        uploadLog(geServerTypeTitle(71,2,@"得到发送文字为空"),[NSString stringWithFormat:@"wxid:%@ 发送消息失败后面的名片也不发送",wxid]);
        return;
    }

    NSLog(@"========================");
    CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:myself];

    msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
    myMsg.m_nsContent = m_textContent;//@"你哈 我是小娟";
    myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    myMsg.m_nsFromUsr = myself;
    myMsg.m_nsToUsr = wxid;
    myMsg.m_uiCreateTime = (int)time(NULL);
    [msMgr ResendMsg: wxid MsgWrap:myMsg];
    NSLog(@"MYHOOK will send to %@:", myMsg);

    NSArray *cardUsers = [[m_taskTypeDic71 objectForKey:@"cardUser"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

    if([cardUsers count]<= 0){

        NSLog(@"MYHOOK this is cardUser is null");
        uploadLog(geServerTypeTitle(71,2,@"得到名片为空"),[NSString stringWithFormat:@"wxid:%@ 名片不会发送",wxid]);
        return;
    }

    uploadLog(geServerTypeTitle(71,2,@"开始发送第一个名片"),[NSString stringWithFormat:@"wxid:%@ 名片为:%@",wxid,cardUsers[0]]);

    //发送第一个名片
    [self sendCardOnePerson:wxid cardUser:cardUsers[0]];

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{
        //延时2s
            uploadLog(geServerTypeTitle(71,2,@"开始发送第二个名片"),[NSString stringWithFormat:@"wxid:%@ 名片为:%@",wxid,cardUsers[0]]);
            [self sendCardOnePerson:wxid cardUser:cardUsers[1]];
        });

    });
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

    NSLog(@"发送给谁名片消息:%@ 名片为：%@",sendContact,sendCardUser);

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

%new
-(void)getNextTask{
//    m_current_taskCount = m_current_taskCount + 1;

    if([m_taskArrayData count]<= 0){
        write2File(@"/var/root/hkwx/operation.txt",@"-1");
        uploadLog(geServerTypeTitle(0,0,@"hook当前所有没有任务"),@"");
        return;
    }

    int __block hookOverTime = 0;
    static NSMutableDictionary *taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];

    //
    dispatch_group_async(group, queue, ^{

        for(int i=0; i<[m_taskArrayData count]; i++){

            //得到当前的数据
            [taskDataDic removeAllObjects];

            taskDataDic = m_taskArrayData[i];

            //得到当前的异步时间
            hookOverTime = [[taskDataDic objectForKey:@"hookOverTime"] intValue];

            NSLog(@"当前的任务为：%@ 间隔时间为：%d",taskDataDic,hookOverTime);

            dispatch_async(dispatch_get_main_queue(), ^{
                //简析当前的任务类型等
                m_current_taskType = [[taskDataDic objectForKey:@"taskType"] intValue];

                if(m_current_taskType == 4){
                    //      发朋友圈
                    NSLog(@"-----------当前要发朋友圈");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSendFriendsNotificton object:nil userInfo:taskDataDic];

                }else if(m_current_taskType == 45){
                    //      同步通讯录
                    [self syncMailList];

                }else if(m_current_taskType == 59){
                    //发送消息执行获取key
                    write2File(@WXGROUP_RED_MAP_LIST, [taskDataDic objectForKey:@"weixinListData"]);

                    m_taskDicKey = [m_taskArrayData[i] mutableCopy];

                    [self batchMpDocReadCount:[taskDataDic objectForKey:@"taskId"]];


                }else if(m_current_taskType == 64){
                    //公众号关注
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAttentionPublicCardNotificton object:nil userInfo:taskDataDic];

                }else if(m_current_taskType == 66){
                    //捡瓶子
                    m_pickupinterval = [[taskDataDic objectForKey:@"interval"] intValue];
                    m_pickupCount = [[taskDataDic objectForKey:@"pickupCount"] intValue];

                    write2File(@WXPICK_BOTTLE_LIST, [taskDataDic objectForKey:@"weixinListData"]);

                    m_taskTypeDicBottle = [m_taskArrayData[i] mutableCopy];
                    //       漂流瓶
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDriftingBottleNotificton object:nil];
                    
                }else if(m_current_taskType == 71){

                    m_current_taskType71 = 71;
                    m_taskTypeDic71 = m_taskArrayData[i];

                    NSLog(@"-----------当前要进行暴力加好友 %@",m_taskTypeDic71);

                    //1、暴力加好友
                    [self addFriendByWXId:taskDataDic];

                }else if(m_current_taskType == 72){
                    //首页附近人
                    [self findLBSUsrs:taskDataDic];
                }

            });

            while(!m_current_taskIsOK){
                NSLog(@"hook 等待上一个任务结束");
                [NSThread sleepForTimeInterval:5];
            }

            m_current_taskIsOK = NO;

            //判断是不是暴力加好友,延时5s 执行下一个任务。
            if(m_current_taskType == 71){
                [NSThread sleepForTimeInterval:5];
            }

        }

        uploadLog(geServerTypeTitle(0,0,@"当前所有任务结束告诉脚本"),@"所有任务结束");

        //延时10s 告诉脚本结束
        [NSThread sleepForTimeInterval:10];

        //告诉脚本结束
        write2File(@"/var/root/hkwx/wxResult.txt", @"1");

    });

}

- (void)viewDidLoad {
    %orig;

//    [self syncMailList];
////
//    return;

    if(m_current_taskCount == -1){
        [self registerNotification];
    }

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString *text = @"";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [nearByFriendlable setText:text];
    nearByFriendlable.textColor = [UIColor redColor];
    [window addSubview:nearByFriendlable];
    [window bringSubviewToFront:nearByFriendlable];

     NSLog(@"是否漂流瓶 %d",m_enterBottle);

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

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];

        for (id key in dicContact) {


            dispatch_async(dispatch_get_main_queue(), ^{

                id valueCContact= key;///[ dicContact objectForKey:key];
                NSLog(@"valueCContact :%@",valueCContact);

                id contact5 = [[NSClassFromString(@"CContact") alloc] init];

                [contact5 setM_nsAliasName:@"cocoachinabbs"];
                [contact5 setM_nsUsrName:@"gh_d9c2fdea6f2a"];
                [contact5 setM_nsNickName:@"CocoaChina"];
                [contact5 setM_nsSignature:@"CocoaChina苹果开发中文社区官方微信，提供教程资源、app推广营销、招聘、外包及培训信息、各类沙龙交流活动以及更多开发者服务"];
                [contact5 setM_nsBrandIconUrl:@"http://wx.qlogo.cn/mmhead/Q3auHgzwzM4OH1MN4UzFt2rUgRy54mibicUR0ROvJGcygibZ8UAyCwfjQ/132"];
                [contact5 setM_uiCertificationFlag:24];
                NSLog(@"MYHOOK contact: %@", contact5);


                id contact = [[NSClassFromString(@"CContact") alloc] init];

                [contact setM_nsAliasName:@"kzg365"];
                [contact setM_nsUsrName:@"gh_e99e3fe85453"];
                [contact setM_nsNickName:@"侃中国"];
                [contact setM_nsSignature:@"侃历史，侃天下，侃是非，侃文化。"];
                [contact setM_nsBrandIconUrl:@"http://wx.qlogo.cn/mmhead/Q3auHgzwzM4uttX3x7oice5fRr4k0Zqxb9N7WNMWVl91j3h6ic80Kgqw/132"];
                [contact setM_uiCertificationFlag:8];
                NSLog(@"MYHOOK contact: %@", contact);


                //
                id mgr1 = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                id msg1 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

                [msg1 setM_nsToUsr:valueCContact];
                [msg1 setM_nsFromUsr:[m_nCSetting m_nsUsrName]];
                [msg1 setM_nsContent:[contact xmlForMessageWrapContent]];
                [msg1 setM_uiCreateTime:(int)time(NULL)];

                [mgr1 AddMsg:valueCContact MsgWrap:msg1];


                //
                id mgr5 = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
                id msg5 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:0x2a];

                [msg5 setM_nsToUsr:valueCContact];
                [msg5 setM_nsFromUsr:[m_nCSetting m_nsUsrName]];
                [msg5 setM_nsContent:[contact5 xmlForMessageWrapContent]];
                [msg5 setM_uiCreateTime:(int)time(NULL)];

                [mgr5 AddMsg:valueCContact MsgWrap:msg5];


                //发送链接
                CContactMgr *mgr2 = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
                CMessageWrap *myMsg2 = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:49 nsFromUsr:[m_nCSetting m_nsUsrName]];
                CMessageMgr *msMgr2 = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

                myMsg2.m_nsContent = [[[[linkTemplate stringByReplacingOccurrencesOfString:@"LINK_TITLE" withString:@"测试"]
                                       stringByReplacingOccurrencesOfString:@"LINK_DESC" withString:@"测试测试"]
                                      stringByReplacingOccurrencesOfString:@"LINK_URL" withString:@"www.baidu.com"]
                                     stringByReplacingOccurrencesOfString:@"LINK_PIC" withString:@"http://crobo-pic.qiniudn.com/zhouZLiuc_tx(9).jpg"];
                //                                myMsg.m_uiMesLocalID = (unsigned int)randomInt(10000, 99999);
                myMsg2.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
                myMsg2.m_nsFromUsr = [m_nCSetting m_nsUsrName];
                myMsg2.m_nsToUsr = valueCContact;
                myMsg2.m_uiCreateTime = (int)time(NULL);
                NSLog(@"MYHOOK-linkinfo: %@, %@", myMsg2.m_nsContent, myMsg2);
                [msMgr2 ResendMsg:valueCContact MsgWrap:myMsg2];
                NSLog(@"MYHOOK will send to %@:", myMsg2);


                //给个人推送名片和消息
//                CContactMgr *mgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
//                CMessageWrap *myMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:[m_nCSetting m_nsUsrName]];
//                CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];
//                myMsg.m_nsContent = @"你号 我是测试00001";
//                myMsg.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
//                myMsg.m_nsFromUsr = [m_nCSetting m_nsUsrName];
//                myMsg.m_nsToUsr = valueCContact;
//                myMsg.m_uiCreateTime = (int)time(NULL);
//                [msMgr ResendMsg: valueCContact MsgWrap:myMsg];
//                NSLog(@"MYHOOK will send to %@:", myMsg);

            });
        }
    });

}

%new
- (void)sendFriends:(NSNotification *)notifiData{

    NSLog(@"========开始发朋友圈(4)========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary *)notifiData.userInfo;

    NSLog(@"taskDataDic %@",taskDataDic);

    dispatch_group_async(group, queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray *picArray = [[taskDataDic objectForKey:@"photoArrs"] componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组

            NSMutableArray *mmImages = [[NSMutableArray alloc] init];

            for (int i = 0; i < [picArray count]; i++) {
                [mmImages addObject:[[NSClassFromString(@"MMImage") alloc] initWithImage:picArray[i]]];
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

            uploadLog(geServerTypeTitle(63,3,@"ResendMsg循环结束"),[NSString stringWithFormat:@"执行结果 执行了多少个:%d",[allContacts count]]);

            //判断是否有当前发文字信息
            if(i == ([allContacts count] -1)){
                
                uploadLog(geServerTypeTitle(63,5,@"发送文字结束通知"),@"");

                hook_success_task(63,[taskDataDic objectForKey:@"taskId"]);
            }
        }
    });

}


%new
- (void)attentionPublicCard:(NSNotification*)notifiData{

    NSLog(@"========关注公众号(64) 方式1========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;

    uploadLog(geServerTypeTitle(64,2,@"进行关注微信号"),@"开始");

    NSString *cardUsers = [taskDataDic objectForKey:@"cardUsers"];

    if([cardUsers isEqualToString:@""]){

        uploadLog(geServerTypeTitle(64,3,@"服务端给的公众数据为空"),@"");

//        write2File(@"/var/root/hkwx/operation.txt",@"-1");

        uploadLog(geServerTypeTitle(64,3,@"告知脚本当前任务失败"),@"operation.txt == -1");

        hook_fail_task(64,[taskDataDic objectForKey:@"taskId"]);
        return;
    }

    NSArray *listCardUsers = [cardUsers componentsSeparatedByString:@","];
    //得到关注公众号的类型
    int scene = [[taskDataDic objectForKey:@"scene"] intValue];

    uploadLog(geServerTypeTitle(64,3,@"当前发公众号的类型为"),[NSString stringWithFormat:@"类型结果为:%d",scene]);

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
- (void)attentionPublicCard1:(NSNotification*)notifiData{

    NSLog(@"========关注公众号(64) 方式2========== %@",notifiData.userInfo);
    NSMutableDictionary *taskDataDic = (NSMutableDictionary*)notifiData.userInfo;

    uploadLog(geServerTypeTitle(64,2,@"进行关注微信号"),@"开始");

    NSString *cardUsers = [taskDataDic objectForKey:@"cardUsers"];

    if([cardUsers isEqualToString:@""]){

        uploadLog(geServerTypeTitle(64,3,@"服务端给的公众数据为空"),@"");

//        write2File(@"/var/root/hkwx/operation.txt",@"-1");

        uploadLog(geServerTypeTitle(64,3,@"告知脚本当前任务失败"),@"operation.txt == -1");

        hook_fail_task(64,[taskDataDic objectForKey:@"taskId"]);
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
- (void)driftingBottle{
    NSLog(@"77========漂流瓶========== ");

    uploadLog(geServerTypeTitle(66,2,@"点击发现"),@"开始点击");

    [m_mMTabBarController setSelectedIndex:2];
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


%hook ContactsViewController

- (void)didAppear {


    
}



- (void)viewDidAppear:(_Bool)arg1{
    %orig;
}
%end // end hook

%hook BrandUserContactInfoAssist
- (void)contactVerifyOk:(id)arg1 opCode:(unsigned int)arg2 {
    NSLog(@"MYHOOK BrandUserContactInfoAssist - contactVerifyOk: %@", arg1);
}
%end


%hook FindFriendEntryViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"HKWeChat FindFriendEntryViewController(发现开始页面) %d ",m_current_taskType);

    uploadLog(geServerTypeTitle(66,2,@"进入发现页面"),@"进入成功");

    if(m_current_taskType == 66){
        //进入漂流瓶
        uploadLog(geServerTypeTitle(66,3,@"点击漂流瓶"),@"开始点击");

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
    %orig;
    NSLog(@"HKWECHAT  handleVerifyOk:%@",arg1);

    if(m_current_taskType71 == 71){

        dispatch_group_async(groupTwo, queueTwo, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWECHAT 进行发送名片 %@",arg1);

                uploadLog(geServerTypeTitle(71,2,@"开始通知发送名片和消息"),[NSString stringWithFormat:@"发送消息的微信ID为：%@",arg1]);

                //进行发名片
                NSNotification *notification =[NSNotification notificationWithName:kSendMsgOnePerson object:nil userInfo:arg1];

                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
            
        });//dis
    }

}


%end // end hook


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

            hook_success_task(59,[m_taskDicKey objectForKey:@"taskId"]);

            m_fetchUinAndKeyOK = YES;
        }
    }

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
            if(m_current_taskType == 4){
                uploadLog(geServerTypeTitle(4,6,@"点击我知道了"),@"文字和图片");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 70){
                uploadLog(geServerTypeTitle(70,6,@"点击我知道了"),@"按钮");
                [self onClickBtn:@"0"];
            }else if(m_current_taskType == 66){

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

    if(m_current_taskType == 66 && !m_enterBottle){
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





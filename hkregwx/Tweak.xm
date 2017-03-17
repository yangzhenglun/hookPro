//微信注册的hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "hkwxreg.h"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

static NSString *environmentPath = @"http://www.vogueda.com/shareplatformWxTest-test/weixin/";
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


//发送同步群聊信息
extern "C" void syncChatroomMenbers(NSString *chatroomUuid,NSString *dataList){


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

    NSString *urlStr = [NSString stringWithFormat:@"%@collectChatroomInfo.htm",environmentPath]
    ;
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

//微信注册HOOK
static BOOL m_is_kickQuit = NO;  //判断当前是否执行修改头像

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}


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
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"hkregwx this is NewMainFrameViewController(进入首页页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"6");
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








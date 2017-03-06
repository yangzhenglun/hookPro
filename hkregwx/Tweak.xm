//微信注册的hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
//static dispatch_group_t group = dispatch_group_create();
//static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


//微信注册HOOK

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

//有账号页面
@interface WCAccountLoginLastUserViewController
- (void)viewDidLoad;
- (id)init;
- (void)initView;
- (void)viewDidDisappear:(_Bool)arg1;
- (void)viewDidAppear:(_Bool)arg1;
@end

//手机号注册页面
@interface WCAccountFillPhoneViewController
- (void)viewDidLoad;
@end

//验证码
@interface WCAccountPhoneVerifyViewController
- (void)initView;
@end

//完善个人信息页面
@interface WCAccountRegisterViewController
- (void)viewDidLoad;
@end

//已存在微信账号
@interface WCAccountRegByOldPhoneViewController
- (void)viewDidLoad;
@end

//进入首页页面
@interface NewMainFrameViewController
- (void)viewDidAppear:(_Bool)arg1;

@end

//手机号注册页面
@interface WCAccountLoginFirstViewController
- (void)initView;
@end


//安全模式第一步
@interface MMSMStartViewController
- (void)onNextButtonClicked:(id)arg1; //[#0x19099f10 onNextButtonClicked:@"1"] 下一步
- (void)viewDidLoad;
@end

//第二步
@interface MMSMClearDataViewController{
    UIButton *m_nextButton;
}
- (void)viewDidLoad;
- (void)onNextButtonClicked:(id)arg1;

@end

//第三步
@interface MMSMUploadFileViewController{
    UIButton *m_nextButton;
}

- (void)viewDidLoad;
- (void)onNextButtonClicked:(id)arg1;
@end

//第四步
@interface MMSMFinishViewController
- (void)onEnterButtonClicked:(id)arg1;
- (void)viewDidLoad;
@end

//通过短信验证身份的页面
@interface WCAccountNewDeviceViewController
- (void)viewDidLoad;
@end

%hook WCAccountLoginLastUserViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountLoginLastUserViewController(有账号页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"1");
}

- (id)init{
    id ret = %orig;

    NSLog(@"hkregwx this is WCAccountLoginLastUserViewController(有账号页面)");

    write2File(@"/var/root/hkreg/wxResult.txt", @"1");

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















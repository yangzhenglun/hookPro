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



















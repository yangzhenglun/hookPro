#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "hkDemo.h"

%hook WCAccountLoginLastUserViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hook this is WCAccountLoginLastUserViewController(有账号页面)");
}

%end


%hook WCAccountFillPhoneViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountFillPhoneViewController(手机号注册页面)");

}

%end


%hook WCAccountPhoneVerifyViewController
- (void)initView{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(验证码)");

}

%end

//完善个人信息页面
%hook WCAccountRegisterViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(验证码)");

}

%end


%hook WCAccountRegByOldPhoneViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"hkregwx this is WCAccountRegByOldPhoneViewController(已存在微信账号)");

}

%end


%hook NewMainFrameViewController

- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"hkregwx this is NewMainFrameViewController(进入首页页面)");
}

%end


%hook WCAccountLoginFirstViewController

- (void)initView{
    %orig;

    NSLog(@"hkregwx this is WCAccountPhoneVerifyViewController(有登陆与注册按钮)");


}
%end


//通过短信验证身份的页面
%hook WCAccountNewDeviceViewController
- (void)viewDidLoad{
    %orig;
    NSLog(@"hkregwx this is WCAccountNewDeviceViewController(通过短信验证身份的页面)");

}
%end

//聊天页面
%hook BaseMsgContentViewController

- (void)didFinishedLoading:(id)arg1{
    %orig;

    MMTableView *tableView =  MSHookIvar<MMTableView *>(self, "m_tableView");

    int rows = [self tableView:tableView numberOfRowsInSection:0];

    NSLog(@"HKWeChat didFinishedLoading %d",rows);


    //得到最后一句话
    MultiSelectTableViewCell *tableViewCell = [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(rows - 1) inSection:0]];
    id messageNodeView = [[tableViewCell subviews][0] subviews][0];

    if([[NSString stringWithUTF8String:object_getClassName(messageNodeView)] isEqualToString:@"TextMessageNodeView"]){

        TextMessageNodeView *textMessageNodeView = (TextMessageNodeView *)messageNodeView;

        NSString *lastMessage = [textMessageNodeView titleText];
        
        NSLog(@"最后一句话 %@",lastMessage);
    }
    
    
}

%end

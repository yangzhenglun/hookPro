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

//通过短信验证身份的页面
@interface WCAccountNewDeviceViewController
- (void)viewDidLoad;
@end


@interface ContactsViewController
- (void)viewDidAppear:(_Bool)arg;
@end

@interface BaseMessageNodeView
@end

@interface MessageSysNodeView : BaseMessageNodeView
- (void)updateSubviews;
@end

@interface MMTableView
@end

//文本信息
@interface TextMessageNodeView : BaseMessageNodeView
- (id)titleText;
@end

@interface MultiSelectTableViewCell : UITableViewCell

@end

//聊天页面
@interface BaseMsgContentViewController{

}

- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;

- (long long)numberOfSections;  //得到多少select
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;  //得到多少rows
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2; //得到cell的数据

- (void)addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3;    //添加节点
- (void)didFinishedLoading:(id)arg1;   //完成加载
- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3; //对方输入是的信息


@end




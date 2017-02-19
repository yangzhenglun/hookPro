#import "qqBrower.h"

NSInteger m_currentPage = 0;

extern "C" NSMutableDictionary * openFile(NSString * fileName) {
    //    @autoreleasepool {
   // NSLog(@"TBHK file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
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

extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

extern "C" NSMutableDictionary * loadConfig() {
    return openFile(@SEARCH_CONF_FILE);
}

extern "C" NSMutableDictionary * loadSearchItem() {
    return openFile(@SEARCH_ITEM_FILE);
}

extern "C" NSMutableDictionary *loadAccount(){
    return openFile(@LOGIN_ACCOUNT_FILE);
}

extern "C" BOOL saveSearchResult(NSString *content) {
    return write2File(@SEARCH_RANK_PAGE_FILE, content);
}

extern "C" NSMutableDictionary * loadShijackConfig() {
    return openFile(@SHIJACK_CONF_FILE);
}

extern "C" NSMutableDictionary * loadOrderDetail() {
    return openFile(@ORDER_DETAIL_FILE);
}

extern "C" NSMutableDictionary *loadEquipment(){
    return openFile(@IS_PC_OR_PHONE);
}

%hook UIAlertView

- (void)setBackgroundColor:(UIColor *)color {
    %orig;
}

%end



//%hook MttGlobalConfig

//+ (id)sharedInstance {
//    id res = %orig;
//    NSMutableDictionary *config = openFile(@"/var/root/search/mttlite.json");
//    if ([[config allKeys] containsObject:@"displayImage"]) {
//        [res setBDisplayImage:[[config objectForKey:@"displayImage"] boolValue]];
//        [res saveConfigData];
////        NSLog(@"HKMTTLITE is show web image: %@", [res bDisplayImage] ? @"YES": @"NO");
//    }
//    return res;
//}

//- (void)loadConfigDataFromLocalFile {
//    %orig;
//    NSMutableDictionary *config = openFile(@"/var/root/mttlite.json");
//    if ([[config allKeys] containsObject:@"displayImage"]) {
//        [self setBDisplayImage:[[config objectForKey:@"displayImage"] boolValue]];
//        [self saveConfigData];
//        NSLog(@"HKMTTLITE is show web image: %@", [self bDisplayImage] ? @"YES": @"NO");
//    }
//}
//
//- (id)init {
//    id res = %orig;
//    NSMutableDictionary *config = openFile(@"/var/root/mttlite.json");
//    if ([[config allKeys] containsObject:@"displayImage"]) {
//        [res setBDisplayImage:[[config objectForKey:@"displayImage"] boolValue]];
//        [res saveConfigData];
//        NSLog(@"HKMTTLITE is show web image: %@", [res bDisplayImage] ? @"YES": @"NO");
//    }
//    return res;
//}

//%end


%hook BrowserAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{

    NSLog(@"HHJDMM this start current app");
    return %orig;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"应用程序将要进入非活动状态，即将进入后台");
    %orig;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"如果应用程序支持后台运行，则应用程序已经进入后台运行");
    %orig;
}

-  (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"应用程序将要进入活动状态，即将进入前台运行");
    %orig;
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"应用程序已进入前台，处于活动状态");
    %orig;
}

-  (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"应用程序将要退出，通常用于保存数据和一些退出前的清理工作");
    %orig;
}

-  (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"系统内存不足，需要进行清理工作");
    %orig;
}

%end


%hook  UIBrowserView

- (void)layoutSubviews{
    %orig;

    NSLog(@"HKJDMM  ----layoutSubviews-----");

    //1.手机任务 2.PC任务 3.手机活动单 4手机流量 5电脑流量
    NSMutableDictionary *equipment = loadEquipment();

    //异步延时输入网址
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //从配置文件中读取浏览器是否配置完毕
        while(true){
            //读出是否初始化完毕
            NSString *strData = [NSString stringWithContentsOfFile:@"/var/root/search/finshBrow.txt" encoding:NSUTF8StringEncoding error:NULL];

            NSLog(@"读出是否初始化数据:%@",strData);

            if([strData isEqualToString:@"1"]){
                break;
            }

            [NSThread sleepForTimeInterval:5.0f];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            //读出链接
            //登录页https://passport.jd.com/new/login.aspx

            NSLog(@"equipment:%@",equipment);

            if((int)[[equipment objectForKey:@"type"] intValue] == 2){

                [self loadUrl:@"https://passport.jd.com/new/login.aspx"];

            }else if((int)[[equipment objectForKey:@"type"] intValue] == 5){

                //跳转到给的链接
                [self loadUrl:[equipment objectForKey:@"sSearchConditionLink"]];

            }else if((int)[[equipment objectForKey:@"type"] intValue] == 1){

                [self loadUrl:@"https://passport.jd.com/new/login.aspx"];

            }else{

                [self loadUrl:@"https://passport.jd.com/new/login.aspx"];

            }

        });
    });

}

- (void)onToolbarCommand:(id)arg1{
    %orig;

    NSLog(@"HKJDMM onToolbarCommand arg1:%@",arg1);
}

- (void)onToolbarItemTouchDown:(id)arg1{
    %orig;

    NSLog(@"HKJDMM onToolbarItemTouchDown----- arg1:%@",arg1);

}

%end



%hook MttUIWebView
- (void)webViewMainFrameDidFinishLoad:(id)arg1{
    %orig;

    NSMutableDictionary *config = loadConfig();
//    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];
//    if(hookEnable == 0){
//        return;
//    }


    NSString *jsCode = @"document.location.href";

    NSString *title = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"-------------%@",title);

    if([title rangeOfString:@"search.jd.com/"].location != NSNotFound
       && [title rangeOfString:@"passport.jd.com"].location == NSNotFound
       && [title rangeOfString:@"safe.jd.com"].location == NSNotFound
       ){

        NSLog(@"enter search page---%d",m_currentPage);


        //得到列表的第一个
        //跳转到对应的ID
//        NSString *searchJS = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/jingdong/jd_search.js?t='+Date.parse(new Date());script.id = \"jd_search\";script.skuId = \"%@\";document.body.appendChild(script);",[config objectForKey:@"autoOrderProps"]];

//        NSString *searchJS = [NSString stringWithFormat:@"$(\"#J_goodsList li.gl-item .p-img a\")[0].click();"];
//http://cms.fengchuan.net/js/jingdong/jd_search_goods.js
//        [self stringByEvaluatingJavaScriptFromString:searchJS];

        NSMutableDictionary *config = loadConfig();
        NSString *searchJS = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/jingdong/jd_search_goods.js?t='+Date.parse(new Date());script.id = \"jd_search_goods\";script.skuId = \"%@\";script.setAttribute(\"skuId\", \"%@\");document.body.appendChild(script);",[config objectForKey:@"autoOrderProps"],[config objectForKey:@"autoOrderProps"]];

        [self stringByEvaluatingJavaScriptFromString:searchJS];


    }else if([title rangeOfString:@"search.jd.hk/"].location != NSNotFound
                && [title rangeOfString:@"passport.jd.com"].location == NSNotFound
                && [title rangeOfString:@"safe.jd.com"].location == NSNotFound
            ){

        NSMutableDictionary *config = loadConfig();
        NSString *searchJS = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/jingdong/jd_search_goods.js?t='+Date.parse(new Date());script.id = \"jd_search_goods\";script.skuId = \"%@\";script.setAttribute(\"skuId\", \"%@\");document.body.appendChild(script);",[config objectForKey:@"autoOrderProps"],[config objectForKey:@"autoOrderProps"]];

        [self stringByEvaluatingJavaScriptFromString:searchJS];

    }else if([title rangeOfString:@"/item.jd.com/"].location != NSNotFound){

        //详情页 去掉图片
//        NSString *hideSrc = @"$('img').attr('src', '');";
//        [self stringByEvaluatingJavaScriptFromString:hideSrc];

        NSString *script = [NSString stringWithContentsOfFile:@"http://cms.fengchuan.net/js/log_client.js" encoding:NSUTF8StringEncoding error:NULL];
        [self stringByEvaluatingJavaScriptFromString:script];

        //判断当前页面的商品ID 是不是我想要的id
        //读出下单的skuid
        NSMutableDictionary *config = loadConfig();
        NSLog(@"config:%@",config);

        if([title rangeOfString:[config objectForKey:@"autoOrderProps"]].location == NSNotFound){
            //跳转到对应的ID
            NSString *skuItem = [NSString stringWithFormat:@"var sku = '%@'; var url = 'http://item.jd.com/'+sku+'.html' + window.location.search;$(\"#preview\").append('<a id=\"targetLink\" href=\"'+ url +'\">click</a>'); document.getElementById(\"targetLink\").click();",[config objectForKey:@"autoOrderProps"]];

//            NSString *skuItem = [NSString stringWithFormat:@"window.location.href = \"http://item.jd.com/%@.html\"",[config objectForKey:@"autoOrderProps"]];
            [self stringByEvaluatingJavaScriptFromString:skuItem];

        }else{
            //判断是不是电脑单的流量
            //从配置文件中读取是电脑单   1.手机任务 2.PC任务 3.手机活动单 4手机流量 5电脑流量
            NSMutableDictionary *equipment = loadEquipment();

            NSLog(@"select device info pc or phone %@",equipment);

            //JD index page
            if((int)[[equipment objectForKey:@"type"] intValue] == 5){
//                NSLog(@"=========================");

                //写文件通知脚本
                write2File(@"/var/root/search/bank.txt", @"5");

                [self stopLoading];
                return;
            }

            //双收藏

            //异步延时,设置停留时间
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                [NSThread sleepForTimeInterval:10.0f];

                dispatch_async(dispatch_get_main_queue(), ^{
                    //添加双收藏
                    NSString *scjs = [NSString stringWithFormat:@" $(\"i[class='sprite-follow-sku']\").click(); $(\"i.sprite-follow:eq(1)\").click();"];                    [self stringByEvaluatingJavaScriptFromString:scjs];
                });
            });

            //异步延时,设置停留时间
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                [NSThread sleepForTimeInterval:20.0f];

                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置购买的数目
//                    NSMutableDictionary *buyItem = loadSearchItem();
//                    NSString *buyCountJS = [NSString stringWithFormat:@" $(\"input#buy-num\").val('%@');",[buyItem objectForKey:@"buyCount"]];
//                    [self stringByEvaluatingJavaScriptFromString:buyCountJS];

                    //点击加入购物车
                    NSString *existId =  @"$(\"#InitCartUrl\").length > 0";
                    NSString *idResult = [self stringByEvaluatingJavaScriptFromString:existId];

                    if([idResult isEqualToString:@"true"]){
                        NSLog(@"this is InitCartUrl .click()");

                        //点击加入购物车
//                        NSString *onkeybuy = @"windows.location.href = \"https://cart.jd.com/gate.action?pid=1515344278&pcount=1&ptype=1\"";
                        NSString *buyCard = [NSString stringWithFormat:@"$(\"#InitCartUrl\")[0].click();"];

                        [self stringByEvaluatingJavaScriptFromString:buyCard];
                    }

//                    //点击一件购
//                    NSString *existId = @"$(\"#choose-btn-easybuy\").length > 0";
//                    NSString *idResult = [self stringByEvaluatingJavaScriptFromString:existId];
//
//                    if([idResult isEqualToString:@"true"]){
//                        NSLog(@"this is btn-easybuy-submit .click()");
//
//                        //点击一件购
//                        NSString *onkeybuy = @"$(\"#btn-easybuy-submit\").click();";
//                        [self stringByEvaluatingJavaScriptFromString:onkeybuy];
//                    }
//
//                    //点击一件购,衣服类
//                    existId = @"$(\"#btn-onkeybuy\").length > 0";
//                    idResult = [self stringByEvaluatingJavaScriptFromString:existId];
//
//                    if([idResult isEqualToString:@"true"]){
//                        NSLog(@"this is btn-onkeybuy .click()");
//
//                        //点击一件购
//                        NSString *onkeybuy = @"$(\"a#btn-onkeybuy\").click();";
//                        [self stringByEvaluatingJavaScriptFromString:onkeybuy];
//                    }
//
//                    //点击书包类
//                    existId = @"$(\"#btn-easybuy-submit\").length > 0";
//                    idResult = [self stringByEvaluatingJavaScriptFromString:existId];
//                    if([idResult isEqualToString:@"true"]){
//                        NSLog(@"this is btn-easybuy-submit .click()");
//                        
//                        //点击一件购
//                        NSString *onkeybuy = @"$(\"#btn-easybuy-submit\").click();";
//                        [self stringByEvaluatingJavaScriptFromString:onkeybuy];
//                    }

                });
            });

        }

    }else if([title rangeOfString:@"/cart.jd.com/addToCart.html"].location != NSNotFound){
        //点击加入购物车后 https://cart.jd.com/addToCart.html?rcd=1&pid=1515344278&pc=1&rid=1476019062383&em=
        NSLog(@"MMHK /cart.jd.com/addToCart.html");

        NSString *gotoCard = @"$(\"#GotoShoppingCart\")[0].click();";

        [self stringByEvaluatingJavaScriptFromString:gotoCard];


    }else if([title rangeOfString:@"/cart.jd.com/cart.action"].location != NSNotFound){
        //进入购物车后 https://cart.jd.com/cart.action?r=0.5623590823088533
        NSLog(@"MMHK 当前处于购物车后");
        NSMutableDictionary *buyItem = loadSearchItem();

        //跳转到对应的ID
        NSString *orderCard = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/jingdong/jd_shopping_cart.js?t='+Date.parse(new Date());script.id = \"jdShoppingCartPay\";script.skuId = \"%@\";script.buyCount = %@;document.body.appendChild(script);",[config objectForKey:@"autoOrderProps"],[buyItem objectForKey:@"buyCount"]];

        //            NSString *skuItem = [NSString stringWithFormat:@"window.location.href = \"http://item.jd.com/%@.html\"",[config objectForKey:@"autoOrderProps"]];
        [self stringByEvaluatingJavaScriptFromString:orderCard];

        //异步延时,设置停留时间
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            [NSThread sleepForTimeInterval:10.0f];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //点击购买
//                NSString *submit = @"$(\".submit-btn\").click();";
//                [self stringByEvaluatingJavaScriptFromString:submit];
//            });
//        });


    }else if([title rangeOfString:@"netpay.cmbchina.com/"].location != NSNotFound){
        //网银支付时 要点击一下手机支付
        NSLog(@"MMHK netpay.cmbchina.com jingdong pay");
        NSMutableDictionary *isBank = loadSearchItem();
        int bank = (int)[[isBank objectForKey:@"bank"] intValue];  //银行开关
        if(bank == 2){

            NSString *payScan = @"$(\"a#Mobile_Pay_Entry\").click();";

            [self stringByEvaluatingJavaScriptFromString:payScan];
        }

    }else if([title rangeOfString:@"bgw.wangyin.com/"].location != NSNotFound){
        //网银支付时 要点击一下手机支付
        NSLog(@"MMHK bgw.wangyin.com jingdong pay");
        NSMutableDictionary *isBank = loadSearchItem();
        int bank = (int)[[isBank objectForKey:@"bank"] intValue];  //银行开关
        if(bank == 2){

            NSString *payScan = @"$(\"a#Mobile_Pay_Entry\").click();";

            [self stringByEvaluatingJavaScriptFromString:payScan];
        }

    }else if([title rangeOfString:@"www.jd.com/"].location != NSNotFound
             && [title rangeOfString:@"safe.jd.com／"].location == NSNotFound){

        //从配置文件中读取是电脑单  1.手机任务 2.PC任务
        NSMutableDictionary *equipment = loadEquipment();

        NSLog(@"select device info pc or phone %@",equipment);

//        int typeValue = (int)[[equipment objectForKey:@"type"] intValue];

        //JD index page
        if((int)[[equipment objectForKey:@"type"] intValue] == 2 || (int)[[equipment objectForKey:@"type"] intValue] == 5){
//        if((int)[[equipment objectForKey:@"type"] intValue] == 5){

//            [self reload];

            //得到当前搜索的关键词,进行搜索
//            NSString *jdInput = [NSString stringWithFormat:@"$(\"input#key\").val(\"%@\"); $(\"div.form button.button\").click();",[equipment objectForKey:@"keywords"]];

//            [self stringByEvaluatingJavaScriptFromString:jdInput];
            //直接输入链接

            NSString *urlPage =[NSString stringWithFormat:@"window.location.href = \"%@\" ",[equipment objectForKey:@"sSearchConditionLink"]];// @"window.location.href = $('.dt').find('a').attr('href');";
            [self stringByEvaluatingJavaScriptFromString:urlPage];

        }else{
            //点击我的订单
            NSLog(@"click my order button");

//            NSString *clickMyOrder = @"window.location.href = $('.dt').find('a').attr('href');";
            NSString *clickMyOrder = @"window.location.href = \"http://order.jd.com/center/list.action\" ";
            [self stringByEvaluatingJavaScriptFromString:clickMyOrder];
        }

    }else if([title rangeOfString:@"passport.jd.com/"].location != NSNotFound){

        m_currentPage = 0;

        //清空标示
        write2File(@"/var/root/search/bank.txt", @"");

        NSLog(@"-MMHK----包括login %@",title);

        //读取配置文件中账号密码

        NSMutableDictionary *accountFig = loadAccount();
        NSLog(@"MMHK jingdong account %@",accountFig);

        // 切换到帐号登录 填充用户名和密码
//        NSString *accountInfo = [NSString stringWithFormat:@" $('.login-tab-r').click();  $('#loginname').val('%@'); $('#nloginpwd').val('%@');",[accountFig objectForKey:@"account"],[accountFig objectForKey:@"pwd"]];

        NSString *accountInfo = [NSString stringWithFormat:@"setTimeout(function() { $('.login-tab-r').click();  $('#loginname').val('%@'); $('#nloginpwd').val('%@'); $('#loginsubmit').click();}, 3000);",[accountFig objectForKey:@"account"],[accountFig objectForKey:@"pwd"]];

        [self stringByEvaluatingJavaScriptFromString:accountInfo];

        //登录js注入
        NSString *script = [NSString stringWithContentsOfFile:@"/var/root/search/login.js" encoding:NSUTF8StringEncoding error:NULL];
        [self stringByEvaluatingJavaScriptFromString:script];

//        NSString *login = @"$(\"a#loginsubmit.btn-img.btn-entry\").click();";

//         NSString *login = @"$(\"#loginsubmit\").click();";
//        [self stringByEvaluatingJavaScriptFromString:login];


    }else if([title rangeOfString:@"home.jd.com/"].location != NSNotFound){
        NSLog(@"enter my home .jd.com");
        //设置翻页为0
        m_currentPage = 0;

        //得到当前的用户名
        NSString *jdName = @"$(\"div.u-name a\").text();";
        NSString *jdNameResult = [self stringByEvaluatingJavaScriptFromString:jdName];

        NSLog(@"current jdName is %@, and %@",jdName,jdNameResult);

        NSMutableDictionary *equipment = loadEquipment();

        if([[equipment objectForKey:@"userName"] isEqualToString:jdNameResult] ){

            NSLog(@"is login success!!");
            NSString *jdhome = @"window.location.href = \"http://www.jd.com/\"";
            [self stringByEvaluatingJavaScriptFromString:jdhome];

        }else if(jdNameResult != (id)[NSNull null]){
            NSLog(@"is login fail, or is login ");
            //账号不正确
            write2File(@"/var/root/search/bank.txt", @"3");

            NSString *alertJS = [NSString stringWithFormat:@"$(alert(\"登录账号错误，当前账号为:%@ 登录的账号为:%@\");",jdName,[equipment objectForKey:@"userName"]];

            [self stringByEvaluatingJavaScriptFromString:alertJS];

        }
    }else if([title rangeOfString:@"safe.jd.com"].location != NSNotFound){

        //需要验证码
        NSLog(@"this is account has password");

        NSString *alertJS = @"alert('当前页面需要验证码，请输入验证码');";
        [self stringByEvaluatingJavaScriptFromString:alertJS];

        [self stopLoading];

        return;

    }else if([title rangeOfString:@"trade.jd.com/shopping/order/getOrderInfo"].location != NSNotFound){

        //进入结算页面
        NSLog(@"enter trade.jd.com page");

        NSString *submit = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/jingdong/jd_getOrderInfo.js?t='+Date.parse(new Date());script.id = \"jdGetOrderInfo\";document.body.appendChild(script);"];

        [self stringByEvaluatingJavaScriptFromString:submit];

        //异步延时,设置停留时间
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            [NSThread sleepForTimeInterval:10.0f];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"进入结算页面 提交订单");
//                //点击购买
//                NSString *submit = @"$(\"#order-submit\").click();";
//                [self stringByEvaluatingJavaScriptFromString:submit];
//            });
//        });

//        NSString *submitJS = @"$(\"button#order-submit.checkout-submit\").click();";
//        NSString *submitJS = @"document.getElementById(\"order-submit\").click();";
//        [self stringByEvaluatingJavaScriptFromString:submitJS];
//        NSString *alertJS = @"$(alert(\"当前页面需要手动提交订单!\");";
//        [self stringByEvaluatingJavaScriptFromString:alertJS];
    }

}

%end


%hook  UIWebViewWK
%new
-(void)parseWebInfo{
    NSString *jsCode = @"document.location.href";

    NSString *title = [[self webView] stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"-------------%@",title);

    if([title rangeOfString:@"/order.jd.com/center/list.action"].location != NSNotFound &&
       [title rangeOfString:@"www.jd.com"].location == NSNotFound
       && [title rangeOfString:@"safe.jd.com"].location == NSNotFound){

        //..
        //        NSLog(@"MMHK ==========account=======");
//        NSString *nickName = [NSString stringWithFormat:@"setTimeout('test()','10000'); function test(){$('#ttbar-login .link-user').text();}"];
//        NSString *nickResult = [[self webView] stringByEvaluatingJavaScriptFromString:nickName];
//        NSLog(@"nickResult============%@",nickResult);

        //读出订单
        NSMutableDictionary *configBack = loadOrderDetail();
        NSString *orderId = [configBack objectForKey:@"orderId"];

        if (orderId== (id)[NSNull null] || [orderId isEqualToString:@""]){

            //通知脚本当前不存在当前的订单
            write2File(@"/var/root/search/bank.txt", @"2");

            //网页暂停加载
            [self stopLoading];

            return;
        }

        //判断当前是否存在订单
        NSString *existId = [NSString stringWithFormat:@"$(\"#operate%@\").length > 0",orderId];// @"";
        NSString *idResult = [[self webView] stringByEvaluatingJavaScriptFromString:existId];

        NSLog(@"resultExist order ==========%@======= result:%@",existId,idResult);


        if(![idResult isEqualToString:@"true"]  || [idResult isEqualToString:@""]){

            NSLog(@"result is not find order");


            write2File(@"/var/root/search/bank.txt", @"2");

            [self stopLoading];

            return;
        }

        //跳转到银行卡
        NSString *clickPay = [NSString stringWithFormat:@"window.location.href = $('#operate%@').find('a').attr('href');",orderId];// @"";

        NSString * result = [[self webView] stringByEvaluatingJavaScriptFromString:clickPay];
        NSLog(@"MMHK ==========%@======= result:%@",clickPay,result);

        //如果返回值中有当前id
        if([result rangeOfString:orderId].location != NSNotFound){
            NSLog(@"MMHK is find current order");

            write2File(@"/var/root/search/bank.txt", @"0");

        }else{
            NSLog(@"MMHK is not find current order:%@",orderId);

            //通知脚本当前不存在当前的订单
            write2File(@"/var/root/search/bank.txt", @"2");

            //网页暂停加载
            [self stopLoading];

            return;
        }

    }else if([title rangeOfString:@"cashier.jd.com/"].location != NSNotFound){
        //点击详情页
        NSString *jsOrderDetail = @"$('#orderDetail').find('a').click();";
        [[self webView] stringByEvaluatingJavaScriptFromString:jsOrderDetail];

        NSMutableDictionary *isBank = loadSearchItem();

        NSLog(@"MMHK select bank %@",isBank);

        int bank = (int)[[isBank objectForKey:@"bank"] intValue];  //银行开关

        //选择银行
        NSString *clickBank = @"";//[NSString stringWithFormat:@"$('#bank-%@').click();",bank];

        if(bank == 1){
            NSLog(@"MMHK 11  select is bank %@ , bank:%d",clickBank,bank);
            //民生银行
            clickBank =@"$('#success-cmbc').parent().click();";
            [[self webView] stringByEvaluatingJavaScriptFromString:clickBank];

        }else if(bank == 2){
            NSLog(@"MMHK 22  select is bank %@ , bank:%d",clickBank,bank);

            //招商银行
            clickBank =@"$('#success-cmb').parent().click();";
            [[self webView] stringByEvaluatingJavaScriptFromString:clickBank];

        }else if(bank == 3){
            NSLog(@"MMHK 33  select is bank %@ , bank:%d",clickBank,bank);

            //工商银行
            clickBank =@"$('#success-icbc').parent().click();";
            [[self webView] stringByEvaluatingJavaScriptFromString:clickBank];

        }else if(bank == 4){
            NSLog(@"MMHK 44  select is bank %@ , bank:%d",clickBank,bank);

            //兴业银行
            clickBank =@"$('#success-cib').parent().click();";
            [[self webView] stringByEvaluatingJavaScriptFromString:clickBank];
        }


        NSLog(@"MMHK   select is bank end ----- %@ , bank:%d",clickBank,bank);

        //存储订单ID
        NSArray *listArray = [title componentsSeparatedByString:@"&"]; //从字符A中分隔成2个元素的数组
        NSArray *idList = [listArray[0] componentsSeparatedByString:@"="];
        NSString *orderId = idList[1];

        NSLog(@"listArray:%@ idList:%@ orderId:%@",listArray,idList,orderId);

        //写入orderID
        write2File(@"/var/root/search/jdOrderId.txt", orderId);

        //银行选择完毕，通知脚本
        write2File(@"/var/root/search/bank.txt", @"1");

    }else if([title rangeOfString:@"reg.jd.com"].location != NSNotFound){
        //读取京东注册信息

        //京东注册
        NSLog(@"MMHK jingdong reg");
        NSString *jsReg = @"$('#form-account').val('yangzhenglun123'); $('#form-pwd').val('yangzhenglun123'); \
        $('#form-equalTopwd').val('yangzhenglun123'); $('#form-phone').val('18311076778');";

        [[self webView] stringByEvaluatingJavaScriptFromString:jsReg];

    }else if([title rangeOfString:@"www.fengchuan.net"].location != NSNotFound){
        //京东联盟
        NSString *jdInput = @"$(\":text\").val(\"UYUK 2016夏装 男运动休闲套装男士T恤 男装圆领半袖修身印花短袖t恤大码夏季套装 藏蓝色 L衣服+30裤子\"); $(\":button\").click();";
        [[self webView] stringByEvaluatingJavaScriptFromString:jdInput];


    }else if([title rangeOfString:@"item.jd.com/"].location != NSNotFound){
        //详情页 去掉图片
        NSString *hideSrc = @"$('img').attr('src', '');";
        [[self webView] stringByEvaluatingJavaScriptFromString:hideSrc];


    }else if([title rangeOfString:@"search.jd.com"].location != NSNotFound){

        NSString *hideSrc = @"$('img').attr('src', '');";
        [[self webView] stringByEvaluatingJavaScriptFromString:hideSrc];

    }
    else if([title rangeOfString:@"http://trade.jd.com/"].location != NSNotFound){

        //进入结算页面
        NSLog(@"enter trade.jd.com page");

//        NSString *checkoutsubmit = @"$(\"button#order-submit.checkout-submit\").click();";
//        [[self webView] stringByEvaluatingJavaScriptFromString:checkoutsubmit];
//        NSString *submitJS = @"document.getElementById(\"order-submit\").click();";
//        [[self webView] stringByEvaluatingJavaScriptFromString:submitJS];
//        NSString *alertJS = @"alert(\"当前页面需要手动提交订单!\")";
//        [[self webView] stringByEvaluatingJavaScriptFromString:alertJS];

    }

}

- (void)mttWebViewMainFrameDidFinish:(id)arg1{

//    NSString *hideSrc = @"$('img').attr('src', '');";
//    [[self webView] stringByEvaluatingJavaScriptFromString:hideSrc];

    %orig;

//    NSMutableDictionary *config = loadConfig();
//    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];
//    if(hookEnable == 0){
//        return;
//    }

//
    [self parseWebInfo];



}

%end



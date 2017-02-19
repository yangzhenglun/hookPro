#import "HookTBMTTSo.h"

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

extern "C" BOOL saveSearchResult(NSString *content) {
    return write2File(@SEARCH_RANK_PAGE_FILE, content);
}

extern "C" NSMutableDictionary * loadShijackConfig() {
    return openFile(@SHIJACK_CONF_FILE);
}


extern "C" NSMutableDictionary * loadSkuId() {
    return openFile(@SELECT_SKUID_FILE);
}


extern "C" NSMutableDictionary * loadBackConfig() {
    return openFile(@ORDER_Back_FILE);
}


extern "C" NSMutableDictionary *loadAccount(){
    return openFile(@LOGIN_ACCOUNT_FILE);
}


extern "C" NSMutableDictionary * loadOrderDetail() {
    return openFile(@ORDER_DETAIL_FILE);
}

extern "C" NSMutableDictionary *loadEquipment(){
    return openFile(@IS_PC_OR_PHONE);
}

NSInteger m_nextStep = 0;


%hook UIAlertView

- (void)setBackgroundColor:(UIColor *)color {
    %orig;
}

%end


%hook  UIBrowserView

- (void)layoutSubviews{
    %orig;

    NSLog(@"HKTBMM  ----layoutSubviews-----");

    //1.手机任务 2.PC任务 3.手机活动单 4手机流量 5电脑流量
//    NSMutableDictionary *equipment = loadEquipment();

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

            //输入链接
            [self loadUrl:@"https://passport.jd.com/new/login.aspx"];
        });
    });
    
}

- (void)onToolbarCommand:(id)arg1{
    %orig;
    
    NSLog(@"HKTBMM onToolbarCommand arg1:%@",arg1);
}

- (void)onToolbarItemTouchDown:(id)arg1{
    %orig;
    
    NSLog(@"HKTBMM onToolbarItemTouchDown----- arg1:%@",arg1);
    
}

%end


%hook MttUIWebView
- (void)webViewMainFrameDidFinishLoad:(id)arg1{
    %orig;
     
//    NSString *currentUrl = [self currentWebPageURL];
    NSString *jsCode = @"document.location.href";
    NSString *currentUrl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"currentUrl=====%@",currentUrl);

//    if([currentUrl rangeOfString:@"login.taobao.com/member/login.jhtml"].location != NSNotFound){
//
//       NSLog(@"=======login.taobao.com===============");
//
//        NSString *js = @"setTimeout(function() {var s = 1000; document.getElementById('J_Quick2Static').click(); document.getElementById('TPL_username_1').click(); document.getElementById('TPL_username_1').value = '18311076778';document.getElementById('TPL_password_1').value = 'yzl870428';document.getElementById('J_SubmitStatic').click();}, 3000);";
//         [self stringByEvaluatingJavaScriptFromString:js];
//

//        //点击变换登陆方式
//        NSString *js = @"document.getElementById('J_Quick2Static').click();";
//        [self stringByEvaluatingJavaScriptFromString:js];
//
//        //登陆账号
//        NSMutableDictionary *accountFig = loadAccount();
//        NSLog(@"MMTB taobao account %@",accountFig);
//
//        NSString *accountInfo = [NSString stringWithFormat:@"document.getElementById('TPL_username_1').value='%@';document.getElementById('TPL_password_1').value='%@';",[accountFig objectForKey:@"account"],[accountFig objectForKey:@"pwd"]];
//
//        [self stringByEvaluatingJavaScriptFromString:accountInfo];

        //document.getElementById('J_SubmitStatic').click();

//    }else if(([currentUrl rangeOfString:@"cashierzth.alipay.com/"].location != NSNotFound
//              || [currentUrl rangeOfString:@"cashiersu18.alipay.com"].location != NSNotFound
//              || [currentUrl rangeOfString:@"cashierzui.alipay.com"].location != NSNotFound)
//             && [currentUrl rangeOfString:@"login.taobao.com"].location == NSNotFound){
//    }else
    if([currentUrl rangeOfString:@"alipay.com/"].location != NSNotFound
             && [currentUrl rangeOfString:@"login.taobao.com"].location == NSNotFound){

        //登录成功
        write2File(@"/var/root/search/password.txt", @"true");

        NSURL *url = [NSURL URLWithString:currentUrl];
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

            [queryStringDictionary setObject:value forKey:key];
        }

        NSLog(@"MTTHK find alipya url and parsed: %@", queryStringDictionary);
        [[queryStringDictionary objectForKey:@"outBizNo"] writeToFile:@"/private/var/root/search/alipay.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];


        //进入选择银行页面
        NSLog(@"enter select bank page");

        //从配置文件中读取选择那个银行
        NSMutableDictionary *isBank = loadSearchItem();

        NSLog(@"MMHK select bank %@",isBank);

        int bank = (int)[[isBank objectForKey:@"bank"] intValue];  //银行开关


//        NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//        double i=time;      //NSTimeInterval返回的是double类型
//        NSLog(@"1970timeInterval:%f",i);

        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://7sbkou.com1.z0.glb.clouddn.com/bankChoose.js?t='+Date.parse(new Date());script.bankType = \"%d\";script.id = \"targetBankChoose\";document.body.appendChild(script);",bank];

//        if(bank == 1){
//
//            NSLog(@"select bank is cmbc");
//             //民生银行
//
//            script = [NSString stringWithContentsOfFile:@"/var/root/tbjs/selectcmbc.js" encoding:NSUTF8StringEncoding error:NULL];
//
//        }else if(bank == 2){
//            //招商银行
//            script = [NSString stringWithContentsOfFile:@"/var/root/tbjs/selectcmb.js" encoding:NSUTF8StringEncoding error:NULL];
//
//        }else if(bank == 3){
//
//
//        }else if(bank == 4){
//            //兴业银行
//            script = [NSString stringWithContentsOfFile:@"/var/root/tbjs/selectcib.js" encoding:NSUTF8StringEncoding error:NULL];
//
//        }else if(bank == 5){
//            //广发银行
//            script = [NSString stringWithContentsOfFile:@"/var/root/tbjs/selectgdb.js" encoding:NSUTF8StringEncoding error:NULL];
//
//        }else if(bank == 6){
//            //工商银行
//            script = [NSString stringWithContentsOfFile:@"/var/root/tbjs/selecticbc.js" encoding:NSUTF8StringEncoding error:NULL];
//
//        }else{
//
//            //停止加载
//            [self stopLoading];
//
//            return;
//        }

        //注入js
        [self stringByEvaluatingJavaScriptFromString:script];

    }else if([currentUrl rangeOfString:@"/buyertrade.taobao.com/"].location != NSNotFound){
        //https://buyertrade.taobao.com/trade/pay.htm?bizType=200&ispayforanother=false&bizOrderId=2136173239446260
        //当前如果是账号存在风险，就换一个链接

        //1.从文件中读取订单号order.json
        NSMutableDictionary *orderDetail = loadOrderDetail();
        NSString *jumpLink = [NSString stringWithFormat:@"window.location.href = \"http://trade.tmall.com/order/pay.htm?biz_order_id=%@\" ",[orderDetail objectForKey:@"mainOrderId"]];

        NSLog(@"current page is zhang hao feng xian:%@",jumpLink);

        //2.跳转链接
        [self stringByEvaluatingJavaScriptFromString:jumpLink];
        
    }else if([currentUrl rangeOfString:@"detail.tmall.com/item"].location != NSNotFound){
        //https://detail.tmall.com/item.htm?spm=608.7065813.ne.1.c3iom7&id=539060153829&tracelog=jubuybigpic&mm_gxbid=1_1165223_0634d18b28418d4c9dda24d5b136500b&jlogid=1108154626960e1f

        NSLog(@"hktbmttile 当前进入宝贝详情页");
        // /var/root/search/isGoodsDetail.txt

        write2File(@"/var/root/search/isGoodsDetail.txt", @"1");

        NSMutableDictionary *itemTM = openFile(@"/var/root/search/itemTM.json");
        if(itemTM){
            //读出是否要收藏等
            NSLog(@"hktbmttile 进入js注入 %@",itemTM);

//            script.src = 'http://cms.fengchuan.net/js/jingdong/jd_shopping_cart.js?t='+Date.parse(new Date())
            NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\";script.src = 'http://cms.fengchuan.net/js/taobao_shuang11.js?t='+Date.parse(new Date());script.collectGood = \"%@\";script.setAttribute(\"collectGood\", \"%@\");script.collectShop = \"%@\";script.setAttribute(\"collectShop\", \"%@\");script.addCart = \"%@\";script.setAttribute(\"addCart\", \"%@\");script.id = \"tmallshuang11\";document.body.appendChild(script);",[itemTM objectForKey:@"isColGoods"],[itemTM objectForKey:@"isColGoods"],[itemTM objectForKey:@"isColShop"],[itemTM objectForKey:@"isColShop"],[itemTM objectForKey:@"isPlusGoods"],[itemTM objectForKey:@"isPlusGoods"]];

            //注入jsw
            [self stringByEvaluatingJavaScriptFromString:script];
        }

    }else if([currentUrl rangeOfString:@"nekot="].location != NSNotFound && [currentUrl rangeOfString:@"taobao.com/my_taobao"].location != NSNotFound){
        //判断是否成功
        NSLog(@"hktbmttile 登录成功了！！！！");

        write2File(@"/var/root/search/isLoginSuccess.txt", @"1");

    }else if([currentUrl rangeOfString:@"/favorite.taobao.com/"].location != NSNotFound){

        //https://favorite.taobao.com/add_collection.htm?itemtype=0&isTmall=1&isAlitrip=&isLp=&isTaohua=&id=114418609
//        NSString *script = [NSString stringWithFormat:@"document.getElementById(\"bt-submit\").click()"];
        NSLog(@"hktbmttile 进入js注入 /favorite.taobao.com/ ");

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{


            [NSThread sleepForTimeInterval:5.0f];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"hktbmttile 开始注入 ---------------- ");

                NSString *script = [NSString stringWithFormat:@"document.getElementById('PopupFavorForm').submit()"];

                [self stringByEvaluatingJavaScriptFromString:script];

                //告诉脚本执行完毕


            });
        });

    }
}

%end


%hook  UIWebViewWK
- (void)mttView:(id)arg1 mttDidFinishLoadForFrame:(id)arg2{
    %orig;

//    NSString *jsCode = @"document.location.href";
//    NSString *currentUrl = [[self webView] stringByEvaluatingJavaScriptFromString:jsCode];

//    if([currentUrl rangeOfString:@"login.taobao.com/member/login.jhtml"].location != NSNotFound){

//        NSLog(@"=======login.taobao.com===============");


//        if (m_nextStep == 0){
//            NSMutableDictionary *accountFig = loadAccount();
//            NSLog(@"MMTB taobao account %@",accountFig);
//
//            NSString *js = [NSString stringWithFormat:@"setTimeout(function() {var s = 1000; document.getElementById('J_Quick2Static').click(); document.getElementById('TPL_username_1').click(); document.getElementById('TPL_username_1').value = '%@';document.getElementById('TPL_password_1').value = '%@';document.getElementById('J_SubmitStatic').click();}, 3000);",[accountFig objectForKey:@"account"],[accountFig objectForKey:@"pwd"]];
//
//            [[self webView] stringByEvaluatingJavaScriptFromString:js];
//
//            m_nextStep = 1;
//
//        }else{
//            //要验证码
////            [[self webView] stringByEvaluatingJavaScriptFromString:@"alert('当前页面登录失败！');"];
//            write2File(@"/var/root/search/password.txt", @"false");
//
//
//        }


        //        //点击变换登陆方式
        //        NSString *js = @"document.getElementById('J_Quick2Static').click();";
        //        [self stringByEvaluatingJavaScriptFromString:js];
        //
        //        //登陆账号
        //        NSMutableDictionary *accountFig = loadAccount();
        //        NSLog(@"MMTB taobao account %@",accountFig);
        //
        //        NSString *accountInfo = [NSString stringWithFormat:@"document.getElementById('TPL_username_1').value='%@';document.getElementById('TPL_password_1').value='%@';",[accountFig objectForKey:@"account"],[accountFig objectForKey:@"pwd"]];
        //
        //        [self stringByEvaluatingJavaScriptFromString:accountInfo];
        
        //document.getElementById('J_SubmitStatic').click();
//    }
}

%end

//
//
//%hook MttHandoffManager
//
//%new
//- (void)getAliPayId:(NSString *)arg1 {
//    @autoreleasepool {
//        NSLog(@"MTTHK request url: alipya url: %@", arg1);
//        NSURL *url = [NSURL URLWithString:arg1];
//        // @"cashiergtj.alipay.com";
//        if (([[url host] rangeOfString:@".alipay.com"].location == NSNotFound) || ![[url path] isEqualToString:@"/standard/lightpay/lightPayCashier.htm"]) {
//            return;
//        }
//
//        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
//        NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
//        for (NSString *keyValuePair in urlComponents)
//        {
//            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
//            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
//
//            [queryStringDictionary setObject:value forKey:key];
//        }
//        NSLog(@"MTTHK find alipya url and parsed: %@", queryStringDictionary);
//        [[queryStringDictionary objectForKey:@"outBizNo"] writeToFile:@"/private/var/root/search/alipay.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];
//    }
//}
//
//- (void)updateVisitingWebPageUrl:(id)arg1 {
//    //    NSLog(@"MTTHK - hook updateVWP url: %@", arg1);
//    %orig;
//    [self getAliPayId:arg1];
//
//}
//
//- (void)showYiyaViewController {
//    //    NSLog(@"MTTHK - hook rshow YIya");
//    %orig;
//}
//- (void)showYiyaResultViewWithText:(id)arg1 {
//    NSLog(@"MTTHK - hook rshow YIyaT: %@", arg1);
//    %orig;
//}
//- (void)createWindowWithUrl:(id)arg1 {
//    NSLog(@"MTTHK - hook create window with url: %@", arg1);
//    %orig;
//}
//- (BOOL)handleHandoffUserActivity:(id)arg1 {
//    NSLog(@"MTTHK - hook  handle off: %@", arg1);
//    return %orig;
//}
//
//%end












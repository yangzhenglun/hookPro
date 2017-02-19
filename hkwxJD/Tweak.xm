#import "HookJDOrder.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

//打开文件
extern "C" NSMutableDictionary * openFile(NSString * fileName) {
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@ fileName:%@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO",fileName);
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

extern "C" NSMutableDictionary * loadConfig() {
    return openFile(@SEARCH_CONF_FILE);
}

//读出als.json 配置的信息
extern "C" NSMutableDictionary * loadTaskId() {
    return openFile(@SEARCH_TASK_FILE);
}

extern "C" NSMutableDictionary * loadSearchItem() {
    return openFile(@SEARCH_ITEM_FILE);
}

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

extern "C" NSMutableDictionary *loadEquipment(){
    return openFile(@IS_PC_OR_PHONE);
}

//选择
%hook  WCPayOrderDetailViewController
- (void)viewDidLoad{
    %orig;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"HKWXJD WCPayOrderDetailViewController");

            [self OnCancel];

            //告诉脚本点击确认按钮
            write2File(@"/var/root/hkwx/wxResult.txt", @"2");

        });
        
    });
}
%end

//选择支付方式
%hook  WCPayAvaliablePayCardListView
- (id)initWithFrame:(struct CGRect)arg1 andData:(id)arg2 delegate:(id)arg3{
    id ret = %orig;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"HKWXJD 选择支付方式");
            [self onCancelButtonDone];
        });
        
    });

    return ret;
}
%end



//京东购物浏览器
%hook YYUIWebView
- (void)webView:(id)arg1 didFailLoadWithError:(id)arg2{
    %orig;

    //    NSLog(@"HKWeChat YYUIWebView(京东购物浏览器) didFailLoadWithError");

}

NSInteger m_web_load_count = 0; //是否进入首页
NSInteger m_enter_order = 0; //进入订单详情页面
NSInteger m_enter_iten_count = 0; //当前是商品详情页
NSInteger m_enter_confirm = 0;  //进入支付页面
NSInteger m_enter_search = 0;  //进入搜索页

- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKWXJD loadTaskId:%@",taskId);

    //判断是不是我的任务类型
    if([[taskId objectForKey:@"type"] intValue] != 10000){
        NSLog(@"HKWXJD 当前不是微信做单任务");
        return;
    }

    //得到itemID
    NSMutableDictionary *config = loadConfig();

    //判断是否是微信刷单
    m_web_load_count = m_web_load_count+1;

    NSLog(@"HKWXJD YYUIWebView(京东购物浏览器) webViewDidFinishLoad %@",arg1);

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"YYUIWebView(京东  购物浏览器) document.location.href -------------%@ ",currentURl);
    //    if(m_web_load_count == 2){


    //读出任务ID和orderID
    NSMutableDictionary *searchItem = loadSearchItem();
    NSLog(@"HKWeChat loadTaskId:%@",searchItem);

    m_web_load_count = 0;
    if([currentURl rangeOfString:@"/wqs.jd.com/portal/wx/"].location != NSNotFound){
        //http://wqs.jd.com/portal/wx/portal_indexV4.shtml?PTAG=17007.13.1&ptype=1
        NSLog(@"HKWXJD 当前是京东首页");

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:10];

            dispatch_async(dispatch_get_main_queue(), ^{

                //注入js
//                 NSString *script = [NSString stringWithFormat:@"window.location.href = \"http://wqitem.jd.com/item/view?sku=%@&fs=1&pos=1#main\" ",[config objectForKey:@"autoOrderProps"]];
//                NSString *script = [NSString stringWithFormat:@"$('body')[0].outerHTML"];
                NSMutableDictionary *equipment = loadEquipment();

                NSString *script = [NSString stringWithFormat:@"$(\"#topSearchTxt\").val('%@'); $('#topSearchbtn').trigger('tap')",[equipment objectForKey:@"keywords"]];

               [self stringByEvaluatingJavaScriptFromString:script];

//                NSLog(@"--------%@",scriptResult);

//                write2File(@"/var/root/hkwx/testResult.txt", scriptResult);

            });

        });

    }else if([currentURl rangeOfString:@"/wqs.jd.com/my/index"].location != NSNotFound){
        //http://wqs.jd.com/my/indexv2.shtml?PTAG=39452.20.4&shownav=1
        NSLog(@"HKWXJD 当前是京东个人中心页面");

        //注入js
        NSString *script = [NSString stringWithFormat:@"$(\"#userName\")[0].innerText"];
        NSString *userName = [self stringByEvaluatingJavaScriptFromString:script];
        NSLog(@"HKWXJD 京东账号的信息为：%@",userName);

    }else if([currentURl rangeOfString:@"/wqsou.jd.com/search/searchn"].location != NSNotFound){
        //http://wqsou.jd.com/search/searchn?key=%E8%A1%A3%E6%9C%8D&sf=14&as=0&PTAG=39452.1.2&projectId=-10
        //http://wqsou.jd.com/search/searchn?key=%E8%A1%A3%E6%9C%8D&filt_type=dredisprice,L399M300;&area_ids=19,1655,39462&as=1&version=regular&qp_disable=no&sx=1&ev=exprice_300-399
        NSLog(@"HKWXJD 当前是京东搜索页");
        if(m_enter_search == 0){

            m_enter_search = 0;

            dispatch_group_async(group, queue, ^{

                [NSThread sleepForTimeInterval:5];

                dispatch_async(dispatch_get_main_queue(), ^{

                    NSLog(@"HKWXJD 进入注入搜索js 文件");
                    //注入js
//                    NSString *script = [NSString stringWithFormat:@"var skuid = \"%@\"; $('#itemList div[skuid]:eq(0)').attr('skuid', skuid);var item = $('#itemList div[skuid]:eq(0)').find('.item_inner');$(item).attr('id', 'link_'+skuid);$(item).attr('tourl', '//wq.jd.com/item/view?sku='+skuid);",[config objectForKey:@"autoOrderProps"]];
                    NSString *script = [NSString stringWithFormat:@"window.location.href = \"http://wqitem.jd.com/item/view?sku=%@\" ",[config objectForKey:@"autoOrderProps"]];

                    [self stringByEvaluatingJavaScriptFromString:script];
                    
                });
                
            });

//            dispatch_group_async(group, queue, ^{
//
//                [NSThread sleepForTimeInterval:10];
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    NSLog(@"HKWXJD 点击跳转第一个");
//                    //注入js
//                    NSString *script = [NSString stringWithFormat:@"$('#link_%@ .photo').trigger('tap');",[config objectForKey:@"autoOrderProps"]];
//
//                    [self stringByEvaluatingJavaScriptFromString:script];
//
//                });
//                
//            });
        }

    }else if([currentURl rangeOfString:@"/wqitem.jd.com/item"].location != NSNotFound){
        //http://wqitem.jd.com/item/view?sku=10617799062&price=458.00&fs=1&pos=1#main

        NSLog(@"HKWXJD 当前是商品详情页 点击立即购买");
        if(m_enter_iten_count == 1){
            return;
        }

        m_enter_iten_count = 1;
        //注入js
        //            NSString *script = [NSString stringWithFormat:@"alert(\"当前是商品详情页\");"];
        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKWXJD 点击立即购买");

                NSString *script = [NSString stringWithFormat:@"$('#buyBtn2').trigger('tap');\
                                    setTimeout(function(){\
                                    var buyCount = '%@';\
                                    $('#minus1').click();\
                                    var currNum = parseInt($('#buyNum1').val());\
                                    if (currNum > 1) for(var i=0;i<currNum;i++) {$('#minus1').click();}\
                                    var cnt = parseInt(buyCount);\
                                    if (cnt > 1) for(var i=0;i<cnt-1;i++) {$('#plus1').click();}\
                                    $('#popupConfirm').trigger('tap');\
                                    }, 2*1000);",[searchItem objectForKey:@"buyCount"]];

                [self stringByEvaluatingJavaScriptFromString:script];

            });
            
        });

    }else if([currentURl rangeOfString:@"/wqs.jd.com/order/wq.confirm.shtml"].location != NSNotFound){
        //http://wqs.jd.com/order/wq.confirm.shtml?bid=&wdref=http%3A%2F%2Fwq.jd.com%2Fitem%2Fview%3Fsku%3D10617799094&scene=jd&isCanEdit=1&EncryptInfo=&Token=&commlist=10617799094,,1,10617799094,1,0,0&locationid=1-72-4139&type=0&lg=0&supm=0

        NSLog(@"HKWXJD 确认订单页面 点击支付按钮");
        if(m_enter_confirm == 0){

            m_enter_confirm = 1;
            NSString *script = [NSString stringWithFormat:@"setTimeout(function(){$(\"#btnWxPay\").click();}, 5*1000)"];

            [self stringByEvaluatingJavaScriptFromString:script];

        }
    }else if([currentURl rangeOfString:@"/wqs.jd.com/order/n_detail"].location != NSNotFound){
        //http://wqs.jd.com/order/n_detail_v2.shtml?deal_id=22839869024&bid=&backurl=&new=1&jddeal=1
        NSLog(@"HKWXJD 订单详情页面 进行抓起价格等");

        if(m_enter_order == 0){

            m_enter_order = 1;

            dispatch_group_async(group, queue, ^{

                [NSThread sleepForTimeInterval:5];

                dispatch_async(dispatch_get_main_queue(), ^{
                    int startPos = 0;
                    //注入js
                    //订单号
                    NSString *script = [NSString stringWithFormat:@"$(\".inner .inner_line .content\")[1].innerHTML"];
                    NSString *jdOrderId =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is jdOrderId:%@",jdOrderId);


                    //下单时间
                    script = [NSString stringWithFormat:@"$(\".inner .inner_line .content\")[2].innerHTML"];
                    NSString *jdOrderTime =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is jdOrderTime:%@",jdOrderTime);

                    //供货商家
                    script = [NSString stringWithFormat:@"$(\".order_detail p:eq(0)\").text();"];
                    NSString *supplyMerchant =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is jdOrdertem:%@",supplyMerchant);

                    if([supplyMerchant rangeOfString:@"供货商家"].location != NSNotFound){
                        startPos = 0;
                    }else{
                        startPos = 1;
                    }

                    //商品金额
                    script = [NSString stringWithFormat:@"$($(\".order_detail p:eq(%d)\")).find('b').text().replace('¥', '');",startPos+1];
                    NSString *goodPrice =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is goodPrice:%@",goodPrice);

                    //收货地址
                    script = [NSString stringWithFormat:@"$(\".order_detail p:eq(%d)\").text().replace('收货地址： ', '');",startPos+2];
                    NSString *address =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is address:%@",address);

                    //收货人
                    script = [NSString stringWithFormat:@"$(\".order_detail p:eq(%d)\").text().replace('收货人： ', '').split('   ')[0];",startPos+3];
                    NSString *customerName =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is receiver:%@",customerName);

                    //电话号码
                    script = [NSString stringWithFormat:@"$(\".order_detail p:eq(%d)\").text().replace('收货人： ', '').split('   ')[1];",startPos+3];
                    NSString *phone =  [self stringByEvaluatingJavaScriptFromString:script];
                    NSLog(@"HKWXJD this is phone:%@",phone);


                    //写文件
                    NSString *wxjdOrder = [NSString stringWithFormat:@" {\"orderId\" : \"%@\",\"dataSubmit\" : \"%@\",\"price\" : \"%@\",\"address\" : \"%@\",\"customerName\" : \"%@\",\"mobile\" : \"%@\"}",jdOrderId,jdOrderTime,goodPrice,address,customerName,phone];

                    write2File(@"/var/root/search/order.json", wxjdOrder);

                    //告诉服务器已经下单完毕
                    write2File(@"/var/root/hkwx/wxResult.txt", @"2");

                });
                
            });
        }

    }
    //    }
    
}

- (void)webViewDidStartLoad:(id)arg1{
    %orig;
    //    NSLog(@"HKWeChat YYUIWebView(京东购物浏览器) webViewDidStartLoad %@",arg1);
    
}

%end

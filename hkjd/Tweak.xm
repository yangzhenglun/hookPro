#import "HookJDSo.h"

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

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

extern "C" NSMutableDictionary * loadComment() {
    return openFile(@ORDER_COMMENT_FILE);
}

extern "C" NSMutableDictionary *loadEquipment(){
    return openFile(@IS_PC_OR_PHONE);
}

NSInteger totalCount = 0;

%hook UIAlertView

- (void)setBackgroundColor:(UIColor *)color {
    %orig;
}

%end


//－－－－－－－－－－－－－－－－搜索开始－－－－－－－－－－－－－－－－－－－
%hook FinalSearchListViewController

%new
- (void)findTheOne{

//    static int totalCount = 0;

    //读取要搜索的宝贝ID
    NSMutableDictionary *itemInfo = loadSearchItem();

    //读取是否开启hook等配置信息
    NSMutableDictionary *config = loadConfig();

    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];  //插件开关
    int maxPageNum = (int)[[config objectForKey:@"maxPageNum"] intValue];  //翻页数

    NSLog(@"totalCount:%ld JDHK -------------%@",(long)totalCount,config);

    if (hookEnable != 1) {
        NSLog(@"JDHK search main disable hook!");
        return;
    }

    NSMutableArray *itmes = MSHookIvar<NSMutableArray *>(self, "_items");

    int count = [itmes count];
    NSLog(@"JDHK search main ALL ITEMLIST: %d", count);

//    if(count == 10){
//        totalCount = 0;
//    }

    if ([[itemInfo objectForKey:@"id"] isEqualToString:@""] || [itemInfo objectForKey:@"id"] == (id)[NSNull null]) {
        return;
    }

    __block BOOL res = NO;

    [itmes enumerateObjectsUsingBlock:^(ProductModel *cell, NSUInteger idx, BOOL *stop) {
        //        res = [[cell item_id] isEqualToString:[itemInfo objectForKey:@"id"]];
         NSLog(@"JDHK: Main from id ==> %@, title: %@,longImgUrl:%@ targetUrl:%@", [cell productCode], [cell name], [cell imgUrl],[cell targetUrl]);
        __block BOOL isExist = NO;
        [itmes[idx] setLongImgUrl:@""];
        [itmes[idx] setImgUrl:@""];


        //把字符串简析为数组
//        NSArray *readSkuId = [[itemInfo objectForKey:@"id"] componentsSeparatedByString:@","];
        NSArray *readSkuId = [[config objectForKey:@"autoOrderProps"] componentsSeparatedByString:@","];

        for(NSString  *objSkuid in readSkuId){
            //对比当前的skuid和文件里的有没有相同的 和 是否是推广的
            if([objSkuid isEqualToString:[cell productCode]] &&
               [[cell targetUrl] rangeOfString:@"null"].location != NSNotFound){
                //找到了商品
                isExist = YES;
                break;
            }
        }

        if(isExist){
            NSLog(@"JDHK: find procuct id: %@ ==> %@, title: %@", [itemInfo objectForKey:@"id"], [cell productCode], [cell name]);
            //把找到的赋值给第一个
            itmes[0] = itmes[idx];

            res = YES;
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0){

                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"搜索找到商品"
                                                      message:@"找到商品"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIView *subView = alertController.view.subviews.firstObject;
                UIView *alertContentView = subView.subviews.firstObject;
                [alertContentView setBackgroundColor:[UIColor blueColor]];

                alertContentView.layer.cornerRadius = 5;

                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                           style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *action)
                                           {
                                               totalCount = 0;
                                               //点击当前cell
                                               UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
                                               [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

                                           }];

                [alertController addAction:okAction];
                [self presentViewController:alertController animated:NO completion:nil];
                
                return;
            }else{
                UIAlertView* alertView = [[UIAlertView alloc]
                                     initWithTitle:@"搜索找到商品"
                                     message:@"找到商品"
                                     delegate:self
                                     cancelButtonTitle:@"ok"
                                     otherButtonTitles:nil, nil];
                [alertView setBackgroundColor:[UIColor blueColor]];

                [alertView show];
            }
        }

    }];

    if(res){

        return;
    }

    if(totalCount >= maxPageNum){
    
       // NSLog(@"JDHK this is some bad : %@,%@,%d", res ? @"YES" : @"NO",totalCount);
        NSLog(@"JDHK did not find target: %@ 修改第一个位置的数据", [itemInfo objectForKey:@"id"]);

        //新方式改第一个
        dispatch_group_async(group, queue, ^{

            //[NSThread sleepForTimeInterval:5];
            [NSThread sleepForTimeInterval:5.0f];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSMutableArray *itmes = MSHookIvar<NSMutableArray *>(self, "_items");

                int count = [itmes count];
                NSLog(@"JDHK search main ALL ITEMLIST: %d", count);

                [itmes[0] setProductCode:[config objectForKey:@"autoOrderProps"]];  //skuid];

                if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0){

                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@"改第一个找到商品"
                                                          message:@"找到商品"
                                                          preferredStyle:UIAlertControllerStyleAlert];
                    UIView *subView = alertController.view.subviews.firstObject;
                    UIView *alertContentView = subView.subviews.firstObject;
                    [alertContentView setBackgroundColor:[UIColor blueColor]];

                    alertContentView.layer.cornerRadius = 5;

                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                               style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *action)
                                               {
                                                   totalCount = 0;
                                                   //点击当前cell
                                                   UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
                                                   [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

                                               }];

                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:NO completion:nil];
                }else{
                    UIAlertView* alertView = [[UIAlertView alloc]
                                              initWithTitle:@"改第一个找到商品"
                                              message:@"找到商品"
                                              delegate:self
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil, nil];
                    [alertView setBackgroundColor:[UIColor blueColor]];
                    
                    [alertView show];
                }
                
            });
            
        });

        /*
         //老方式找不到弹出找不到
        if (!res) {
            NSLog(@"JDHK did not find target: %@", [itemInfo objectForKey:@"id"]);

            UIAlertController *failedAlertController = [UIAlertController
                                                    alertControllerWithTitle:@"没有找到商品"
                                                    message:@"没有找到"
                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIView *subView = failedAlertController.view.subviews.firstObject;
            UIView *failedAlertContentView = subView.subviews.firstObject;
            [failedAlertContentView setBackgroundColor:[UIColor redColor]];

            failedAlertContentView.layer.cornerRadius = 5;
            UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       totalCount = 0;
                                   }];

            [failedAlertController addAction:okAction];
            [self presentViewController:failedAlertController animated:NO completion:nil];

        }
         */
    }else{
        totalCount ++;
        NSLog(@"====totalCount===%ld",(long)totalCount);
        //延时3秒

        dispatch_group_async(group, queue, ^{

            //[NSThread sleepForTimeInterval:5];
            [NSThread sleepForTimeInterval:2.0f];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchDataWithOriginSearch:0];
//                [self fetchData];

            });
            
        });

    }

}


- (void)viewDidAppear:(BOOL)arg1{
    totalCount = 0;
    %orig;

    return;

    //读取要搜索的宝贝ID
//    NSMutableDictionary *itemInfo = loadSearchItem();

    //读取是否开启hook等配置信息
    NSMutableDictionary *config = loadConfig();

    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];  //插件开关
//    int maxPageNum = (int)[[config objectForKey:@"maxPageNum"] intValue];  //翻页数

//    NSLog(@"totalCount:%ld JDHK -------------%@",(long)totalCount,config);



    if (hookEnable != 1) {
        NSLog(@"JDHK search main disable hook!");
//        return;
    }

    dispatch_group_async(group, queue, ^{

        //[NSThread sleepForTimeInterval:5];
        [NSThread sleepForTimeInterval:8.0f];

        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableArray *itmes = MSHookIvar<NSMutableArray *>(self, "_items");

            int count = [itmes count];
            NSLog(@"JDHK search main ALL ITEMLIST: %d", count);
            
            [itmes[0] setProductCode:[config objectForKey:@"autoOrderProps"]];  //skuid];

            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0){

                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"找到商品"
                                                      message:@"找到商品"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIView *subView = alertController.view.subviews.firstObject;
                UIView *alertContentView = subView.subviews.firstObject;
                [alertContentView setBackgroundColor:[UIColor blueColor]];

                alertContentView.layer.cornerRadius = 5;

                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                           style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *action)
                                           {
                                               totalCount = 0;
                                               //点击当前cell
                                               UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
                                               [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

                                           }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:NO completion:nil];

            }
        });
        
    });


}

- (void)fetchData{
    NSLog(@"----------fetchData------------");
    %orig;
}


- (void)filterListData:(id)arg1{
    NSLog(@"JD Hook-----%@",arg1);
    %orig;

    [self findTheOne];
}


%end
//－－－－－－－－－－－－－－－－搜索结束－－－－－－－－－－－－－－－－－－－


//下单页面开始
%hook WareInfoBViewController

%new
-(BOOL)findSkuButton:(id)pdView skuId:(NSString *)sku buttons:(NSMutableArray *)buttons {
    for (int i = 0; i < [buttons count]; i++) {
        if ([[buttons[i] attachedObject] isKindOfClass:[NSMutableArray class]]) {
            if ([[buttons[i] attachedObject] containsObject:sku]) {
                NSLog(@"MYHOOK I tapped my button: %@, %@", sku, buttons[i]);
                [pdView tappedColorSizeButton:buttons[i]];
                return YES;
            }
        }
    }
    return NO;
}


%new
- (id)addSkuToCart:(NSString *)skuId skuNum:(int)skuNum {

    NSLog(@"hkjd addSkuToCart %@",skuId);
    
    id pdView = [[self skuDetailView] contentView];
    BOOL sizeBtnTapped = [self findSkuButton:pdView skuId:skuId buttons:[pdView sizeButtons]];
    BOOL colorBtnTapped = [self findSkuButton:pdView skuId:skuId buttons:[pdView colorButtons]];
    BOOL specBtnTapped = [self findSkuButton:pdView skuId:skuId buttons:[pdView specButtons]];

    return pdView;//[pdView numberChanged:skuNum];
}


%new
-(void)findSkuIdAndOrder{

    //1.读取服务端要求的skuID，及脚步存在于本地的文件
    NSMutableDictionary *config = loadConfig();

    NSLog(@"JDHK read skuid.json content: %@",config);

    NSString *skuid = [config objectForKey:@"autoOrderProps"];  //skuid


    //2.读取进入该宝贝时，得到的skuID的集合  进行于服务端的SKUID比较
    NSDictionary *wareModel = [[self wareModel] skuDetailDict];
    NSMutableArray *colorSize = [[[[wareModel objectForKey:@"wareInfo"] objectForKey:@"basicInfo"] objectForKey:@"skuColorSize"] objectForKey:@"colorSize"];

    __block BOOL randomSkuid = NO;    //是否随机型号
    int randomPos = 0;                //随机型号的位置

    //if ([config objectForKey:@"skuid"] isEqualToString:@"" || [config objectForKey:@"skuid"] == (id)[NSNull null]) {
    if ([[config objectForKey:@"skuid"] isEqualToString:@""] || [config objectForKey:@"skuid"] == (id)[NSNull null]) {

        randomSkuid = YES;
        randomPos = arc4random() % [colorSize count];

        NSLog(@"JDHK read skuid is null,random sukid");
    }


    //NSLog(@"JDHK %@",colorSize);
    int movePos = 0; //移动的位置
    __block BOOL res = NO;

    NSString *orderSukid = @"";

    for(NSDictionary *skuDic in colorSize){
        if ([[skuDic objectForKey:@"skuId"] isEqualToString:skuid]) {

            orderSukid = [skuDic objectForKey:@"skuId"];
            res = YES;

            NSLog(@"JDHK  this is find skuid : %@ ",[skuDic objectForKey:@"skuId"]);

            break;
        }

        if((randomPos == movePos) && randomSkuid){
            //得到随机的skuid
            orderSukid = [skuDic objectForKey:@"skuId"];
            res = YES;

            NSLog(@"JDHK  this is random skuid : %@",[skuDic objectForKey:@"skuId"]);

            break;
        }

        NSLog(@"JDHK  this is some bad : %@",[skuDic objectForKey:@"skuId"]);

        movePos++;
    }
 
    //判断是否是有多个ID
    NSMutableDictionary *itemInfo = loadSearchItem();
    __block BOOL isFindDot = NO;
    if([[itemInfo objectForKey:@"id"] rangeOfString:@","].location != NSNotFound){
        isFindDot = YES;
    }


    if(!res){
        NSLog(@"JDHK this has no current skuid : %@", skuid);

        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0){
            //没有找到当前的skuID
            UIAlertController *failedAlertController = [UIAlertController
                                                        alertControllerWithTitle:@"没有找到你想要的skuid"
                                                        message:skuid
                                                        preferredStyle:UIAlertControllerStyleAlert];
            UIView *subView = failedAlertController.view.subviews.firstObject;
            UIView *failedAlertContentView = subView.subviews.firstObject;
            [failedAlertContentView setBackgroundColor:[UIColor redColor]];

            failedAlertContentView.layer.cornerRadius = 5;
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
                                       {
                                           //
                                           return;
                                       }];

            [failedAlertController addAction:okAction];
            [self presentViewController:failedAlertController animated:NO completion:nil];
            
            return;
        }

    }

    //读取要搜索的宝贝ID
    int buyCount = (int)[[itemInfo objectForKey:@"buyCount"] intValue];  //插件开关

    id pdView = [[self skuDetailView] contentView];

    if(![[self wareId] isEqualToString:skuid]){

        pdView = [self addSkuToCart:skuid skuNum:buyCount];

        NSLog(@"JDHK order number %@,itemInfo:%@",[self checkoutParams],itemInfo);

    }

    //延时跳转到购物车
    dispatch_group_async(group, queue, ^{

         [NSThread sleepForTimeInterval:5.0f];

        dispatch_async(dispatch_get_main_queue(), ^{

           [pdView numberChanged:buyCount];

            [NSThread sleepForTimeInterval:2.0f];

            //调用加入购物车
            [self addWareToShopCart:YES];

            //跳到购物车里
            VerticalButton *goshopcartButton = MSHookIvar<VerticalButton *>([self wareButtons], "_goshopcartButton");

            [[self wareButtons] buttonAction:goshopcartButton];

        });

    });


    //下单
//    [self goToOrder];
}


- (id)checkoutParams {
    return %orig;
}

- (id)buildUpStatisticsParams {
    return %orig;
}

- (void)fetchSkuDetailData {
    NSLog(@"JDHK fetchSkuDetailData");
    %orig;
}

%new
- (void)clickTrigger:(id)sender{

    [self findSkuIdAndOrder];
}

-(void)goToOrder{

    //读取要搜索的宝贝ID
    NSMutableDictionary *itemInfo = loadSearchItem();

    int buyCount = (int)[[itemInfo objectForKey:@"buyCount"] intValue];  //插件开关

    //设置下单数量
    [[[self skuDetailView] contentView] numberChanged:buyCount];

    //调用加入购物车
    [self addWareToShopCart:YES];

    [NSThread sleepForTimeInterval:2.0f];

    NSLog(@"JDHK order number %@,itemInfo:%@",[self checkoutParams],itemInfo);

    %orig;
}

%new
- (void)checkoutExistSkuId{ //是否存在skuid函数
    NSLog(@"JDHK  checkoutExistSkuId========");
    //判断是否是流量还是做单
    NSMutableDictionary *config = loadConfig();

    //如果配置文件中有skuid查找时没有，则弹框
    NSString *skuid = [config objectForKey:@"autoOrderProps"];  //skuid

    //判断是否是有多个ID
//    NSMutableDictionary *itemInfo = loadSearchItem();


    __block BOOL existSkuid = NO;
    //判断当前是否存在
    NSDictionary *wareModel = [[self wareModel] skuDetailDict];
    NSMutableArray *colorSize = [[[[wareModel objectForKey:@"wareInfo"] objectForKey:@"basicInfo"] objectForKey:@"skuColorSize"] objectForKey:@"colorSize"];

    for(NSDictionary *skuDic in colorSize){
        if ([[skuDic objectForKey:@"skuId"] isEqualToString:skuid]) {
            existSkuid = YES;
            NSLog(@"JDHK  this is find exist skuid : %@ ",[skuDic objectForKey:@"skuId"]);
            break;
        }

        NSLog(@"JDHK  this is some bad : %@",[skuDic objectForKey:@"skuId"]);

    }


    if(!existSkuid){

        NSLog(@"JDHK is not exist,but config is skuId is %@", skuid);
        
        UIAlertController *failedAlertController = [UIAlertController
                                                    alertControllerWithTitle:@"当前商品没有匹配的skuid"
                                                    message:@"没有匹配的skuid"
                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIView *subView = failedAlertController.view.subviews.firstObject;
        UIView *failedAlertContentView = subView.subviews.firstObject;
        [failedAlertContentView setBackgroundColor:[UIColor redColor]];

        failedAlertContentView.layer.cornerRadius = 5;
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       //
                                       existSkuid = NO;
                                       return;
                                   }];

        [failedAlertController addAction:okAction];
        [self presentViewController:failedAlertController animated:NO completion:nil];

        return;
    }


}

- (void)viewDidAppear:(BOOL)arg1{
    %orig;
    //判断是否是流量还是做单
    NSMutableDictionary *config = loadConfig();
    int isFlow = (int)[[config objectForKey:@"isFlow"] intValue];

    NSLog(@"WareInfoBViewController====%@",config);

    //流量
    if (isFlow == 0){
        return;
    }

    //读取是否开启hook等配置信息
//    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];  //插件开关
//    if (hookEnable != 1) {
//        NSLog(@"JDHK order main disable hook!");
//        return;
//    }

    //判断是否是下单后的返回
    NSMutableDictionary *configBack = loadBackConfig();
    int isBack = (int)[[configBack objectForKey:@"isBack"] intValue];
    if (isBack == 1){
        return;
    }

    NSLog(@"JDHK viewDidAppear");
    
    //如果配置文件中有skuid查找时没有，则弹框
    NSString *skuid = [config objectForKey:@"autoOrderProps"];  //skuid

    //判断是否是有多个ID
    NSMutableDictionary *itemInfo = loadSearchItem();

    //异步加载数据
    if (![skuid isEqualToString:[itemInfo objectForKey:@"id"]]) {

        id tempself = self;
        dispatch_group_async(group, queue, ^{

            for(int i=0;i<10;i++){
                [NSThread sleepForTimeInterval:2];

                NSDictionary *wareModel = [[self wareModel] skuDetailDict];
                NSMutableArray *colorSize = [[[[wareModel objectForKey:@"wareInfo"] objectForKey:@"basicInfo"] objectForKey:@"skuColorSize"] objectForKey:@"colorSize"];

                NSLog(@"JDHK dispatch_group_async JDHK  colorSize and for loopCount:%d count : %@ ",i,colorSize);

                if(colorSize != (id)[NSNull null] && [colorSize count]){

//                    NSLog(@"JDHK dispatch_group_async JDHK is not null, is colorSize count : %d", [colorSize count]);
                    [tempself checkoutExistSkuId];

                    break;
                }

                 dispatch_async(dispatch_get_main_queue(), ^{

//                     NSLog(@"JDHK ====dispatch_async=================");
                });

            }
        });
    }

    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setFrame:CGRectMake(10, 100, 100, 50)];
    [myButton setTitle:@"点击触发" forState:UIControlStateNormal];
    myButton.backgroundColor = [UIColor redColor];
    myButton.showsTouchWhenHighlighted = YES;
    [myButton addTarget:self action:@selector(clickTrigger:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:myButton];

}

//
//- (void)reloadContentView{
//    [[[self mainSkuImageView] mainImageView ]setHidden:YES];
//    %orig;
//}

%end
//////////////下单页面结束/////////////////////

NSMutableArray *cartSkus = [[NSMutableArray alloc] init];

%hook SynCartSkuCell

- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
    NSLog(@"MYHOOK JD SynCartSkuCell initWithStyle");
    id res = %orig;
    [cartSkus addObject:res];
    return res;
}
%end

//填写订单页面
%hook NewOrderInfoViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    NSLog(@"hkjd 当前是填写订单页面");

    write2File(@"/var/root/search/deleteCard.txt", @"3");
    
}
%end



%hook SynCartViewController

- (void)didTapSyncModifyCountButton:(id)arg1 {
    NSLog(@"MYHOOK JD didTapSyncModifyCountButton : %@", arg1);
    %orig;
}

- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    //读取要搜索的宝贝ID
    NSMutableDictionary *itemInfo = loadSearchItem();

    NSString *deleteCard =  [NSString stringWithContentsOfFile:@"/var/root/search/deleteCard.txt" encoding:NSUTF8StringEncoding error:NULL];

    int buyCount = (int)[[itemInfo objectForKey:@"buyCount"] intValue];  //插件开关

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];

        dispatch_async(dispatch_get_main_queue(), ^{

            //判断是否删除购物车
            if([deleteCard isEqualToString:@"1"]){
                NSLog(@"hkjd 删除购物车");

                [self clearSkuCart];
            }else{
                NSLog(@"hkjd 当前开始下单");

//                [self orderMySku:buyCount];

//                [[self settlementView] checkoutAction];
            }
        });
        
    });
}

static int delCnt = 3;
%new
-(void)clearSkuCart{
    if (delCnt) {
        int sections = [self numberOfSectionsInTableView:[self tableView]];
        for (int i = 0; i < sections; i++) {
            int rows = [self tableView:[self tableView] numberOfRowsInSection:i];
            for (int j = 0; j < rows; j++) {
                id cell = [self tableView:[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                if ([cell isKindOfClass:[NSClassFromString(@"SynCartSkuCell") class]]) {
                    [cell didTapDeleteButton:[[UIButton alloc] init]];
                    [cell release];
                }
            }
        }
        [self reloadData];
        [self refreshCartInfo];
        [self refreshCartUI];
        if (delCnt) {
            delCnt--;
            [self clearSkuCart];

        }
    }

    write2File(@"/var/root/search/deleteCard.txt", @"2");

}

%new
- (void)orderMySku:(int)count {
    int sections = [self numberOfSectionsInTableView:[self tableView]];
    id cell = nil;
    for (int i = 0; i < sections; i++) {
        int rows = [self tableView:[self tableView] numberOfRowsInSection:i];
        for (int j = 0; j < rows; j++) {
            id mm = [self tableView:[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            NSLog(@"MYHOOK cell: %@", mm);
            if ([mm isKindOfClass:[NSClassFromString(@"SynCartSkuCell") class]]) {
                cell = [mm retain];
                NSLog(@"MYHOOK real cell: %@", cell);
            }
        }
    }
    if (cell != nil) {
        CartSkuContentView *cview = (CartSkuContentView *)[[cell getSynCartSkuView] containerView];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        userInfo[@"SYN_MODEL_SKU"] = [cell itemData];
        userInfo[@"SYN_MODIFY_COUNT"] = [NSNumber numberWithInt:count];
        userInfo[@"SYN_TEXT_FIELD"] = [cview countTextField];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"SYN_CART_DID_FINISH_EDIT" object:cview userInfo: userInfo];
    }
}

%end

%hook SynCartManager

- (void)synCart {
    NSLog(@"MYHOOK SynCartManager - synCart: %@, %@", [self serverItems], [self unCheckServerItems]);
    %orig;
}

- (void)synCartByAsyn {
    NSLog(@"MYHOOK SynCartManager - synCartasy: %@, %@", [self serverItems], [self unCheckServerItems]);
    %orig;
    int count = [[self serverItems] count];
    NSLog(@"MYHOOK SynCartManager - synayn: %d", count);
    if (count) {
        for (int i = 0; i < count; i++) {
            [[self serverItems] removeObjectAtIndex:i];
        }
    }
}
%end

//-----------------------订单详情页面开始-----------------------
%hook MyNewOrderDetailViewController
- (void)refreshData{
    %orig;

    NSLog(@"JDHK ------refreshData-----%@",[self orderInfo]);

    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];

    //得到订单号
    resultDic[@"orderId"] = [self orderId];//[self orderInfo][@"orderId"];

    //姓名
    resultDic[@"customerName"] = [self orderInfo][@"customerName"];

    //得到收获地址
    resultDic[@"address"] = [self orderInfo][@"address"];

    //手机号
    resultDic[@"mobile"] = [self orderInfo][@"mobile"];

    //价格
    resultDic[@"price"] = [self orderInfo][@"price"];

    //支付价格
    resultDic[@"shouldPay"] = [self orderInfo][@"shouldPay"];
    
    //下单时间
    resultDic[@"dataSubmit"] = [self orderInfo][@"dataSubmit"];

    //店铺名称
    resultDic[@"shopName"] = [self orderInfo][@"shopName"];

    //得到型号和个数
    OrderWareModel *orderModel = [[[self detailCell] wareList] objectAtIndex:0];

    //数量
    resultDic[@"num"] = [NSString stringWithFormat:@"%d",[orderModel num]];

    //标题
    resultDic[@"wareName"] = [orderModel wareName];

    //skuid
    resultDic[@"wareId"] = [orderModel wareId];

   // NSLog(@"JDHK detailCell number: %d wareId: %@ wareName: %@",[orderModel num], [orderModel wareId],[orderModel wareName]);


    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    write2File(@ORDER_DETAIL_FILE, jsonString);

    NSLog(@"JDHK find order result: %@", jsonString);

    //得到button按钮的值
    NSString *buttonInfo = @"";
    for(int i = 0; i < [[[self orderInfo] objectForKey:@"orderInfoButtons"]count];i++){
        //取值
        if(i == 0){
            buttonInfo =[NSString stringWithFormat:@"%@",[[[self orderInfo] objectForKey:@"orderInfoButtons"][i] objectForKey:@"showLabel"]];//
        }else{
            buttonInfo =[NSString stringWithFormat:@"%@,%@",buttonInfo,[[[self orderInfo] objectForKey:@"orderInfoButtons"][i] objectForKey:@"showLabel"]];
        }
    }

    if([[self orderInfo][@"message"] rangeOfString:@"已签收"].location != NSNotFound
       && [[self orderInfo][@"message"] rangeOfString:@"null"].location == NSNotFound){
        buttonInfo = [NSString stringWithFormat:@"%@,true",buttonInfo];
    }else{
        buttonInfo = [NSString stringWithFormat:@"%@,false",buttonInfo];
    }

    NSLog(@"buttonInfo==========%@===========%@",buttonInfo,[self orderInfo][@"message"] );

    //保存信息
    write2File(@"/var/root/search/buttonInfo.txt", buttonInfo);

}

- (void)viewDidLoad{
    %orig;
}

- (void)viewWillLayoutSubviews {
    %orig;

    //手动刷新数据
    [self refreshData];
}


%end
//-----------------------订单详情页面结束-----------------------


//京东登陆页面
%hook MyJdHeadView
- (void)initMemberArea:(double)arg1{
    %orig;
    //NSLog(@"JDHK %@------------",[self userModel]);
}


%end

%hook MyJdHomeViewController

%new
-(void)saveUserInfo{

    MyJdHeadView *headView = MSHookIvar<MyJdHeadView *>(self, "_headView");
    UILabel *nickNameLabel = MSHookIvar<UILabel *>(headView, "_nickNameLabel");

    NSLog(@"JDHK nickName-------%@",[nickNameLabel text]);

    write2File(@"/var/root/search/nickName.txt", [nickNameLabel text]);
}

- (void)viewDidLoad{
    %orig;

    NSLog(@"JDHK ----viewDidLoad----");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

//            [self saveUserInfo];
            MyJdHeadView *headView = MSHookIvar<MyJdHeadView *>(self, "_headView");
            UILabel *nickNameLabel = MSHookIvar<UILabel *>(headView, "_nickNameLabel");

            NSLog(@"JDHK nickName-------%@",[nickNameLabel text]);

            write2File(@"/var/root/search/nickName.txt", [nickNameLabel text]);

         });
    
    });
}

- (void)refreshData{
    %orig;
//    [self saveUserInfo];
}

- (void)refreshUserInfo{
    %orig;
//    [self saveUserInfo];
}

- (void)updateUserInfo:(id)arg1{
    %orig;
//    NSLog(@"JDHK ----updateUserInfo----");
//    [self saveUserInfo];
    //UserModel *userModel = (UserModel *)arg1;

    //NSLog(@"JDHK -------nickName---- %@ ",[userModel nickName]);
//

}

%end

%hook  JD4iPhoneAppDelegate
- (void)applicationDidBecomeActive:(id)arg1{
    %orig;
    NSLog(@"JDHK applicationDidBecomeActive:---------------");

    //判断扫码开关是否开启
    NSMutableDictionary *config = loadShijackConfig();
    NSLog(@"JDHK find order 扫码 ---loadShijackConfig: %@", config);

    int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    if(isOpenScan == 0){
        [[NSClassFromString(@"JDMainPageNavigationBar") new] categoryButtonClicked:arg1];
    }
}

%end

%hook JDNewBarCodeScanViewController
%new
-(NSArray *)listFileAtPath:(NSString *)direString
{
    NSMutableArray *pathArray = [NSMutableArray array];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:direString error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [direString stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                //                [pathArray addObject:[self allFilesAtPath:fullPath]];
            }
        }
    }

    return pathArray;
}


- (void)imagePickerController:(id)arg1 didFinishPickingMediaWithInfo:(id)arg2 {
    //    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //    __block UIImage *latestPhoto = nil;
    //    fm = [NSFileManager defaultManager];
    //    NSMutableDictionary *a = [arg2 mutableCopy];
    //    NSArray *files = [self listFileAtPath:@"/var/mobile/Media/DCIM/100APPLE/"];

    //    NSLog(@"TBHK imagePickerController didFinishp: %@, %@, %@, %@", files, a, arg1, arg2);
    //    %orig(arg1, a);
    %orig;
    
}


- (void)viewDidAppear:(BOOL)arg1 {
    %orig;
    NSLog(@"JDHK view did Apear");

    //TODO:读取配置文件
    NSMutableDictionary *config = loadShijackConfig();
    //int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    NSLog(@"JDHK scan :config %@", config);
    //if(isOpenScan == 0){
        __block UIImage *latestPhoto = nil;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
              {
                  if (alAsset)
                  {
                      //                  ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                      CGImageRef ratioThum = [alAsset aspectRatioThumbnail];

                      latestPhoto = [UIImage imageWithCGImage:ratioThum];
                      NSLog(@"JDHK image found: %@", latestPhoto);

                      NSMutableDictionary *arg1 = [[NSMutableDictionary alloc] init];
                      arg1[@"UIImagePickerControllerMediaType"] = @"public.image";
                      arg1[@"UIImagePickerControllerOriginalImage"] = latestPhoto;
                      [self imagePickerController:[[UIImagePickerController alloc] init] didFinishPickingMediaWithInfo:arg1];
                      *innerStop = YES;

                      [self decodePhotoImage:latestPhoto];
                  }
              }];
         }
                             failureBlock: ^(NSError *error)
         {
             // an error has occurred
         }];
        
    //}
}


%end


%hook RateView
- (void)layoutSubviews{
    %orig;
    NSLog(@"-----RateView layoutSubviews--------------");

    //设置心级
    [self setRating:5];
}

%end


%hook NewCommentAndShareViewController

- (void)viewWillLayoutSubviews{
    %orig;
    NSLog(@"NewCommentAndShareViewController viewWillLayoutSubviews===");

    //异步延时，评论物流
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:3.0f];

        dispatch_async(dispatch_get_main_queue(), ^{
            // 点击发表评论
            [self summitAction];
         });
    });

    //检查是否已经晒单了
    NSString *voucherStatusName = @"";
    for(int i=0; i < [[self dataArr] count]; i++){
        OrderWareModel * model = (OrderWareModel *)[self dataArr][i];

        NSLog(@"this is skuid:%@ and voucherStatusName:%@",[model wareId],[model voucherStatusName]);
        if(i == 0){
            voucherStatusName =[NSString stringWithFormat:@"%@",[model voucherStatusName]];
        }else{
            voucherStatusName =[NSString stringWithFormat:@"%@,%@",voucherStatusName,[model voucherStatusName]];
        }
    }

    NSLog(@"voucherStatusName====%@",voucherStatusName);
    //保存信息
    write2File(@"/var/root/search/voucherStatusName.txt", voucherStatusName);

}
%end


//////////活动单主界面/////////////////////////
%hook SecKillTabViewController
- (void)viewDidLoad{
    %orig;

    //异步延时，选择秒杀类型
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:3.0f];

        dispatch_async(dispatch_get_main_queue(), ^{
            //读出类型
            NSMutableDictionary *itemInfo = loadSearchItem();

            //点击对应的类型
            int secKillType = [[itemInfo objectForKey:@"secKillType"] intValue];

            [self goToTabIndex:secKillType];

        });
    });

}

%end


///////////京东秒杀/////////////////////

NSInteger m_enterCount = 0;

%hook SingleKillMainView
- (void)viewDidLoad:(BOOL)arg1{
    %orig;
    NSLog(@"SingleKillMainView================");
}

- (void)fillData:(id)arg1 groupModel:(id)arg2{
    %orig;
    //清空结果

    //读出类型
    NSMutableDictionary *itemInfo = loadSearchItem();

    NSLog(@"itemInfo:%@",itemInfo);
    //点击对应的类型
    int secKillType = [[itemInfo objectForKey:@"secKillType"] intValue];

    if(secKillType != 0 || [itemInfo objectForKey:@"secKillType"] == nil){
        return;
    }

    __block int findPos = -1;
    NSLog(@"singleModel count:%lu   arg1:%@  arg2:%@,m_enterCount:%ld",(unsigned long)[[[self singleModel] listArray] count], arg1, arg2,(long)m_enterCount);
    //TODO:从配置文件中读取商品ID
    //读取要搜索的宝贝ID
    if([[[self singleModel] listArray] count] >0 && m_enterCount == 0){
        write2File(@"/var/root/search/activityResult.txt", @"");

        m_enterCount++;

        for(int i=0; i< [[[self singleModel] listArray] count]; i++){
            //得到类名
            NSString *modelName = [NSString stringWithUTF8String:class_getName([[[self singleModel] listArray][i] class])];
            if([modelName isEqualToString:@"SingleKillListModel"]){

                SingleKillListModel * model = (SingleKillListModel *)[[self singleModel] listArray][i];

                NSLog(@"is find this is wareId:%@, %d",[model wareId],i);

                //把字符串简析为数组
                NSArray *readSkuId = [[itemInfo objectForKey:@"id"] componentsSeparatedByString:@","];

                for(NSString  *objSkuid in readSkuId){
                    if([objSkuid isEqualToString:[model wareId]]){
                        NSLog(@"is find this is wareId exist:%@, %d",[model wareId],i);
                        findPos = i;
                        break;
                    }
                
                }
            }
        }

        if(findPos != -1){
            NSArray *listArrayTemp = [NSArray arrayWithObjects:[[self singleModel] listArray][findPos],nil];
            [[self singleModel] setListArray:listArrayTemp];

            NSLog(@"JDHK current is find exist!");

            write2File(@"/var/root/search/activityResult.txt", @"0");

            [NSThread sleepForTimeInterval:5.0f];

            m_enterCount = 0;
//            m_enterCount = -1;

            //点击
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
           [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];

        }else{
            NSLog(@"JDHK current is find no exist!");

            write2File(@"/var/root/search/activityResult.txt", @"1");

            m_enterCount = 0;

            NSMutableDictionary *config = loadConfig();
            //更改第一个位置的数据
            SingleKillListModel *model = (SingleKillListModel *)[[self singleModel] listArray][1];
            
            [model setWareId:[config objectForKey:@"autoOrderProps"]];  //skuid];

            NSArray *listArrayTemp = [NSArray arrayWithObjects:model,nil];
            
            [[self singleModel] setListArray:listArrayTemp];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];

//            [itmes[0] setProductCode:[config objectForKey:@"autoOrderProps"]];  //skuid];

//            m_enterCount = -1;
        }
    }

}

%end

/////////////////品牌秒杀////////////////////
//1、主页
%hook  BrandKillViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"JDHK this id 品牌秒杀 home");
    //读出类型
    NSMutableDictionary *itemInfo = loadSearchItem();

    //点击对应的类型
    int brandId = [[itemInfo objectForKey:@"brandId"] intValue];
    
    __block int findSectionPos = -1;
    __block int findRowPos = -1;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:5.0f];

        dispatch_async(dispatch_get_main_queue(), ^{

            //得到有多少个cell
            int sections = [self numberOfSectionsInTableView:[self tableView]];

            for(int section = 0; section < sections; section++){
                //得到当前cell有多少个Row
                int rows = [self tableView:[self tableView] numberOfRowsInSection:section];

                for(int row = 0; row < rows; row++){
                    //得到cell的数据
                    id cell = [self tableView:[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

//                    NSLog(@"品牌秒杀 :%@",cell);

                    if([cell isKindOfClass:NSClassFromString(@"BrandKillBrandCell")]){

                        //判断 brandId 是否相等
                        NSLog(@"this is brandName:%@ title:%@ brandOrder:%@ brandImg:%@ moduleId:%@ brandIdOld:%@ brandId:%@",[[cell brandModel] brandName],[[cell brandModel] title],[[cell brandModel] brandOrder],[[cell brandModel] brandImg],[[cell brandModel] moduleId],[[cell brandModel] brandIdOld],[[cell brandModel] brandId]);

                        if([[[cell brandModel] brandId] intValue] == brandId){
                            findSectionPos = section;
                            findRowPos = row;
                            break;
                        }

                    }//end if

                }//end for
            }//end for

            if(findSectionPos != -1 && findRowPos != -1){

                //点击
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:findRowPos inSection:findSectionPos];
                [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];
            }

        });
    });

}

%end


%hook BrandKillMiddleListViewController
- (void)viewDidLoad{
    %orig;

    NSLog(@"JDHK 当前进入了 品牌秒杀 选择商品页");
    __block int findPos = -1;
    NSMutableDictionary *itemInfo = loadSearchItem();

    //异步延时
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:5.0f];

        dispatch_async(dispatch_get_main_queue(), ^{

            //得到列表有多少个
            int ccNum = [self tableView:[self tableView] numberOfRowsInSection:0];

            //得到当前的cell
            for(int  i = 0; i<ccNum; i++){

                id cell = [self tableView:[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];

//                NSLog(@"cell is %@",cell);

                if([cell isKindOfClass:NSClassFromString(@"SecKillNormalKillOnSellCell")]){

                    id killListModel = [cell data];

                    NSLog(@"--------------------data:%@",[killListModel wareId]);
                    //把字符串简析为数组
                    NSArray *readSkuId = [[itemInfo objectForKey:@"id"] componentsSeparatedByString:@","];

                    for(NSString  *objSkuid in readSkuId){
                        if([objSkuid isEqualToString:[killListModel wareId]]){
                            NSLog(@"is find this is wareId exist:%@, %d",[killListModel wareId],i);
                            findPos = i;
                            break;
                        }

                    }

                }//end if

            }//end for

            if(findPos != -1){

                NSLog(@"JDHK current is find exist!");

                write2File(@"/var/root/search/activityResult.txt", @"0");

                //点击
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:findPos inSection:0];
                [self tableView:[self tableView] didSelectRowAtIndexPath:indexPath];

            }else{
                NSLog(@"JDHK current is find no exist!");

                write2File(@"/var/root/search/activityResult.txt", @"1");
            }

        });
    });
}
%end


///////////量贩秒杀/////////////////////
%hook SSSGroupBuyingViewController

- (void)viewDidLoad{
    %orig;

    NSLog(@"JDHK 当前进入了，量贩秒杀");

    __block int findPos = -1;
    NSMutableDictionary *itemInfo = loadSearchItem();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:5.0f];

        dispatch_async(dispatch_get_main_queue(), ^{
            //得到列表有多少个
            int ccNum = [self tableView:[self groupBuyTableView] numberOfRowsInSection:0];

            //得到当前cell
            for(int i=1; i<ccNum; i++){

                id valueWareCell = [self tableView:[self groupBuyTableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];

                NSLog(@"cell is %@",valueWareCell);

//                NSString *modelName = [NSString stringWithUTF8String:class_getName([valueWareCell class])];
//                if([modelName isEqualToString:@"SSSSuperValueWareCell"]){
                if([valueWareCell isKindOfClass:NSClassFromString(@"SSSGroupSuperValueWareCell")]){

                    NSLog(@"--------------------%@",[[valueWareCell secModel] wareId]);
                    //把字符串简析为数组
                    NSArray *readSkuId = [[itemInfo objectForKey:@"id"] componentsSeparatedByString:@","];

                    for(NSString  *objSkuid in readSkuId){
                        if([objSkuid isEqualToString:[[valueWareCell secModel] wareId]]){
                            NSLog(@"is find this is wareId exist:%@, %d",[[valueWareCell secModel] wareId],i);
                            findPos = i;
                            break;
                        }
                        
                    }
                }
            }

            if(findPos != -1){
                
                NSLog(@"JDHK current is find exist!");

                write2File(@"/var/root/search/activityResult.txt", @"0");

//                [NSThread sleepForTimeInterval:5.0f];

                //            m_enterCount = -1;

                //点击
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:findPos inSection:0];
                [self tableView:[self groupBuyTableView] didSelectRowAtIndexPath:indexPath];

            }else{
                NSLog(@"JDHK current is find no exist!");
                
                write2File(@"/var/root/search/activityResult.txt", @"1");
                
                //            m_enterCount = -1;
            }


        });
    });


    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

}

%end

extern "C" UIImage * downloadImageWithCurl(NSString *url) {
    CURL *image = curl_easy_init();
    FILE *fp;
    CURLcode imgresult;
    fp = fopen("/var/root/search/image_tmp.jpg", "wb");
    if (image) {
        if( fp == NULL ) {
            NSLog(@"MYHOOK-curl image failed: %@", @"File cannot be opened");
            return nil;
        }
        curl_easy_setopt(image, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(image, CURLOPT_WRITEFUNCTION, NULL);
        curl_easy_setopt(image, CURLOPT_WRITEDATA, fp);

        imgresult = curl_easy_perform(image);
        if( imgresult ){
            NSLog(@"MYHOOK-curl Cannot grab the image!\n");
            return nil;
        }
    }

    curl_easy_cleanup(image);
    // Close the file
    if (!fp) fclose(fp);

    return [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:@"/var/root/search/image_tmp.jpg"]];
}


///////////////////京东评价///////////////////////
%hook ShareOrderBaseViewController
//存储图片
static NSMutableArray *photos = [[NSMutableArray alloc] init];
static NSMutableArray *imageList = [[NSMutableArray alloc] init];

%new
- (void)deletePhotos{
//    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc]init];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group,BOOL *stop){
//            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
//                if(asset.isEditable){
//                    [asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL,NSError *error){
//                        NSLog(@"Asset url %@ should be deleted. (Error %@)",assetURL,error);
//                    }];
//                }
//            }];
//        }];
//    });
}

// 获取服务器晒单图片
%new
- (UIImage *)loadImageFromSrv:(NSString *)imageUrl {
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    return img;
}

- (void)viewDidLoad{
    %orig;

    //开始下载图片

}

- (void)commitCommetInfo {

    write2File(@"/var/root/search/commiteResult.txt", @"1");

    NSMutableDictionary *commentInfo = loadComment();

    NSArray *array = [[commentInfo objectForKey:@"imags"] componentsSeparatedByString:@","];

    NSLog(@"MYHOOK array:%@ array count:%lu",array,(unsigned long)[array count]);
    //[title rangeOfString:@"search.jd.com/"].location != NSNotFound
    if([array count] > 0 && [[commentInfo objectForKey:@"imags"] rangeOfString:@"jpg"].location != NSNotFound){

        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];

        NSMutableArray *imageList = [[NSMutableArray alloc] init];
        for (NSString *imageURL in array) {
            UIImage *image = downloadImageWithCurl(imageURL);

            [imageList addObject:image];
        }

//        UIImage *image1 = downloadImageWithCurl(@"http://7sbkou.com2.z0.glb.clouddn.com/shaike_2c886b47a84a47699584e8b4cea861b0.jpg");
//        UIImage *image2 = downloadImageWithCurl(@"http://crobo-pic.qiniudn.com/nEO_IMG_IMG_7613.jpg");
//        UIImage *image3 = downloadImageWithCurl(@"http://crobo-pic.qiniudn.com/jrdp11%20(3).jpg");

        [[[self publishManager] wareModel] setPhotos:[[NSMutableArray alloc] init]];


        NSLog(@"MYHOOK-JD start block.");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < [imageList count]; i++) {
                [assetsLibrary writeImageToSavedPhotosAlbum:[imageList[i] CGImage] orientation:(ALAssetOrientation)[imageList[i] imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"Save image fail：%@",error);
                    }else{
                        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset )
                         {
                             ShareOrderImageViewCell *cell = [[NSClassFromString(@"ShareOrderImageViewCell") alloc] init];
                             ShareOrderAssetProduct *product = [[NSClassFromString(@"ShareOrderAssetProduct") alloc] initWithAsset:asset];
                             NSLog(@"MYHOOK_JD: %@, %@", asset, [product asset]);
                             [cell setProduct:product];
                             [photos addObject:cell];
                             [NSThread sleepForTimeInterval:0.1];
                         }
                                      failureBlock:^(NSError *error )
                         {
                             NSLog(@"Error loading asset");
                         }];
                    }
                }];
            }
        });

        [[[self headerView] textView] setText:[commentInfo objectForKey:@"comment"]];

        [self setCellsArray:photos];
        [self completeWareInfoModel];
        [[self wareInfoModel] setPhotos:photos];
        [[[self publishManager] wareModel] setPhotos:photos];
        NSLog(@"MYHOOK_JD: ---- %@, ### , %@", [[self wareInfoModel] photos], photos);
        if ([photos count]) {
            %orig;
            
            photos = [[NSMutableArray alloc] init];
        }

    }
    else{
        %orig;
    }
}

%end


/////////京东劫持开始 //////////////
%hook JDMainPageAppcenterCell
- (void)setupUI{
     // 京东超市 等图标
//    %orig;
}

%end

%hook JDMainPageCell
- (void)setupUI{
    %orig;
}
//- (void)willDisPlay;
%end

%hook  JDMainPageBannerCell

- (void)layoutSubviews{
    NSLog(@"HKJD JDMainPageBannerCell layoutSubviews");

}
- (void)setupUI{
    NSLog(@"HKJD JDMainPageBannerCell setupUI");

}

%end

%hook JDMainPageSeckillCell

- (void)setupUI{

    //掌上秒杀
    m_enterCount = 0;
    //TODO:判断是不是活动单
    //从配置文件中读取是电脑单  1.手机任务 2.PC任务 3.活动单
    NSMutableDictionary *equipment = loadEquipment();

    NSLog(@"select device info pc or phone %@",equipment);
    if((int)[[equipment objectForKey:@"type"] intValue] == 3){
        %orig;

        [self collectionView:[self collectionView] didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }

}

- (void)viewDidLoad{
    %orig;
}

NSInteger m_jump_activity_count = 0;

- (void)willDisPlay{
    %orig;

    NSLog(@"willDisPlay====================%ld",(long)m_jump_activity_count);

    //从配置文件中读取是电脑单  1.手机任务 2.PC任务 3.活动单
    NSMutableDictionary *equipment = loadEquipment();

    NSString *strData = [NSString stringWithContentsOfFile:@"/var/root/search/seckillGoods.txt" encoding:NSUTF8StringEncoding error:NULL];

    NSLog(@" strData :%@ select device info pc or phone %@ m_jump_activity_count:%ld",strData,equipment,(long)m_jump_activity_count);

    if([strData isEqualToString:@"1"]){

        if((int)[[equipment objectForKey:@"type"] intValue] == 3 && m_jump_activity_count == 0){

            m_jump_activity_count ++;
            //异步延时，等首页加载完毕
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                [NSThread sleepForTimeInterval:5.0f];

                dispatch_async(dispatch_get_main_queue(), ^{
                    // 点击秒杀
                    [self collectionView:[self collectionView] didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });
            });
        }

    }

}
- (void)updateContent{
    %orig;

    NSLog(@"updateContent====================");

}
%end

%hook  JDMainPageCycleScrollView
//- (void)layoutSubviews{
//    NSLog(@"HKJD JDMainPageCycleScrollView layoutSubviews");
//}

- (void)addSubviews{
    NSLog(@"HKJD JDMainPageCycleScrollView addSubviews");
}
%end

%hook JDMainPageAnnouceBarView
- (void)setupUI{
    NSLog(@"HKJD JDMainPageAnnouceBarView setupUI");

}
%end


%hook  JDMainPageNormalFloorCell
- (void)setupUI{

}
%end


//我的账号 为你推荐劫持
%hook NewRecommendCell
- (void)layoutSubviews{
    NSLog(@"NewRecommendCell layoutSubviews");
}
%end

//店铺劫持
%hook JDNativeShopTableCell
- (void)layoutSubviews{
    NSLog(@"JDNativeShopTableCell==============");
}

%end

%hook JDNativeShopFreeLayoutView
- (void)setupUI{
}
%end

//商品详情页劫持
%hook  WareIntroDetailView
- (void)setWithData:(id)arg1{
//    %orig;
}

%end

%hook WareBImageView
- (id)initWithFrame:(struct CGRect)arg1{
    return nil;
}

%end

//京东会员web
%hook JDWebView
- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [self stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"JDWebView(京东) document.location.href -------------%@ ",currentURl);
    //http://h5.m.jd.com/active/member/html/index.html?lng=0.000000&lat=0.000000&un_area=0_0_0_0&sid=03d9f6b88cb0ec301157ee94342cd4cw
    if([currentURl rangeOfString:@"active/member"].location != NSNotFound){

        //异步延时，等首页加载完毕
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            [NSThread sleepForTimeInterval:5.0f];

            dispatch_async(dispatch_get_main_queue(), ^{

                //得到星级
                NSString *script = [NSString stringWithFormat:@"$('#J_UserCard .u_log b.u_lv i').attr('class').replace('i i-uv uv', '');"];
                NSString *scriptResult = [self stringByEvaluatingJavaScriptFromString:script];

                NSLog(@"HKJD 当前的星级为：%@",scriptResult);

                write2File(@"/var/root/search/starLevel.txt", scriptResult);

            });
        });
        
    }

}

%end


/////////京东劫持结束//////////////

//启动页
%hook JDAdStartView
- (id)init{
//    存入1表示收菜
    NSString *strData = [NSString stringWithContentsOfFile:@"/var/root/search/openEvaluate.txt" encoding:NSUTF8StringEncoding error:NULL];

    NSLog(@"=============JDAdStartView= %@=============",strData);

    if([strData isEqualToString:@"1"]){
        return %orig;
    }
    else{
        return nil;
    }
}

%end


//首页红包弹框
%hook JDSHWebGameWebViewController
- (void)showWebView{

}

- (void)showWebViewPassthrough:(_Bool)arg1{
    NSLog(@"=============showWebViewPassthrough=============");

}

%end


//关闭更新框
%hook JDModalView
- (id)initWithFrame:(struct CGRect)arg1{
    NSLog(@"HKJD JDModalView(关闭更新框)");
    return nil;
}
%end

//关闭4s的更新框
%hook JDUpgradeView
- (id)initWithFrame:(struct CGRect)arg1{
    NSLog(@"HKJD JDUpgradeView(关闭4s的更新框)");
    return nil;
}
%end

//关闭新人大红包
%hook JDSHXViewController
- (void)setupWebView{
}
%end

//去掉轮播图
%hook StartAnimationView
- (id)initWithFrame:(struct CGRect)arg1{
    return nil;
}

%end












#import "hktaobao.h"


static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

TBSearchItemList *searchItemList = nil;
TBXSearchCollectionViewComponent *tbxSearchClVC = nil;

static BOOL findItem = NO;
static BOOL needStop = YES;
static BOOL isEvaluateText = NO;

NSInteger m_current_page = 0;

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


extern "C" NSString * openFileToString(NSString * fileName) {
        //    @autoreleasepool {
        // NSLog(@"TBHK file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
        NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
        return strData;
}

extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

extern "C" NSString * loadEvaluateImages() {
    return openFileToString(@SHIJACK_SERVER_EVALUATE_IMGS_FILE);
}

extern "C" NSMutableDictionary * loadConfig() {
	// NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:SEARCH_CONF_FILE];
	// return preferences;
	return openFile(@SEARCH_CONF_FILE);
}

extern "C" NSMutableDictionary * loadServerAddress() {
        return openFile(@SHIJACK_SERVER_ADDRESS_FINDPOSITION_FILE);
}


extern "C" NSMutableDictionary * loadSearchItem() {
    return openFile(@SEARCH_ITEM_FILE);
}

extern "C" NSMutableDictionary * loadShijackConfig() {
    return openFile(@SHIJACK_CONF_FILE);
}

extern "C" BOOL saveSearchResult(NSString *content) {
    return write2File(@SEARCH_RANK_PAGE_FILE, content);
}

extern "C" NSMutableDictionary * loadOrder() {
    return openFile(@ORDER_DETAIL_FILE);
}

extern "C" BOOL saveOrder(NSString *content) {
    write2File(@ORDER_DETAIL_FILE, content);
    return YES;
}

%hook  AppDelegate

- (void)applicationDidBecomeActive:(id)arg1{
    %orig;
    NSLog(@"TBHK applicationDidBecomeActive:---------------");

    //判断扫码开关是否开启
    NSMutableDictionary *config = loadShijackConfig();
    NSLog(@"TBHK find order 扫码 ---loadShijackConfig: %@", config);

    int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    if(isOpenScan == 0){
        [[NSClassFromString(@"WeAppHUOYANActionExecute") new] doOpenHuoYan];

    }
}

%end


%hook TBXSearchCollectionViewComponent

%new
- (void)alertFindTip:(NSString *)itemId {
    UIAlertController *alertController = [UIAlertController
                                                    alertControllerWithTitle:@"找到商品"
                                                    message:itemId
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
                                   findItem = NO;
                                   needStop = NO;
                                   [self collectionView:[self collectionView] didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                   
                               }];
    
    [alertController addAction:okAction];
    [[[[[UIApplication sharedApplication]delegate] window] rootViewController] presentViewController:alertController animated:NO completion:nil];
}

%new
- (void)alertNoFindTip:(NSString *)itemId {
    UIAlertController *failedAlertController = [UIAlertController
                                                    alertControllerWithTitle:@"没有找到商品"
                                                    message:itemId
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
                                   findItem = NO;
                                   needStop = NO; //
                               }];
    
    [failedAlertController addAction:okAction];
    [[[[[UIApplication sharedApplication]delegate] window] rootViewController] presentViewController:failedAlertController animated:NO completion:nil];
}

%new
- (BOOL) findTheOne {
    NSMutableDictionary *itemInfo = loadSearchItem();
    NSMutableDictionary *config = loadConfig();
    int maxPageNum = [[config objectForKey:@"maxPageNum"] intValue];
    // int hookEnable = [[config objectForKey:@"hookEnable"] intValue];
    int hookWay = [[config objectForKey:@"hookWay"] intValue];
    int currentPage = [searchItemList currentPage];
    NSLog(@"HKTB find target item: %d, %d, %@", currentPage, maxPageNum, findItem ? @"YES":@"NO");

    if (currentPage <= maxPageNum - 1) {
        if (findItem && (hookWay == 0 || hookWay == 1)) {
            [self alertFindTip:[itemInfo objectForKey:@"id"]];
            return NO;
        }
        return YES;
    } else {
        if (hookWay == 0 || hookWay == 1) {
            [self alertNoFindTip:[itemInfo objectForKey:@"id"]];
        }
        return NO;
    }
}

- (void)loadMoreData {
	%orig;
}

- (_Bool)hasMore {
    NSMutableDictionary *config = loadConfig();
    int hookEnable = [[config objectForKey:@"hookEnable"] intValue];
    int hookWay = [[config objectForKey:@"hookWay"] intValue];
    tbxSearchClVC = self;
	// NSLog(@"TBHK first cell info: %@", [self itemList][0]);
    if (hookEnable == 0 || hookEnable >= 3) {
        // NSLog(@"TBHK search main disable hook!");
        return %orig;
    } else {
        NSLog(@"TBHK itemheader is : %@", [self itemHeader]);
//        if ([self itemHeader]) {
//            NSMutableDictionary *itemInfo = loadSearchItem();
//            needStop = YES;
//            [self alertNoFindTip:[itemInfo objectForKey:@"id"]];
//        }
        if (hookWay != 2 && !needStop) {
            BOOL res = [self findTheOne];
            if (res) {
                [self loadMoreData];
            } 
            return res;
        } 
        BOOL res = %orig;
        NSLog(@"TBHK hasmore result: %@", res ? @"YES":@"NO");
        return res;
    }
    
}

%end


%hook TBSearchWapItem

- (void)setDidWaterFPicShow:(BOOL)t {
    %orig;
}
- (void)setDidListPicShow:(BOOL)t {
    %orig;
}
- (void)setPic_path:(NSString *)pic {
    %orig;
}
%end


%hook TBSearchItemList

- (id)init {
    searchItemList = %orig;
    findItem = NO;
    needStop = NO;
    return searchItemList;
}

- (void)addObjectsFromArray:(id)arg1 {
    // NSLog(@"TBSearchItemList ddObjectsFromArray: %d, %@", (int)[(NSArray *)arg1 count], arg1[0]);
    NSMutableDictionary *config = loadConfig();
    int hookEnable = [[config objectForKey:@"hookEnable"] intValue];
    int hookWay = [[config objectForKey:@"hookWay"] intValue];
    int interval = [[config objectForKey:@"searchInterval"] intValue];
	NSLog(@"TBHK search config: %i", hookEnable);
    if (hookEnable == 0 || hookEnable >= 3 || needStop) {
        NSLog(@"TBHK search main disable hook!");
        %orig;
    } else {
        NSMutableDictionary *itemInfo = loadSearchItem();
        if ([[itemInfo objectForKey:@"id"] isEqualToString:@""] || [itemInfo objectForKey:@"id"] == (id)[NSNull null]) {
            return;
        }

        __block TBSearchWapItem *myItem = nil;
        int count1 = [(NSArray *)arg1 count];

        NSLog(@"TBHK  -----------------arg1 count:%d",count1);

        if ((NSArray *)arg1 == nil || count1 <= 0) {
            
            NSLog(@"TBHK search nil: ------------------>>>>>>");
            needStop = YES;
            [tbxSearchClVC alertNoFindTip:[itemInfo objectForKey:@"id"]];

        } else {
            [arg1 enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
                NSLog(@"TBHK search wrap item type: %@, %@", [cell getBizType], [cell getUIType]);
                if([[cell getBizType] isEqualToString:@"auction"]){
                    if ([cell isKindOfClass:NSClassFromString(@"TBSearchResultItemTips")]) {
                        NSLog(@"TBHK TBSearchResultItemTips: %@", [cell title]);

                    }else if (![cell isKindOfClass:NSClassFromString(@"TBXSearchNXComponent")]) {
                        //查找宝贝
                        NSLog(@"TBHK: Main from id ==> %@, iconList:%@ title: %@,clickUrl:%@  %d, %@ ", [cell item_id], [cell iconList],[cell title],[cell clickUrl], (int)[self currentPage], [[cell item_id] isEqualToString:[itemInfo objectForKey:@"id"]] ? @"YES": @"NO");

                        if([[itemInfo objectForKey:@"dmIsTrainMust"] intValue] == 1){
                            if ([[cell item_id] isEqualToString:[itemInfo objectForKey:@"id"]] && [[cell clickUrl] rangeOfString:@"null"].location == NSNotFound) {
                                findItem = YES;
                                myItem = cell;
                            }
                        }else{
                            if ([[cell item_id] isEqualToString:[itemInfo objectForKey:@"id"]] && [[cell clickUrl] rangeOfString:@"null"].location != NSNotFound) {
                                findItem = YES;
                                myItem = cell;
                            }
                        }

                    }  else {
                        NSLog(@"TBHK: search setatus: %@", [cell status]);
                    }
                }
            }];
            int count = [(NSArray *)arg1 count];
            id one = findItem ? myItem:[(NSArray *)arg1 objectAtIndex:0];
            if (count) {
                [NSThread sleepForTimeInterval:interval];
                if (hookWay == 1) {
                    if (![one isKindOfClass:NSClassFromString(@"TBXSearchNXComponent")]) {
                    }               
                    if ([[self realItemList] count]) {
                        [[self realItemList] replaceObjectAtIndex:0 withObject:one];
                    } else {
                        [[self realItemList] addObject:one];
                    }
                } else {
                    %orig;
                    if ([[self realItemList] count]) {
                        [[self realItemList] replaceObjectAtIndex:0 withObject:one];
                    } else {
                        [[self realItemList] addObject:one];
                    }
                }
            } else {
                %orig;
            }
        }
        
        
    } 
}

- (void)addObject:(id)arg1 {
    NSLog(@"TBSearchItemList addObject:%@", arg1);
    %orig;
}

- (BOOL)hasMore {
    %orig; 
    return !findItem && !needStop;
}

%end


%hook TBOrderDetailViewController

- (void)requestSuccessWithResult:(id)arg1 {
    %orig;
    NSMutableArray *models = [[self dataSource] dataArray];

    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSArray *modelNameList = @[@"TBOrderAddressModel", @"TBOrderInfoModel", @"TBOrderPayDetailModel", @"TBOrderSellerModel", @"TBOrderSubModel", @"TBOrderMemoModel",@"TBOrderPayDetailV2Model"];
    NSMutableArray *extraItems = [NSMutableArray arrayWithCapacity:3];
    
    __block BOOL isFirst = NO;
    for (id model in models) {
        
        NSString *modelName = [NSString stringWithUTF8String:class_getName([model class])];
        NSLog(@"TBHK - ORDER HOOK model class: %@, %@", model, modelName);
        int pos = [modelNameList indexOfObject:modelName];
        if (pos == 0) {
            // NSLog(@"TBHK find class: %@", [modelNameList objectAtIndex:pos]);
            TBOrderAddressModel *addressModel = (TBOrderAddressModel *)model;
            NSMutableDictionary *addressInfo = [[[addressModel address] data] objectForKey:@"fields"];
            resultDic[@"buyer"] = addressInfo[@"name"];
            resultDic[@"mobilephone"] = addressInfo[@"mobilephone"];
            resultDic[@"buyerAddress"] = addressInfo[@"value"];
        } else if (pos == 1){
            // NSLog(@"TBHK find class: %@", [modelNameList objectAtIndex:pos]);
            TBOrderInfoModel *infoModel = (TBOrderInfoModel *)model;
            // NSLog(@"TBHK find orderInfo: %@", [[infoModel storage] fields]);
            resultDic[@"itemIds"] = [[[infoModel storage] fields][@"subAuctionIds"] componentsJoinedByString:@","];
            NSMutableArray *labels = [[[infoModel orderInfo] fields] objectForKey:@"labels"];
            [labels enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"name"] isEqualToString:@"支付宝交易号:"]) {
                    resultDic[@"aliPayId"] = obj[@"value"];
                }
                if ([obj[@"name"] isEqualToString:@"创建时间:"]) {
                    resultDic[@"createTime"] = obj[@"value"];
                }
            }];
        } else if (pos == 2) {
            // NSLog(@"TBHK find class: %@", [modelNameList objectAtIndex:pos]);
            TBOrderPayDetailModel * payDetailModel = (TBOrderPayDetailModel *)model;
            NSMutableDictionary *payDetailInfo = [[[payDetailModel payDetail] data] objectForKey:@"fields"];
            resultDic[@"actualFee"] = payDetailInfo[@"actualFee"][@"value"];
            resultDic[@"postFee"] = payDetailInfo[@"postFee"][@"value"];
        }else if (pos == 3) {
            // NSLog(@"TBHK find class: %@", [modelNameList objectAtIndex:pos]);
            TBOrderSellerModel *sellerModel = (TBOrderSellerModel *)model;
            NSMutableDictionary *seller = [[[sellerModel seller] data] objectForKey:@"fields"];
            
            resultDic[@"sellerId"] = seller[@"id"];
            resultDic[@"sellerNick"] = seller[@"nick"];
            resultDic[@"sellerShopName"] = seller[@"shopName"];
            resultDic[@"sellerImg"] = seller[@"shopeImg"];
            
        } else if (pos == 4) {
            
            //  NSLog(@"TBHK find class: %@", [modelNameList objectAtIndex:pos]);
            TBOrderSubModel *subModel = (TBOrderSubModel *)model;
            NSMutableDictionary *subInfo = [[[subModel item] data] objectForKey:@"fields"];
            // NSLog(@"TBHK find subInfo: %@", subInfo);
            if  (!isFirst) {
                resultDic[@"itemPricePromotion"] = subInfo[@"priceInfo"][@"promotion"];
                resultDic[@"itemPriceOriginal"] = subInfo[@"priceInfo"][@"original"];
                resultDic[@"itemQuantity"] = subInfo[@"quantity"];
                resultDic[@"itemSkuText"] = subInfo[@"skuText"];
                resultDic[@"itemName"] = subInfo[@"title"];
                resultDic[@"mainOrderId"] = [subModel mainOrderId];
                resultDic[@"itempic"] = subInfo[@"pic"];
            } else {
                [extraItems addObject:subInfo];
            }
            
            
            isFirst = YES;
        } else if (pos == 5) {
            TBOrderMemoModel *memoModel = (TBOrderMemoModel *)model;
            NSMutableDictionary *memoInfo = [[memoModel memo] fields];
            if ([memoInfo[@"title"] isEqualToString:@"买家留言"]) {
                resultDic[@"memo"] = memoInfo[@"content"];
            }
            
        }else if(pos == 6){

            TBOrderPayDetailV2Model* payDetailModel = (TBOrderPayDetailV2Model *)model;
            NSArray *payDetails = [[payDetailModel payDetailV2] payDetails];

            NSLog(@"===========%@",payDetails);

            for(int i=0; i<[payDetails count]; i++){
                TBOrderLabelInfo *labelInfo = payDetails[i];

                NSLog(@"name:%@ value:%@",[labelInfo name],[labelInfo value]);

                if([[labelInfo name] isEqualToString:@"需付款"]){
                    resultDic[@"actualFee"] = [labelInfo value];
                }

            }

//            NSMutableDictionary *payDetailInfo = [[[payDetailModel payDetailV2] data] objectForKey:@"fields"];

//            NSMutableDictionary *payDetails = [payDetailInfo objectForKey:@"payDetails"];


//            NSLog(@"111%@",payDetails);

//            NSLog(@"222%@",[payDetails objectForKey:@"value" ]);
        }
    }
    if ([extraItems count]) {
        resultDic[@"extraItems"] = extraItems;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    write2File(@ORDER_DETAIL_FILE, jsonString);
    NSLog(@"TBHK find order result: %@", jsonString);

    //TODO:读取配置文件
    NSMutableDictionary *config = loadShijackConfig();
    NSLog(@"TBHK find order 扫码 ---loadShijackConfig: %@", config);

    int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    if(isOpenScan == 0){
        [[NSClassFromString(@"WeAppHUOYANActionExecute") new] doOpenHuoYan];

    }
}



- (void)reloadData{

    %orig;
    NSLog(@"TBHK find reloadData:--------");

    NSMutableDictionary *config = loadShijackConfig();
    int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    if(isOpenScan == 0){
    [[NSClassFromString(@"WeAppHUOYANActionExecute") new] doOpenHuoYan];
    }
}

- (void)viewWillAppear:(BOOL)arg1{
    %orig;
    NSLog(@"TBHK find viewWillAppear:--------");

    //到详情页要获取button按钮
    isEvaluateText = YES;
}

- (void)viewDidLoad{
     %orig;
}
- (void)viewWillDisappear:(BOOL)arg1{
    %orig;
    NSLog(@"TBHK find xviewWillDisappear:--------");
}

%end




///////////////////////////////////////////////////////////////////////////////
//// Sku
///////////////////////////////////////////////////////////////////////////////
///
///

void doAlert(id self, BOOL state) {

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle: state ? @"型号类型选择成功" : @"型号选择失败"
                                          message:state ? @"点击弹窗确认自动下单" : @""
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:state ?[UIColor blueColor]:[UIColor redColor]];

    alertContentView.layer.cornerRadius = 5;

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"确认", @"Ok action")
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   if (state) {
                                       [self triggerBuyBtn:[self rightBtn]];
                                   }
                                   //                                               [props release];
                               }];

    [alertController addAction:okAction];
    NSLog(@"TBHK in alertCTl");
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated: NO completion: nil];
}

%hook AliTradeSKUView

- (void)layoutSubviews {
    %orig;
    NSMutableDictionary *config = loadConfig();
    int hookEnable = (int)[[config objectForKey:@"hookEnable"] intValue];
    int autoOrder = (int)[[config objectForKey:@"autoOrder"] intValue];
    int autoOrderType = (int)[[config objectForKey:@"autoOrderType"] intValue];
    if (hookEnable == 0 || hookEnable >= 3 || autoOrder == 0) {
        NSLog(@"TBHK search main disable hook!: %d, %d", hookEnable, autoOrder);
        return;
    } else {
        NSMutableDictionary *itemInfo = loadSearchItem();
        if (![[itemInfo objectForKey:@"id"] isEqualToString:[[[self detailModel] item] itemId] ]) {
            return;
        }

        __block NSString *target = [config objectForKey:@"autoOrderProps"];
        NSMutableArray *finds = [[NSMutableArray alloc] init];
        AliTradeSKUSelectionControl *ctl = nil;
        NSLog(@"TBHK ok skuid::::::: targ: %@", target);
        __block NSArray *props = [[NSArray alloc] init];
        BOOL isFind = NO;
        int selectedCtrl = -1;
        for (int i = 0; i < [[[self skuContainer] subviews] count]; i++) {
            NSLog(@"TBHK ok ---------------- first");

            if ([self.skuContainer.subviews[i] isKindOfClass:NSClassFromString(@"AliTradeSKUSelectionControl")]) {
                ctl = (AliTradeSKUSelectionControl *)self.skuContainer.subviews[i];
                selectedCtrl = i;
                if (autoOrderType == 0){
                    props = (NSArray *)target;
                    for (int j = 0; j < [[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] count]; j++) {
                        isFind = NO;

                        for (int m = 0; m < [[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] count]; m++) {

                            for (int n = 0; n < [props count]; n++) {
                                NSLog(@"TBHK iter name: %@ for prop: %@: state: %llu", props[n], [[[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] titleLabel] text],
                                      [[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] getCurrentState]);
                                BOOL ok = [[props objectAtIndex:n] isEqualToString:[[[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] titleLabel] text]];
                                if (ok) {
                                    if ([[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] getCurrentState] == 532575944708) {
                                        [finds addObject:@"YES"];
                                        isFind = YES;
                                        break;
                                    } else
                                        if ([[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] getCurrentState] == 532575944702) {
                                            isFind = NO;
                                            break;
                                        } else if ([[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m] getCurrentState] == 532575944704){
                                            [[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] propButtonClicked:[[[[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] propertySelectControls] objectAtIndex:j] buttons] objectAtIndex:m]];
                                            [finds addObject:@"YES"];
                                            NSLog(@"TBHK ########### FIND prop: %@ ################ ", [props objectAtIndex:n]);
                                            isFind = YES;
                                            break;
                                        }

                                }
                                if (isFind) {
                                    break;
                                }
                            }
                            if (isFind) {
                                break;
                            }
                        }

                    }
                } else {
                    //                    NSString *propPath = [props componentsJoinedByString:@";"];
                    __block NSString *propPath = @"";
                    __block NSString *skuId = @"";
                    [[[[self detailModel] skuBase] skus] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                        AliDetailSkuPropPathModel *ppath = (AliDetailSkuPropPathModel *)obj;
                        NSLog(@"TBHK to find skuId: %@ ==> %@, %@, %d", target, [ppath skuId], [[ppath skuId] isEqualToString:target] ? @"YES": @"NO", (int)[[[[self detailModel] skuBase] skus] count] );
                        if ([[ppath skuId] isEqualToString:target]) {
                            skuId = [ppath skuId];
                            propPath = [ppath propPath];
                            NSLog(@"TBHK find skuId: %@, propPath: %@", skuId, propPath);
                            *stop = YES;
                        }
                    }];
                    if (![skuId isEqualToString:@""]) {
                        [[[[self detailModel] skuBase] props] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                            NSLog(@"TBHK find our skuProps size: %d", (int)[[[[self detailModel] skuBase] props] count]);
                            AliDetailSkuPropsModel *ppm = (AliDetailSkuPropsModel *)obj;
                            props = [propPath componentsSeparatedByString:@";"];
                            for (int m = 0; m < [props count]; m++){
                                int len = (int)[[ppm values] count];
                                NSLog(@"TBHK find per real props: size: %d, %d, %@", (int)[props count], len, [ppm values]);
                                NSArray *propIds = [props[m] componentsSeparatedByString:@":"];
                                NSLog(@"TBHK find props id: %@, %@", [ppm pid], propIds);
                                if ([[ppm pid] isEqualToString:propIds[0]]) {
                                    for (int n = 0; n < len; n++) {
                                        TBDetailUIButton *btn = [[(AliTradeSKUSelectionControl *)self.skuContainer.subviews[selectedCtrl] propertySelectControls][idx] buttons][n];
                                        NSLog(@"TBHK AliTradeSKUSelectionControl: %@, %@, %@", (AliTradeSKUSelectionControl *)self.skuContainer.subviews[selectedCtrl],
                                              [(AliTradeSKUSelectionControl *)self.skuContainer.subviews[selectedCtrl] propertySelectControls],
                                              [[btn titleLabel] text]
                                              );
                                        // if (![(AliTradeSKUSelectionControl *)self.skuContainer.subviews[i] isKindOfClass:@"AliTradeSKUSelectionControl"]) {
                                        //     continue;
                                        // }
                                        if ([[[ppm values][n] name] isEqualToString:[[btn titleLabel] text]] && [[[ppm values][n] vid] isEqualToString:propIds[1]]) {
                                            NSLog(@"TBHK btn state: %llu", [btn getCurrentState]);
                                            if ([btn getCurrentState] % 10 == 4) {
                                                NSLog(@"TBHK find ====> ##### propsIds: %@, %@", [[ppm values][n] name], propIds[1]);
                                                [[self.skuContainer.subviews[selectedCtrl] propertySelectControls][idx] propButtonClicked:btn];
                                                [finds addObject:@"Y"];
                                                NSLog(@"TBHK after trigger btn: finds added");
                                            } else if ([btn getCurrentState] % 10 == 8){
                                                [finds addObject:@"Y"];
                                            } else if ([btn getCurrentState] % 2 == 2) {

                                            }
                                            break;
                                        }
                                    }
                                }
                            }
                        }];

                    }
                }
            }
        }
        NSLog(@"TBHK before compare: finds: %lu, props: %lu", (unsigned long) [finds count], (unsigned long)[[[[self detailModel] skuBase] props] count]);
        int right = (int)[[[[self detailModel] skuBase] props] count];
        int left = (int)[finds count];
        if (left == right) {
            NSLog(@"TBHK before CTL");
            //            if (ctl and [[ctl propertySelectControls] count] == [finds count]) {
            doAlert(self, YES);
            //                [alertController release];
            //            }
        } else {
            doAlert(self, NO);
        }
    }
}


%end


//存储在 "确认订单" 校验skuid
%hook TBExtBuyItemInfoCell

- (void)layoutSubviews{
    %orig;

    //保存skuid
    NSLog(@"TBHK itemId:%@ -------------skuId:%@",[[[self model] itemModel] itemId],[[[self model] itemModel] skuId]);

    write2File(@"/var/root/search/skuId.txt", [[[self model] itemModel] skuId]);

}

%end // end hook


///////////////////////发货地////////////////////
%hook TBXSearchXFilterLocationComponent
- (void)expandButtonClicked:(id)arg1{
    %orig;

    NSLog(@"TBHK TBXSearchXFilterLocationComponent arg1:%@",arg1);
}
- (void)componentInitWithService:(id)arg1{
    %orig;

    NSLog(@"TBHK TBXSearchXFilterLocationComponent arg1:%@",arg1);

    dispatch_group_async(group, queue, ^{
        
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self expandButtonClicked:[self reLocationButton]];

        });
    });
    
}
%end


///////////////////////////假聊////////////////////
%hook TBIMCommonChatViewController
- (void)SessionChange:(id)arg1{
    NSLog(@"TBHK---------count: %lu  ------ list: %@   --------- arg1:%@",(unsigned long)[[self list] count],[self list], arg1);
    NSString* startString =@"";
    NSString *chatCount = [NSString stringWithFormat:@"%lu",(unsigned long)[[self list] count]];
    for (id mode in [self list]){
        TBIMMessageWangxin *msg  = (TBIMMessageWangxin*) mode;
        NSString* string1=[NSString stringWithFormat:@"%@",[[msg data] receiverId]];
        NSString *string2=[NSString stringWithFormat:@"%@",[[msg data] content]];
        NSString* string =[NSString stringWithFormat:@"%@:%@", string1, string2 ];
        startString=[NSString stringWithFormat:@"%@\n%@", startString, string ];
    }
    write2File(@"/var/root/search/chatMsgContent.txt", startString);
    NSLog(@"TBHK ----%@ --------",startString);
    //假聊语句
    write2File(@"/var/root/search/chatMsg.txt",chatCount);
}


%end // end hook



//////////////////淘宝评价开始/////////////////
%hook TBOUGCPublisherViewController
- (void)viewDidLoad{
    %orig;

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *list = loadEvaluateImages();
            
            if(![list isEqualToString:@""]){
                NSArray *listItems = [list componentsSeparatedByString:@","];

                NSMutableArray *tbpList = [[NSMutableArray alloc] init];
                int myCount=0;
                for(id item in listItems){
                    NSString *imgsUrl=( NSString *)item;
                    NSLog(@"TBHK - ORDER HOOK ----commitCommetInfo2-----%@:",imgsUrl);
                    NSURL *url = [NSURL URLWithString:imgsUrl];
                    myCount++;
                    NSString *filePath = [NSString stringWithFormat:@"/var/root/search/%d.jpg",myCount];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    NSLog(@"HKTAOBAO ok image data saved, will create UIImage2.");
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    [UIImageJPEGRepresentation(img, 1.0) writeToFile:filePath atomically:YES];
                    TBPhotoObject *tbp = [[NSClassFromString(@"TBPhotoObject") alloc] init];
                    tbp.image = img;
                    tbp.assetUrl = filePath;
                    tbp.localPath = filePath;
                    tbp.thumbnail = img;
                    tbp.thumbPath = filePath;
                    tbp.isNewPhoto = YES;
                    [tbpList addObject:tbp];
                }

                for (int i = 0; i < [[self components] count]; i++) {
                    id imageComponent = [self components][i];
                    if ([imageComponent isKindOfClass:[NSClassFromString(@"TBOUGCImageComponent") class]]) {
                        [[self components][i] addPthotos:tbpList];
                    }
                }
            }

        });
    });


}
%end

//追评
%hook TBAppendRatePublishViewController
- (void)addPhotoToUploadPhotos:(id)arg1 component:(id)arg2  {
    NSLog(@"HKTAOBAO addPhotoToUploadPhotos: %@, %@", arg1, arg2);
    %orig;
}

- (void)doRateItem {
    NSString *list = loadEvaluateImages();
    if(![list isEqualToString:@""]){
        NSArray *listItems = [list componentsSeparatedByString:@","];
        int myCount=0;
        NSMutableArray *tbpList = [[NSMutableArray alloc] init];
        for(id item in listItems){
            NSString *imgsUrl=( NSString *)item;
            NSLog(@"TBHK - ORDER HOOK ----commitCommetInfo-----%@:",imgsUrl);
            NSURL *url = [NSURL URLWithString:imgsUrl];
            myCount++;
            NSString *filePath = [NSString stringWithFormat:@"/var/root/search/%d.jpg",myCount];
            NSData *data = [NSData dataWithContentsOfURL:url];

            NSLog(@"HKTAOBAO ok image data saved, will create UIImage.");
            UIImage *img = [[UIImage alloc] initWithData:data];
            [UIImageJPEGRepresentation(img, 1.0) writeToFile:filePath atomically:YES];
            TBPhotoObject *tbp = [[NSClassFromString(@"TBPhotoObject") alloc] init];
            tbp.image = img;
            tbp.assetUrl = filePath;
            tbp.localPath = filePath;
            tbp.thumbnail = img;
            tbp.thumbPath = filePath;
            tbp.isNewPhoto = YES;
            [tbpList addObject:tbp];
        }
        //if (![[[[self appendOrderComponent] appendRateList][0] uploadPhotos] count]) {
        [self addPhotoToUploadPhotos:tbpList component:[[self appendOrderComponent] appendRateList][0]];
        //}
    }
    NSLog(@"HKTAOBAO doRateItem");
    %orig;
}

%end


%hook TBRatePublishViewController

- (void)addPhotoToUploadPhotos:(id)arg1 component:(id)arg2 {
    NSLog(@"HKTAOBAO addPhotoToUploadPhotos: %@, %@", arg1, arg2);
    %orig;
}

- (void)uploadPicAction:(id)arg1 completion:(id)arg2 progress:(id)arg3 {
    NSLog(@"HKTAOBAO uploadPicAction: %@, %@, %@", arg1, arg2, arg3);
    %orig;
}

- (void)addPhoto:(long long)arg1 {
    NSLog(@"HKTAOBAO addPhoto: %lld", arg1);
    %orig;
}

- (void)viewDidLoad {
    %orig;

}

- (void)doRateItem {
    NSString *list = loadEvaluateImages();
    NSLog(@"TBHK - ORDER HOOK %@",list);

    if(![list isEqualToString:@""]){
        NSArray *listItems = [list componentsSeparatedByString:@","];

        NSMutableArray *tbpList = [[NSMutableArray alloc] init];
        int myCount=0;
        for(id item in listItems){
            NSString *imgsUrl=( NSString *)item;
            NSLog(@"TBHK - ORDER HOOK ----commitCommetInfo2-----%@:",imgsUrl);
            NSURL *url = [NSURL URLWithString:imgsUrl];
            myCount++;
            NSString *filePath = [NSString stringWithFormat:@"/var/root/search/%d.jpg",myCount];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSLog(@"HKTAOBAO ok image data saved, will create UIImage2.");
            UIImage *img = [[UIImage alloc] initWithData:data];
            [UIImageJPEGRepresentation(img, 1.0) writeToFile:filePath atomically:YES];
            TBPhotoObject *tbp = [[NSClassFromString(@"TBPhotoObject") alloc] init];
            tbp.image = img;
            tbp.assetUrl = filePath;
            tbp.localPath = filePath;
            tbp.thumbnail = img;
            tbp.thumbPath = filePath;
            tbp.isNewPhoto = YES;
            [tbpList addObject:tbp];
        }
        //if (![[[[[self orderRateInfoComponent] auctionComponents][0] auctionInfo] uploadPhotos] count]) {
        [self addPhotoToUploadPhotos:tbpList component:[[self orderRateInfoComponent] auctionComponents][0]];
        //}
    }

    NSLog(@"HKTAOBAO doRateItem2");
    %orig;
}
%end


%hook TBRateMainRateCell

- (void)setComponent:(id)arg1{

    NSString *feedback=[arg1 rateText];
    NSLog(@"HKTAOBAO TBRateMainRateCell=====%@:",feedback);
    //保存文件
//    saveEvaluate(feedback);
    write2File(@SHIJACK_EVALUATE_FILE, feedback);

    %orig;

}

%end

//得到按钮的次数;

%hook  TBOrderOperationBar
//- (id)init{
//    id ret = %orig;
//
////    NSLog(@"TBHK 当前buttons %@",[self buttons]);
//    if(isEvaluateText){
//        dispatch_group_async(group, queue, ^{
//
//            [NSThread sleepForTimeInterval:5];
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                if([[self buttons] count] != 0 && isEvaluateText) {
//                    for (UIButton * button in [self buttons]) {
//                        
//                        if([button.titleLabel.text isEqualToString:@"评价"] || [button.titleLabel.text isEqualToString:@"追加评价"] || [button.titleLabel.text isEqualToString:@"确认收货"]){
//
//                            isEvaluateText = NO;
//
//                        }
//
//                        NSLog(@"TBHK 评价button的标题:%@",button.titleLabel.text);
//                        //                m_button_text = [NSString stringWithFormat:@"%@,%@",m_button_text,button.titleLabel.text];
//                    }
//                }
//
//            });
//            
//        });
//    }
//
//    return ret;
//}

%end


//////////////////我的淘宝开始////////////////////////
%hook  TBMyTaobaoMainViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"TBHK 我的淘宝名字为:%@",[[[self personalInfoView] data] userName]);

    //存文件名
    write2File(@"/var/root/search/wangwangFile.txt", [[[self personalInfoView] data] userName]);
}

%end

%hook  aluLoginBox
- (void)layoutSubviews{
    NSLog(@"aluLoginBox-----");
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"TBHK 我的淘宝名字为:%@",[self getLoginId]);
        });

    });
}
%end
//////////////////我的淘宝结束////////////////////////


/////////////////////////淘抢购开始/////////////////////

%hook TBQGBatchTableView

%end



////////////////扫码开始///////////////
%hook huoyanBridgeViewController

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
    NSLog(@"TBHK view did Apear");

    //TODO:读取配置文件
    NSMutableDictionary *config = loadShijackConfig();
    int isOpenScan = (int)[[config objectForKey:@"isOpenScan"] intValue];
    NSLog(@"TBHK scan :config %@", config);
    if(isOpenScan == 0){
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
                      NSLog(@"TBHK image found: %@", latestPhoto);

                      NSMutableDictionary *arg1 = [[NSMutableDictionary alloc] init];
                      arg1[@"UIImagePickerControllerMediaType"] = @"public.image";
                      arg1[@"UIImagePickerControllerOriginalImage"] = latestPhoto;
                      [self imagePickerController:[[UIImagePickerController alloc] init] didFinishPickingMediaWithInfo:arg1];
                      *innerStop = YES;
                      [self showLocalPhotoResult];
                  }
              }];
         }
                             failureBlock: ^(NSError *error)
         {
             // an error has occurred
         }];

    }
}

- (void)scanUIImage:(id)arg1 {
    NSLog(@"TBHK scan image: %@", arg1);
    %orig;
}

- (void)viewDidLoad {
    %orig;
    NSLog(@"TBHK view loaded");
    
}

%end // end hook
///////////////扫码结束////////////////////////////////

/////////////////////点击删除弹出红包框//////////////////
%hook  TBHomeFloatHtmlView
- (id)initWithFrame:(struct CGRect)arg1{
    id ret = %orig;

    NSLog(@"TBHK TBHomeFloatHtmlView(点击删除弹出红包)");
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self closedPopCtrl:@"1"];
        });
        
    });

    return ret;
}

%end

//////////////////////点击新人礼包弹出框//////////////////
%hook  JHSFloatingLayer
 - (id)initWithConfiguration:(id)arg1{
    id ret = %orig;

    NSLog(@"TBHK JHSFloatingLayer(点击新人礼包弹出框)");

    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self closeButtonIsClicked:[self closeButton]];
        });

    });
    
    return ret;
}
%end



///////////////webView网页类开始//////////////////

%hook  WVCommonWebView

- (void)webViewDidFinishLoad:(id)arg1{

    %orig;
    NSLog(@"WVCommonWebView webViewDidFinishLoad%@ ",arg1);


    NSString *jsCode = @"document.location.href";

    NSString *currentURl = [arg1 stringByEvaluatingJavaScriptFromString:jsCode];

    NSLog(@"document.location.href currentURl:%@",currentURl);

    NSMutableDictionary *itemInfo = loadSearchItem();

    //    [arg1 stringByEvaluatingJavaScriptFromString:@"alert('WVCommonWebView');"];
    if([currentURl rangeOfString:@"/tjb/"].location != NSNotFound){
        //淘金币
        //https://h5.m.taobao.com/app/tjb/www/index3.html?locate=icon-8&spm=a2141.1.icons.8&scm=2019.1.2.1004&ttid=700407@taobao_iphone_6.0.0
        NSLog(@"HKTBNEW 进入了淘金币");

        //        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/tb_tjb.js?t='+Date.parse(new Date());document.body.appendChild(script);"];

        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/tb_tjb.js?t='+Date.parse(new Date());script.setAttribute(\"skuId\", \"%@\");script.id = \"tb_tjb\";document.body.appendChild(script);",[itemInfo objectForKey:@"id"]];

        [arg1 stringByEvaluatingJavaScriptFromString:script];

    }else if([currentURl rangeOfString:@"/tejia/"].location != NSNotFound){
        //天天特价
        //https://h5.m.taobao.com/app/tejia/www/index/index.html?scm=2019.4.1.5&itemId=535007812728&spm=a2141.1.specialcard1.5&locate=SpecialCard1-5&ttid=700407@taobao_iphone_6.0.0
        NSLog(@"HKTBNEW 进入天天特价");

        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/tb_tejia.js?t='+Date.parse(new Date());script.setAttribute(\"skuId\", \"%@\");script.id = \"tb_tejia\";document.body.appendChild(script);",[itemInfo objectForKey:@"id"]];

        [arg1 stringByEvaluatingJavaScriptFromString:script];


    }else if([currentURl rangeOfString:@"/quality/"].location != NSNotFound){
        //中国制造
        //https://h5.m.taobao.com/app/quality/www/portal/index.html?scm=2019.4.1.1200&itemId=525496114967&spm=a2141.1.specialcard3.5&locate=SpecialCard3-5&ttid=700407@taobao_iphone_6.0.0
        NSLog(@"HKTBNEW 中国制造");

        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/tb_quality.js?t='+Date.parse(new Date());script.setAttribute(\"skuId\", \"%@\");script.id = \"tb_tejia\";document.body.appendChild(script);",[itemInfo objectForKey:@"id"]];

        [arg1 stringByEvaluatingJavaScriptFromString:script];

    }else if([currentURl rangeOfString:@"detail.m.tmall.com/templates/"].location != NSNotFound){
        //车载类
        //得到型号ID
        NSMutableDictionary *config = loadConfig();

        NSLog(@"HKTBNEW 车载类 选择型号 %@",config);

        //http://detail.m.tmall.com/templates/pages/miniBuy?appLogin=true&from=taobao&id=531810934800
        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/tb_miniBuyVehicle.js?t='+Date.parse(new Date());script.setAttribute(\"skuId\", \"%@\");script.id = \"tb_miniBuyVehicle\";document.body.appendChild(script);",[config objectForKey:@"autoOrderProps"]];

        [arg1 stringByEvaluatingJavaScriptFromString:script];

    }
        else if([currentURl rangeOfString:@"/shop_collect_list_n"].location != NSNotFound && m_current_page==0){

        NSLog(@"HKTB (当前页面是店铺收藏页面)");

        m_current_page = 1;

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];
            dispatch_async(dispatch_get_main_queue(), ^{


                NSLog(@"HKTB (当前注入js)");

                NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/taobao_shop_collect.js?t='+Date.parse(new Date());document.body.appendChild(script);"];



                [self stringByEvaluatingJavaScriptFromString:script];

            });
            
        });


    }else if([currentURl rangeOfString:@"/item_collect_n"].location != NSNotFound && m_current_page==0){
        NSLog(@"HKTB (当前页面是宝贝页面)");

        m_current_page = 1;

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];
            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKTB (当前注入js)");

                NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/taobao_shop_collect.js?t='+Date.parse(new Date());document.body.appendChild(script);"];

                [self stringByEvaluatingJavaScriptFromString:script];
            });
            
        });
    }

}

- (void)webViewDidStartLoad:(id)arg1{
    %orig;
    NSLog(@"WVCommonWebView webViewDidStartLoad%@",arg1);
    
}

%end

///////////////webView网页类结束//////////////////


///////////////app 劫持开始//////////////////

%hook TBHomeViewController

- (void)displayHomeMainContent{
    //NSLog(@"TBHK - ORDER HOOK ----TBHomeViewController----------displayHomeMainContent--------");
//    %orig;
}

%end

%hook TBHomePageNoticeView
- (void)configView{
    %orig;
    //NSLog(@"TBHK - ORDER HOOK TBHomePageNoticeView:--------configView--------------");
}
%end

%hook TBHomePageFirstBannerView
- (void)didScrollPage:(id)arg1 atIndex:(long long)arg2{
    %orig;
    // NSLog(@"TBHK - ORDER HOOK TBHomePageFirstBannerView:  %@", arg1);
}

%end

%hook  TBCycleScrollView
- (void)loadData{
    // NSLog(@"TBHK - ORDER HOOK TBCycleScrollView:---------------loadData--------");
     %orig;
}
- (void)reloadData{
    // NSLog(@"TBHK - ORDER HOOK TBCycleScrollView:-----------reloadData------------");
     %orig;
}
%end

%hook  TBNewMemberFirstPayView
- (void)scrollViewDidScroll:(id)arg1{
    // NSLog(@"TBHK - ORDER HOOK TBNewMemberFirstPayView:-----------scrollViewDidScroll------------");
     %orig;
}

- (void)configViews{
    //  NSLog(@"TBHK - ORDER HOOK TBNewMemberFirstPayView:-----------configViews------------");
    %orig;
}

%end


%hook TBHomeGridView
- (void)reloadData{
    // NSLog(@"TBHK - ORDER HOOK TBHomeGridView:-----------reloadData------------");
    %orig;
}
%end

//淘宝头条
%hook TTViewProxy
//- (id)initWithFrame:(struct CGRect)arg1{
//    return nil;
//}
%end


%hook TBViewController
- (void)viewDidLoad{
    //  NSLog(@"TBHK - ORDER HOOK TBViewController:-----------viewDidLoad------------");
    %orig;
}
- (void)presentModalViewController:(id)arg1 animated:(BOOL)arg2{
    //         NSLog(@"TBHK - ORDER HOOK TBViewController:-----------presentModalViewController------------");
    %orig;

}
- (void)dismissModalViewControllerAnimated:(BOOL)arg1{
    // NSLog(@"TBHK - ORDER HOOK TBViewController:-----------dismissModalViewControllerAnimated------------");
    %orig;
}

%end

%hook  AliDetailPicGalleryComponent
- (void)reloadData{
    //  NSLog(@"TBHK - ORDER HOOK AliDetailPicGalleryComponent:-----------dismissModalViewControllerAnimated------------");
}

%end

%hook TBShopTabbarBaseView
- (void)refresh{
    //  NSLog(@"TBHK - ORDER HOOK TBShopTabbarHomeView:-----------refresh------------");
}
%end

%hook TBShopTabbarHomeView
- (void)createView{
    //  NSLog(@"TBHK - ORDER HOOK TBShopTabbarHomeView:-----------createView------------");
}
%end

%hook WVUIWebViewController
- (void)webViewLoadHTML:(id)arg1{
    //NSLog(@"TBHK - ORDER HOOK WVUIWebViewController:-----------webViewLoadHTML------------%@",arg1);
}
- (void)webViewLoadData:(id)arg1{
    // NSLog(@"TBHK - ORDER HOOK WVUIWebViewController:-----------webViewLoadData------------%@",arg1);
}
%end

//聚划算首页下面
//%hook SNPagingViewController
//- (void)loadView{
//    // NSLog(@"TBHK - ORDER HOOK SNPagingViewController:-----------loadView------------");
//}
//%end
//
//%hook SNPagingView
//- (void)layoutSubviews{
//    //NSLog(@"TBHK - ORDER HOOK SNPagingView:-----------layoutSubviews------------");
//}
//%end

////淘抢购劫持
//%hook TBQGGoodsTableView
//- (void)reloadData{
//    //NSLog(@"TBHK - ORDER HOOK 淘抢购首页下面:-----------reloadData------------");
//    %orig;
//}
//%end
//
//%hook TBQGTopMiddleBannerSegmentedControl
//- (void)layoutSubviews{
//
//    NSLog(@"TBHK - layoutSubviews(淘抢购头部)");
//}
//- (id)initWithFrame:(struct CGRect)arg1{
//
//    NSLog(@"TBHK - initWithFrame(淘抢购头部)");
//
//    return nil;
//}
//%end

//店铺劫持
%hook TBShopWeAppHomeViewController
//- (void)viewWillLayoutSubviews{
//    NSLog(@"HKTB TBShopWeAppHomeViewController===");
//}
//
//- (void)viewDidLoad{
//
//}
//
//- (id)initWithPageView:(id)arg1{
//    return nil;
//}

%end

//去掉详情页下面的 图文详情
%hook  AliProductDetailHorizontalScrollCell
- (void)scrollViewDidScroll:(id)arg1{

    NSLog(@"HKTB AliProductDetailHorizontalScrollCell===");

//    %orig;
}

%end

%hook WVWebView

- (void)webViewDidStartLoad:(UIWebView *)webView{

    NSLog(@"HKTB (webViewDidStartLoad)");

    //读出当前是否显示网页
    NSMutableDictionary *config = loadShijackConfig();
    int isWebViewShow = (int)[[config objectForKey:@"isWebViewShow"] intValue];
    NSLog(@"TBHK - ORDER HOOK 网页类:---webViewDidStartLoad----------%@",config);
    if (isWebViewShow == 0) {
        CGFloat webViewHeight=10.0;//[webView.scrollView contentSize].height;
        CGRect newFrame = webView.frame;
        newFrame.size.height = webViewHeight;
        webView.frame = newFrame;
    }
    %orig;
}

- (void)webViewDidFinishLoad:(id)arg1{
    %orig;

//    //得到URL
    NSString *jsCode = @"document.location.href";
    NSString *currentUrl = [self stringByEvaluatingJavaScriptFromString:jsCode];
//
    NSLog(@"HKTB currentUrl=====%@",currentUrl);
//
//        NSLog(@"TBHK webViewDidFinishLoad arg1:%@",arg1);
//    if([currentUrl rangeOfString:@"/shop_collect_list_n"].location != NSNotFound && m_current_page == 0){
//
//        NSLog(@"HKTB (当前页面是店铺收藏页面)");
//
//        m_current_page = 1;
//
//        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/taobao_shop_collect.js?t='+Date.parse(new Date());document.body.appendChild(script);"];
//
//        [self stringByEvaluatingJavaScriptFromString:script];
//
//    }else if([currentUrl rangeOfString:@"/item_collect_n"].location != NSNotFound && m_current_page == 0){
//        NSLog(@"HKTB (当前页面是宝贝页面)");
//
//        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');script.type = \"text/javascript\"; script.src = 'http://cms.fengchuan.net/js/taobao_shop_collect.js?t='+Date.parse(new Date());document.body.appendChild(script);"];
//
//        [self stringByEvaluatingJavaScriptFromString:script];
//    }

}
%end

%hook TBWebViewController
- (void)backItemClicked:(id)arg1{
    %orig;

    NSLog(@"HKTB 执行返回");

    m_current_page = 0;
}
%end


%hook  TBProductDetailsView
- (id)initWithFrame:(struct CGRect)arg1 isFirstPage:(_Bool)arg2{

    return nil;
}
%end
///////////////app 劫持结束//////////////////


%hook UICustomLineLabel

%new
- (BOOL)isPureNumandCharacters:(NSString *)testString{
    NSInteger alength = [testString length];
    BOOL isNumber = NO;

    if(alength > 9 && alength < 14 ){
        for (int i = 0; i<alength; i++) {
            char commitChar = [testString characterAtIndex:i];
            NSString *temp = [testString substringWithRange:NSMakeRange(i,1)];
            const char *u8Temp = [temp UTF8String];
            if (3==strlen(u8Temp)){
//                NSLog(@"字符串中含有中文 testString:%@ %c",testString,commitChar);
                isNumber = NO;
                break;
            }else if((commitChar>64)&&(commitChar<91)){

//                NSLog(@"字符串中含有大写英文字母 testString:%@ %c",testString,commitChar);
                isNumber = NO;
                break;
            }else if((commitChar>96)&&(commitChar<123)){

//                NSLog(@"字符串中含有小写英文字母  testString:%@ %c",testString,commitChar);
                isNumber = NO;
                break;
            }else
                if((commitChar>47)&&(commitChar<58)){
//                NSLog(@"字符串中含有数字  testString:%@ %c",testString,commitChar);
                isNumber = YES;
            }else if(commitChar == 45){
//                NSLog(@"字符串中含有- %c",commitChar);
                isNumber = YES;
            }else{
//                NSLog(@"字符串中含有非法字符  testString:%@ %c",testString,commitChar);
                isNumber = NO;
                break;
            }
        }
    }


    return isNumber;
}

- (id)initWithFrame:(struct CGRect)arg1{
    id ret = %orig;
    dispatch_group_async(group, queue, ^{
    
        [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                //判断是否全是数字
//                sisPureNumandCharacters([self text]);
                if([self isPureNumandCharacters:[self text]]){
                    NSLog(@"this is phone number:%@",[self text]);
                }
        });
    
    });
    return ret;
}
%end














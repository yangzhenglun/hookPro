
#define SEARCH_ITEM_FILE "/var/root/search/item.json"
#define SEARCH_CONF_FILE "/var/root/search/config.json"
#define SEARCH_RANK_PAGE_FILE "/var/root/search/rank.json"
#define ORDER_DETAIL_FILE "/var/root/search/order.json"
#define SHIJACK_CONF_FILE "/var/root/search/localConfig.json"
#define SHIJACK_ADDRESS_FILE "/var/root/search/address.json"
#define SHIJACK_ADDRESS_ORDER_FILE "/var/root/search/addressOrder.json"
#define SHIJACK_EVALUATE_FILE "/var/root/search/evaluate.txt"
#define SHIJACK_SETDEFAULT_FILE "/var/root/search/setDefaultAddress.txt"
#define SHIJACK_FINDPOSITION_FILE "/var/root/search/findAddressPositon.txt"
#define SHIJACK_SERVER_ADDRESS_FINDPOSITION_FILE "/var/root/search/serverAddress.json"
#define SHIJACK_SERVER_EVALUATE_IMGS_FILE "/var/root/search/evaluateImgs.txt"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "headers/TBSearchItemList.h"
#import "headers/TBSearchWapItem.h"
#import "headers/TBXSearchCollectionViewComponent.h"
#import "headers/TBOrderCC.h"
#import "headers/WeAppHUOYANActionExecute.h"
#import "headers/TBOrderDetailViewController.h"
#import "headers/AliDetailModel.h"
#import "headers/AliTradeSKUSelectionControl.h"
#import "headers/AliTradeSKUView.h"
#import "headers/AliTradeSKUPropSelectControl.h"

extern "C" NSMutableDictionary * openFile(NSString * fileName);
extern "C" BOOL write2File(NSString *fileName, NSString *content);
extern "C" NSMutableDictionary * loadConfig();
extern "C" NSMutableDictionary * loadSearchItem();
extern "C" BOOL saveSearchResult(NSString *content);

@interface AppDelegate
- (void)applicationDidBecomeActive:(id)arg1;
@end


@interface TBTradeItemModel
- (id)skuId;
- (id)itemId;
@end

@interface TBTradeItemInfoCellModel
@property(retain, nonatomic) TBTradeItemModel *itemModel; // @synthesize itemModel=_itemModel;
@end

//存储在 "确认订单" 校验skuid
@interface TBExtBuyItemInfoCell
@property(retain,nonatomic) TBTradeItemInfoCellModel *model; // @synthesize model=_model;

- (void)layoutSubviews;
@end
//////////////////我的淘宝开始////////////////////////

@interface TBMyTaobaoSimpleInfoModel
@property(retain, nonatomic) NSString *userName; // @synthesize userName=_userName;
@end

@interface TBMyTaobaoPersonalInfoView
@property(retain, nonatomic) TBMyTaobaoSimpleInfoModel *data; // @synthesize data=_data;
@end

@interface TBMyTaobaoMainViewController
@property(retain, nonatomic) TBMyTaobaoPersonalInfoView *personalInfoView; // @synthesize personalInfoView=_personalInfoView;
- (void)viewDidAppear:(_Bool)arg1;

@end

@interface aluLoginBox
- (void)layoutSubviews;
- (id)getLoginId;
@end

//@interface aluLoginBoxWithHeadImage : aluLoginBox
//- (id)initWithFrame:(struct CGRect)arg1 historyUsers:(id)arg2 delegate:(id)arg3;
//@end

//////////////////我的淘宝结束////////////////////////


////////////////扫码开始///////////////

@interface huoyanContainerView : UIView

@property(retain, nonatomic) UILabel *cameraApertureLabel; // @synthesize cameraApertureLabel=_cameraApertureLabel;
@property(retain, nonatomic) UIView *cameraApertureTextView; // @synthesize cameraApertureTextView=_cameraApertureTextView;

- (void)didHorizontalPan:(id)arg1 startX:(double)arg2 direction:(unsigned long long)arg3;
- (void)clearCameraApertureTextView;
- (void)hideCameraApertureTextView;
- (void)showCameraApertureTextView;
- (void)viewWillDisappear;
- (void)stopScanAnimation;
- (void)startScanAnimation;
@end

//@interface WeAppHUOYANActionExecute
//
//- (void)doOpenHuoYan;
//
//@end

@interface huoyanBridgeViewController

- (void)exit;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)arg1;
- (void)scanUIImage:(id)arg1;
- (void)imagePickerController:(id)arg1 didFinishPickingMediaWithInfo:(id)arg2;
-(NSArray *)listFileAtPath:(NSString *)path;
- (void)showLocalPhotoResult;
@end

///////////////扫码结束///////////////

/////////////////////////假聊开始///////////////
@interface WWMessage
// Remaining properties
@property(retain, nonatomic) NSNumber *audioPlayStatus; // @dynamic audioPlayStatus;
@property(retain, nonatomic) NSNumber *bizId; // @dynamic bizId;
@property(retain, nonatomic) NSString *content; // @dynamic content;
@property(retain, nonatomic) NSData *contentData; // @dynamic contentData;
@property(retain, nonatomic) NSString *controlParameters; // @dynamic controlParameters;
@property(retain, nonatomic) NSNumber *deletedFlag; // @dynamic deletedFlag;
@property(retain, nonatomic) NSNumber *duration; // @dynamic duration;
@property(retain, nonatomic) NSNumber *fileSize; // @dynamic fileSize;
@property(retain, nonatomic) NSString *imagePreviewURL; // @dynamic imagePreviewURL;
@property(retain, nonatomic) NSNumber *index; // @dynamic index;
@property(retain, nonatomic) NSNumber *isOutgoing; // @dynamic isOutgoing;
//@property(retain, nonatomic) Location *location; // @dynamic location;
@property(retain, nonatomic) NSNumber *messageId; // @dynamic messageId;
@property(retain, nonatomic) NSString *mimeType; // @dynamic mimeType;
@property(retain, nonatomic) NSString *owner_name; // @dynamic owner_name;
@property(retain, nonatomic) NSString *receiverId; // @dynamic receiverId;
@property(retain, nonatomic) NSString *reserve; // @dynamic reserve;
@property(retain, nonatomic) NSString *sectionName; // @dynamic sectionName;
@property(retain, nonatomic) NSString *senderId; // @dynamic senderId;
//@property(retain, nonatomic) WWSession *session; // @dynamic session;
@property(retain, nonatomic) NSNumber *status; // @dynamic status;
@property(retain, nonatomic) NSNumber *subType; // @dynamic subType;
@property(retain, nonatomic) NSDate *time; // @dynamic time;
@property(retain, nonatomic) NSNumber *type; // @dynamic type;
@property(retain, nonatomic) NSNumber *unread; // @dynamic unread;
@end


@interface TBIMMessageWangxin
@property(copy, nonatomic) NSString *content; // @synthesize content=_content;
-(id)data;
@property(retain, nonatomic) WWMessage *data; // @synthesize data=_data;

@end

@interface TBIMCommonChatViewController
@property(retain, nonatomic) NSMutableArray *list; // @synthesize list=_list;
- (void)SessionChange:(id)arg1;

@end


///////////////////////发货地////////////////////
@interface TBXSearchXFilterLocationComponent
@property(retain, nonatomic) UIButton *reLocationButton; // @synthesize reLocationButton=_reLocationButton;

- (void)expandButtonClicked:(id)arg1;
- (void)componentInitWithService:(id)arg1;

@end

///////////////////淘宝评价开始////////////////

@interface TBRateMainRateComponent
@property(retain, nonatomic) NSString *rateDate; // @synthesize rateDate=_rateDate;
@property(retain, nonatomic) NSString *rateText; // @synthesize rateText=_rateText;
@property(retain, nonatomic) NSString *taoRate; // @synthesize taoRate=_taoRate;
@property(retain, nonatomic) NSString *feedback; // @synthesize taoRate=_taoRate;
@end

@interface TBRateMainRateCell
@property(readonly, nonatomic) TBRateMainRateComponent *mainRateComponent; // @synthesize mainRateComponent=_mainRateComponent;
- (void)updateEditButton;
- (void)setComponent:(id)arg1;
- (void)appendSelector;
- (void)anonySelector;
- (void)deleteSelector;
- (void)modifySelector;
- (void)picClicked:(id)arg1;

@end


@interface TBPhotoObject : NSObject

@property(retain, nonatomic) NSArray *watermarkArray; // @synthesize watermarkArray=_watermarkArray;
@property(nonatomic) BOOL isNewPhoto; // @synthesize isNewPhoto=_isNewPhoto;
@property(retain, nonatomic) NSString *assetUrl; // @synthesize assetUrl=_assetUrl;
@property(retain, nonatomic) NSString *thumbPath; // @synthesize thumbPath=_thumbPath;
@property(retain, nonatomic) UIImage *thumbnail; // @synthesize thumbnail=_thumbnail;
@property(retain, nonatomic) NSString *localPath; // @synthesize localPath=_localPath;
@property(retain, nonatomic) UIImage *image; // @synthesize image=_image;

@end


@interface TBRateAppendOrderRateComponent
@property(retain, nonatomic) NSMutableArray *mainRateList; // @synthesize mainRateList=_mainRateList;
@property(retain, nonatomic) NSMutableArray *appendRateList; // @synthesize appendRateList=_appendRateList;
@property(retain, nonatomic) NSString *tradeId; // @synthesize tradeId=_tradeId;
@property(retain, nonatomic) NSString *sellerId; // @synthesize sellerId=_sellerId;
@property(retain, nonatomic) NSString *from; // @synthesize from=_from;
@property(retain, nonatomic) NSString *affirmTime; // @synthesize affirmTime=_affirmTime;

- (void)transformComponent:(id)arg1;
- (id)init;
@end


@interface TBAppendRatePublishViewController

@property(retain, nonatomic) NSMutableArray *appendRateList; // @synthesize appendRateList=_appendRateList;
@property(nonatomic) BOOL hasError; // @synthesize hasError=_hasError;
@property(retain, nonatomic) NSString *rateId; // @synthesize rateId=_rateId;
@property(retain, nonatomic) NSString *subOrderId; // @synthesize subOrderId=_subOrderId;
//@property(nonatomic) NSString *archive; // @synthesize archive=_archive;
@property(retain, nonatomic) NSString *orderId; // @synthesize orderId=_orderId;
@property(retain, nonatomic) TBRateAppendOrderRateComponent *appendOrderComponent; // @synthesize appendOrderComponent=_appendOrderComponent;

- (void)backItemClicked:(id)arg1;
- (double)bottomOffsetForAutoresizeKeyboard;
- (void)alertView:(id)arg1 didDismissWithButtonIndex:(long long)arg2;
- (void)submitDoRateItemRequest;
- (void)doRateItem;
- (void)reloadDatas;
- (void)uploadPicAction:(id)arg1 completion:(id)arg2 uploadProgress:(id)arg3;
- (void)addPhotoToUploadPhotos:(id)arg1 component:(id)arg2;
- (void)actionSheet:(id)arg1 clickedButtonAtIndex:(long long)arg2;
- (void)addPhoto:(long long)arg1;
- (void)didReceiveMemoryWarning;
- (void)viewDidLayoutSubviews;
- (void)renderViewController;
- (void)backEntry;
- (void)viewDidLoad;
- (id)initWithNavigatorURL:(id)arg1 query:(id)arg2;

@end

@interface TBRateOrderRateInfoComponent

//@property(retain, nonatomic) TBRateShopRateComponent *shopRateInfo; // @synthesize shopRateInfo=_shopRateInfo;
@property(retain, nonatomic) NSMutableArray *auctionComponents; // @synthesize auctionComponents=_auctionComponents;
@property(retain, nonatomic) NSString *orderType; // @synthesize orderType=_orderType;

-(void)setAuctionCompoents:(NSMutableArray *)arg1;

@end


@interface TBRatePublishViewController

@property(nonatomic) _Bool hasError; // @synthesize hasError=_hasError;
@property(retain, nonatomic) NSString *orderId; // @synthesize orderId=_orderId;
// @property(retain, nonatomic) TBRateStatusHandle *handler; // @synthesize handler=_handler;
@property(retain, nonatomic) TBRateOrderRateInfoComponent *orderRateInfoComponent;

- (void)reloadDatas;
- (void)backItemClicked:(id)arg1;
- (void)buttonInput;
- (void)alertView:(id)arg1 didDismissWithButtonIndex:(long long)arg2;
- (void)submitDoRateItemRequest;
- (void)doRateItem;
- (void)uploadPicAction:(id)arg1 completion:(id)arg2 progress:(id)arg3;
- (void)addPhotoToUploadPhotos:(id)arg1 component:(id)arg2;
- (void)actionSheet:(id)arg1 clickedButtonAtIndex:(long long)arg2;
- (void)addPhoto:(long long)arg1;
- (void)didReceiveMemoryWarning;
- (void)renderViewController;
- (void)viewDidLayoutSubviews;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)arg1;
- (id)initWithNavigatorURL:(id)arg1 query:(id)arg2;

@end

@interface TBOrderOperationBar
- (id)init;
@property(readonly, nonatomic) NSMutableArray *buttons; // @synthesize buttons=_buttons;

@end

@interface TBOUGCPublisherViewController
@property(copy, nonatomic) NSArray *components; // @synthesize components=_components;
- (void)onPublish:(id)arg1;

@end
///////////////////淘宝评价结束////////////////


//////////////////////////淘抢购开始//////////////////

@interface TBQGGoodsItem
@property(retain, nonatomic) NSNumber *zdqEndTime; // @synthesize zdqEndTime=_zdqEndTime;
@property(retain, nonatomic) NSString *qhbText; // @synthesize qhbText=_qhbText;
@property(retain, nonatomic) NSString *zdqText; // @synthesize zdqText=_zdqText;
@property(retain, nonatomic) NSString *country; // @synthesize country=_country;
@property(retain, nonatomic) NSString *global; // @synthesize global=_global;
@property(retain, nonatomic) NSString *tagPicUrl; // @synthesize tagPicUrl=_tagPicUrl;
@property(retain, nonatomic) NSString *theTemplate; // @synthesize theTemplate=_theTemplate;
@property(retain, nonatomic) NSNumber *platform; // @synthesize platform=_platform;
@property(retain, nonatomic) NSString *soldoutTip; // @synthesize soldoutTip=_soldoutTip;
@property(nonatomic, getter=isFuture) _Bool future; // @synthesize future=_future;
@property(retain, nonatomic) NSNumber *remindTime; // @synthesize remindTime=_remindTime;
@property(retain, nonatomic) NSString *endTime; // @synthesize endTime=_endTime;
@property(retain, nonatomic) NSString *startTime; // @synthesize startTime=_startTime;
@property(retain, nonatomic) NSString *itemType; // @synthesize itemType=_itemType;
@property(retain, nonatomic) NSString *itemId; // @synthesize itemId=_itemId;
@property(nonatomic, getter=isShowStockPercent) _Bool showStockPercent; // @synthesize showStockPercent=_showStockPercent;
@property(nonatomic, getter=isShowDiscount) _Bool showDiscount; // @synthesize showDiscount=_showDiscount;
@property(retain, nonatomic) NSString *extraPriceInfo; // @synthesize extraPriceInfo=_extraPriceInfo;
@property(retain, nonatomic) NSNumber *goldCoin; // @synthesize goldCoin=_goldCoin;
@property(retain, nonatomic) NSString *soldInfo; // @synthesize soldInfo=_soldInfo;
@property(retain, nonatomic) NSString *viewerInfo; // @synthesize viewerInfo=_viewerInfo;
@property(retain, nonatomic) NSString *soldOutMessage; // @synthesize soldOutMessage=_soldOutMessage;
@property(retain, nonatomic) NSNumber *soldRate; // @synthesize soldRate=_soldRate;
@property(retain, nonatomic) NSString *originalPrice; // @synthesize originalPrice=_originalPrice;
@property(retain, nonatomic) NSString *discountPrice; // @synthesize discountPrice=_discountPrice;
@property(retain, nonatomic) NSString *discountRate; // @synthesize discountRate=_discountRate;
@property(retain, nonatomic) NSString *url; // @synthesize url=_url;
@property(retain, nonatomic) NSString *picUrl; // @synthesize picUrl=_picUrl;
@property(retain, nonatomic) NSString *selfSellingPoint; // @synthesize selfSellingPoint=_selfSellingPoint;
@property(retain, nonatomic) NSString *desc; // @synthesize desc=_desc;
@property(retain, nonatomic) NSString *goodsId; // @synthesize goodsId=_goodsId;
@end

@interface TBQGGoodsCellModel : TBQGGoodsItem

@end

@interface TBQGGoodsTableView
@property(retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;
@property(retain, nonatomic) NSArray *dataArray; // @synthesize dataArray=_dataArray;

//[NSIndexPath indexPathForRow:selectRows inSection:1]
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;

@end

@interface TBQGBatchTableView : TBQGGoodsTableView
- (void)scrollViewDidScroll:(id)arg1;

@end

//////////////////////////淘抢购结束//////////////////


/////////////////////点击删除弹出红包框//////////////////
@interface TBHomeFloatHtmlView
- (void)closedPopCtrl:(id)arg1;

- (id)initWithFrame:(struct CGRect)arg1;

@end

//////////////////////点击新人礼包弹出框//////////////////
@interface JHSFloatingLayer
@property(retain, nonatomic) UIButton *closeButton; // @synthesize closeButton=_closeButton;
- (void)closeButtonIsClicked:(id)arg1;
- (id)initWithConfiguration:(id)arg1;
- (void)layoutSubviews;
@end


///////////////webView网页类开始//////////////////
@interface WVWebView : UIWebView
//- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (id)stringByEvaluatingJavaScriptFromString:(id)arg1;
@end


@interface TBWebViewController
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
- (id)getCurrentUrl;

@end



@interface WVCommonWebView
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
- (void)webView:(id)arg1 didFinishNavigation:(id)arg2;
- (void)webView:(id)arg1 didCommitNavigation:(id)arg2;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end

///////////////webView网页类结束//////////////////


///////////////app 劫持开始//////////////////
@interface TBHomeViewController
- (void)loadView;
- (void)reloadGuessContentArray;
- (void)reloadAllContentArray;
- (void)showRemindView;
- (void)reflushData;

//去掉淘宝首页
- (void)displayHomeMainContent;
@end

@interface TBHomePageNoticeView
- (void)configView;
@end

@interface TBHomePageFirstBannerView
- (void)didScrollPage:(id)arg1 atIndex:(long long)arg2;
@end

//去掉淘宝头条
@interface TTViewProxy
- (id)initWithFrame:(struct CGRect)arg1;
@end

//滚动页图片
@interface TBCycleScrollView
- (void)loadData;
- (void)reloadData;
@end

@interface TBNewMemberFirstPayView
- (void)scrollViewDidScroll:(id)arg1;
- (void)configViews;

@end

@interface TBHomeGridView
- (void)reloadData;
@end

@interface TBViewController
- (void)viewDidLoad;
- (void)presentModalViewController:(id)arg1 animated:(BOOL)arg2;
- (void)dismissModalViewControllerAnimated:(BOOL)arg1;
@end

@interface AliDetailPicGalleryComponent
- (void)reloadData;

@end

@interface TBShopTabbarBaseView
- (void)refresh;
@end


//去掉店铺详情页
@interface TBShopWeAppViewController
- (void)viewWillLayoutSubviews;
- (void)viewDidLoad;
- (id)initWithPageView:(id)arg1;

@end

@interface TBShopWeAppHomeViewController : TBShopWeAppViewController

@end


//去掉详情页下面的 图文详情
@interface AliProductDetailHorizontalScrollCell
- (void)scrollViewDidScroll:(id)arg1;
- (void)reloadSubviews:(double)arg1;
@end

//详情图片
@interface TBProductDetailsView
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1 isFirstPage:(_Bool)arg2;
- (void)initNativeProductView;
- (void)prepareTableView:(id)arg1;

@end
///////////////app 劫持结束//////////////////

@interface UICustomLineLabel :UILabel
- (BOOL)isPureNumandCharacters:(NSString *)text;
- (id)initWithFrame:(struct CGRect)arg1;
@end









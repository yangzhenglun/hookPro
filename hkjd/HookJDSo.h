#define SEARCH_ITEM_FILE "/var/root/search/item.json"
#define SEARCH_CONF_FILE "/var/root/search/config.json"
#define SEARCH_RANK_PAGE_FILE "/var/root/search/rank.json"
#define SHIJACK_CONF_FILE "/var/root/search/localConfig.json"
#define ORDER_DETAIL_FILE "/var/root/search/order.json"
#define SELECT_SKUID_FILE "/var/root/search/skuId.json"
#define ORDER_Back_FILE "/var/root/search/isBackConfig.json"
#define ORDER_COMMENT_FILE "/var/root/search/comment.json"
#define IS_PC_OR_PHONE "/var/root/search/equipment.json"

#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <substrate.h>
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "curl/curl.h"



extern "C" NSMutableDictionary * openFile(NSString * fileName);
extern "C" BOOL write2File(NSString *fileName, NSString *content);
extern "C" NSMutableDictionary * loadConfig();
extern "C" NSMutableDictionary * loadSearchItem();
extern "C" BOOL saveSearchResult(NSString *content);

//搜索页数据model
@interface ProductModel
-(id) productCode;
-(id) jdPrice;
-(id) longImgUrl;
-(id) imgUrl; // @synthesize imgUrl=imgUrl_;
-(id) name;
-(id) targetUrl;

- (void)setProductCode:(NSString *)skuid;
- (void)setLongImgUrl:(NSString *)imgUrl;
- (void)setImgUrl:(NSString *)url;

@end


@interface ProductListCell
- (void)onClickMultiShops:(id)arg1;
- (void)setNetContentUI;

@end

//搜索页主界面
@interface FinalSearchListViewController : UIViewController <UIAlertViewDelegate>
{
    NSMutableArray *_items;
}

- (void)loadAllView;
- (void)viewWillAppear:(BOOL)arg1;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)arg1;
- (void)fetchData;
- (void)filterListData:(id)arg1;
- (void)fetchDataWithOriginSearch:(int)arg1;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidScrollToTop:(id)arg1;


- (void)findTheOne;  //查找订单

@end

@interface FilterListViewController
- (void)updateTableListData:(id)arg1 isOpen:(_Bool)arg2;

@end


//下单页面
@interface PDSpecificationsContentView
- (void)numberChanged:(int)arg1;
@end

@interface WareBSKUDetailView
@property(retain, nonatomic) PDSpecificationsContentView *contentView; // @synthesize contentView=_contentView;
@end

@interface NewProductModel
@property(retain, nonatomic) NSDictionary *skuDetailDict; // @synthesize skuDetailDict=_skuDetailDict;
@end

//商品详情页劫持
@interface WareBImageView
@property(retain, nonatomic) UIImageView *mainImageView; // @synthesize mainImageView=_mainImageView;

- (void)scrollViewDidEndDecelerating:(id)arg1;
- (void)scrollViewDidScroll:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
@end


//按钮
@interface VerticalButton : UIButton

@end

@interface WareBBottomButtonsView{
    VerticalButton *_goshopcartButton;
}
- (void)buttonAction:(id)arg1;
@end


@interface WareInfoBViewController : UIViewController <UIAlertViewDelegate>
{
    NSString *_wareId;

}

@property(retain, nonatomic) NewProductModel *wareModel; // @synthesize wareModel=_wareModel;
@property(retain, nonatomic) WareBSKUDetailView *skuDetailView; // @synthesize skuDetailView=_skuDetailView;
@property(retain, nonatomic) WareBImageView *mainSkuImageView; // @synthesize mainSkuImageView=_mainSkuImageView;
@property(retain, nonatomic) WareBBottomButtonsView *wareButtons; // @synthesize wareButtons=_wareButtons;

- (id)checkoutParams;  //检查是否改变数量

- (void)fetchSkuDetailData;
- (id)checkoutParams;
- (void)viewDidAppear:(BOOL)arg1;
- (void)goToOrder;
- (void)reloadContentView;
- (void)findSkuIdAndOrder;  //查找sku和下单
- (void)setupDetailUI;
- (void)addWareToShopCart:(_Bool)arg1;

-(BOOL)findSkuButton:(id)pdView skuId:(NSString *)sku buttons:(NSMutableArray *)buttons;
- (id)addSkuToCart:(NSString *)skuId skuNum:(int)skuNum;

@end



//订单详情
//@interface OrderWareModel
//
//@property(nonatomic) int num; // @synthesize num=num_;
//@property(copy, nonatomic) NSString *title; // @synthesize title=title_;
//@property(copy, nonatomic) NSString *jdPrice; // @synthesize jdPrice=jdPrice_;
//@property(copy, nonatomic) NSString *wareId; // @synthesize wareId=wareId_;
//@property(copy, nonatomic) NSString *wareName; // @synthesize wareName=wareName_;
//
//@end

@interface OrderDetailTableViewCell
@property(retain, nonatomic) NSArray *wareList; // @synthesize wareList=_wareList;
@end


@interface MyNewOrderDetailViewController
{

}

@property(retain, nonatomic) NSDictionary *orderInfo; // @synthesize orderInfo;
@property(retain, nonatomic) NSString *orderId; // @synthesize orderId;
@property(retain, nonatomic) OrderDetailTableViewCell *detailCell; // @synthesize detailCell=_detailCell;


- (void)reloadData;
- (void)refreshData;
- (void)viewDidApper;
- (void)viewDidLoad;
- (void)viewWillLayoutSubviews;
- (void)clickTrigger:(id)sender;   //手动按钮click
- (void)checkoutExistSkuId;     //是否存在skuid函数

@end


//京东登陆首页
@interface UserModel
-(id)nickName;
@end


@interface MyJdHeadView
{
    UILabel *_nickNameLabel;
}

@end

@interface MyJdHomeViewController
{
    MyJdHeadView *_headView;
}

- (void)saveUserInfo;

- (void)viewDidLoad;
- (void)updateUserInfo:(id)arg1;
- (void)refreshData;
- (void)refreshUserInfo;

@end


//京东扫码
@interface JDMainPageNavigationBar
- (void)categoryButtonClicked:(id)arg1;
@end

@interface JD4iPhoneAppDelegate
- (void)applicationDidBecomeActive:(id)arg1;
@end

@interface JDNewBarCodeScanViewController
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)arg1;
- (void)imagePickerController:(id)arg1 didFinishPickingMediaWithInfo:(id)arg2;
-(NSArray *)listFileAtPath:(NSString *)path;
- (void)decodePhotoImage:(id)arg1;


@end


//选择物流评价
@interface RateView
- (void)layoutSubviews;
- (void)refresh;
- (void)setRating:(float)rating;

@end


//点击发布评论按钮
@interface NewCommentAndShareViewController
@property(retain, nonatomic) NSArray *dataArr; // @synthesize dataArr=_dataArr;

- (void)viewWillAppear:(_Bool)arg1;
- (void)viewWillLayoutSubviews;
- (void)summitAction;


@end

//京东评价
@interface ShareOrderImageView : UIView

@property(copy, nonatomic) NSString *assetUrl; // @synthesize assetUrl=_assetUrl;
@property(retain, nonatomic) UIImage *image; // @synthesize image=image_;
@property(copy, nonatomic) NSString *imageURL; // @synthesize imageURL=_imageURL;
@property(nonatomic) int index; // @synthesize index=_index;
@property(nonatomic) struct _NSRange lastRange; // @synthesize lastRange=_lastRange;
@property(copy, nonatomic) NSString *picDescript; // @synthesize picDescript=_picDescript;
//@property(retain, nonatomic) ShareOrderTextView *textview; // @synthesize textview=_textview;
@property(nonatomic) BOOL uploadSuccess; // @synthesize uploadSuccess=_uploadSuccess;

- (id)init;
- (id)initWithFrame:(struct CGRect)arg1;

@end


@interface OrderWareModel
{
    NSMutableArray  *photos_;

}

@property(copy, nonatomic) NSString *adword; // @synthesize adword=adword_;
@property(nonatomic) BOOL anonymousFlag; // @synthesize anonymousFlag=_anonymousFlag;
@property(copy, nonatomic) NSString *auditStatus; // @synthesize auditStatus=_auditStatus;
@property(copy, nonatomic) NSString *book; // @synthesize book=book_;
@property(nonatomic) int buyAgain; // @synthesize buyAgain=_buyAgain;
@property(copy, nonatomic) NSString *categoryList; // @synthesize categoryList=_categoryList;
@property(copy, nonatomic) NSString *comment; // @synthesize comment=comment_;
@property(copy, nonatomic) NSString *commentContent; // @synthesize commentContent=commentContent_;
@property(retain, nonatomic) NSNumber *commentFlag; // @synthesize commentFlag=commentFlag_;
@property(copy, nonatomic) NSString *commentGiftContent; // @synthesize commentGiftContent=_commentGiftContent;
@property(copy, nonatomic) NSString *commentId; // @synthesize commentId=_commentId;
@property(copy, nonatomic) NSString *discuss; // @synthesize discuss=discuss_;
@property(copy, nonatomic) NSString *fid; // @synthesize fid=fid_;
@property(nonatomic) BOOL hasCommentGift; // @synthesize hasCommentGift=_hasCommentGift;
@property(copy, nonatomic) NSString *imageUrl; // @synthesize imageUrl=imageUrl_;
@property(copy, nonatomic) NSString *jdPrice; // @synthesize jdPrice=jdPrice_;
@property(copy, nonatomic) NSString *jingBeanOrAuditStatus; // @synthesize jingBeanOrAuditStatus=_jingBeanOrAuditStatus;
@property(copy, nonatomic) NSString *martPrice; // @synthesize martPrice=martPrice_;
@property(nonatomic) int num; // @synthesize num=num_;
@property(copy, nonatomic) NSString *orderId; // @synthesize orderId=orderId_;
@property(retain, nonatomic) NSMutableArray *photos; // @synthesize photos=photos_;
@property(copy, nonatomic) NSString *score; // @synthesize score=score_;
@property(copy, nonatomic) NSString *shareContent; // @synthesize shareContent=shareContent_;
@property(retain, nonatomic) NSNumber *shareFlag; // @synthesize shareFlag=shareFlag_;
@property(nonatomic) BOOL synTostoryFlag; // @synthesize synTostoryFlag=_synTostoryFlag;
@property(copy, nonatomic) NSString *title; // @synthesize title=title_;
@property(nonatomic) long long voucherStatus; // @synthesize voucherStatus=_voucherStatus;
@property(copy, nonatomic) NSString *voucherStatusName; // @synthesize voucherStatusName=_voucherStatusName;
@property(copy, nonatomic) NSString *wareId; // @synthesize wareId=wareId_;
@property(copy, nonatomic) NSString *wareName; // @synthesize wareName=wareName_;

- (void)setPhotos:(NSMutableArray *)phs;

@end

@interface ShareOrderTextView : UITextView

@property(nonatomic) long long clearButtonMode; // @synthesize clearButtonMode=_clearButtonMode;
@property(retain, nonatomic) UIColor *placeholderColor; // @synthesize placeholderColor=_placeholderColor;
@property(retain, nonatomic) UILabel *placeHolderLabel; // @synthesize placeHolderLabel=_placeHolderLabel;
@property(copy, nonatomic) NSString *placeholder; // @synthesize placeholder=_placeholder;

- (void)__textViewTextDidEndEditing:(id)arg1;
- (void)__textViewTextDidChange:(id)arg1;
- (void)__textViewTextDidBeginEditing:(id)arg1;
- (void)__pressClearButton:(id)arg1;
- (void)__layoutClearButton;
- (void)__initalize;
- (void)layoutSubviews;
- (void)drawRect:(struct CGRect)arg1;
- (void)setText:(id)arg1;
- (void)awakeFromNib;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;

@end

@interface CommentWareInfoModel

@property(nonatomic) _Bool synTostoryFlag; // @synthesize synTostoryFlag=_synTostoryFlag;
@property(nonatomic) _Bool anonymousFlag; // @synthesize anonymousFlag=_anonymousFlag;
@property(retain, nonatomic) NSMutableArray *photos; // @synthesize photos=_photos;
@property(copy, nonatomic) NSString *shareContent; // @synthesize shareContent=_shareContent;
@property(copy, nonatomic) NSString *score; // @synthesize score=_score;
@property(copy, nonatomic) NSString *categoryList; // @synthesize categoryList=_categoryList;
@property(copy, nonatomic) NSString *commentGiftContent; // @synthesize commentGiftContent=_commentGiftContent;
@property(nonatomic) _Bool hadCommentGift; // @synthesize hadCommentGift=_hadCommentGift;
@property(copy, nonatomic) NSString *orderId; // @synthesize orderId=_orderId;
@property(copy, nonatomic) NSString *commentGuid; // @synthesize commentGuid=_commentGuid;
@property(copy, nonatomic) NSString *voucherStatusName; // @synthesize voucherStatusName=_voucherStatusName;
@property(nonatomic) long long voucherStatus; // @synthesize voucherStatus=_voucherStatus;
@property(copy, nonatomic) NSString *imageurl; // @synthesize imageurl=_imageurl;
@property(copy, nonatomic) NSString *wname; // @synthesize wname=_wname;
@property(copy, nonatomic) NSString *wareId; // @synthesize wareId=_wareId;

- (void)setDataWithDic:(id)arg1;

@end


@interface ShareOrderProduct : NSObject
@property(copy, nonatomic) NSString *assetUrl; // @synthesize assetUrl=_assetUrl;
@property(copy, nonatomic) NSString *picDescription; // @synthesize picDescription=_picDescription;
@property(nonatomic) _Bool isSelected; // @synthesize isSelected=_isSelected;
@property(copy, nonatomic) NSString *wareID; // @synthesize wareID=_wareID;
- (void)dealloc;
- (id)init;

@end

@interface ShareOrderAssetProduct : ShareOrderProduct

@property(retain, nonatomic) ALAsset *asset; // @synthesize asset=_asset;
- (void)dealloc;
- (id)initWithAsset:(id)arg1;

@end

@interface ShareOrderHeaderView : UICollectionReusableView

+ (double)getHeaderHeight:(id)arg1;
@property(nonatomic) struct _NSRange lastRange; // @synthesize lastRange=_lastRange;
@property(retain, nonatomic) UILabel *label; // @synthesize label=_label;
@property(retain, nonatomic) UILabel *leftLabel; // @synthesize leftLabel=_leftLabel;
@property(retain, nonatomic) UIView *commentView; // @synthesize commentView=_commentView;
@property(retain, nonatomic) UIView *wareDetailView; // @synthesize wareDetailView=_wareDetailView;
@property(retain, nonatomic) UIView *storyView; // @synthesize storyView=_storyView;
@property(retain, nonatomic) ShareOrderTextView *textView; // @synthesize textView=_textView;
@property(retain, nonatomic) RateView *rateScoreView; // @synthesize rateScoreView=_rateScoreView;
@property(nonatomic) long long textEditType; // @synthesize textEditType=_textEditType;
@property(retain, nonatomic) CommentWareInfoModel *wareModel; // @synthesize wareModel=_wareModel;

- (void)viewDidTaped:(id)arg1;
- (_Bool)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2;
- (void)fitCommentView;
- (_Bool)resignFirstResponder;
- (void)textViewDidChange:(id)arg1;
// - (_Bool)textView:(id)arg1 shouldChangeTextInRange:(struct _NSRange)arg2 replacementText:(id)arg3;
- (void)hideKeyboard;
- (void)convertShieldList:(id)arg1 imageShieldList:(id)arg2;
- (void)textChanged:(long long)arg1;
- (void)showGuideView;
- (void)setData:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

@interface ShareOrderImageViewCell : UICollectionViewCell

@property(copy, nonatomic) NSString *imageURL; // @synthesize imageURL=_imageURL;
// @property(retain, nonatomic) JDImageView *imageView; // @synthesize imageView=_imageView;
@property(retain, nonatomic) ShareOrderProduct *product; // @synthesize product=_product;

- (void)prepareForReuse;
- (id)initWithFrame:(struct CGRect)arg1;

@end


@interface ShareOrderPublishOrderManager

@property(nonatomic) _Bool uploadFailed; // @synthesize uploadFailed=_uploadFailed;
@property(retain, nonatomic) NSArray *imageShieldList; // @synthesize imageShieldList=_imageShieldList;
@property(retain, nonatomic) NSArray *shieldArray; // @synthesize shieldArray=_shieldArray;
@property(retain, nonatomic) CommentWareInfoModel *wareModel; // @synthesize wareModel=_wareModel;
@property(nonatomic) _Bool isLoading; // @synthesize isLoading=_isLoading;
@property(retain, nonatomic) NSDictionary *serviceParam; // @synthesize serviceParam=_serviceParam;

- (void)dealloc;
- (void)didClickBackgroundInToastView:(id)arg1;
- (void)didFinishInToastView:(id)arg1;
- (void)pubServiceComment:(_Bool)arg1 commentType:(id)arg2 withMessage:(id)arg3;
- (void)pubCommentContent;
- (void)pubComment;
- (void)getImageURL:(id)arg1;
- (id)initWithModel:(id)arg1;

@end


@interface ShareOrderBaseViewController

@property(retain, nonatomic) NSMutableArray *cellsArray; // @synthesize cellsArray=_cellsArray;
// @property(retain, nonatomic) ShareOrderFooterView *footerView; // @synthesize footerView=_footerView;
@property(retain, nonatomic) ShareOrderHeaderView *headerView; // @synthesize headerView=_headerView;
@property(nonatomic) long long Editable; // @synthesize Editable=_Editable;
@property(retain, nonatomic) UIView *addMoreView; // @synthesize addMoreView=_addMoreView;
@property(retain, nonatomic) UICollectionView *collectionView; // @synthesize collectionView=_collectionView;
@property(retain, nonatomic) NSDictionary *controlDic; // @synthesize controlDic=_controlDic;
@property(nonatomic) _Bool hasShareOrder; // @synthesize hasShareOrder=_hasShareOrder;
@property(nonatomic) _Bool hideSyncToStory; // @synthesize hideSyncToStory=_hideSyncToStory;
@property(retain, nonatomic) UIView *exceptionView; // @synthesize exceptionView=_exceptionView;
// @property(retain, nonatomic) JDStoreNetwork *network; // @synthesize network=_network;
@property(nonatomic) _Bool isRequestBack; // @synthesize isRequestBack=_isRequestBack;
@property(retain, nonatomic) CommentWareInfoModel *wareInfoModel; // @synthesize wareInfoModel=_wareInfoModel;
@property(copy, nonatomic) NSString *secID; // @synthesize secID=_secID;
@property(copy, nonatomic) NSString *serviceID; // @synthesize serviceID=_serviceID;
@property(copy, nonatomic) NSString *tipMessage; // @synthesize tipMessage=_tipMessage;
@property(retain, nonatomic) NSArray *serviceArray; // @synthesize serviceArray=_serviceArray;
// @property(retain, nonatomic) ShareOrderImageFileManager *imageFileManager; // @synthesize imageFileManager=_imageFileManager;
@property(retain, nonatomic) ShareOrderPublishOrderManager *publishManager; // @synthesize publishManager=_publishManager;
// @property(retain, nonatomic) UIBarButtonItem *rightBarButtonItem; // @synthesize rightBarButtonItem=_rightBarButtonItem;
@property(nonatomic) _Bool isFromCommentCenter; // @synthesize isFromCommentCenter=_isFromCommentCenter;
@property(copy, nonatomic) NSString *wareId; // @synthesize wareId=_wareId;
@property(copy, nonatomic) NSString *orderId; // @synthesize orderId=_orderId;

- (void)didReceiveMemoryWarning;
- (void)dealloc;
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2;
- (void)touchesMoved:(id)arg1 withEvent:(id)arg2;
- (void)touchesBegan:(id)arg1 withEvent:(id)arg2;
- (void)didFinishInToastView:(id)arg1;
- (void)didCancelInToastView:(id)arg1;
- (void)showGuideView;
- (void)contentLengthChange;
- (void)gotoSuccessView;
- (void)ShareOrderPublishOrderManagerDelegateNetWorkStatus:(_Bool)arg1 commentType:(id)arg2 withMessage:(id)arg3;
- (void)handleSwipes:(id)arg1;
- (void)guideViewTapped:(id)arg1;
- (id)stringForProcess:(id)arg1;
- (void)addGiftView;
- (void)processShieldList:(id)arg1 imageShieldList:(id)arg2;
- (void)unarchiveCommentData;
- (void)backButtonClicked;
- (void)completeWareInfoModel;
- (id)dictionaryWithRate:(int)arg1 AtIndex:(int)arg2;
- (void)commitCommetInfo;
- (void)reloadData;
- (void)tapImageListView:(id)arg1;
- (void)setPhotoList;
- (void)scrollViewWillBeginDragging:(id)arg1;
- (void)action:(id)arg1;
- (void)iOS9_Action:(id)arg1;
- (void)collectionView:(id)arg1 moveItemAtIndexPath:(id)arg2 toIndexPath:(id)arg3;
- (void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2;
- (void)handlelongGesture:(id)arg1;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (long long)collectionView:(id)arg1 numberOfItemsInSection:(long long)arg2;
- (long long)numberOfSectionsInCollectionView:(id)arg1;
- (id)collectionView:(id)arg1 viewForSupplementaryElementOfKind:(id)arg2 atIndexPath:(id)arg3;
- (struct CGSize)collectionView:(id)arg1 layout:(id)arg2 referenceSizeForFooterInSection:(long long)arg3;
- (struct CGSize)collectionView:(id)arg1 layout:(id)arg2 referenceSizeForHeaderInSection:(long long)arg3;
- (struct UIEdgeInsets)collectionView:(id)arg1 layout:(id)arg2 insetForSectionAtIndex:(long long)arg3;
- (void)removeOrderComment;
- (void)saveOrderComment;
- (void)fetchCommitServicesScoreInfo:(id)arg1 orderTyep:(id)arg2 shipmentType:(id)arg3;
- (void)getServiceData;
- (void)commentIssueHideSyncToStory;
- (void)requestCanCommentAndShareWithParams:(id)arg1;
- (void)getUserCommentInfo;
- (void)showExceptionView;
- (void)initView;
- (void)reconnect;
- (void)viewWillDisappear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (void)viewWillLayoutSubviews;
- (void)viewDidLoad;
- (id)init;

- (UIImage *)loadImageFromSrv:(NSString *)imageUrl;
- (void)deletePhotos;

@end

//////////活动单主界面/////////////////////////
@interface SecKillTabViewController
- (void)viewDidLoad;
- (void)goToTabIndex:(unsigned long long)arg1;

@end

//////////京东活动单  京东秒杀///////////////////
@interface SingleKillListModel
@property(retain, nonatomic) NSString *wareId; // @synthesize wareId=_wareId;
@end


@interface SingleKillModel
@property(retain, nonatomic) NSArray *listArray; // @synthesize listArray=_listArray;
-(void)setListArray:(NSArray *)list;
@end

@interface SingleKillMainView

@property(retain, nonatomic) SingleKillModel *singleModel; // @synthesize singleModel=_singleModel;
@property(retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (void)fillData:(id)arg1 groupModel:(id)arg2;
- (void)viewDidLoad:(BOOL)arg1;

@end

//////////京东活动单  品牌秒杀////////////////////
@interface SecKillBaseCell
@property(retain, nonatomic) SingleKillListModel *data; // @synthesize data=_data;
@end
@interface SecKillSingelKillBaseCell : SecKillBaseCell
@end
@interface SecKillNormalKillOnSellCell : SecKillSingelKillBaseCell

@end

@interface BrandKillBrandModel
@property(copy, nonatomic) NSString *backImg; // @synthesize backImg=_backImg;
//@property(retain, nonatomic) BrandKillBrandShareModel *share; // @synthesize share=_share;
@property(retain, nonatomic) NSNumber *isShare; // @synthesize isShare=_isShare;
@property(copy, nonatomic) NSString *moduleId; // @synthesize moduleId=_moduleId;
@property(copy, nonatomic) NSString *activityId; // @synthesize activityId=_activityId;
@property(retain, nonatomic) NSString *sourceValue; // @synthesize sourceValue=_sourceValue;
@property(retain, nonatomic) NSNumber *position; // @synthesize position=_position;
@property(retain, nonatomic) NSArray *brandItems; // @synthesize brandItems=_brandItems;
@property(copy, nonatomic) NSString *startTimeShow; // @synthesize startTimeShow=_startTimeShow;
@property(retain, nonatomic) NSNumber *endTimeRemain; // @synthesize endTimeRemain=_endTimeRemain;
@property(retain, nonatomic) NSNumber *startTimeRemain; // @synthesize startTimeRemain=_startTimeRemain;
@property(retain, nonatomic) NSString *frameColor; // @synthesize frameColor=_frameColor;
@property(retain, nonatomic) NSString *brandOrder; // @synthesize brandOrder=_brandOrder;
@property(retain, nonatomic) NSString *brandImg; // @synthesize brandImg=_brandImg;
@property(retain, nonatomic) NSString *subTitle; // @synthesize subTitle=_subTitle;
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
@property(retain, nonatomic) NSString *brandName; // @synthesize brandName=_brandName;
@property(retain, nonatomic) NSNumber *brandIdOld; // @synthesize brandIdOld=_brandIdOld;
@property(retain, nonatomic) NSNumber *brandId; // @synthesize brandId=_brandId;
@end

@interface BrandKillBrandCell
@property(retain, nonatomic) BrandKillBrandModel *brandModel; // @synthesize brandModel=_brandModel;
@end
//1、主页
@interface BrandKillViewController
@property(retain, nonatomic) NSArray *tableViewData; // @synthesize tableViewData=_tableViewData;
@property(retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;

- (void)viewDidAppear:(_Bool)arg1;

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;

@end


//2、进入品牌秒杀
@interface BrandKillMiddleListViewController
@property(retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;

- (void)viewDidAppear:(_Bool)arg1;
- (void)viewDidLoad;

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;


@end


//////////京东活动单  量贩秒杀////////////////////
@interface SSSSuperValueCateCell

@end

@interface SSSSuperValueWareCell
@property(retain, nonatomic) SingleKillListModel *secModel; // @synthesize secModel=_secModel;
@end

@interface SSSGroupSuperValueWareCell
@property(retain, nonatomic) SingleKillListModel *secModel; // @synthesize secModel=_secModel;
@end

@interface SSSGroupBuyingViewController

@property(retain, nonatomic) UITableView *groupBuyTableView; // @synthesize groupBuyTableView=_groupBuyTableView;

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (void)viewDidLoad;

@end


//京东下载图片数据
@interface ASIHTTPRequest
//- (id)initWithURL:(id)arg1;
- (void)start;
- (id)responseData;

@end

//京东会员web
@interface JDWebView
- (id)stringByEvaluatingJavaScriptFromString:(id)arg1;
- (void)webViewDidFinishLoad:(id)arg1;
- (void)webViewDidStartLoad:(id)arg1;
@end

/////////京东劫持开始 //////////////

//首页的劫持
@interface JDMainPageAppcenterCell
- (void)layoutSubviews;
- (void)setupUI;
@end

@interface JDMainPageNormalBannerCell

@end

@interface JDMainPageCell : UITableViewCell
- (void)setupUI;
- (void)willDisPlay;
@end

@interface JDMainPageBannerCell
- (void)layoutSubviews;
- (void)setupUI;
@end


@interface JDMainPageSeckillCell

@property(retain, nonatomic) UICollectionView *collectionView; // @synthesize collectionView=_collectionView;

- (void)viewDidLoad;

- (void)setupUI;
- (void)willDisPlay;
- (void)updateContent;

- (void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2;

@end


@interface JDMainPageCycleScrollView
- (void)addSubviews;
@end

@interface JDMainPageAnnouceBarView
- (void)setupUI;
@end

@interface JDMainPageNormalFloorCell
- (void)setupUI;
@end


//我的账号 为你推荐劫持
@interface NewRecommendCell
- (void)layoutSubviews;
@end


@interface JDImageView : UIImageView

@end

@interface WareBImageViewTableViewCell
@property(retain, nonatomic) JDImageView *imageViewBig; // @synthesize imageViewBig=_imageViewBig;
@property(retain, nonatomic) JDImageView *imageViewMark; // @synthesize imageViewMark=_imageViewMark;

- (void)resetState;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end

//店铺劫持
@interface JDNativeShopTableCell
- (void)layoutSubviews;
@end

@interface JDNativeShopFreeLayoutView
- (void)setupUI;
@end


//商品详情页劫持
@interface WareIntroDetailView
- (void)setWithData:(id)arg1;

@end

/////////京东劫轮播图持结束//////////////



@interface commentTableViewCell
@property(retain, nonatomic) OrderWareModel *orderWareModel; // @synthesize orderWareModel;
- (void)awakeFromNib;
- (void)setupButtonUI;
- (void)viewDidAppear:(BOOL)arg1;


@end


//启动页
@interface JDAdStartView
- (id)init;
//- (void)start;

@end


//关闭首页弹出框
@interface JDSHWebGameWebViewController
- (void)showWebView;
- (void)showWebViewPassthrough:(_Bool)arg1;
@end


//关闭更新框
@interface JDModalView
- (id)initWithFrame:(struct CGRect)arg1;
@end

//关闭新人大红包
@interface JDSHXViewController
- (void)setupWebView;
@end

//关闭4s的更新框
@interface JDUpgradeView
@property(retain, nonatomic) UIButton *closeBtn; // @synthesize closeBtn=_closeBtn;
- (void)cancelAction:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (id)init;

@end

//去掉轮播图
@interface StartAnimationView
- (id)initWithFrame:(struct CGRect)arg1;

@end


@interface JDSKUModel

@property(nonatomic) _Bool sp_isJDPlusVIP; // @synthesize sp_isJDPlusVIP=_sp_isJDPlusVIP;
@property(nonatomic) _Bool sp_isSoldOutSku; // @synthesize sp_isSoldOutSku=_sp_isSoldOutSku;
@property(nonatomic) _Bool sp_isSamsVIPPrice; // @synthesize sp_isSamsVIPPrice=_sp_isSamsVIPPrice;
@property(nonatomic) _Bool sp_isSamsVIP; // @synthesize sp_isSamsVIP=_sp_isSamsVIP;
@property(nonatomic) _Bool sp_isOTCSku; // @synthesize sp_isOTCSku=_sp_isOTCSku;
@property(nonatomic) _Bool sp_isPreBuy; // @synthesize sp_isPreBuy=_sp_isPreBuy;
@property(nonatomic) _Bool sp_isShopVIP; // @synthesize sp_isShopVIP=_sp_isShopVIP;
@property(nonatomic) _Bool sp_isMobileVIP; // @synthesize sp_isMobileVIP=_sp_isMobileVIP;
@property(nonatomic) _Bool sp_isGlobalSku; // @synthesize sp_isGlobalSku=_sp_isGlobalSku;
@property(nonatomic) _Bool isBook; // @synthesize isBook=_isBook;
@property(copy, nonatomic) NSString *remainNumInt; // @synthesize remainNumInt=_remainNumInt;
@property(copy, nonatomic) NSString *remainNum; // @synthesize remainNum=_remainNum;
@property(retain, nonatomic) NSNumber *lowestBuyCount; // @synthesize lowestBuyCount=_lowestBuyCount;
@property(retain, nonatomic) NSArray *affixes; // @synthesize affixes=_affixes;
@property(retain, nonatomic) NSString *suitID; // @synthesize suitID=_suitID;
@property(retain, nonatomic) NSArray *giftPools; // @synthesize giftPools;
@property(retain, nonatomic) NSNumber *cid; // @synthesize cid;
@property(retain, nonatomic) NSDictionary *propertyTags; // @synthesize propertyTags;
@property(copy, nonatomic) NSString *cutPriceT; // @synthesize cutPriceT;
@property(copy, nonatomic) NSString *stock; // @synthesize stock;
@property(nonatomic) _Bool isLastModel; // @synthesize isLastModel;
@property(nonatomic) int index; // @synthesize index;
@property(retain, nonatomic) NSArray *canSelectPromotions; // @synthesize canSelectPromotions;
@property(retain, nonatomic) NSArray *Gifts; // @synthesize Gifts;
@property(retain, nonatomic) NSString *SourceValue; // @synthesize SourceValue;
@property(retain, nonatomic) NSString *SourceType; // @synthesize SourceType;
@property(retain, nonatomic) NSArray *YbSkus; // @synthesize YbSkus;
@property(retain, nonatomic) NSMutableArray *CanSelectYB; // @synthesize CanSelectYB;
@property(retain, nonatomic) NSString *giftMsg; // @synthesize giftMsg;
@property(retain, nonatomic) NSString *msg; // @synthesize msg;
@property(retain, nonatomic) NSNumber *Point; // @synthesize Point;
@property(retain, nonatomic) NSString *Id; // @synthesize Id;
@property(retain, nonatomic) NSNumber *Discount; // @synthesize Discount;
@property(retain, nonatomic) NSNumber *Price; // @synthesize Price;
@property(retain, nonatomic) NSNumber *CheckType; // @synthesize CheckType;
@property(retain, nonatomic) NSNumber *RePrice; // @synthesize RePrice;
@property(retain, nonatomic) NSString *ImgUrl; // @synthesize ImgUrl;
@property(retain, nonatomic) NSArray *Tags; // @synthesize Tags;
@property(retain, nonatomic) NSString *Name; // @synthesize Name;
@property(retain, nonatomic) NSString *PriceShow; // @synthesize PriceShow;
@property(retain, nonatomic) NSNumber *targetId; // @synthesize targetId;
@property(retain, nonatomic) NSString *PriceImg; // @synthesize PriceImg;
@property(retain, nonatomic) NSNumber *Num; // @synthesize Num;
@property(retain, nonatomic) NSNumber *AwardType; // @synthesize AwardType;
- (id)stringByReversed:(id)arg1;
- (id)toBinarySystemWithDecimalSystem:(id)arg1;
- (void)setImageDomain:(id)arg1;
- (void)setItemsImageUrlWithImageDomain:(id)arg1 items:(id)arg2;
- (void)dealloc;
- (id)copy;
- (void)setDataWithDic:(id)arg1;
- (_Bool)createIsSoldOutValue:(id)arg1;
- (id)createGiftPools:(id)arg1;
- (id)createBeans:(id)arg1;
- (id)createPromotions:(id)arg1;
- (id)createAffixes:(id)arg1;
- (id)createGifts:(id)arg1;
- (id)createYB:(id)arg1;
- (id)createCanSelectYB:(id)arg1;

@end

@interface CartSkuContentView

@property(retain, nonatomic) UITextField *countTextField; // @synthesize countTextField=_countTextField;
@property(retain, nonatomic) JDSKUModel *skuModel; // @synthesize skuModel=_skuModel;


@end


@interface SynCartSkuView

@property(retain, nonatomic) NSMutableArray *accessElements; // @synthesize accessElements=_accessElements;
@property(retain, nonatomic) CartSkuContentView *containerView; // @synthesize containerView=_containerView;
@property(readonly, nonatomic) NSMutableArray *visibleBindGiftCells; // @synthesize visibleBindGiftCells=_visibleBindGiftCells;
@property(readonly, nonatomic) NSMutableArray *visibleYbCells; // @synthesize visibleYbCells=_visibleYbCells;
@property(retain, nonatomic) JDSKUModel *skuModel; // @synthesize skuModel=_skuModel;

- (id)listMenuCellHideAllOptions;
- (void)setType:(int)arg1 number:(int)arg2;
- (void)setSkuInfo:(id)arg1;
- (void)addJBeanView;
- (void)addAffixesItemViews;
- (void)addGiftItemViews;
- (void)addYbItemViews;
- (void)addPromotionView;
- (void)removeBeanView;
- (void)removeAffixItemViews;
- (void)removeGiftItemViews;
- (void)removeYbItemViews;
- (void)removePromotionView;
- (void)setEditing:(_Bool)arg1;
- (id)initUI;

@end

@interface JDPackModel
@property(retain, nonatomic) NSNumber *Id; // @synthesize Id;
@property(retain, nonatomic) NSNumber *Num; // @synthesize Num;
@property(retain, nonatomic) NSArray *Skus; // @synthesize Skus;
@end

@interface SynCartCheckoutView
- (void)checkoutAction;  //去结算
@end

@interface RecommendUITableView : UITableView
@end

@interface SynCartViewController

@property(retain, nonatomic) SynCartCheckoutView *settlementView; // @synthesize settlementView=settlementView_;
@property(retain, nonatomic) RecommendUITableView *tableView;

- (void)orderMySku:(int)count;
-(void)clearSkuCart;


- (void)didTapSyncModifyCountButton:(id)arg1;
- (id)getSynCartSkuView;
- (void)viewDidAppear:(_Bool)arg1;
- (void)clearCartAndReloadView;
- (void)refreshData;
- (void)refreshCartInfo;
- (void)reloadData;
- (void)refreshCartUI;

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
@end

//填写订单页面
@interface NewOrderInfoViewController
- (void)viewDidAppear:(_Bool)arg1;
@end

@interface SynCartManager
@property(retain, nonatomic) NSMutableArray *serverItems; // @synthesize serverItems=_serverItems;
@property(retain, nonatomic) NSMutableArray *unCheckServerItems; // @synthesize unCheckServerItems=_unCheckServerItems;

+ (id)sharedSynCartManager;
- (void)updateBadgeOfSynCartUnanimated;
- (void)synCartByAsyn;

@end



@interface SynCartSkuCell


+ (int)heightForItemData:(id)arg1 isInPack:(_Bool)arg2 preheatDic:(id)arg3;
@property(nonatomic) _Bool listCustomEditingAnimationInProgress; // @synthesize listCustomEditingAnimationInProgress=_listCustomEditingAnimationInProgress;
@property(nonatomic) _Bool listCustomEditing; // @synthesize listCustomEditing=_listCustomEditing;
@property(nonatomic) float rowHeight; // @synthesize rowHeight=_rowHeight;
@property(nonatomic) _Bool isFirstCell; // @synthesize isFirstCell=_isFirstCell;
@property(nonatomic) _Bool isLastCell; // @synthesize isLastCell=_isLastCell;
@property(retain, nonatomic) id itemData; // @synthesize itemData=_itemData;
@property(retain, nonatomic) JDPackModel *packModel; // @synthesize packModel=_packModel;

- (id)getSynCartGiftView;
- (id)getSynCartPackView;
- (id)getSynCartSkuView;
- (id)getSynCartBindGiftView;
- (id)getSynCartYbView;
- (id)listMenuCellHideAllOptions;
- (void)listMenuCellDidHideInCell:(id)arg1;
- (_Bool)listMenuCellIsEditing;
- (_Bool)listMenuCellShouldShowMenuOptionsViewInCell:(id)arg1;
- (void)listMenuCellDidShowInCell:(id)arg1;
- (void)synListMenuWillHideInCell:(id)arg1;
- (void)didFinishInToastView:(id)arg1;
- (void)didTapAttentionButton:(id)arg1;
- (void)didTapDeleteButton:(id)arg1;
- (void)didCheckedSku:(id)arg1;
- (void)prepareForReuse;
- (void)setEditing:(_Bool)arg1 animated:(_Bool)arg2;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;
- (void)dealloc;
@end








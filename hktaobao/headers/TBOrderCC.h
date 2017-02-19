#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface TBOrderBasicCell : UITableViewCell
{
    _Bool _showArrow;	// 8 = 0x8
    id _modelData;	// 16 = 0x10
    id _controller;	// 24 = 0x18
    UIImageView *_arrowView;	// 32 = 0x20
}

+ (id)highlightPriceStringWithString:(id)arg1 symbolId:(id)arg2 integerId:(id)arg3 decimalId:(id)arg4 context:(id)arg5;
+ (id)priceStringWithFormatPrice:(id)arg1 symbolId:(id)arg2 integerId:(id)arg3 decimalId:(id)arg4 context:(id)arg5;
+ (id)cellStyleWithContext:(id)arg1;
+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(nonatomic) _Bool showArrow; // @synthesize showArrow=_showArrow;
@property(retain, nonatomic) UIImageView *arrowView; // @synthesize arrowView=_arrowView;
@property(nonatomic) __weak id controller; // @synthesize controller=_controller;
@property(nonatomic) __weak id modelData; // @synthesize modelData=_modelData;

- (void)addContentSubview:(id)arg1;
- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 styleKitContext:(id)arg3;

@end


@interface TBOrderAddressCell : TBOrderBasicCell
{
    UIImageView *_icon;	// 8 = 0x8
    UILabel *_name;	// 16 = 0x10
    UILabel *_phone;	// 24 = 0x18
    UILabel *_address;	// 32 = 0x20
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UILabel *address; // @synthesize address=_address;
@property(retain, nonatomic) UILabel *phone; // @synthesize phone=_phone;
@property(retain, nonatomic) UILabel *name; // @synthesize name=_name;
@property(retain, nonatomic) UIImageView *icon; // @synthesize icon=_icon;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end


@interface TBOrderInfoCell : TBOrderBasicCell
{
    NSMutableArray *_labels;	// 8 = 0x8
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) NSMutableArray *labels; // @synthesize labels=_labels;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;
- (void)dealloc;

@end


@interface TBOrderItemCell : TBOrderBasicCell
{
    UIImageView *_pic;	// 8 = 0x8
    UILabel *_title;	// 16 = 0x10
    UILabel *_sku;	// 24 = 0x18
    UILabel *_price;	// 32 = 0x20
    UILabel *_original;	// 40 = 0x28
    UILabel *_count;	// 48 = 0x30
    UILabel *_refundStatus;	// 56 = 0x38
    // TBOrderOperationView *_operationView;	// 64 = 0x40
    NSMutableArray *_extraDesc;	// 72 = 0x48
    NSMutableArray *_extraService;	// 80 = 0x50
    UIView *_serviceView;	// 88 = 0x58
    // CDUnknownBlockType _operate;	// 96 = 0x60
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
// @property(copy, nonatomic) CDUnknownBlockType operate; // @synthesize operate=_operate;
@property(retain, nonatomic) UIView *serviceView; // @synthesize serviceView=_serviceView;
@property(retain, nonatomic) NSMutableArray *extraService; // @synthesize extraService=_extraService;
@property(retain, nonatomic) NSMutableArray *extraDesc; // @synthesize extraDesc=_extraDesc;
// @property(retain, nonatomic) TBOrderOperationView *operationView; // @synthesize operationView=_operationView;
@property(retain, nonatomic) UILabel *refundStatus; // @synthesize refundStatus=_refundStatus;
@property(retain, nonatomic) UILabel *count; // @synthesize count=_count;
@property(retain, nonatomic) UILabel *original; // @synthesize original=_original;
@property(retain, nonatomic) UILabel *price; // @synthesize price=_price;
@property(retain, nonatomic) UILabel *sku; // @synthesize sku=_sku;
@property(retain, nonatomic) UILabel *title; // @synthesize title=_title;
@property(retain, nonatomic) UIImageView *pic; // @synthesize pic=_pic;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)clickAtIndex:(unsigned long long)arg1;
- (void)viewLayout;
- (void)dealloc;

@end


@interface TBOrderLogisticCell : TBOrderBasicCell
{
    UILabel *_message;	// 8 = 0x8
    UILabel *_time;	// 16 = 0x10
    UIImageView *_icon;	// 24 = 0x18
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UIImageView *icon; // @synthesize icon=_icon;
@property(retain, nonatomic) UILabel *time; // @synthesize time=_time;
@property(retain, nonatomic) UILabel *message; // @synthesize message=_message;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end


@interface TBOrderPayCell : TBOrderBasicCell
{
    UILabel *_pay;	// 8 = 0x8
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UILabel *pay; // @synthesize pay=_pay;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end


@interface TBOrderPayDetailCell : TBOrderBasicCell
{
    UILabel *_actualName;	// 8 = 0x8
    UILabel *_actualValue;	// 16 = 0x10
    UIImageView *_actualIcon;	// 24 = 0x18
    NSString *_actualFeeInfo;	// 32 = 0x20
    NSMutableArray *_promotions;	// 40 = 0x28
    NSMutableArray *_postFees;	// 48 = 0x30
    NSMutableArray *_labels;	// 56 = 0x38
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) NSMutableArray *labels; // @synthesize labels=_labels;
@property(retain, nonatomic) NSMutableArray *postFees; // @synthesize postFees=_postFees;
@property(retain, nonatomic) NSMutableArray *promotions; // @synthesize promotions=_promotions;
@property(retain, nonatomic) NSString *actualFeeInfo; // @synthesize actualFeeInfo=_actualFeeInfo;
@property(retain, nonatomic) UIImageView *actualIcon; // @synthesize actualIcon=_actualIcon;
@property(retain, nonatomic) UILabel *actualValue; // @synthesize actualValue=_actualValue;
@property(retain, nonatomic) UILabel *actualName; // @synthesize actualName=_actualName;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end

@interface TBOrderPayDetailV2Cell : TBOrderBasicCell
{
    NSMutableArray *_orderPriceDetailViews;	// 8 = 0x8
    NSMutableArray *_payDetailViews;	// 16 = 0x10
    UIView *_payDetailBackgroundView;	// 24 = 0x18
    UIView *_payDetailSepLineView;	// 32 = 0x20
    UIView *_payDetailSepLineUpwardArrowView;	// 40 = 0x28
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UIView *payDetailSepLineUpwardArrowView; // @synthesize payDetailSepLineUpwardArrowView=_payDetailSepLineUpwardArrowView;
@property(retain, nonatomic) UIView *payDetailSepLineView; // @synthesize payDetailSepLineView=_payDetailSepLineView;
@property(retain, nonatomic) UIView *payDetailBackgroundView; // @synthesize payDetailBackgroundView=_payDetailBackgroundView;
@property(retain, nonatomic) NSMutableArray *payDetailViews; // @synthesize payDetailViews=_payDetailViews;
@property(retain, nonatomic) NSMutableArray *orderPriceDetailViews; // @synthesize orderPriceDetailViews=_orderPriceDetailViews;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end


@interface TBOrderSellerCell : TBOrderBasicCell
{
    UIImageView *_shopIcon;	// 8 = 0x8
    UILabel *_shopName;	// 16 = 0x10
    UIImageView *_arrow;	// 24 = 0x18
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UIImageView *arrow; // @synthesize arrow=_arrow;
@property(retain, nonatomic) UILabel *shopName; // @synthesize shopName=_shopName;
@property(retain, nonatomic) UIImageView *shopIcon; // @synthesize shopIcon=_shopIcon;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end


@interface TBOrderStatusCell : TBOrderBasicCell
{
    UIImageView *_icon;	// 8 = 0x8
    UILabel *_title;	// 16 = 0x10
    UILabel *_status;	// 24 = 0x18
    UILabel *_extra;	// 32 = 0x20
}

+ (double)cellHeight:(id)arg1 withWidth:(double)arg2 styleKitContext:(id)arg3 controller:(id)arg4;
@property(retain, nonatomic) UILabel *extra; // @synthesize extra=_extra;
@property(retain, nonatomic) UILabel *status; // @synthesize status=_status;
@property(retain, nonatomic) UILabel *title; // @synthesize title=_title;
@property(retain, nonatomic) UIImageView *icon; // @synthesize icon=_icon;

- (void)bindData:(id)arg1 controller:(id)arg2 styleKitContext:(id)arg3;
- (void)layoutSubviews;
- (void)viewLayout;

@end

///////////////////////////////////////////////////////////////////////////////
/// Component
///////////////////////////////////////////////////////////////////////////////

@interface TBOrderObject : NSObject

@property(retain, nonatomic) NSMutableDictionary *data; // @synthesize data=_data;

- (id)initWithData:(id)arg1;

@end

@interface TBOrderLabelCSS : TBOrderObject

+ (id)attributedInfoFromData:(id)arg1;
@property(nonatomic) double fontSize; // @synthesize fontSize=_fontSize;
@property(nonatomic, getter=isItalic) _Bool italic; // @synthesize italic=_italic;
@property(nonatomic, getter=isStrikeThrough) _Bool strikeThrough; // @synthesize strikeThrough=_strikeThrough;
@property(nonatomic, getter=isBold) _Bool bold; // @synthesize bold=_bold;
@property(retain, nonatomic) UIColor *color; // @synthesize color=_color;

- (id)attributedInfo;
- (id)initWithData:(id)arg1;

@end


@interface TBOrderLabelInfo : TBOrderObject

@property(retain, nonatomic) NSAttributedString *richTextValue; // @synthesize richTextValue=_richTextValue;
@property(retain, nonatomic) NSAttributedString *richTextName; // @synthesize richTextName=_richTextName;
@property(retain, nonatomic) TBOrderLabelCSS *css; // @synthesize css=_css;

- (id)richTexts;
- (id)desc;
- (_Bool)isBold;
- (_Bool)isHighLight;
- (_Bool)isCopy;
- (id)icon;
- (id)value;
- (id)name;
- (id)initWithData:(id)arg1;

@end

@interface TBOrderItemPriceInfo : TBOrderObject

- (id)price;
- (id)promotion;
- (id)original;

@end

@interface TBOrderComponent : TBOrderObject

// @property(nonatomic) __weak TBOrderMainModel *mainModel; // @synthesize mainModel=_mainModel;
@property(retain, nonatomic) NSString *type; // @synthesize type=_type;
@property(retain, nonatomic) NSString *cid; // @synthesize cid=_cid;
@property(retain, nonatomic) NSString *tag; // @synthesize tag=_tag;
@property(retain, nonatomic) NSMutableDictionary *fields; // @synthesize fields=_fields;

- (id)labelInfosWithKey:(id)arg1;
- (id)storage;
- (id)key;
- (id)initWithData:(id)arg1;

@end

@interface TBOrderStorageComponent : TBOrderComponent

- (id)findValueWithKey:(id)arg1;
- (id)subValueWithName:(id)arg1 andKey:(id)arg2;
- (_Bool)needDegrade;
- (id)subAuctionIdWithKey:(id)arg1;
- (id)subOrderIdWithKey:(id)arg1;
- (id)itemTypeWithKey:(id)arg1;
- (_Bool)archive;
- (id)pageName;
- (_Bool)isB2C;
- (id)phone;
- (id)sellerNick;
- (id)statusCode;
- (id)sellerId;
- (id)subCatIds;
- (id)subAuctionIds;
- (_Bool)shopDisable;
- (id)subOrderIds;
- (id)mainOrderId;
- (id)itemType;
- (id)orderType;
- (id)bizType;
- (id)buyerId;

@end

@interface TBOrderAddressComponent : TBOrderComponent

- (id)transitValue;
- (id)value;
- (id)name;
- (id)mobilephone;
- (id)phone;
- (id)label;

@end

@interface TBOrderSellerComponent : TBOrderComponent

- (id)sellerId;
- (id)shopImg;
- (id)nick;
- (id)shopName;

@end

@interface TBOrderStatusComponent : TBOrderComponent

- (_Bool)rainbowBar;
- (id)bgColor;
- (id)style;
- (id)extra;
- (id)flagPic;
- (id)title;
- (id)code;
- (id)text;

@end

@interface TBOrderCheckBoxComponent : TBOrderComponent

- (void)setChecked:(_Bool)arg1;
- (_Bool)disabled;
- (_Bool)checked;

@end


@interface TBOrderServiceInfoComponent : TBOrderComponent

@property(retain, nonatomic) NSMutableArray *mainExt; // @synthesize mainExt=_mainExt;
@property(retain, nonatomic) NSMutableArray *main; // @synthesize main=_main;

- (id)serviceWithKey:(id)arg1;
- (id)initWithData:(id)arg1;

@end

@interface TBOrderItemPromotionComponent : TBOrderComponent

- (id)displayPromotions;

@end

@interface TBOrderOperateComponent : TBOrderComponent

@property(retain, nonatomic) NSMutableArray *operateList; // @synthesize operateList=_operateList;

- (id)extraStyle;
- (id)extraUrl;
- (id)extra;
- (void)initOperateList;
- (id)list;
- (id)initWithData:(id)arg1;

@end

@interface TBOrderItemComponent : TBOrderComponent

@property(retain, nonatomic) NSMutableArray *extraDesc; // @synthesize extraDesc=_extraDesc;
@property(retain, nonatomic) TBOrderItemPriceInfo *priceInfo; // @synthesize priceInfo=_priceInfo;

- (id)pic;
- (id)refundStatus;
- (id)skuText;
- (long long)quantity;
- (id)title;
- (id)initWithData:(id)arg1;

@end

@interface TBOrderPayDetailComponent : TBOrderComponent

@property(retain, nonatomic) TBOrderLabelInfo *actualFee; // @synthesize actualFee=_actualFee;
@property(retain, nonatomic) NSMutableArray *details; // @synthesize details=_details;
@property(retain, nonatomic) NSMutableArray *postFees; // @synthesize postFees=_postFees;
@property(retain, nonatomic) NSMutableArray *promotions; // @synthesize promotions=_promotions;

- (id)initWithData:(id)arg1;

@end

@interface TBOrderInfoComponent : TBOrderComponent
@property(retain, nonatomic) NSMutableArray *labels; // @synthesize labels=_labels;
- (_Bool)isB2C;
- (id)initWithData:(id)arg1;

@end


@interface TBOrderMemoComponent : TBOrderComponent

- (void)setUnfold:(_Bool)arg1;
- (_Bool)unfold;
- (id)content;
- (id)title;

@end

///////////////////////////////////////////////////////////////////////////////
/// Model
///////////////////////////////////////////////////////////////////////////////

@class NSMutableArray, NSMutableDictionary, NSString, TBOrderMainModel;

@interface TBOrderModel : TBOrderObject
{
    NSString *_cellType;	// 8 = 0x8
    NSMutableArray *_cellData;	// 16 = 0x10
    TBOrderMainModel *_main;	// 24 = 0x18
    NSMutableDictionary *_userInfo;	// 32 = 0x20
}

@property(retain, nonatomic) NSMutableDictionary *userInfo; // @synthesize userInfo=_userInfo;
@property(nonatomic) __weak TBOrderMainModel *main; // @synthesize main=_main;
@property(retain, nonatomic) NSMutableArray *cellData; // @synthesize cellData=_cellData;
@property(retain, nonatomic) NSString *cellType; // @synthesize cellType=_cellType;

- (id)storage;
- (id)mainOrderId;
- (id)findBasicComponentWithType:(id)arg1;
- (id)findBizComponentWithTag:(id)arg1;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderMainModel : TBOrderModel

@property(nonatomic, getter=isChecked) _Bool checked; // @synthesize checked=_checked;
@property(retain, nonatomic) NSString *eventId; // @synthesize eventId=_eventId;
@property(nonatomic) __weak TBOrderStorageComponent *storage; // @synthesize storage=_storage;

@end

@interface TBOrderSellerModel : TBOrderModel

@property(retain, nonatomic) TBOrderSellerComponent *seller; // @synthesize seller=_seller;

- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderAddressModel : TBOrderModel

@property(retain, nonatomic) TBOrderAddressComponent *address; // @synthesize address=_address;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderSubModel : TBOrderModel

@property(retain, nonatomic) TBOrderStatusComponent *status; // @synthesize status=_status;
@property(retain, nonatomic) TBOrderServiceInfoComponent *serviceInfo; // @synthesize serviceInfo=_serviceInfo;
@property(retain, nonatomic) TBOrderItemPromotionComponent *promotion; // @synthesize promotion=_promotion;
@property(retain, nonatomic) TBOrderOperateComponent *operate; // @synthesize operate=_operate;
@property(retain, nonatomic) TBOrderItemComponent *item; // @synthesize item=_item;

- (id)subAuctionId;
- (id)subOrderId;
- (id)cid;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderOperationModel : TBOrderModel

@property(retain, nonatomic) TBOrderOperateComponent *operate; // @synthesize operate=_operate;

- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderInfoModel : TBOrderModel

@property(retain, nonatomic) TBOrderInfoComponent *orderInfo; // @synthesize orderInfo=_orderInfo;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end


@interface TBOrderMemoModel : TBOrderModel

@property(retain, nonatomic) TBOrderMemoComponent *memo; // @synthesize memo=_memo;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end

@interface TBOrderPayDetailModel : TBOrderModel

@property(retain, nonatomic) TBOrderPayDetailComponent *payDetail; // @synthesize payDetail=_payDetail;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end


@interface TBOrderHeadModel : TBOrderModel

@property(retain, nonatomic) TBOrderCheckBoxComponent *checkBox; // @synthesize checkBox=_checkBox;
@property(retain, nonatomic) TBOrderStatusComponent *status; // @synthesize status=_status;
@property(retain, nonatomic) TBOrderSellerComponent *seller; // @synthesize seller=_seller;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;

@end


@interface TBOrderPayDetailV2Component : TBOrderComponent
{
    NSArray *_orderPriceDetails;	// 8 = 0x8
    NSArray *_payDetails;	// 16 = 0x10
}


@property(retain, nonatomic) NSArray *payDetails; // @synthesize payDetails=_payDetails;
@property(retain, nonatomic) NSArray *orderPriceDetails; // @synthesize orderPriceDetails=_orderPriceDetails;
 - (id)createLabelInfosWithData:(id)arg1;
- (id)initWithData:(id)arg1;

@end


@interface TBOrderPayDetailV2Model : TBOrderModel
@property(retain, nonatomic) TBOrderPayDetailV2Component *payDetailV2; // @synthesize payDetailV2=_payDetailV2;
- (id)initWithCellType:(id)arg1 cellData:(id)arg2;
@end
